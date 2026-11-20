import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// ============================================================
///  Ad settings.
///  The ids below are Google's official TEST ids: they show a
///  harmless "Test Ad". Replace the banner id with your own
///  Ad Unit ID (from AdMob) when you are ready for real ads.
/// ============================================================
class AdsConfig {
  // Set to false to switch all ads off.
  static const bool enabled = true;

  // Banner Ad Unit ID (TEST id).
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
}

/// A small banner ad. It stays invisible until an ad has loaded,
/// so the app looks normal when there is no internet or no ad.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdsConfig.enabled) _start();
  }

  Future<void> _start() async {
    try {
      await MobileAds.instance.initialize();
      if (!mounted) return;
      final BannerAd ad = BannerAd(
        adUnitId: AdsConfig.bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad a) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (Ad a, LoadAdError e) {
            a.dispose();
            if (mounted) {
              setState(() {
                _ad = null;
                _loaded = false;
              });
            }
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      // Ads must never break the app.
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: ad.size.height.toDouble(),
      alignment: Alignment.center,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
