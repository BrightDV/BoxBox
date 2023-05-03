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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';

class TeamDetailsScreen extends StatelessWidget {
  final String teamId;
  final String teamFullName;
  const TeamDetailsScreen(this.teamId, this.teamFullName, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            teamFullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
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
        ),
        backgroundColor: useDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: FormulaOneScraper().scrapeTeamDetails(teamId),
                      builder: (context, snapshot) => snapshot.hasError
                          ? RequestErrorWidget(
                              snapshot.error.toString(),
                            )
                          : snapshot.hasData
                              ? TeamDetailsFragment(
                                  snapshot.data!,
                                )
                              : const LoadingIndicatorUtil(),
                    ),
                  ],
                ),
              ),
            ),
            TeamResults(teamId),
          ],
        ),
      ),
    );
  }
}

class TeamDetailsFragment extends StatelessWidget {
  final Map<String, dynamic> teamDetails;
  const TeamDetailsFragment(this.teamDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Column(
      children: [
        Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  teamDetails["drivers"]["images"][0],
                  height: (MediaQuery.of(context).size.width - 10) / 2,
                  width: (MediaQuery.of(context).size.width - 10) / 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    teamDetails["drivers"]["names"][0],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Image.network(
                  teamDetails["drivers"]["images"][1],
                  height: (MediaQuery.of(context).size.width - 10) / 2,
                  width: (MediaQuery.of(context).size.width - 10) / 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    teamDetails["drivers"]["names"][1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              for (int i = 0;
                  i < teamDetails["teamStats"]["attributes"].length;
                  i++)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          // localize it
                          teamDetails["teamStats"]["attributes"][i],
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
                          teamDetails["teamStats"]["values"][i],
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: useDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  for (var item in teamDetails["articles"])
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
          padding: const EdgeInsets.only(top: 15),
          child: MarkdownBody(
            data: teamDetails["information"].join("\n"),
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              pPadding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              a: const TextStyle(fontSize: 0),
              h1: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              h3: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
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
                  for (int i = 0;
                      i < teamDetails["medias"]["images"].length;
                      i++)
                    Column(
                      children: [
                        Image.network(teamDetails["medias"]["images"][i]),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Text(
                            teamDetails["medias"]["captions"][i].toString(),
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

class TeamResults extends StatelessWidget {
  final String team;
  const TeamResults(this.team, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<List<List<DriverResult>>>(
      future: ErgastApi().getTeamResults(team),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) => index == 0
                      ? Container(
                          color: const Color(0xff383840),
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    AppLocalizations.of(context)?.time ??
                                        'TIME',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    AppLocalizations.of(context)?.laps ??
                                        'Laps',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    AppLocalizations.of(context)
                                            ?.pointsAbbreviation ??
                                        'PTS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
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
                                    snapshot.data![index - 1][0].raceId!,
                                  );
                                  String circuitName = Convert()
                                      .circuitNameFromErgastToFormulaOne(
                                    snapshot.data![index - 1][0].raceId!,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            AppLocalizations.of(context)!.race,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        body: RaceResultsProvider(
                                          raceUrl:
                                              'https://www.formula1.com/en/results.html/2023/races/$circuitId/$circuitName/race-result.html',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  '${snapshot.data![index - 1][0].raceName!} >',
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DriverResultItem(
                              snapshot.data![index - 1][0],
                              5,
                            ),
                            DriverResultItem(
                              snapshot.data![index - 1][1],
                              5,
                            ),
                          ],
                        ),
                )
              : const LoadingIndicatorUtil(),
    );
  }
}
