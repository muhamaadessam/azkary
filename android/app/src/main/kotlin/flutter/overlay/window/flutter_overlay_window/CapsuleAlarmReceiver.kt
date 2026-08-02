package flutter.overlay.window.flutter_overlay_window

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec

class CapsuleAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val preferences = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
        val enabled = preferences.getBoolean(
            "flutter.periodicAzkarEnabled",
            intent.getBooleanExtra(EXTRA_ENABLED, true),
        )
        val intervalMinutes = preferences.getLong(
            "flutter.periodicAzkarInterval",
            intent.getIntExtra(EXTRA_INTERVAL_MINUTES, 30).toLong(),
        ).toInt()

        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            intent.action == ACTION_SHOW_CAPSULE
        ) {
            if (!enabled || intervalMinutes <= 0) {
                cancel(context)
                return
            }

            if (intent.action == ACTION_SHOW_CAPSULE) {
                showCapsule(context)
            }
            schedule(context, intervalMinutes)
        }
    }

    private fun showCapsule(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(context)
        ) {
            context.startActivity(
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${context.packageName}"),
                ).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
            return
        }

        WindowSetup.width = WindowSize.MATCH_PARENT
        WindowSetup.height = 180
        WindowSetup.setGravityFromAlignment("centerRight")
        WindowSetup.setFlag("focusPointer")
        WindowSetup.setNotificationVisibility("visibilityPublic")
        WindowSetup.positionGravity = "none"
        WindowSetup.overlayTitle = "أذكاري"
        WindowSetup.overlayContent = ""

        ContextCompat.startForegroundService(
            context,
            Intent(context, OverlayService::class.java).apply {
                putExtra("startX", OverlayConstants.DEFAULT_XY)
                putExtra("startY", OverlayConstants.DEFAULT_XY)
            },
        )

        Handler(Looper.getMainLooper()).postDelayed({
            FlutterEngineCache.getInstance().get(OverlayConstants.CACHED_TAG)?.let { engine ->
                BasicMessageChannel<Any?>(
                    engine.dartExecutor,
                    OverlayConstants.MESSENGER_TAG,
                    JSONMessageCodec.INSTANCE,
                ).send("__random_capsule_zekr__")
            }
        }, 700)
    }

    companion object {
        private const val ACTION_SHOW_CAPSULE = "com.example.azkary.SHOW_CAPSULE"
        private const val EXTRA_ENABLED = "enabled"
        private const val EXTRA_INTERVAL_MINUTES = "intervalMinutes"
        private const val REQUEST_CODE = 7001
        private const val PREFERENCES_NAME = "FlutterSharedPreferences"

        fun schedule(context: Context, intervalMinutes: Int) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val triggerAt = SystemClock.elapsedRealtime() + intervalMinutes * 60_000L
            val pendingIntent = pendingIntent(context)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            }
        }

        fun cancel(context: Context) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .cancel(pendingIntent(context))
        }

        private fun pendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, CapsuleAlarmReceiver::class.java).apply {
                action = ACTION_SHOW_CAPSULE
            }
            return PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}

private object WindowSize {
    const val MATCH_PARENT = -1
}
