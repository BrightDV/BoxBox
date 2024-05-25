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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:boxbox/Screens/FormulaYou/settings.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/circuit.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaceDetailsScreen extends StatelessWidget {
  final Race race;
  final bool hasSprint;
  final int? tab;

  const RaceDetailsScreen(this.race, this.hasSprint, {Key? key, this.tab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
      length: 3,
      initialIndex: tab != null
          ? tab == 10
              ? 2
              : tab!
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
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      dividerColor: Colors.transparent,
                      tabs: hasSprint
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
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: hasSprint
                ? TabBarView(
                    children: [
                      FreePracticesResultsProvider(race, hasSprint),
                      DefaultTabController(
                        length: 2,
                        initialIndex: tab == 10 ? 1 : 0,
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
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: SafeArea(
                                      child: QualificationResultsProvider(
                                        race: race,
                                        hasSprint: hasSprint,
                                        isSprintQualifying: true,
                                      ),
                                    ),
                                  ),
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: SafeArea(
                                      child: SprintResultsProvider(
                                        race: race,
                                      ),
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
                        initialIndex: tab == 10 ? 1 : 0,
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
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: SafeArea(
                                      child: QualificationResultsProvider(
                                        race: race,
                                        hasSprint: hasSprint,
                                      ),
                                    ),
                                  ),
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: SafeArea(
                                      child: RaceResultsProvider(race: race),
                                    ),
                                  ),
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
                      FreePracticesResultsProvider(race, hasSprint),
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: SafeArea(
                          child: QualificationResultsProvider(
                            race: race,
                            hasSprint: hasSprint,
                          ),
                        ),
                      ),
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
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
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
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
    String scheduleLastSavedFormat = Hive.box('requests')
        .get('scheduleLastSavedFormat', defaultValue: 'ergast');
    final Race race = widget.race;
    final bool hasSprint = widget.hasSprint;

    final List<String> sessionsTitle = [
      AppLocalizations.of(context)!.freePracticeOne,
      AppLocalizations.of(context)!.freePracticeTwo,
      AppLocalizations.of(context)!.freePracticeThree,
    ];
    if (scheduleLastSavedFormat == 'ergast') {
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
                ? race.sessionDates.isEmpty // TODO: update when Ergast not down
                    ? Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.dataNotAvailable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: hasSprint ? 1 : 3,
                        itemBuilder: (context, index) => snapshot.data! > index
                            ? ListTile(
                                title: Text(
                                  sessionsTitle[index],
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FreePracticeScreen(
                                      sessionsTitle[index],
                                      index + 1,
                                      race.circuitId,
                                      race.meetingId,
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
                                      child: Divider(),
                                    ),
                                  ],
                                ),
                              ),
                      )
                : const LoadingIndicatorUtil(),
      );
    } else {
      int maxSession = 0;
      for (var session in race.sessionStates!) {
        if (session == "completed") {
          maxSession++;
        }
      }
      return ListView.builder(
        itemCount: hasSprint ? 1 : 3,
        itemBuilder: (context, index) => maxSession > index
            ? ListTile(
                title: Text(
                  sessionsTitle[index],
                  textAlign: TextAlign.center,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FreePracticeScreen(
                      sessionsTitle[index],
                      index + 1,
                      race.circuitId,
                      race.meetingId,
                      DateTime.parse(race.date).year,
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
                      child: Divider(),
                    ),
                  ],
                ),
              ),
      );
    }
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
  Future<List<DriverResult>> getRaceStandingsFromApi(Race race) async {
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: false) as bool;
    if (useOfficialDataSoure) {
      return await Formula1().getRaceStandings(race.meetingId, race.round);
    } else {
      return await ErgastApi().getRaceStandings(race.round);
    }
  }

  Future<List<DriverResult>> getRaceStandingsFromF1(String raceUrl) async {
    // TODO: prefer api instead of scraping?
    return await FormulaOneScraper().scrapeRaceResult(
      '',
      0,
      '',
      false,
      raceUrl: raceUrl,
    );
  }

  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    late Map savedData;
    late Race race;
    late int timeToRace;
    late DateTime raceFullDateParsed;
    String raceUrl = '';
    String scheduleLastSavedFormat = Hive.box('requests')
        .get('scheduleLastSavedFormat', defaultValue: 'ergast');

    if (widget.raceUrl != null) {
      timeToRace = -1;
      raceUrl = widget.raceUrl!;
    } else {
      race = widget.race!;
      savedData = Hive.box('requests')
          .get('race-${race.round}', defaultValue: {}) as Map;
      if (scheduleLastSavedFormat == 'ergast') {
        raceFullDateParsed = DateTime.parse("${race.date} ${race.raceHour}");
      } else {
        raceFullDateParsed = DateTime.parse(race.date);
      }
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
        update: _setState,
      );
    } else {
      String raceResultsLastSavedFormat = Hive.box('requests')
          .get('raceResultsLastSavedFormat', defaultValue: 'ergast');
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
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.watchOnYoutube,
                                textAlign: TextAlign.center,
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
                              tileColor:
                                  Theme.of(context).colorScheme.onSecondary,
                            ),
                            RaceDriversResultsList(snapshot.data!),
                          ],
                        ),
                      )
                    : const LoadingIndicatorUtil();
              })
          : FutureBuilder<List<DriverResult>>(
              future: getRaceStandingsFromApi(race),
              builder: (context, snapshot) => snapshot.hasError
                  ? savedData[raceResultsLastSavedFormat == 'ergast'
                              ? 'MRData'
                              : 'raceResultsRace'] !=
                          null
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                leading: FaIcon(
                                  FontAwesomeIcons.youtube,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .unavailableOffline,
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {},
                              ),
                              RaceDriversResultsList(
                                raceResultsLastSavedFormat == 'ergast'
                                    ? ErgastApi().formatRaceStandings(savedData)
                                    : Formula1().formatRaceStandings(savedData),
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
                            ),
                          ),
                        )
                  : snapshot.hasData
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const FaIcon(
                                  FontAwesomeIcons.youtube,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.watchOnYoutube,
                                  textAlign: TextAlign.center,
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
                                tileColor:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              RaceDriversResultsList(snapshot.data!),
                            ],
                          ),
                        )
                      : savedData[raceResultsLastSavedFormat == 'ergast'
                                  ? 'MRData'
                                  : 'raceResultsRace'] !=
                              null
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: FaIcon(
                                      FontAwesomeIcons.youtube,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(context)!
                                          .unavailableOffline,
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () async {},
                                  ),
                                  RaceDriversResultsList(
                                    raceResultsLastSavedFormat == 'ergast'
                                        ? ErgastApi()
                                            .formatRaceStandings(savedData)
                                        : Formula1()
                                            .formatRaceStandings(savedData),
                                  ),
                                ],
                              ),
                            )
                          : const LoadingIndicatorUtil(),
            );
    }
  }
}

