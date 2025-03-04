import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musicflutter/ad_helper.dart';

class InterstitialAdWidget extends StatefulWidget {
  const InterstitialAdWidget({super.key});

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
          });
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _isAdLoaded = false;
          Navigator.pop(context); // Close the dialog if ad fails to load
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          Navigator.pop(context); // Close the dialog when the ad is dismissed
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          Navigator.pop(context); // Close the dialog if ad fails to show
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      print('Interstitial ad is not loaded yet.');
      Navigator.pop(context); // Close the dialog if ad is not loaded
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
