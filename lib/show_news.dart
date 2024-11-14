import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/mock_news_list.dart';
import 'package:news/news_model.dart';

class MockNewsRepository {
  Future<List<NewsModel>> getNews() async =>
      Future.delayed(const Duration(seconds: 1), () async {
        return mockNewsList;
      });
}

void showNews(BuildContext context) async {
  showModalBottomSheet(
    scrollControlDisabledMaxHeightRatio: 1,
    constraints: const BoxConstraints(maxHeight: 700),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    context: context,
    builder: (context) {
      return NewsPage(
        contxt: context,
        limitHeight: 250,
      );
    },
  );
}

class NewsPage extends StatefulWidget {
  final Map<String, String>? extrasAdsense;
  final double limitHeight;
  final BuildContext contxt;

  const NewsPage({
    super.key,
    this.extrasAdsense,
    required this.contxt,
    required this.limitHeight,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final mock = MockNewsRepository();
  static const _insets = 16.0;

  BannerAd? inlineAdaptiveAd;

  bool isLoaded = false;

  AdSize? adSize;

  Orientation? currentOrientation;

  double adWidth = 0;

  double get insets => _insets;

  double get _adWidth =>
      MediaQuery.of(widget.contxt).size.width - (2 * _insets);

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extrasAdsense != null &&
        oldWidget.extrasAdsense != widget.extrasAdsense) {}
  }

  @override
  void didChangeDependencies() {
    loadAd();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    inlineAdaptiveAd?.dispose();
    super.dispose();
  }

  Future<void> loadAd() async {
    await inlineAdaptiveAd?.dispose();

    setState(() {
      inlineAdaptiveAd = null;
      isLoaded = false;
    });

    final AdSize size = AdSize.getInlineAdaptiveBannerAdSize(
      _adWidth.truncate(),
      widget.limitHeight.truncate(),
    );

    inlineAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          final bannerAd = ad as BannerAd;
          final size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            return;
          }
          setState(() {
            inlineAdaptiveAd = ad;
            isLoaded = true;
            adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            isLoaded = false;
            inlineAdaptiveAd = null;
            adSize = null;
          });
        },
      ),
    );
    await inlineAdaptiveAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 800,
      child: FutureBuilder(
        future: mock.getNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final news = snapshot.data;

          return ListView.separated(
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Divider(
                  height: .3,
                  color: Colors.grey.shade400,
                ),
              );
            },
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: news!.length,
            itemBuilder: (context, index) {
              if (index == 3) {
                return Container(
                    padding: const EdgeInsets.all(_insets),
                    height: isLoaded && adSize != null ? 250 : 0,
                    child: inlineAdaptiveAd != null && isLoaded
                        ? AdWidget(
                            ad: inlineAdaptiveAd!,
                          )
                        : const SizedBox.shrink());
              }

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 15,
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          errorWidget: (context, url, error) {
                            return Container(
                              width: screenSize * .4,
                              height: screenSize * .4,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                color: Colors.grey.shade200,
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                              ),
                            );
                          },
                          placeholder: (context, url) => SizedBox(
                            width: screenSize * .4,
                            height: screenSize * .4,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          imageUrl: news[index].imageUrl,
                          imageBuilder: (context, imageProvider) {
                            return SizedBox(
                              width: screenSize * .4,
                              height: screenSize * .4,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  news[index].title,
                                  textAlign: TextAlign.left,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  news[index].description,
                                  textAlign: TextAlign.left,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  formatDate(
                                    news[index].dateBegin,
                                  ),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