class SprintResultsProvider extends StatefulWidget {
  final Race? race;
  final String? raceUrl;
  const SprintResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
  }) : super(key: key);

  @override
  State<SprintResultsProvider> createState() => _SprintResultsProviderState();
}

class _SprintResultsProviderState extends State<SprintResultsProvider> {
  Future<List<DriverResult>> getSprintStandings(
    Race race,
  ) async {
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: false) as bool;
    if (useOfficialDataSoure) {
      return await Formula1().getSprintStandings(race.meetingId, race.round);
    } else {
      return await ErgastApi().getSprintStandings(race.round);
    }
  }

  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return (widget.race?.sessionDates.isEmpty ?? true) &&
            (widget.raceUrl == null)
        ? Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.dataNotAvailable,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : FutureBuilder<List<DriverResult>>(
            future: widget.raceUrl != null
                ? FormulaOneScraper().scrapeRaceResult(
                    '',
                    0,
                    '',
                    false,
                    raceUrl: widget.raceUrl!,
                  )
                : getSprintStandings(
                    widget.race!,
                  ),
            builder: (context, snapshot) => snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.dataNotAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : snapshot.hasData
                    ? snapshot.data!.isEmpty
                        ? SessionCountdownTimer(
                            widget.race,
                            2,
                            AppLocalizations.of(context)!.sprint,
                            update: _setState,
                          )
                        : SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: ListTile(
                                    leading: const FaIcon(
                                      FontAwesomeIcons.youtube,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(context)!
                                          .watchOnYoutube,
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () async {
                                      var yt = YoutubeExplode();
                                      final raceYear =
                                          widget.race!.date.split('-')[0];
                                      final List<Video> searchResults =
                                          await yt.search.search(
                                        "Formula 1 Sprint Highlights ${widget.race!.raceName} $raceYear",
                                      );
                                      final Video bestVideoMatch =
                                          searchResults[0];
                                      await launchUrl(
                                        Uri.parse(
                                            "https://youtube.com/watch?v=${bestVideoMatch.id.value}"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    tileColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                RaceDriversResultsList(
                                  snapshot.data!,
                                ),
                              ],
                            ),
                          )
                    : const LoadingIndicatorUtil(),
          );
  }
}

class QualificationResultsProvider extends StatefulWidget {
  final Race? race;
  final String? raceUrl;
  final bool? hasSprint;
  final bool? isSprintQualifying;
  const QualificationResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
    this.hasSprint,
    this.isSprintQualifying,
  }) : super(key: key);

  @override
  State<QualificationResultsProvider> createState() =>
      _QualificationResultsProviderState();
}

