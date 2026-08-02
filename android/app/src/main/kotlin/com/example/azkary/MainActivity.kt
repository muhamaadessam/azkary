package com.example.azkary

import flutter.overlay.window.flutter_overlay_window.CapsuleAlarmReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "azkary/capsule_scheduler")
            .setMethodCallHandler { call, result ->
                if (call.method != "schedulePeriodicCapsule") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val enabled = call.argument<Boolean>("enabled") ?: false
                val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 0
                if (enabled && intervalMinutes > 0) {
                    CapsuleAlarmReceiver.schedule(this, intervalMinutes)
                } else {
                    CapsuleAlarmReceiver.cancel(this)
                }
                result.success(null)
            }
    }
}
