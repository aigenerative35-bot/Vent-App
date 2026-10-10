package com.ventapp.vent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "ventNative",
                VentNativeAdFactory(applicationContext)
            )
        } catch (_: Exception) {
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        try {
            GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "ventNative")
        } catch (_: Exception) {
        }
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