class _QualificationResultsProviderState
    extends State<QualificationResultsProvider> {
  Future<List<DriverQualificationResult>> getQualificationStandings(
    Race race,
  ) async {
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: false) as bool;
    if (widget.isSprintQualifying ?? false) {
      return await Formula1().getSprintQualifyingStandings(race.meetingId);
    } else {
      if (useOfficialDataSoure) {
        return await Formula1().getQualificationStandings(race.meetingId);
      } else {
        return await ErgastApi().getQualificationStandings(
          race.round,
        );
      }
    }
  }

  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return (widget.race?.sessionDates.isEmpty ?? true) &&
            (widget.raceUrl == null)
        ? Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.dataNotAvailable,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : FutureBuilder<List<DriverQualificationResult>>(
            future: widget.raceUrl != null
                ? FormulaOneScraper().scrapeQualifyingResults(
                    '',
                    0,
                    '',
                    false,
                    qualifyingResultsUrl: widget.raceUrl!,
                    hasSprint: widget.hasSprint,
                  )
                : getQualificationStandings(
                    widget.race!,
                  ),
            builder: (context, snapshot) => snapshot.hasError
                ? (widget.race?.sessionDates.isNotEmpty ?? false) &&
                        ((widget.isSprintQualifying ?? false
                                ? widget.race?.sessionDates[1]
                                    .isAfter(DateTime.now())
                                : widget.race?.sessionDates.last.isAfter(
                                    DateTime.now(),
                                  )) ??
                            false)
                    ? SessionCountdownTimer(
                        widget.race,
                        widget.isSprintQualifying ?? false ? 1 : 3,
                        widget.isSprintQualifying ?? false
                            ? 'Sprint Qualifying'
                            : AppLocalizations.of(context)!.qualifyings,
                        update: _setState,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.dataNotAvailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                : snapshot.hasData
                    ? snapshot.data!.isNotEmpty
                        ? QualificationDriversResultsList(
                            snapshot.data!,
                            widget.race,
                            widget.raceUrl,
                            widget.isSprintQualifying,
                          )
                        : widget.isSprintQualifying ?? false
                            ? widget.race!.sessionDates[1]
                                    .isBefore(DateTime.now())
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .dataNotAvailable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SessionCountdownTimer(
                                    widget.race,
                                    1,
                                    'Sprint Qualifying',
                                    update: _setState,
                                  )
                            : widget.race!.sessionDates[3]
                                    .isBefore(DateTime.now())
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .dataNotAvailable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SessionCountdownTimer(
                                    widget.race,
                                    3,
                                    AppLocalizations.of(context)!.qualifyings,
                                    update: _setState,
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
    Color tC = TeamBackgroundColor().getTeamColor(teamId);
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
              child: BoxBoxVerticalDivider(
                color: finalTeamColors,
                thickness: 8,
                width: 25,
                indent: 7,
                endIndent: 7,
                border: BorderRadius.circular(2.75),
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
    bool shouldUseCountdown = Hive.box('settings')
        .get('shouldUseCountdown', defaultValue: true) as bool;
    bool shouldUse12HourClock = Hive.box('settings')
        .get('shouldUse12HourClock', defaultValue: false) as bool;
    String scheduleLastSavedFormat = Hive.box('requests')
        .get('scheduleLastSavedFormat', defaultValue: 'ergast');
    String languageCode = Localizations.localeOf(context).languageCode;

    late int timeToRace;
    late int days;
    late int hours;
    late int minutes;
    late int seconds;
    late DateTime raceFullDateParsed;

    Race race = widget.race!;
    if (widget.sessionIndex == 4) {
      if (scheduleLastSavedFormat == 'ergast') {
        raceFullDateParsed =
            DateTime.parse("${race.date} ${race.raceHour}").toLocal();
      } else {
        raceFullDateParsed = DateTime.parse(race.date);
      }
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
                ),
                colonsTextStyle: TextStyle(
                  fontSize: 23,
                ),
                descriptionTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
                  scheduleLastSavedFormat == 'ergast'
                      ? shouldUse12HourClock
                          ? '${DateFormat.MMMMd(languageCode).format(raceFullDateParsed.toLocal()).toUpperCase()} - ${DateFormat.jm().format(raceFullDateParsed.toLocal())}'
                          : '${DateFormat.MMMMd(languageCode).format(raceFullDateParsed.toLocal()).toUpperCase()} - ${DateFormat.Hm().format(raceFullDateParsed.toLocal())}'
                      : shouldUse12HourClock
                          ? '${DateFormat.MMMMd(languageCode).format(raceFullDateParsed).toUpperCase()} - ${DateFormat.jm().format(raceFullDateParsed)}'
                          : '${DateFormat.MMMMd(languageCode).format(raceFullDateParsed).toUpperCase()} - ${DateFormat.Hm().format(raceFullDateParsed)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
        !kIsWeb
            ? Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: TextButton.icon(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      AppLocalizations.of(context)!.addToCalendar,
                    ),
                  ),
                  icon: Icon(
                    Icons.add_alert_outlined,
                  ),
                  style: TextButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
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
                ),
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
                  textAlign: TextAlign.end,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Switch(
                    value: shouldUseCountdown,
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
              ),
              Expanded(
                flex: 6,
                child: Text(
                  AppLocalizations.of(context)!.countdown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
