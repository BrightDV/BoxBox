/*
 *  This file is part of BoxBox (https://github.com/BrightDV/BoxBox).
 * 
 * BoxBox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BoxBox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BoxBox.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2022-2025, BrightDV
 */

import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/custom_physics.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';

class DriverDetailsScreen extends StatelessWidget {
  final String driverId;
  final String givenName;
  final String familyName;
  final String? detailsPath;
  const DriverDetailsScreen(
    this.driverId,
    this.givenName,
    this.familyName, {
    super.key,
    this.detailsPath,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${givenName} ${familyName.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Text(
                  AppLocalizations.of(context)!.information.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  AppLocalizations.of(context)!.results.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: TabBarView(
          children: [
            DriverInfo(driverId, detailsPath: detailsPath),
            DriverResults(driverId),
          ],
        ),
      ),
    );
  }
}

class DriverInfo extends StatelessWidget {
  final String driverId;
  final String? detailsPath;
  const DriverInfo(
    this.driverId, {
    super.key,
    this.detailsPath,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: DriverImageProvider(driverId, 'driver'),
          ),
          FutureBuilder<List<List>>(
            future: FormulaOneScraper().scrapeDriversDetails(
              driverId,
              detailsPath,
            ),
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
    );
  }
}

class DriverResults extends StatelessWidget {
  final String driverId;
  const DriverResults(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DriverResult>>(
      future: ErgastApi().getDriverResults(driverId),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) => index == 0
                      ? Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          height: 45,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppLocalizations.of(context)
                                            ?.positionAbbreviation ??
                                        ' POS',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text(''),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    AppLocalizations.of(context)
                                            ?.driverAbbreviation ??
                                        'DRI',
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    AppLocalizations.of(context)?.time ??
                                        'TIME',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    AppLocalizations.of(context)?.laps ??
                                        'Laps',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    AppLocalizations.of(context)
                                            ?.pointsAbbreviation ??
                                        'PTS',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                              child: GestureDetector(
                                onTap: () {
                                  String circuitId =
                                      Convert().circuitIdFromErgastToFormulaOne(
                                    snapshot.data![index - 1].raceId!,
                                  );
                                  String circuitName = Convert()
                                      .circuitNameFromErgastToFormulaOne(
                                    snapshot.data![index - 1].raceId!,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          title: Text(
                                            AppLocalizations.of(context)!.race,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        body: RaceResultsProvider(
                                          raceUrl:
                                              'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/race-result.html',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  '${snapshot.data![index - 1].raceName!} >',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DriverResultItem(
                              snapshot.data![index - 1],
                              5,
                            ),
                          ],
                        ),
                )
              : const LoadingIndicatorUtil(),
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
                height: kIsWeb ? 400 : MediaQuery.of(context).size.width,
                //width: idOfImage == 'driver' ? 400 : 200,
              )
            : SizedBox(
                height: MediaQuery.of(context).size.width,
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
          padding: const EdgeInsets.all(10),
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
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        driverDetails[0][i],
                        textAlign: TextAlign.start,
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
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 275,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 4),
                scrollDirection: Axis.horizontal,
                physics: const PagingScrollPhysics(
                  itemDimension: 300,
                ),
                itemCount: driverDetails[1].length,
                itemBuilder: (context, index) => FutureBuilder<Article>(
                  future: Formula1().getArticleData(
                    driverDetails[1][index][0],
                  ),
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
                                  snapshot.data!.articleHero['contentType'] ==
                                          'atomVideo'
                                      ? snapshot.data!.articleHero['fields']
                                          ['thumbnail']['url']
                                      : snapshot.data!
                                                  .articleHero['contentType'] ==
                                              'atomImageGallery'
                                          ? snapshot.data!.articleHero['fields']
                                              ['imageGallery'][0]['url']
                                          : snapshot.data!.articleHero['fields']
                                              ['image']['url'],
                                ),
                                true,
                              )
                            : const SizedBox(
                                height: 200,
                                width: 300,
                                child: LoadingIndicatorUtil(),
                              );
                  },
                ),
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
                  fontSize: 18,
                ),
              ),
              for (String biographyParagraph in driverDetails[2])
                Text(
                  '\n$biographyParagraph',
                  textAlign: TextAlign.justify,
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  AppLocalizations.of(context)!.gallery,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              CarouselSlider(
                items: [
                  for (int i = 0; i < driverDetails[3][0].length; i++)
                    Image.network(driverDetails[3][0][i]),
                  /* removed on website
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
                    ), */
                ],
                options: CarouselOptions(
                  height: kIsWeb ? 350 : 250,
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

class DriverDetailsFromIdScreen extends StatelessWidget {
  final String detailsPath;
  const DriverDetailsFromIdScreen(this.detailsPath, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FormulaOneScraper().scrapeDriversDetails('', detailsPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: RequestErrorWidget(
              snapshot.error.toString(),
            ),
          );
        } else if (snapshot.hasData) {
          List driverName = snapshot.data![4][0].split(' ');
          driverName.last = driverName.last.toString().toUpperCase();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                driverName.join(' '),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: DriverImageProvider(detailsPath, 'driver'),
                  ),
                  DriverDetailsFragment(
                    snapshot.data!,
                  )
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: Center(
              child: LoadingIndicatorUtil(),
            ),
          );
        }
      },
    );
  }
}
