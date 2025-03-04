import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musicflutter/ad_helper.dart';

class RewardedAdWidget extends StatefulWidget {
  const RewardedAdWidget({super.key});

  @override
  State<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends State<RewardedAdWidget> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          // Handle reward logic here
        },
      );
      _rewardedAd = null;
      _isAdLoaded = false;
      _loadRewardedAd(); // Load a new ad
    } else {
      print('Rewarded ad is not loaded yet.');
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isAdLoaded ? _showRewardedAd : null,
      child: const Text('Watch Ad to Earn Points'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          320,
          50,
        ), // Set the width to fill the parent and height to 50
      ),
    );
  }
}
