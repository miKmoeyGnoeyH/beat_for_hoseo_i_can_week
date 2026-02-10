package com.dclab.beat.steps

import android.app.*
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*
import com.dclab.beat.R

class StepCounterService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null

    private val prefs by lazy {
        getSharedPreferences("step_store", Context.MODE_PRIVATE)
    }

    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        ensureChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 포그라운드 알림 시작
        startForeground(
            NOTI_ID,
            buildNotification("Step counter running")
        )

        // 센서 구독
        stepSensor?.let {
            // UI 스레드 부담 줄이려면 NORMAL/FASTEST 적절히 선택
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }

        return START_STICKY
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_STEP_COUNTER) return

        val stepsAfterBoot = event.values[0].toLong()
        val todayKey = yyyyMMdd(Date())

        val lastDay = prefs.getString(KEY_LAST_DAY, "") ?: ""
        var baseline = prefs.getLong(KEY_BASELINE_AFTER_BOOT, -1L)
        var todaySteps = prefs.getLong(KEY_TODAY_STEPS, 0L)

        // 날짜 바뀜 처리
        if (lastDay != todayKey) {
            // 날짜가 바뀌면 오늘 누적 리셋 + 기준선 재설정
            todaySteps = 0L
            baseline = stepsAfterBoot
            prefs.edit()
                .putString(KEY_LAST_DAY, todayKey)
                .putLong(KEY_TODAY_STEPS, todaySteps)
                .putLong(KEY_BASELINE_AFTER_BOOT, baseline)
                .apply()
        }

        // 첫 기준선이 없으면 설정
        if (baseline < 0) {
            baseline = stepsAfterBoot
            prefs.edit().putLong(KEY_BASELINE_AFTER_BOOT, baseline).apply()
        }

        // 누적 계산
        val computedToday = (stepsAfterBoot - baseline).coerceAtLeast(0)
        prefs.edit()
            .putLong(KEY_STEPS_AFTER_BOOT, stepsAfterBoot)
            .putLong(KEY_TODAY_STEPS, computedToday)
            .putLong(KEY_LAST_TS, System.currentTimeMillis())
            .apply()

        // (선택) 알림 내용 업데이트 (너무 자주하면 배터리/성능 안 좋음 → throttle 권장)
        // updateNotification("Today: $computedToday")
        StepEventSink.emit(computedToday) // EventChannel로 보내고 싶으면
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "Step Counter",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(content: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pending = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BEAT")
            .setContentText(content)
            .setSmallIcon(R.drawable.ic_bg_service_small) // 네 아이콘으로 교체
            .setContentIntent(pending)
            .setOngoing(true)
            .build()
    }

    private fun yyyyMMdd(d: Date): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(d)

    private fun updateNotification(content: String) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTI_ID, buildNotification(content))
    }

    companion object {
        const val CHANNEL_ID = "step_channel"
        const val NOTI_ID = 1001

        const val KEY_STEPS_AFTER_BOOT = "stepsAfterBoot"
        const val KEY_BASELINE_AFTER_BOOT = "baselineAfterBoot"
        const val KEY_TODAY_STEPS = "todaySteps"
        const val KEY_LAST_DAY = "lastDay"
        const val KEY_LAST_TS = "lastTs"
    }
}