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

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:boxbox/Screens/FormulaYou/settings.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaceDetailsScreen extends StatefulWidget {
  final Race race;
  final bool hasSprint;
  final int? tab;

  const RaceDetailsScreen(this.race, this.hasSprint, {Key? key, this.tab})
      : super(key: key);

  @override
  State<RaceDetailsScreen> createState() => _RaceDetailsScreenState();
}

class _RaceDetailsScreenState extends State<RaceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final Race race = widget.race;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return Scaffold(
        backgroundColor: useDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
        body: DefaultTabController(
          length: 3,
          initialIndex: widget.tab != null
              ? widget.tab == 10
                  ? 2
                  : widget.tab!
              : 0,
          child: Builder(
            builder: (BuildContext context) {
              return NestedScrollView(
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
                          race.country,
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          tabs: widget.hasSprint
                              ? <Widget>[
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .freePracticeShort,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .sprint
                                        .toUpperCase(),
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .race
                                        .toUpperCase(),
                                  ),
                                ]
                              : <Widget>[
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .freePracticeShort,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .qualifyingsShort,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!
                                        .race
                                        .toUpperCase(),
                                  ),
                                ],
                          labelColor: useDarkMode
                              ? Colors.white
                              : Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: widget.hasSprint
                    ? TabBarView(
                        children: [
                          FreePracticesResultsProvider(race, widget.hasSprint),
                          DefaultTabController(
                            length: 2,
                            initialIndex: widget.tab == 10 ? 1 : 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TabBar(
                                  tabs: <Widget>[
                                    const Tab(
                                      text: 'SHOOTOUT',
                                    ),
                                    Tab(
                                      text: AppLocalizations.of(context)!
                                          .results
                                          .toUpperCase(),
                                    ),
                                  ],
                                  labelColor: useDarkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      SafeArea(
                                        child: SingleChildScrollView(
                                          child: QualificationResultsProvider(
                                            raceUrl:
                                                'https://www.formula1.com/en/results.html/2023/races/${Convert().circuitIdFromErgastToFormulaOne(widget.race.circuitId)}/${Convert().circuitNameFromErgastToFormulaOne(widget.race.circuitId)}/sprint-shootout.html',
                                            hasSprint: widget.hasSprint,
                                          ),
                                        ),
                                      ),
                                      SafeArea(
                                        child: SprintResultsProvider(
                                          race: race,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          DefaultTabController(
                            length: 2,
                            initialIndex: widget.tab == 10 ? 1 : 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TabBar(
                                  tabs: <Widget>[
                                    Tab(
                                      text: AppLocalizations.of(context)!
                                          .qualifyings
                                          .toUpperCase(),
                                    ),
                                    Tab(
                                      text: AppLocalizations.of(context)!
                                          .results
                                          .toUpperCase(),
                                    ),
                                  ],
                                  labelColor: useDarkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      SafeArea(
                                        child: SingleChildScrollView(
                                          child: QualificationResultsProvider(
                                            race: race,
                                            hasSprint: widget.hasSprint,
                                          ),
                                        ),
                                      ),
                                      RaceResultsProvider(race: race),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : TabBarView(
                        children: [
                          FreePracticesResultsProvider(race, widget.hasSprint),
                          SafeArea(
                            child: SingleChildScrollView(
                              child: QualificationResultsProvider(
                                race: race,
                                hasSprint: widget.hasSprint,
                              ),
                            ),
                          ),
                          SafeArea(
                            child: RaceResultsProvider(race: race),
                          ),
                        ],
                      ),
              );
            },
          ),
        ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Container(
      color: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class FreePracticesResultsProvider extends StatefulWidget {
  final Race race;
  final bool hasSprint;
  const FreePracticesResultsProvider(this.race, this.hasSprint, {Key? key})
      : super(key: key);

  @override
  State<FreePracticesResultsProvider> createState() =>
      _FreePracticesResultsProviderState();
}

class _FreePracticesResultsProviderState
    extends State<FreePracticesResultsProvider> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Race race = widget.race;
    final bool hasSprint = widget.hasSprint;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    final List<String> sessionsTitle = [
      AppLocalizations.of(context)!.freePracticeOne,
      AppLocalizations.of(context)!.freePracticeTwo,
      AppLocalizations.of(context)!.freePracticeThree,
    ];
    return FutureBuilder<int>(
      future: FormulaOneScraper().whichSessionsAreFinised(
        Convert().circuitIdFromErgastToFormulaOne(race.circuitId),
        Convert().circuitNameFromErgastToFormulaOne(race.circuitId),
      ),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemCount: hasSprint ? 1 : 3,
                  itemBuilder: (context, index) => snapshot.data! > index
                      ? ListTile(
                          title: Text(
                            sessionsTitle[index],
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FreePracticeScreen(
                                sessionsTitle[index],
                                index + 1,
                                race.circuitId,
                                int.parse(
                                  race.date.split('-')[2],
                                ),
                                race.raceName,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sessionsTitle[index],
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SessionCountdownTimer(
                                race,
                                index,
                                sessionsTitle[index],
                                update: update,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 25,
                                ),
                                child: Divider(
                                  color: useDarkMode
                                      ? const Color(0xff1d1d28)
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                )
              : const LoadingIndicatorUtil(),
    );
  }
}

class RaceResultsProvider extends StatefulWidget {
  final Race? race;
  final String? raceUrl;
  const RaceResultsProvider({Key? key, this.race, this.raceUrl})
      : super(key: key);
  @override
  State<RaceResultsProvider> createState() => _RaceResultsProviderState();
}

class _RaceResultsProviderState extends State<RaceResultsProvider> {
  Future<List<DriverResult>> getRaceStandingsFromErgast(String round) async {
    return await ErgastApi().getRaceStandings(round);
  }

  Future<List<DriverResult>> getRaceStandingsFromF1(String raceUrl) async {
    return await FormulaOneScraper().scrapeRaceResult(
      '',
      0,
      '',
      false,
      raceUrl: raceUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    late Map savedData;
    late Race race;
    late int timeToRace;
    String raceUrl = '';
    if (widget.raceUrl != null) {
      timeToRace = -1;
      raceUrl = widget.raceUrl!;
    } else {
      race = widget.race!;
      savedData = Hive.box('requests')
          .get('race-${race.round}', defaultValue: {}) as Map;
      DateTime raceFullDateParsed = DateTime.parse(
        "${race.date} ${race.raceHour}",
      );
      int timeBetween(DateTime from, DateTime to) {
        return to.difference(from).inSeconds;
      }

      timeToRace = timeBetween(
        DateTime.now(),
        raceFullDateParsed,
      );
    }
    if (timeToRace > 0) {
      return SessionCountdownTimer(
        race,
        4,
        AppLocalizations.of(context)!.race,
      );
    } else {
      return raceUrl != ''
          ? FutureBuilder<List<DriverResult>>(
              future: getRaceStandingsFromF1(raceUrl),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.dataNotAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }
                return snapshot.hasData
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const FaIcon(
                                FontAwesomeIcons.youtube,
                                color: Colors.white,
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.watchOnYoutube,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                var yt = YoutubeExplode();
                                final raceYear = widget.raceUrl != null
                                    ? DateTime.now()
                                    : race.date.split('-')[0];
                                final List<Video> searchResults =
                                    await yt.search.search(
                                  "Formula 1 Race Highlights ${race.raceName} $raceYear",
                                );
                                final Video bestVideoMatch = searchResults[0];
                                await launchUrl(
                                  Uri.parse(
                                      "https://youtube.com/watch?v=${bestVideoMatch.id.value}"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              tileColor: const Color(0xff383840),
                            ),
                            RaceDriversResultsList(snapshot.data!),
                          ],
                        ),
                      )
                    : const LoadingIndicatorUtil();
              })
          : FutureBuilder<List<DriverResult>>(
              future: getRaceStandingsFromErgast(race.round),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return savedData['MRData'] != null
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                leading: FaIcon(
                                  FontAwesomeIcons.youtube,
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .unavailableOffline,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () async {},
                              ),
                              RaceDriversResultsList(
                                ErgastApi().formatRaceStandings(savedData),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.dataNotAvailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                }

                return snapshot.hasData
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const FaIcon(
                                FontAwesomeIcons.youtube,
                                color: Colors.white,
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.watchOnYoutube,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                var yt = YoutubeExplode();
                                final raceYear = widget.raceUrl != null
                                    ? DateTime.now()
                                    : race.date.split('-')[0];
                                final List<Video> searchResults =
                                    await yt.search.search(
                                  "Formula 1 Race Highlights ${race.raceName} $raceYear",
                                );
                                final Video bestVideoMatch = searchResults[0];
                                await launchUrl(
                                  Uri.parse(
                                      "https://youtube.com/watch?v=${bestVideoMatch.id.value}"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              tileColor: const Color(0xff383840),
                            ),
                            RaceDriversResultsList(snapshot.data!),
                          ],
                        ),
                      )
                    : savedData['MRData'] != null
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: FaIcon(
                                    FontAwesomeIcons.youtube,
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .unavailableOffline,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () async {},
                                ),
                                RaceDriversResultsList(
                                  ErgastApi().formatRaceStandings(savedData),
                                ),
                              ],
                            ),
                          )
                        : const LoadingIndicatorUtil();
              },
            );
    }
  }
}

class SprintResultsProvider extends StatelessWidget {
  Future<List<DriverResult>> getSprintStandings(
    String round,
  ) async {
    return await ErgastApi().getSprintStandings(
      round,
    );
  }

  final Race? race;
  final String? raceUrl;
  const SprintResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return SingleChildScrollView(
      child: FutureBuilder<List<DriverResult>>(
        future: raceUrl != null
            ? FormulaOneScraper().scrapeRaceResult(
                '',
                0,
                '',
                false,
                raceUrl: raceUrl!,
              )
            : getSprintStandings(
                race!.round,
              ),
        builder: (context, snapshot) => snapshot.hasError
            ? Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.dataNotAvailable,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            : snapshot.hasData
                ? snapshot.data!.isEmpty
                    ? SessionCountdownTimer(
                        race,
                        2,
                        AppLocalizations.of(context)!.sprint,
                      )
                    : Column(
                        children: [
                          GestureDetector(
                            child: ListTile(
                              leading: const FaIcon(
                                FontAwesomeIcons.youtube,
                                color: Colors.white,
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.watchOnYoutube,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                var yt = YoutubeExplode();
                                final raceYear = race!.date.split('-')[0];
                                final List<Video> searchResults =
                                    await yt.search.search(
                                  "Formula 1 Sprint Highlights ${race!.raceName} $raceYear",
                                );
                                final Video bestVideoMatch = searchResults[0];
                                await launchUrl(
                                  Uri.parse(
                                      "https://youtube.com/watch?v=${bestVideoMatch.id.value}"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              tileColor: const Color(0xff383840),
                            ),
                          ),
                          RaceDriversResultsList(
                            snapshot.data!,
                          ),
                        ],
                      )
                : const LoadingIndicatorUtil(),
      ),
    );
  }
}

class QualificationResultsProvider extends StatelessWidget {
  Future<List<DriverQualificationResult>> getQualificationStandings(
    String round,
  ) async {
    return await ErgastApi().getQualificationStandings(
      round,
    );
  }

  final Race? race;
  final String? raceUrl;
  final bool? hasSprint;
  const QualificationResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
    this.hasSprint,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<List<DriverQualificationResult>>(
      future: raceUrl != null
          ? FormulaOneScraper().scrapeQualifyingResults(
              '',
              0,
              '',
              false,
              qualifyingResultsUrl: raceUrl!,
            )
          : getQualificationStandings(
              race!.round,
            ),
      builder: (context, snapshot) => snapshot.hasError
          ? (race?.sessionDates.isNotEmpty ?? false) &&
                  (race?.sessionDates.last.isBefore(
                        DateTime.now(),
                      ) ??
                      false)
              ? SessionCountdownTimer(
                  race,
                  3,
                  AppLocalizations.of(context)!.qualifyings,
                )
              : Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.dataNotAvailable,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
          : snapshot.hasData
              ? snapshot.data!.isNotEmpty
                  ? Column(
                      children: [
                        GestureDetector(
                          child: ListTile(
                            leading: const FaIcon(
                              FontAwesomeIcons.youtube,
                              color: Colors.white,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.watchOnYoutube,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onTap: () async {
                              var yt = YoutubeExplode();
                              final raceYear = race!.date.split('-')[0];
                              final List<Video> searchResults =
                                  await yt.search.search(
                                raceUrl?.contains('sprint-shootout') ?? false
                                    ? "Formula 1 Sprint Shootout Highlights ${race!.raceName} $raceYear"
                                    : "Formula 1 Qualification Highlights ${race!.raceName} $raceYear",
                              );
                              final Video bestVideoMatch = searchResults[0];
                              await launchUrl(
                                Uri.parse(
                                  "https://youtube.com/watch?v=${bestVideoMatch.id.value}",
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            tileColor: const Color(0xff383840),
                          ),
                        ),
                        QualificationDriversResultsList(
                          snapshot.data!,
                        ),
                      ],
                    )
                  : race!.sessionDates[3].isBefore(DateTime.now())
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.dataNotAvailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        )
                      : SessionCountdownTimer(
                          race,
                          3,
                          AppLocalizations.of(context)!.qualifyings,
                        )
              : const LoadingIndicatorUtil(),
    );
  }
}

class StartingGridProvider extends StatelessWidget {
  final String raceUrl;
  const StartingGridProvider(this.raceUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StartingGridPosition>>(
      future: FormulaOneScraper().scrapeStartingGrid(raceUrl),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length + 1,
                  physics: const ClampingScrollPhysics(),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 4,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .positionAbbreviation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 1,
                                  child: Text(''),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .driverAbbreviation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .team
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    AppLocalizations.of(context)!.time,
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
                      : StartingGridPositionItem(
                          snapshot.data![index - 1],
                          index - 1,
                        ),
                )
              : const LoadingIndicatorUtil(),
    );
  }
}

class StartingGridPositionItem extends StatelessWidget {
  final StartingGridPosition startingGridPosition;
  final int index;
  const StartingGridPositionItem(this.startingGridPosition, this.index,
      {super.key});

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(startingGridPosition.team);
    return Container(
      color: index % 2 == 1 ? const Color(0xff22222c) : const Color(0xff15151f),
      height: 45,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 4,
                ),
                child: Text(
                  startingGridPosition.position,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: VerticalDivider(
                color: finalTeamColors,
                thickness: 8,
                width: 25,
                indent: 7,
                endIndent: 7,
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                ),
                child: Text(
                  startingGridPosition.driver,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Text(
                  startingGridPosition.teamFullName,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      startingGridPosition.time,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          return RequestErrorWidget(snapshot.error.toString());
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

class SessionCountdownTimer extends StatefulWidget {
  final Race? race;
  final int sessionIndex;
  final String sessionName;
  final Function? update;
  const SessionCountdownTimer(
    this.race,
    this.sessionIndex,
    this.sessionName, {
    super.key,
    this.update,
  });

  @override
  State<SessionCountdownTimer> createState() => _SessionCountdownTimerState();
}

class _SessionCountdownTimerState extends State<SessionCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool shouldUseCountdown = Hive.box('settings')
        .get('shouldUseCountdown', defaultValue: true) as bool;
    List months = [
      AppLocalizations.of(context)?.monthAbbreviationJanuary,
      AppLocalizations.of(context)?.monthAbbreviationFebruary,
      AppLocalizations.of(context)?.monthAbbreviationMarch,
      AppLocalizations.of(context)?.monthAbbreviationApril,
      AppLocalizations.of(context)?.monthAbbreviationMay,
      AppLocalizations.of(context)?.monthAbbreviationJune,
      AppLocalizations.of(context)?.monthAbbreviationJuly,
      AppLocalizations.of(context)?.monthAbbreviationAugust,
      AppLocalizations.of(context)?.monthAbbreviationSeptember,
      AppLocalizations.of(context)?.monthAbbreviationOctober,
      AppLocalizations.of(context)?.monthAbbreviationNovember,
      AppLocalizations.of(context)?.monthAbbreviationDecember,
    ];

    late int timeToRace;
    late int days;
    late int hours;
    late int minutes;
    late int seconds;
    late DateTime raceFullDateParsed;

    Race race = widget.race!;
    if (widget.sessionIndex == 4) {
      String raceFullDate = "${race.date} ${race.raceHour}";
      raceFullDateParsed = DateTime.parse(raceFullDate);
    } else {
      raceFullDateParsed = race.sessionDates[widget.sessionIndex];
    }
    int timeBetween(DateTime from, DateTime to) {
      return to.difference(from).inSeconds;
    }

    timeToRace = timeBetween(
      DateTime.now(),
      raceFullDateParsed,
    );
    days = (timeToRace / 60 / 60 / 24).round();
    hours = (timeToRace / 60 / 60 - days * 24 - 1).round();
    minutes = (timeToRace / 60 - days * 24 * 60 - hours * 60 + 60).round();
    seconds =
        (timeToRace - days * 24 * 60 * 60 - hours * 60 * 60 - minutes * 60);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            widget.sessionIndex == 4
                ? shouldUseCountdown
                    ? AppLocalizations.of(context)!.raceStartsIn
                    : AppLocalizations.of(context)!.raceStartsOn
                : shouldUseCountdown
                    ? AppLocalizations.of(context)!.sessionStartsIn
                    : AppLocalizations.of(context)!.sessionStartsOn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        shouldUseCountdown
            ? TimerCountdown(
                format: CountDownTimerFormat.daysHoursMinutesSeconds,
                endTime: DateTime.now().add(
                  Duration(
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  ),
                ),
                timeTextStyle: TextStyle(
                  fontSize: 25,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                colonsTextStyle: TextStyle(
                  fontSize: 23,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                descriptionTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                ),
                spacerWidth: 15,
                daysDescription: AppLocalizations.of(context)!.dayFirstLetter,
                hoursDescription: AppLocalizations.of(context)!.hourFirstLetter,
                minutesDescription:
                    AppLocalizations.of(context)!.minuteAbbreviation,
                secondsDescription:
                    AppLocalizations.of(context)!.secondAbbreviation,
                onEnd: () {
                  setState(() {});
                },
              )
            : Padding(
                padding: const EdgeInsets.all(15.5),
                child: Text(
                  '${raceFullDateParsed.day} ${months[raceFullDateParsed.month - 1]} - ${raceFullDateParsed.toLocal().toIso8601String().split('T')[1].split('.')[0]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
        !kIsWeb
            ? TextButton.icon(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    AppLocalizations.of(context)!.addToCalendar,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.add_alert_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                style: TextButton.styleFrom(
                  side: BorderSide(
                    color: useDarkMode ? Colors.white : Colors.black,
                    width: 1,
                  ),
                ),
                onPressed: () {
                  Event event = Event(
                    title: '${widget.sessionName} - ${race.raceName}',
                    location: race.country,
                    startDate: DateTime(
                      raceFullDateParsed.toLocal().year,
                      raceFullDateParsed.toLocal().month,
                      raceFullDateParsed.toLocal().day,
                      raceFullDateParsed.toLocal().hour,
                      raceFullDateParsed.toLocal().minute,
                      raceFullDateParsed.toLocal().second,
                    ),
                    endDate: DateTime(
                      raceFullDateParsed.toLocal().year,
                      raceFullDateParsed.toLocal().month,
                      raceFullDateParsed.toLocal().day,
                      raceFullDateParsed.toLocal().hour +
                          (widget.sessionIndex == 4 ? 3 : 1),
                      raceFullDateParsed.toLocal().minute,
                      raceFullDateParsed.toLocal().second,
                    ),
                  );
                  Add2Calendar.addEvent2Cal(event);
                },
              )
            : Container(),
        SizedBox(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  AppLocalizations.of(context)!.time.capitalize(),
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Expanded(
                flex: 2,
                child: Switch(
                  value: shouldUseCountdown,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) => setState(
                    () {
                      shouldUseCountdown = value;
                      Hive.box('settings')
                          .put('shouldUseCountdown', shouldUseCountdown);
                      if (widget.update != null) {
                        widget.update!();
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  AppLocalizations.of(context)!.countdown,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
