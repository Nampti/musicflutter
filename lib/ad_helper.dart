import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID
    } else if (Platform.isIOS) {
      return '<Your_IOS_BANNER_AD_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test Ad Unit ID
    } else if (Platform.isIOS) {
      return '<Your_IOS_REWARDED_AD_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Ad Unit ID
    } else if (Platform.isIOS) {
      return '<Your_IOS_INTERSTITIAL_AD_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
