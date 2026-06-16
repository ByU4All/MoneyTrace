package com.luke.dev.moneytrace

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.luke.dev.moneytrace/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getWidgetAction") {
                val action = intent?.getStringExtra("widget_action")
                // Clear it so it doesn't fire again on hot restart
                intent?.removeExtra("widget_action")
                result.success(action)
            } else {
                result.notImplemented()
            }
        }
    }
}
