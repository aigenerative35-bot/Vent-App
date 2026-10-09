import 'package:flutter/material.dart';

/// Web / non-mobile stub - ads are a no-op here so the same code compiles
/// everywhere (Android uses ads_mobile.dart).
Future<void> initAds() async {}

void showAppOpenAd() {}

Future<bool> showRewardedAd() async => true;

Widget nativeAdWidget() => const SizedBox.shrink();
