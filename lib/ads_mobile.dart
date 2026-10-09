import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Google's official TEST ad unit ids (Android). Swap for real ids once the
// AdMob account is set up.
const _nativeUnit = 'ca-app-pub-3940256099942544/2247696110';
const _interstitialUnit = 'ca-app-pub-3940256099942544/1033173712';
const _rewardedUnit = 'ca-app-pub-3940256099942544/5224354917';

InterstitialAd? _interstitial;

Future<void> initAds() async {
  await MobileAds.instance.initialize();
  _loadInterstitial();
}

void _loadInterstitial() {
  InterstitialAd.load(
    adUnitId: _interstitialUnit,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) => _interstitial = ad,
      onAdFailedToLoad: (_) => _interstitial = null,
    ),
  );
}

/// App-open / interstitial ad, shown shortly after launch.
void showAppOpenAd() {
  final ad = _interstitial;
  if (ad == null) return;
  ad.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (a) {
      a.dispose();
      _interstitial = null;
      _loadInterstitial();
    },
    onAdFailedToShowFullScreenContent: (a, e) {
      a.dispose();
      _interstitial = null;
    },
  );
  ad.show();
}

/// Rewarded ad shown before opening analytics. Returns true if the reward was
/// earned (or the ad could not load, so the user is not blocked).
Future<bool> showRewardedAd() async {
  final completer = Completer<bool>();
  RewardedAd.load(
    adUnitId: _rewardedUnit,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (a) {
            a.dispose();
            if (!completer.isCompleted) completer.complete(false);
          },
          onAdFailedToShowFullScreenContent: (a, e) {
            a.dispose();
            if (!completer.isCompleted) completer.complete(false);
          },
        );
        ad.show(onUserEarnedReward: (a, r) {
          if (!completer.isCompleted) completer.complete(true);
        });
      },
      onAdFailedToLoad: (_) {
        if (!completer.isCompleted) completer.complete(true);
      },
    ),
  );
  return completer.future;
}

/// A native ad that blends into the feed.
Widget nativeAdWidget() => const _NativeAdSlot();

class _NativeAdSlot extends StatefulWidget {
  const _NativeAdSlot();

  @override
  State<_NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<_NativeAdSlot> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final ad = NativeAd(
      adUnitId: _nativeUnit,
      factoryId: 'ventNative',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox(height: 4);
    return SizedBox(height: 132, width: double.infinity, child: AdWidget(ad: _ad!));
  }
}
