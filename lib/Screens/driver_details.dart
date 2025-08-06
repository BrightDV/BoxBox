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

import 'package:boxbox/classes/article.dart';
import 'package:boxbox/helpers/custom_physics.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${givenName} ${familyName.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: DriverInfo(driverId, detailsPath: detailsPath),
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
      AppLocalizations.of(context)!.grandsPrix,
      AppLocalizations.of(context)!.points,
      AppLocalizations.of(context)!.highestRaceFinish,
      AppLocalizations.of(context)!.podiums,
      AppLocalizations.of(context)!.highestGridPosition,
      'Pole positions',
      AppLocalizations.of(context)!.worldChampionships,
      'DNF',
      //AppLocalizations.of(context)!.team,
      //AppLocalizations.of(context)!.country,
      //AppLocalizations.of(context)!.dateOfBirth,
      //AppLocalizations.of(context)!.placeOfBirth,
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
                itemBuilder: (context, index) => NewsItem(
                  News(
                    driverDetails[1][index][0],
                    'News',
                    '',
                    driverDetails[1][index][2],
                    '',
                    DateTime.now(),
                    driverDetails[1][index][1],
                    '',
                    // TODO: fix when using API
                    // yet: articles can't be shared
                  ),
                  true,
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
