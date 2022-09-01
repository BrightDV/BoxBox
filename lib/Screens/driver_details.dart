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
 * Copyright (c) 2022, BrightDV
 */

import 'package:boxbox/api/news.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';

class DriverDetailsScreen extends StatelessWidget {
  final String driverId;
  final String givenName;
  final String familyName;

  const DriverDetailsScreen(
    this.driverId,
    this.givenName,
    this.familyName,
  );
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$givenName ${familyName.toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: DriverImageProvider(driverId, 'driver'),
              ),
              FutureBuilder(
                future: FormulaOneScraper().scrapeDriversDetails(driverId),
                builder: (context, snapshot) => snapshot.hasError
                    ? RequestErrorWidget(
                        snapshot.error.toString(),
                      )
                    : snapshot.hasData
                        ? DriverDetailsFragment(
                            snapshot.data,
                          )
                        : LoadingIndicatorUtil(),
              ),
            ],
          ),
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
      return await DriverHelmetImage().getDriverHelmetImage(driverId);
    } else if (idOfImage == 'flag') {
      return await DriverFlagImage().getDriverFlagImage(driverId);
    }
    return "none";
  }

  final String driverId;
  final String idOfImage;
  DriverImageProvider(this.driverId, this.idOfImage);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageURL(this.driverId, this.idOfImage),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? Image.network(
                snapshot.data,
                width: idOfImage == 'driver' ? 400 : 200,
                //fit: BoxFit.scaleDown,
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}

class DriverDetailsFragment extends StatelessWidget {
  final List<List> driverDetails;
  const DriverDetailsFragment(this.driverDetails, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    final List<String> driverInfosLabels = [
      'Équipe',
      'Pays',
      'Podiums',
      'Points',
      'Grand-Prix',
      'Champion du monde',
      'Meilleur résultat (course)',
      'Meilleur résultat (grille)',
      'Date de naissance',
      'Lieu de naissance',
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              for (int i = 0; i < driverDetails[0].length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        driverInfosLabels[i],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
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
              'Articles',
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var item in driverDetails[1])
                    FutureBuilder(
                      future: F1NewsFetcher().getArticleData(item[0]),
                      builder: (context, snapshot) {
                        Article sd = snapshot.data;
                        return snapshot.hasError
                            ? RequestErrorWidget(
                                snapshot.error.toString(),
                              )
                            : snapshot.hasData
                                ? NewsItem(
                                    News(
                                      sd.articleId,
                                      'News',
                                      sd.articleSlug,
                                      sd.articleName,
                                      '',
                                      sd.publishedDate,
                                      sd.articleHero['contentType'] ==
                                              'atomVideo'
                                          ? sd.articleHero['fields']
                                              ['thumbnail']['url']
                                          : sd.articleHero['fields']['image']
                                              ['url'],
                                    ),
                                    true,
                                  )
                                : Container(
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
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                'Biographie',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (String biographyParagraph in driverDetails[2])
                Text(
                  '\n' + biographyParagraph,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  'Galerie',
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
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
                          padding: EdgeInsets.only(
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
                  autoPlayInterval: Duration(seconds: 7),
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
