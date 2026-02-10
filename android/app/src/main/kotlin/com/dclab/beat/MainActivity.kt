package com.dclab.beat

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.dclab.beat.steps.StepCounterService
import com.dclab.beat.steps.StepEventSink
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val METHOD = "beat/steps"
    private val EVENTS = "beat/steps_events"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val prefs = getSharedPreferences("step_store", Context.MODE_PRIVATE)

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
}