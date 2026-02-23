package com.dclab.bfhicw

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.dclab.bfhicw.steps.StepCounterService
import com.dclab.bfhicw.steps.StepEventSink
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.IntentFilter

class MainActivity: FlutterActivity() {

    private val METHOD = "beat/steps"
    private val EVENTS = "beat/steps_events"

    private lateinit var campusChannel: MethodChannel
    private val campusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                "beat.campus.IN" -> campusChannel.invokeMethod("campusIn", null)
                "beat.campus.OUT" -> campusChannel.invokeMethod("campusOut", null)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val prefs = getSharedPreferences("step_store", Context.MODE_PRIVATE)

        campusChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "beat/campus_location"
        )

        campusChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getLastInsideCached" -> {
                    val prefs = getSharedPreferences("step_store", Context.MODE_PRIVATE)
                    if (!prefs.contains("lastInside")) result.success(null)
                    else result.success(prefs.getBoolean(StepCounterService.KEY_LAST_INSIDE, false))
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        startForegroundServiceCompat()
                        result.success(true)
                    }
                    "stopService" -> {
                        stopService(Intent(this, StepCounterService::class.java))
                        result.success(true)
                    }
                    "getTodaySteps" -> {
                        val today = prefs.getLong(StepCounterService.KEY_TODAY_STEPS, 0L)
                        result.success(today)
                    }
                    "isServiceRunning" -> {
                        result.success(StepCounterService.isRunning)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTS)
            .setStreamHandler(object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    StepEventSink.sink = events
                }
                override fun onCancel(arguments: Any?) {
                    StepEventSink.sink = null
                }
            })
    }

    private fun startForegroundServiceCompat() {
        val i = Intent(this, StepCounterService::class.java)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(i)
        } else {
            startService(i)
        }
    }

    override fun onStart() {
        super.onStart()
        val filter = IntentFilter().apply {
            addAction("beat.campus.IN")
            addAction("beat.campus.OUT")
        }

        if (android.os.Build.VERSION.SDK_INT >= 33) {
            registerReceiver(campusReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(campusReceiver, filter)
        }
    }

    override fun onStop() {
        unregisterReceiver(campusReceiver)
        super.onStop()
    }
}