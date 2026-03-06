package com.stereo98.dabplus

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {

    private val CHANNEL = "com.stereo98.dabplus/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "clearNotificationCache") {
                    try {
                        val prefs = getSharedPreferences("notification_plugin_cache", MODE_PRIVATE)
                        prefs.edit().clear().apply()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLEAR_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
