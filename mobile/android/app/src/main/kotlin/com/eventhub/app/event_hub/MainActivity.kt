package com.eventhub.app.event_hub

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.ComponentName
import android.provider.CalendarContract

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.eventhub.app/momo"
    private var momoResult: MethodChannel.Result? = null

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    override fun onResume() {
        super.onResume()
        momoResult?.let {
            it.success(true)
            momoResult = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMomo" -> {
                    try {
                        val amount = call.argument<String>("amount") ?: ""
                        val bookingCode = call.argument<String>("bookingCode") ?: ""
                        val intent = Intent().apply {
                            component = ComponentName("com.mservice.momotransfer", "com.mservice.momotransfer.MainActivity")
                            putExtra("amount", amount)
                            putExtra("bookingCode", bookingCode)
                            putExtra("autoOpenPayment", true)
                        }
                        momoResult = result
                        startActivity(intent)
                    } catch (e: Exception) {
                        try {
                            val launchIntent = packageManager.getLaunchIntentForPackage("com.mservice.momotransfer")
                            if (launchIntent != null) {
                                launchIntent.putExtra("amount", call.argument<String>("amount") ?: "")
                                launchIntent.putExtra("bookingCode", call.argument<String>("bookingCode") ?: "")
                                launchIntent.putExtra("autoOpenPayment", true)
                                momoResult = result
                                startActivity(launchIntent)
                            } else {
                                result.error("NOT_FOUND", "MoMo not installed: ${e.message}", null)
                            }
                        } catch (e2: Exception) {
                            result.error("ERROR", e2.message, null)
                        }
                    }
                }
                "addCalendarEvent" -> {
                    try {
                        val title = call.argument<String>("title") ?: "Sự kiện EventHub"
                        val description = call.argument<String>("description") ?: ""
                        val location = call.argument<String>("location") ?: ""
                        val startTime = call.argument<Long>("startTime") ?: System.currentTimeMillis()
                        val endTime = call.argument<Long>("endTime") ?: (startTime + 3 * 3600 * 1000)

                        val intent = Intent(Intent.ACTION_INSERT).apply {
                            setDataAndType(CalendarContract.Events.CONTENT_URI, "vnd.android.cursor.dir/event")
                            putExtra(CalendarContract.Events.TITLE, title)
                            putExtra(CalendarContract.Events.DESCRIPTION, description)
                            putExtra(CalendarContract.Events.EVENT_LOCATION, location)
                            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startTime)
                            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTime)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CALENDAR_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
