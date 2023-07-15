import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DriverInfo extends StatelessWidget {
  final String driverId;
  const DriverInfo(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: DriverImageProvider(driverId, 'driver'),
            ),
            FutureBuilder<List<List>>(
              future: FormulaOneScraper().scrapeDriversDetails(driverId),
              builder: (context, snapshot) => snapshot.hasError
                  ? RequestErrorWidget(
                snapshot.error.toString(),
              )
                  : snapshot.hasData
                  ? DriverDetailsFragment(
                snapshot.data!,
              )
                  : const LoadingIndicatorUtil(),
            ),
          ],
        ),
      ),
    );
  }
}



class DriverImageProvider extends StatelessWidget {
  Future<String> getImageURL(String driverId, String idOfImage) async {
    if (idOfImage == 'driver') {
      return await DriverStatsImage().getDriverImage(driverId);
    } else if (idOfImage == 'helmet') {
      // not used for the moment, maybe later?
      return await DriverHelmetImage().getDriverHelmetImage(driverId);
    } else if (idOfImage == 'flag') {
      return await DriverFlagImage().getDriverFlagImage(driverId);
    }
    return "none";
  }

  final String driverId;
  final String idOfImage;
  const DriverImageProvider(
      this.driverId,
      this.idOfImage, {
        Key? key,
      }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getImageURL(driverId, idOfImage),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? Image.network(
          snapshot.data!,
          height: MediaQuery.of(context).size.width - 10,
          //width: idOfImage == 'driver' ? 400 : 200,
        )
            : SizedBox(
          height: MediaQuery.of(context).size.width - 10,
          child: const LoadingIndicatorUtil(),
        );
      },
    );
  }
}



class DriverDetailsFragment extends StatelessWidget {
  final List<List> driverDetails;
  const DriverDetailsFragment(this.driverDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
    Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    final List<String> driverInfosLabels = [
      AppLocalizations.of(context)!.team,
      AppLocalizations.of(context)!.country,
      AppLocalizations.of(context)!.podiums,
      AppLocalizations.of(context)!.points,
      AppLocalizations.of(context)!.grandsPrix,
      AppLocalizations.of(context)!.worldChampionships,
      AppLocalizations.of(context)!.highestRaceFinish,
      AppLocalizations.of(context)!.highestGridPosition,
      AppLocalizations.of(context)!.dateOfBirth,
      AppLocalizations.of(context)!.placeOfBirth,
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              for (int i = 0; i < driverDetails[0].length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        driverInfosLabels[i],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        driverDetails[0][i],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              AppLocalizations.of(context)!.news,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var item in driverDetails[1])
                    FutureBuilder<Article>(
                      future: F1NewsFetcher().getArticleData(item[0]),
                      builder: (context, snapshot) {
                        return snapshot.hasError
                            ? RequestErrorWidget(
                          snapshot.error.toString(),
                        )
                            : snapshot.hasData
                            ? NewsItem(
                          News(
                            snapshot.data!.articleId,
                            'News',
                            snapshot.data!.articleSlug,
                            snapshot.data!.articleName,
                            '',
                            snapshot.data!.publishedDate,
                            snapshot.data!
                                .articleHero['contentType'] ==
                                'atomVideo'
                                ? snapshot.data!.articleHero['fields']
                            ['thumbnail']['url']
                                : snapshot.data!.articleHero[
                            'contentType'] ==
                                'atomImageGallery'
                                ? snapshot.data!
                                .articleHero['fields']
                            ['imageGallery'][0]['url']
                                : snapshot.data!
                                .articleHero['fields']
                            ['image']['url'],
                          ),
                          true,
                        )
                            : const SizedBox(
                          height: 200,
                          child: LoadingIndicatorUtil(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.biography,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              for (String biographyParagraph in driverDetails[2])
                Text(
                  '\n$biographyParagraph',
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  AppLocalizations.of(context)!.gallery,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              CarouselSlider(
                items: [
                  for (int i = 0; i < driverDetails[3][0].length; i++)
                    Column(
                      children: [
                        Image.network(driverDetails[3][0][i]),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Text(
                            driverDetails[3][1][i].toString(),
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                ],
                options: CarouselOptions(
                  height: 350,
                  autoPlay: true,
                  viewportFraction: 0.85,
                  autoPlayInterval: const Duration(seconds: 7),
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}