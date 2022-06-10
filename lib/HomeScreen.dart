import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd _topBannerAd;

  BannerAd _bottomBannerad;

  bool _istop = false;

  bool _isbpttom = false;

  loadtopbanner() {
    _topBannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _istop = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _topBannerAd.load();
  }

  loadbottombanner() {
    _bottomBannerad = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isbpttom = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bottomBannerad.load();
  }

  RewardedAd _rewardedAd;

  void _createRewardedAd() async {
    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
      request: AdRequest(),
      rewardedAdLoadCallback:
          RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
        print('$ad loaded.');
        _rewardedAd = ad;
      }, onAdFailedToLoad: (LoadAdError error) {
        print('RewardedAd failed to load: $error');
        _rewardedAd = null;
        _createRewardedAd();
      }),
    );
  }

  void _showRewardedAd() async {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd.setImmersiveMode(true);
    _rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd.show();
    _rewardedAd = null;
  }

  InterstitialAd _interstitialAd;

  void fullscreenInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _interstitialAd = null;
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        fullscreenInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        fullscreenInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  DateTime timeBackPressed = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadtopbanner();
    loadbottombanner();
    fullscreenInterstitialAd();
    _createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    {
      return WillPopScope(
        onWillPop: () async {
          _showInterstitialAd();
          final difference = DateTime.now().difference(timeBackPressed);
          final isExitWarning = difference >= Duration(seconds: 2);

          timeBackPressed = DateTime.now();

          if (_showInterstitialAd == isExitWarning) {
            final message = "Press Back agin to exit";

            print(message);

            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text("Google Add"),
            ),
          ),
          body: Column(
            children: [
              (_istop)
                  ? Container(
                      height: _topBannerAd.size.height.toDouble(),
                      width: _topBannerAd.size.width.toDouble(),
                      child: AdWidget(ad: _topBannerAd),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                _showInterstitialAd();
                              },
                              child: Text("InterstitialAd")),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            _showRewardedAd();
                          },
                          child: Text("RewardedAd"))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              (_isbpttom)
                  ? Container(
                      height: _bottomBannerad.size.height.toDouble(),
                      width: _bottomBannerad.size.width.toDouble(),
                      child: AdWidget(ad: _bottomBannerad),
                    )
                  : SizedBox(
                      height: 0,
                    ),
            ],
          ),
        ),
      );
    }
  }
}
