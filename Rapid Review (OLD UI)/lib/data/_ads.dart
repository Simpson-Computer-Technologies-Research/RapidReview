import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads {
  static bool bannerState = false;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub';
    } else if (Platform.isIOS) {
      return 'ca-app-pub';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static BannerAd loadBanner() => BannerAd(
        adUnitId: Ads.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) => bannerState = true,
          onAdFailedToLoad: (ad, err) {
            bannerState = false;
            ad.dispose();
          },
        ),
      );
}
