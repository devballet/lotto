import 'package:firebase_admob/firebase_admob.dart';

import 'coreLibrary.dart';

class FirebaseAdmobManager {
  bool _isInit = false;
  BannerAd _bottomBannerAd;
  InterstitialAd interstitialAd;

  //Modify the following for the actual Admob advertisement.
  String appID = FirebaseAdMob.testAppId;
  String bannerID = BannerAd.testAdUnitId;
  String interstitialID = InterstitialAd.testAdUnitId;
  //String rewardedVideoAdID = RewardedVideoAd.testAdUnitId;
  String rewardedVideoAdID = getRewardAdUnitId(); // RewardedVideoAd.testAdUnitId;

  Function(MobileAdEvent) _interstitialAdListener;

  init({
    MobileAdListener interstitialAdListener = null,
    RewardedVideoAdListener rewardedVideoListner = null,
  }) async {
    _isInit = await FirebaseAdMob.instance.initialize(appId: appID);

    _bottomBannerAd = createBannerAd();

    _interstitialAdListener = interstitialAdListener;
    RewardedVideoAd.instance.listener = rewardedVideoListner;
  }

  dispose() {
    _bottomBannerAd.dispose();
    interstitialAd.dispose();
    _isInit = false;
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  /*** Banner AD ***/
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      //targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  showBannerAd() {
    _bottomBannerAd ??= createBannerAd();
    _bottomBannerAd
      ..load()
      ..show();
  }

  removeBannerAd() {
    _bottomBannerAd?.dispose();
    _bottomBannerAd = null;
  }

  /*** Interstitial AD ***/
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      listener: _interstitialAdListener,
    );
  }

  loadInterstitialAd() async {
    interstitialAd?.dispose();
    interstitialAd = createInterstitialAd()..load();
  }

  showInterstitialAd() {
    interstitialAd.show();
  }

  /*** RewardedVideo AD ***/
  loadRewardedVideoAd() {
    RewardedVideoAd.instance
        .load(adUnitId: rewardedVideoAdID, targetingInfo: targetingInfo);
  }

  showRewardedVideoAd() {
    RewardedVideoAd.instance.show();
  }
}