package com.dclab.bfhicw.steps

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.dclab.bfhicw.R
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.location.FusedLocationProviderClient
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

const val KEY_EXCLUDED_AFTER_BOOT = "excludedAfterBoot"  // 오늘 캠퍼스 밖에서 누적된(제외할) 부팅누적 증가량
const val KEY_OUT_SNAPSHOT_AFTER_BOOT = "outSnapshotAfterBoot"
const val KEY_OUT_SNAPSHOT_DAY = "outSnapshotDay"        // yyyy-MM-dd

const val KEY_PENDING_CAMPUS_STATE = "pendingCampusState" // "IN" or "OUT"
const val PENDING_IN = "IN"
const val PENDING_OUT = "OUT"

const val KEY_PREV_STEPS_AFTER_BOOT = "prevStepsAfterBoot"


class StepCounterService : Service(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null
    private var isStepListening: Boolean = false

    // Location
    private lateinit var fusedClient: FusedLocationProviderClient

    private val prefs by lazy {
        getSharedPreferences("step_store", Context.MODE_PRIVATE)
    }

    // =========================
    // Permissions
    // =========================
    private fun hasLocationPermission(): Boolean {
        // Background에서도 FINE만으로는 일부 기기/버전에선 제한될 수 있음 (특히 Android 10+)
        // 일단 컴파일/동작 기준으로 FINE 체크
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasActivityPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACTIVITY_RECOGNITION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // =========================
    // Location updates
    // =========================
    @Suppress("MissingPermission")
    private fun primeInsideStateOnce(onDone: () -> Unit) {
        // 권한 없으면 바로 done
        if (!hasLocationPermission()) { onDone(); return }

        // 1) lastLocation 먼저 시도 (빠름)
        fusedClient.lastLocation
            .addOnSuccessListener { loc ->
                if (loc != null) {
                    val inside = isInsideCampus(loc.latitude, loc.longitude)
                    prefs.edit().putBoolean(KEY_LAST_INSIDE, inside).apply()
                    onDone()
                } else {
                    // 2) lastLocation이 null이면 currentLocation 시도
                    fusedClient.getCurrentLocation(
                        Priority.PRIORITY_BALANCED_POWER_ACCURACY,
                        null
                    ).addOnSuccessListener { cur ->
                        if (cur != null) {
                            val inside = isInsideCampus(cur.latitude, cur.longitude)
                            prefs.edit().putBoolean(KEY_LAST_INSIDE, inside).apply()
                        }
                        onDone()
                    }.addOnFailureListener { onDone() }
                }
            }
            .addOnFailureListener { onDone() }
    }

    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_BALANCED_POWER_ACCURACY,
            30_000L
        ).build()

        fusedClient.requestLocationUpdates(
            request,
            locationCallback,
            mainLooper
        )
    }

    private fun stopLocationUpdates() {
        try {
            fusedClient.removeLocationUpdates(locationCallback)
        } catch (_: Throwable) {
        }
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val loc = result.lastLocation ?: return
            val lat = loc.latitude
            val lng = loc.longitude

            val inside = isInsideCampus(lat, lng)
            initCampusStateIfMissing(inside)
            notifyCampusStateIfChanged(inside)
        }
    }

    private fun initCampusStateIfMissing(isInside: Boolean) {
        if (!prefs.contains(KEY_LAST_INSIDE)) {
            prefs.edit().putBoolean(KEY_LAST_INSIDE, isInside).apply()
        }
    }

    // =========================
    // Polygon inside check
    // =========================
    private fun isInsidePolygon(
        lat: Double,
        lng: Double,
        polygon: List<Pair<Double, Double>>
    ): Boolean {
        var intersectCount = 0
        for (i in polygon.indices) {
            val (x1, y1) = polygon[i]
            val (x2, y2) = polygon[(i + 1) % polygon.size]

            if ((y1 > lng) != (y2 > lng)) {
                val atX = (x2 - x1) * (lng - y1) / (y2 - y1) + x1
                if (lat < atX) intersectCount++
            }
        }
        return intersectCount % 2 == 1
    }

    private fun isInsideCampus(lat: Double, lng: Double): Boolean {
        return isInsidePolygon(lat, lng, asanArea) || isInsidePolygon(lat, lng, cheonanArea)
    }

    private fun isKorean(): Boolean {
        // 보통 "ko", "ko-KR" 형태
        val lang = resources.configuration.locales[0].language
        return lang.equals("ko", ignoreCase = true)
    }

    private fun setStepListeningEnabled(enabled: Boolean) {
        if (enabled) {
            if (isStepListening) return
            stepSensor?.let {
                sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
                isStepListening = true
            }
        } else {
            if (!isStepListening) return
            try {
                sensorManager.unregisterListener(this)
            } catch (_: Throwable) {
            }
            isStepListening = false
        }
    }

    private fun notifyCampusStateIfChanged(isInside: Boolean) {
        val lastInside = prefs.getBoolean(KEY_LAST_INSIDE, false)
        if (lastInside == isInside) return

        val todayKey = yyyyMMdd(Date())
        val stepsAfterBoot = prefs.getLong(KEY_STEPS_AFTER_BOOT, -1L)

        prefs.edit().putBoolean(KEY_LAST_INSIDE, isInside).apply()

        // ✅ 해결책 1: 여기서 센서 리스너 토글하지 않음 (항상 켜둠)
        // setStepListeningEnabled(isInside)  // ❌ 제거

        // 스냅샷/제외량 계산
        if (stepsAfterBoot >= 0) {
            if (!isInside) onCampusOut(stepsAfterBoot, todayKey)
            else onCampusIn(stepsAfterBoot, todayKey)
        } else {
            prefs.edit()
                .putString(KEY_PENDING_CAMPUS_STATE, if (isInside) PENDING_IN else PENDING_OUT)
                .apply()
        }

        // Flutter broadcast
        val action = if (isInside) "beat.campus.IN" else "beat.campus.OUT"
        sendBroadcast(Intent(action).setPackage(packageName))

        if (isInside) showCampusEnteredNotification() else showOutOfCampusNotification()
    }

    private fun showOutOfCampusNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val (title, msg) = if (isKorean()) {
            "BEAT" to "캠퍼스 범위를 벗어났습니다."
        } else {
            "BEAT" to "You have left the campus area."
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(msg)
            .setSmallIcon(R.drawable.ic_bg_service_small)
            .setAutoCancel(true)
            .build()

        nm.notify(OUT_OF_CAMPUS_NOTI_ID, notification)
    }

    private fun showCampusEnteredNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val (title, msg) = if (isKorean()) {
            "BEAT" to "캠퍼스 범위에 진입했습니다."
        } else {
            "BEAT" to "You have entered the campus area."
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(msg)
            .setSmallIcon(R.drawable.ic_bg_service_small)
            .setAutoCancel(true)
            .build()

        // 진입 알림은 별도 ID 써도 되고, 동일 ID로 덮어써도 됨
        nm.notify(CAMPUS_ENTERED_NOTI_ID, notification)
    }

    private fun resetForNewDay(stepsAfterBoot: Long, todayKey: String) {
        prefs.edit()
            .putString(KEY_LAST_DAY, todayKey)
            .putLong(KEY_TODAY_STEPS, 0L)
            .putLong(KEY_BASELINE_AFTER_BOOT, stepsAfterBoot)
            .putLong(KEY_EXCLUDED_AFTER_BOOT, 0L)
            .remove(KEY_OUT_SNAPSHOT_AFTER_BOOT)
            .remove(KEY_OUT_SNAPSHOT_DAY)
            .remove(KEY_PENDING_CAMPUS_STATE)
            .apply()
    }

    private fun onCampusOut(stepsAfterBoot: Long, todayKey: String) {
        // OUT 스냅샷 저장
        prefs.edit()
            .putLong(KEY_OUT_SNAPSHOT_AFTER_BOOT, stepsAfterBoot)
            .putString(KEY_OUT_SNAPSHOT_DAY, todayKey)
            .apply()
    }

    private fun onCampusIn(stepsAfterBoot: Long, todayKey: String) {
        val outSnap = if (prefs.contains(KEY_OUT_SNAPSHOT_AFTER_BOOT))
            prefs.getLong(KEY_OUT_SNAPSHOT_AFTER_BOOT, -1L) else null
        val outDay = prefs.getString(KEY_OUT_SNAPSHOT_DAY, null)

        if (outSnap == null || outDay == null || outDay != todayKey) {
            // iOS 로직의 "날짜가 다르면 excluded = inSnapshot"에 해당.
            // Android에서는 "오늘 들어온 시점까지의 증가분"을 모두 제외해야 하므로
            // excluded를 '오늘(=baseline 이후) 캠퍼스 밖 증가분'으로 맞추려면:
            // 가장 안전한 처리 = 오늘 계산을 새로 시작하는 것과 동일하게 baseline을 stepsAfterBoot로 리셋.
            // (캠퍼스 안 유효 걸음은 0부터 다시)
            resetForNewDay(stepsAfterBoot, todayKey)
        } else {
            val deltaOut = (stepsAfterBoot - outSnap).coerceAtLeast(0L)
            val excluded = prefs.getLong(KEY_EXCLUDED_AFTER_BOOT, 0L)
            prefs.edit()
                .putLong(KEY_EXCLUDED_AFTER_BOOT, excluded + deltaOut)
                .remove(KEY_OUT_SNAPSHOT_AFTER_BOOT)
                .remove(KEY_OUT_SNAPSHOT_DAY)
                .apply()
        }
    }

    // =========================
    // Service lifecycle
    // =========================
    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        fusedClient = LocationServices.getFusedLocationProviderClient(this)

        ensureChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true
        startForeground(NOTI_ID, buildNotification("Step counter running"))

        if (!hasActivityPermission() || !hasLocationPermission()) {
            stopSelf()
            return START_NOT_STICKY
        }

        // ✅ 센서 리스너는 무조건 켬 (OUT이어도 stepsAfterBoot 갱신해야 해서)
        setStepListeningEnabled(true)

        primeInsideStateOnce {
            // 위치 업데이트 시작
            startLocationUpdates()
        }

        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false

        try {
            sensorManager.unregisterListener(this)
        } catch (_: Throwable) {
        }

        stopLocationUpdates()

        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_STEP_COUNTER) return

        val stepsAfterBoot = event.values[0].toLong()
        val todayKey = yyyyMMdd(Date())

        // ✅ 부팅/센서 리셋 감지용 이전값
        val prevAfterBoot = prefs.getLong(KEY_PREV_STEPS_AFTER_BOOT, -1L)

        // 0) 항상 최신 stepsAfterBoot 저장 (OUT/IN 스냅샷용)
        prefs.edit()
            .putLong(KEY_STEPS_AFTER_BOOT, stepsAfterBoot)
            .putLong(KEY_PREV_STEPS_AFTER_BOOT, stepsAfterBoot)
            .apply()

        // ✅ (중요) stepsAfterBoot가 감소하면: 부팅/센서리셋으로 간주
        // -> baseline/outSnap/excluded가 다 깨지므로 오늘 계산 상태를 새로 시작
        if (prevAfterBoot >= 0 && stepsAfterBoot < prevAfterBoot) {
            resetForNewDay(stepsAfterBoot, todayKey)
            // resetForNewDay 안에서 pending/outSnapshot/excluded 다 정리됨
        }

        // ✅ pending OUT/IN 처리 (센서 첫 이벤트에서 보정)
        val pending = prefs.getString(KEY_PENDING_CAMPUS_STATE, null)
        if (pending != null) {
            prefs.edit().remove(KEY_PENDING_CAMPUS_STATE).apply()
            if (pending == PENDING_OUT) onCampusOut(stepsAfterBoot, todayKey)
            else onCampusIn(stepsAfterBoot, todayKey)
        }

        val lastDay = prefs.getString(KEY_LAST_DAY, "") ?: ""
        var baseline = prefs.getLong(KEY_BASELINE_AFTER_BOOT, -1L)

        // 1) 날짜 변경 처리
        if (lastDay != todayKey || baseline < 0) {
            resetForNewDay(stepsAfterBoot, todayKey)
            baseline = stepsAfterBoot
        }

        // 2) OUT이면: stepsAfterBoot는 계속 갱신하지만, 유효 steps 저장/emit만 안 함
        val inside = prefs.getBoolean(KEY_LAST_INSIDE, false)
        if (!inside) {
            return
        }

        // 3) IN이면 excluded 반영하여 계산
        val excluded = prefs.getLong(KEY_EXCLUDED_AFTER_BOOT, 0L)
        val computedToday = (stepsAfterBoot - baseline - excluded).coerceAtLeast(0L)

        prefs.edit()
            .putLong(KEY_TODAY_STEPS, computedToday)
            .putLong(KEY_LAST_TS, System.currentTimeMillis())
            .apply()

        StepEventSink.emit(computedToday)
    }

    // =========================
    // Notification channel
    // =========================
    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Step Counter",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(content: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pending = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BEAT")
            .setContentText(content)
            .setSmallIcon(R.drawable.ic_bg_service_small)
            .setContentIntent(pending)
            .setOngoing(true)
            .build()
    }

    private fun yyyyMMdd(d: Date): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(d)

    companion object {
        @Volatile
        var isRunning: Boolean = false

        const val CHANNEL_ID = "step_channel"
        const val NOTI_ID = 1001

        const val OUT_OF_CAMPUS_NOTI_ID = 2001
        const val CAMPUS_ENTERED_NOTI_ID = 2002

        const val KEY_LAST_INSIDE = "lastInside" // ✅ 추가

        const val KEY_STEPS_AFTER_BOOT = "stepsAfterBoot"
        const val KEY_BASELINE_AFTER_BOOT = "baselineAfterBoot"
        const val KEY_TODAY_STEPS = "todaySteps"
        const val KEY_LAST_DAY = "lastDay"
        const val KEY_LAST_TS = "lastTs"

        // ✅ polygon points (lat, lng)
        val asanArea: List<Pair<Double, Double>> = listOf(
            36.738665 to 127.077041,
            36.738750 to 127.076391,
            36.739498 to 127.075712,
            36.739439 to 127.074505,
            36.740096 to 127.074337,
            36.739655 to 127.073618,
            36.740085 to 127.072995,
            36.738334 to 127.071278,
            36.735504 to 127.070047,
            36.735225 to 127.070037,
            36.735188 to 127.070396,
            36.735417 to 127.071305,
            36.735013 to 127.072693,
            36.735409 to 127.072880,
            36.734680 to 127.074740,
            36.733959 to 127.074943,
            36.732805 to 127.076793,
            36.733010 to 127.077406,
            36.734392 to 127.076388,
            36.735113 to 127.076939,
            36.735218 to 127.076731,
            36.736264 to 127.077744,
            36.737103 to 127.077636
        )

        val cheonanArea: List<Pair<Double, Double>> = listOf(
            36.830327274558805 to 127.18020021753239,
            36.83009097680529 to 127.18003992692661,
            36.82990371331767 to 127.18022724802745,
            36.82876674420636 to 127.17977900834666,
            36.82839453209551 to 127.18159404825123,
            36.826534838425715 to 127.18235186916161,
            36.82608035605323 to 127.18197528960386,
            36.82530941393403 to 127.18229852140279,
            36.82545220384936 to 127.1832011762635,
            36.82589369313384 to 127.18323585563941,
            36.82641869776802 to 127.18462142354441,
            36.8283930017052 to 127.1840544914855,
            36.828461000619335 to 127.18378563032861,
            36.82863829677594 to 127.18276039787843,
            36.829313469671476 to 127.1817195240613,
            36.829603672754665 to 127.18198363368744
        )
    }
}