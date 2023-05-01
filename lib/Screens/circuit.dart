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

import 'dart:async';

import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/api/news.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/circuit_map_screen.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CircuitScreen extends StatefulWidget {
  final Race race;
  final bool? isFetched;

  const CircuitScreen(
    this.race, {
    Key? key,
    this.isFetched,
  }) : super(key: key);

  @override
  State<CircuitScreen> createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  @override
  Widget build(BuildContext context) {
    final Race race = widget.race;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    return Scaffold(
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: widget.isFetched ?? true
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: RaceImageProvider(race),
                      title: Text(
                        race.raceName,
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: FutureBuilder<Map>(
                  future: EventTracker().getCircuitDetails(
                    Convert().circuitIdFromErgastToFormulaOne(
                      race.circuitId,
                    ),
                  ),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Column(
                          children: [
                            snapshot.data!['headline'] != null
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      snapshot.data!['headline'],
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: GestureDetector(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: useDarkMode
                                        ? const Color(0xff1d1d28)
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .viewResults,
                                          style: TextStyle(
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: useDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RaceDetailsScreen(
                                      race,
                                      snapshot.data!['meetingContext']
                                              ['timetables'][1]['session'] ==
                                          's',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            snapshot.data!['links'].isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: GestureDetector(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: useDarkMode
                                              ? const Color(0xff1d1d28)
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .viewHighlights,
                                                style: TextStyle(
                                                  color: useDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: useDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ArticleScreen(
                                            snapshot.data!['links'][1]['url']
                                                .split('.')[4],
                                            '',
                                            true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: GestureDetector(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: useDarkMode
                                        ? const Color(0xff1d1d28)
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      10,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .grandPrixMap,
                                          style: TextStyle(
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.map_outlined,
                                          color: useDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CircuitMapScreen(
                                    race.circuitId,
                                  ),
                                ),
                              ),
                            ),
                            snapshot.data!['raceResults'].isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(
                                      10,
                                    ),
                                    child: Container(
                                      height: 210,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: useDarkMode
                                              ? const Color(0xff1d1d28)
                                              : Colors.grey.shade50,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 15,
                                            ),
                                            child: Text(
                                              snapshot.data!['race']
                                                  ['meetingCountryName'],
                                              style: TextStyle(
                                                color: useDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!.race,
                                            style: TextStyle(
                                              color: useDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 15,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .positionAbbreviation,
                                                    style: TextStyle(
                                                      color: useDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .time,
                                                    style: TextStyle(
                                                      color: useDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          for (Map driverResults
                                              in snapshot.data!['raceResults'])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 7,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      driverResults[
                                                          'positionNumber'],
                                                      style: TextStyle(
                                                        color: useDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: SizedBox(
                                                      height: 15,
                                                      child: VerticalDivider(
                                                        color: Color(
                                                          int.parse(
                                                            'FF${driverResults['teamColourCode']}',
                                                            radix: 16,
                                                          ),
                                                        ),
                                                        thickness: 5,
                                                        width: 5,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      driverResults['driverTLA']
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: useDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                      driverResults[
                                                                  'gapToLeader'] !=
                                                              "0.0"
                                                          ? '+${driverResults['gapToLeader']}'
                                                          : driverResults[
                                                              'raceTime'],
                                                      style: TextStyle(
                                                        color: useDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 15,
                                              ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.zero,
                                                    topRight: Radius.zero,
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RaceDetailsScreen(
                                                          race,
                                                          snapshot.data!['meetingContext']
                                                                      [
                                                                      'timetables']
                                                                  [
                                                                  1]['session'] ==
                                                              's',
                                                          tab: 10,
                                                        ),
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          const ContinuousRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .viewResults,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            snapshot.data!['curatedSection'] != null
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (Map article in snapshot
                                            .data!['curatedSection']['items'])
                                          NewsItem(
                                            News(
                                              article['id'],
                                              article['articleType'],
                                              article['slug'],
                                              article['title'],
                                              article['metaDescription'] ?? ' ',
                                              DateTime.parse(
                                                  article['updatedAt']),
                                              useDataSaverMode
                                                  ? article['thumbnail']
                                                                  ['image']
                                                              ['renditions'] !=
                                                          null
                                                      ? article['thumbnail']
                                                              ['image']
                                                          ['renditions']['2col']
                                                      : article['thumbnail']
                                                              ['image']['url'] +
                                                          '.transform/2col-retina/image.jpg'
                                                  : article['thumbnail']
                                                      ['image']['url'],
                                            ),
                                            true,
                                          ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TrackLayoutImage(race),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: FutureBuilder<Map>(
                                future: FormulaOneScraper().scrapeCircuitFacts(
                                  Convert()
                                      .circuitNameFromErgastToFormulaOneForRaceHub(
                                    race.circuitId,
                                  ),
                                  context,
                                ),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) => Column(
                                          children: [
                                            Text(
                                              snapshot.data!.keys
                                                  .elementAt(index),
                                              style: TextStyle(
                                                color: useDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              snapshot.data![snapshot.data!.keys
                                                  .elementAt(index)],
                                              style: TextStyle(
                                                color: useDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 400,
                                        child: LoadingIndicatorUtil(),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: FutureBuilder<String>(
                                future:
                                    FormulaOneScraper().scrapeCircuitHistory(
                                  Convert()
                                      .circuitNameFromErgastToFormulaOneForRaceHub(
                                    race.circuitId,
                                  ),
                                ),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? MarkdownBody(
                                        data: snapshot.data!,
                                        selectable: true,
                                        onTapLink: (text, href, title) =>
                                            launchUrl(
                                          Uri.parse(href!),
                                        ),
                                        styleSheet: MarkdownStyleSheet(
                                          textAlign: WrapAlignment.spaceBetween,
                                          strong: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          p: TextStyle(
                                            fontSize: 14,
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          pPadding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                          ),
                                          h1: TextStyle(
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          h2: TextStyle(
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          a: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 400,
                                        child: LoadingIndicatorUtil(),
                                      ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: useDarkMode
                                    ? const Color(0xff1d1d28)
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.viewResults,
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RaceDetailsScreen(
                                  race,
                                  false, // offline
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            )
          : FutureBuilder<Race>(
              future: ErgastApi().getRaceDetails(
                Convert().circuitNameFromFormulaOneToRoundNumber(
                  race.circuitId,
                ),
              ),
              builder: (context, circuitSnapshot) => circuitSnapshot.hasError
                  ? RequestErrorWidget(
                      circuitSnapshot.toString(),
                    )
                  : circuitSnapshot.hasData
                      ? NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverAppBar(
                                expandedHeight: 200.0,
                                floating: false,
                                pinned: true,
                                centerTitle: true,
                                flexibleSpace: FlexibleSpaceBar(
                                  background: RaceImageProvider(
                                    circuitSnapshot.data!,
                                  ),
                                  title: Text(circuitSnapshot.data!.raceName),
                                ),
                              ),
                            ];
                          },
                          body: SingleChildScrollView(
                            child: FutureBuilder<Map>(
                              future: EventTracker().getCircuitDetails(
                                Convert()
                                    .circuitNameFromFormulaOneToFormulaOneIdForRaceHub(
                                  race.circuitId,
                                ),
                              ),
                              builder: (context, snapshot) => snapshot.hasData
                                  ? Column(
                                      children: [
                                        snapshot.data!['headline'] != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  snapshot.data!['headline'],
                                                  style: TextStyle(
                                                    color: useDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.justify,
                                                ),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: GestureDetector(
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: useDarkMode
                                                    ? const Color(0xff1d1d28)
                                                    : Colors.grey.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  20,
                                                  10,
                                                  20,
                                                  10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .viewResults,
                                                      style: TextStyle(
                                                        color: useDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: useDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RaceDetailsScreen(
                                                  circuitSnapshot.data!,
                                                  snapshot.data!['meetingContext']
                                                              ['timetables'][1]
                                                          ['session'] ==
                                                      's',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        snapshot.data!['links'][1] != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: GestureDetector(
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: useDarkMode
                                                          ? const Color(
                                                              0xff1d1d28)
                                                          : Colors
                                                              .grey.shade400,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        5,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                        20,
                                                        10,
                                                        20,
                                                        10,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .viewHighlights,
                                                            style: TextStyle(
                                                              color: useDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_rounded,
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ArticleScreen(
                                                        snapshot.data!['links']
                                                                [1]['url']
                                                            .split('.')[4],
                                                        '',
                                                        true,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        snapshot.data!['raceResults'] != null
                                            ? Padding(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                child: Container(
                                                  height: 210,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: useDarkMode
                                                          ? const Color(
                                                              0xff1d1d28)
                                                          : Colors.grey.shade50,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 15,
                                                        ),
                                                        child: Text(
                                                          snapshot.data!['race']
                                                              [
                                                              'meetingCountryName'],
                                                          style: TextStyle(
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .race,
                                                        style: TextStyle(
                                                          color: useDarkMode
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 15,
                                                          left: 15,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 5,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .positionAbbreviation,
                                                                style:
                                                                    TextStyle(
                                                                  color: useDarkMode
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Expanded(
                                                              flex: 5,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .time,
                                                                style:
                                                                    TextStyle(
                                                                  color: useDarkMode
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      for (Map driverResults
                                                          in snapshot.data![
                                                              'raceResults'])
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 7,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  driverResults[
                                                                      'positionNumber'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: useDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: SizedBox(
                                                                  height: 15,
                                                                  child:
                                                                      VerticalDivider(
                                                                    color:
                                                                        Color(
                                                                      int.parse(
                                                                          'FF${driverResults['teamColourCode']}',
                                                                          radix:
                                                                              16),
                                                                    ),
                                                                    thickness:
                                                                        5,
                                                                    width: 5,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  driverResults[
                                                                          'driverTLA']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: useDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Text(
                                                                  driverResults[
                                                                              'gapToLeader'] !=
                                                                          "0.0"
                                                                      ? '+${driverResults['gapToLeader']}'
                                                                      : driverResults[
                                                                          'raceTime'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: useDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 15,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft:
                                                                    Radius.zero,
                                                                topRight:
                                                                    Radius.zero,
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () =>
                                                                    Navigator
                                                                        .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RaceDetailsScreen(
                                                                      circuitSnapshot
                                                                          .data!,
                                                                      snapshot.data!['meetingContext']['timetables'][1]
                                                                              [
                                                                              'session'] ==
                                                                          's',
                                                                      tab: 10,
                                                                    ),
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape:
                                                                      const ContinuousRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .zero,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .viewResults,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        snapshot.data!['curatedSection'] != null
                                            ? SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    for (Map article in snapshot
                                                                .data![
                                                            'curatedSection']
                                                        ['items'])
                                                      NewsItem(
                                                        News(
                                                          article['id'],
                                                          article[
                                                              'articleType'],
                                                          article['slug'],
                                                          article['title'],
                                                          article['metaDescription'] ??
                                                              ' ',
                                                          DateTime.parse(
                                                              article[
                                                                  'updatedAt']),
                                                          useDataSaverMode
                                                              ? article['thumbnail']
                                                                              ['image']
                                                                          [
                                                                          'renditions'] !=
                                                                      null
                                                                  ? article['thumbnail']
                                                                              [
                                                                              'image']
                                                                          [
                                                                          'renditions']
                                                                      ['2col']
                                                                  : article['thumbnail']
                                                                              [
                                                                              'image']
                                                                          [
                                                                          'url'] +
                                                                      '.transform/2col-retina/image.jpg'
                                                              : article['thumbnail']
                                                                      ['image']
                                                                  ['url'],
                                                        ),
                                                        true,
                                                      ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: GestureDetector(
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: useDarkMode
                                                    ? const Color(0xff1d1d28)
                                                    : Colors.grey.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  20,
                                                  10,
                                                  20,
                                                  10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .grandPrixMap,
                                                      style: TextStyle(
                                                        color: useDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Icon(
                                                      Icons.map_outlined,
                                                      color: useDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  CircuitMapScreen(
                                                circuitSnapshot.data!.circuitId,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: TrackLayoutImage(
                                            circuitSnapshot.data!,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: FutureBuilder<Map>(
                                            future: FormulaOneScraper()
                                                .scrapeCircuitFacts(
                                              Convert()
                                                  .circuitNameFromErgastToFormulaOneForRaceHub(
                                                circuitSnapshot.data!.circuitId,
                                              ),
                                              context,
                                            ),
                                            builder: (context, snapshot) =>
                                                snapshot.hasData
                                                    ? ListView.builder(
                                                        itemCount: snapshot
                                                            .data!.length,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                Column(
                                                          children: [
                                                            Text(
                                                              snapshot
                                                                  .data!.keys
                                                                  .elementAt(
                                                                      index),
                                                              style: TextStyle(
                                                                color: useDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            Text(
                                                              snapshot.data![
                                                                  snapshot.data!
                                                                      .keys
                                                                      .elementAt(
                                                                          index)],
                                                              style: TextStyle(
                                                                color: useDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 400,
                                                        child:
                                                            LoadingIndicatorUtil(),
                                                      ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: FutureBuilder<String>(
                                            future: FormulaOneScraper()
                                                .scrapeCircuitHistory(
                                              Convert()
                                                  .circuitNameFromErgastToFormulaOneForRaceHub(
                                                circuitSnapshot.data!.circuitId,
                                              ),
                                            ),
                                            builder: (context, snapshot) =>
                                                snapshot.hasData
                                                    ? MarkdownBody(
                                                        data: snapshot.data!,
                                                        selectable: true,
                                                        onTapLink: (text, href,
                                                                title) =>
                                                            launchUrl(
                                                          Uri.parse(href!),
                                                        ),
                                                        styleSheet:
                                                            MarkdownStyleSheet(
                                                          textAlign:
                                                              WrapAlignment
                                                                  .spaceBetween,
                                                          strong: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          p: TextStyle(
                                                            fontSize: 14,
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                          pPadding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                            bottom: 10,
                                                          ),
                                                          h1: TextStyle(
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                          h2: TextStyle(
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                          a: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 400,
                                                        child:
                                                            LoadingIndicatorUtil(),
                                                      ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: GestureDetector(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: useDarkMode
                                                ? const Color(0xff1d1d28)
                                                : Colors.grey.shade400,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              10,
                                              20,
                                              10,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .viewResults,
                                                  style: TextStyle(
                                                    color: useDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: useDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RaceDetailsScreen(
                                              race,
                                              false, // offline
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        )
                      : const LoadingIndicatorUtil(),
            ),
    );
  }
}

class RaceImageProvider extends StatelessWidget {
  Future<String> getCircuitImageUrl(Race race) async {
    return await RaceTracksUrls().getRaceTrackImageUrl(race.circuitId);
  }

  final Race race;
  const RaceImageProvider(this.race, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCircuitImageUrl(race),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(
            snapshot.error.toString(),
          );
        }
        return snapshot.hasData
            ? CachedNetworkImage(
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outlined),
                fadeOutDuration: const Duration(seconds: 1),
                fadeInDuration: const Duration(seconds: 1),
                fit: BoxFit.cover,
                imageUrl: snapshot.data!,
                placeholder: (context, url) => const LoadingIndicatorUtil(),
              )
            : const LoadingIndicatorUtil();
      },
    );
  }
}

class TrackLayoutImage extends StatelessWidget {
  Future<String> getTrackLayoutImageUrl(Race race) async {
    return await RaceTracksUrls().getTrackLayoutImageUrl(race.circuitId);
  }

  final Race race;
  const TrackLayoutImage(this.race, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<String>(
      future: getTrackLayoutImageUrl(race),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(
            snapshot.error.toString(),
          );
        }
        return snapshot.hasData
            ? GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.only(
                          top: 52,
                          bottom: 50,
                        ),
                        insetPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.transparent,
                        content: Builder(
                          builder: (context) {
                            return SizedBox(
                              width: double.infinity - 10,
                              child: InteractiveViewer(
                                minScale: 0.1,
                                maxScale: 8,
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                    ),
                                    Card(
                                      color:
                                          Colors.transparent.withOpacity(0.5),
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image(
                                        image: NetworkImage(
                                          snapshot.data!,
                                        ),
                                        loadingBuilder: (context, child,
                                                loadingProgress) =>
                                            loadingProgress == null
                                                ? child
                                                : SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            (16 / 9),
                                                    child:
                                                        const LoadingIndicatorUtil(),
                                                  ),
                                        errorBuilder: (context, url, error) =>
                                            Icon(
                                          Icons.error_outlined,
                                          color: useDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.close_rounded,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.network(
                      snapshot.data!,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : SizedBox(
                                  height: MediaQuery.of(context).size.width /
                                      (16 / 9),
                                  child: const LoadingIndicatorUtil(),
                                ),
                      errorBuilder: (context, url, error) => Icon(
                        Icons.error_outlined,
                        color: useDarkMode ? Colors.white : Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              )
            : const LoadingIndicatorUtil();
      },
    );
  }
}
