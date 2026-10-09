package com.ventapp.vent

import android.content.Context
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/// Renders a Google native ad into a layout that looks like a feed post.
class VentNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad, null) as NativeAdView

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body = adView.findViewById<TextView>(R.id.ad_body)
        val cta = adView.findViewById<TextView>(R.id.ad_call_to_action)

        headline.text = nativeAd.headline
        body.text = nativeAd.body
        cta.text = nativeAd.callToAction

        adView.headlineView = headline
        adView.bodyView = body
        adView.callToActionView = cta
        adView.setNativeAd(nativeAd)

        return adView
    }
}
