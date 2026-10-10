import 'package:flutter/material.dart';

// AdMob is temporarily disabled: the Google Mobile Ads SDK was crashing the
// app on launch. The feed keeps its "Sponsored" slot, and this module will be
// re-enabled once the AdMob account + config are ready and tested.
Future<void> initAds() async {}

void showAppOpenAd() {}

Future<bool> showRewardedAd() async => true;

Widget nativeAdWidget() => const SizedBox.shrink();
