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

import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/formulae.dart';
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
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaceDetailsScreen extends StatelessWidget {
  final Race race;
  final bool hasSprint;
  final int? tab;
  final bool isFromRaceHub;
  final List? sessions;

  const RaceDetailsScreen(
    this.race,
    this.hasSprint, {
    Key? key,
    this.tab,
    this.isFromRaceHub = false,
    this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: race.isPreSeasonTesting ?? false // only f1
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
                        race,
                      ),
                      title: Text(
                        race.country,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ];
              },
              body: FreePracticesResultsProvider(
                race,
                false,
                isFromRaceHub: isFromRaceHub,
              ),
            )
          : DefaultTabController(
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
                            background: RaceImageProvider(
                              race,
                            ),
                            title: Text(
                              race.country,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
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
                    body: hasSprint // only f1
                        ? TabBarView(
                            children: [
                              FreePracticesResultsProvider(
                                race,
                                hasSprint,
                                isFromRaceHub: isFromRaceHub,
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
                                              child:
                                                  QualificationResultsProvider(
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
                                              child:
                                                  QualificationResultsProvider(
                                                race: race,
                                                hasSprint: hasSprint,
                                              ),
                                            ),
                                          ),
                                          MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: SafeArea(
                                              child: RaceResultsProvider(
                                                race: race,
                                              ),
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
                              FreePracticesResultsProvider(
                                race,
                                hasSprint,
                                isFromRaceHub: isFromRaceHub,
                                sessionsId: sessions != null
                                    ? sessions!.length == 4
                                        ? sessions!.sublist(0, 2)
                                        : sessions!.sublist(0, 1)
                                    : [],
                              ),
                              MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: SafeArea(
                                  child: QualificationResultsProvider(
                                    race: race,
                                    hasSprint: hasSprint,
                                    sessionId: sessions != null
                                        ? sessions!.length == 3
                                            ? sessions![1]
                                            : sessions![2]
                                        : null,
                                  ),
                                ),
                              ),
                              MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: RaceResultsProvider(
                                  race: race,
                                  sessionId: sessions?.last,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
    );
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

class RaceDetailsFromIdScreen extends StatelessWidget {
  final String meetingId;
  const RaceDetailsFromIdScreen(this.meetingId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: EventTracker().getCircuitDetails(
        meetingId,
        isFromRaceHub: true,
      ),
      builder: (context, snapshot) => snapshot.hasError
          ? Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: RequestErrorWidget(snapshot.error.toString()),
            )
          : snapshot.hasData
              ? RaceDetailsScreen(
                  snapshot.data!['raceCustomBBParameter'],
                  snapshot.data!['meetingContext']['timetables'][2]
                          ['session'] ==
                      's',
                )
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  body: LoadingIndicatorUtil(),
                ),
    );
  }
}

class FreePracticesResultsProvider extends StatefulWidget {
  final Race race;
  final bool hasSprint;
  final bool isFromRaceHub;
  final List? sessionsId;
  const FreePracticesResultsProvider(
    this.race,
    this.hasSprint, {
    Key? key,
    this.isFromRaceHub = false,
    this.sessionsId,
  }) : super(key: key);

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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String scheduleLastSavedFormat = '';
    if (championship == 'Formula 1') {
      scheduleLastSavedFormat = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    }

    final Race race = widget.race;
    final bool hasSprint = widget.hasSprint;

    final List<String> sessionsTitle = [
      AppLocalizations.of(context)!.freePracticeOne,
      AppLocalizations.of(context)!.freePracticeTwo,
      AppLocalizations.of(context)!.freePracticeThree,
    ];
    int maxSession = 0;

    if (championship == 'Formula 1') {
      if (scheduleLastSavedFormat == 'ergast' || widget.isFromRaceHub) {
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
                  ? race.sessionDates
                          .isEmpty // TODO: update when Ergast not down
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
                          itemBuilder: (context, index) =>
                              snapshot.data! > index
                                  ? ListTile(
                                      title: Text(
                                        sessionsTitle[index],
                                        textAlign: TextAlign.center,
                                      ),
                                      onTap: () => context.pushNamed(
                                        'practice',
                                        pathParameters: {
                                          'sessionIndex':
                                              (index + 1).toString(),
                                          'meetingId': race.meetingId,
                                        },
                                        extra: {
                                          'sessionTitle': sessionsTitle[index],
                                          'sessionIndex': index + 1,
                                          'circuitId': race.circuitId,
                                          'meetingId': race.meetingId,
                                          'raceYear': int.parse(
                                            race.date.split('-')[2],
                                          ),
                                          'raceName': race.raceName,
                                        },
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
        for (var session in race.sessionStates!) {
          if (session == "completed") {
            maxSession++;
          }
        }
      }
    } else {
      for (var i = 0; i < widget.sessionsId!.length; i++) {
        if (race.sessionStates![i] == "FINISHED") {
          maxSession++;
        }
      }
    }
    return ListView.builder(
      itemCount: championship == 'Formula 1'
          ? hasSprint
              ? 1
              : 3
          : widget.sessionsId?.length,
      itemBuilder: (context, index) => maxSession > index
          ? ListTile(
              title: Text(
                championship == 'Formula E' &&
                        (widget.sessionsId?.length ?? 0) == 1
                    ? sessionsTitle[2]
                    : sessionsTitle[index],
                textAlign: TextAlign.center,
              ),
              onTap: () => context.pushNamed(
                'practice',
                pathParameters: {
                  'sessionIndex': (index + 1).toString(),
                  'meetingId': race.meetingId,
                },
                extra: {
                  'sessionTitle': championship == 'Formula E' &&
                          (widget.sessionsId?.length ?? 0) == 1
                      ? sessionsTitle[2]
                      : sessionsTitle[index],
                  'sessionIndex': index + 1,
                  'circuitId': race.circuitId,
                  'meetingId': race.meetingId,
                  'raceYear': DateTime.parse(race.date).year,
                  'raceName': race.raceName,
                  'sessionId': widget.sessionsId != null
                      ? widget.sessionsId!.isNotEmpty
                          ? widget.sessionsId![index]
                          : null
                      : null,
                },
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

class RaceResultsProvider extends StatefulWidget {
  final Race? race;
  final String? raceUrl;
  final bool isFromRaceHub;
  final String? sessionId;
  final String? raceId;
  const RaceResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
    this.isFromRaceHub = false,
    this.sessionId,
    this.raceId,
  }) : super(key: key);
  @override
  State<RaceResultsProvider> createState() => _RaceResultsProviderState();
}

class _RaceResultsProviderState extends State<RaceResultsProvider> {
  Future<List<DriverResult>> getRaceStandingsFromApi({
    Race? race,
    String? meetingId,
    String? raceUrl,
  }) async {
    if (meetingId != null && raceUrl != null) {
      // starting to do like official api devs...
      if (raceUrl == 'race') {
        return await Formula1().getRaceStandings(meetingId, '66666');
      } else {
        return await Formula1().getSprintStandings(meetingId);
      }
    } else {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      String championship = Hive.box('settings')
          .get('championship', defaultValue: 'Formula 1') as String;
      if (championship == 'Formula 1') {
        if (useOfficialDataSoure && !widget.isFromRaceHub) {
          return await Formula1().getRaceStandings(race!.meetingId, race.round);
        } else {
          return await ErgastApi().getRaceStandings(race!.round);
        }
      } else {
        return await FormulaE().getRaceStandings(
          race!.meetingId,
          widget.sessionId!,
        );
      }
    }
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

  Future<List<DriverResult>> getRaceStandingsFromFE(
      String raceId, String sessionId) async {
    return await FormulaE().getRaceStandings(raceId, sessionId);
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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String scheduleLastSavedFormat = '';
    if (championship == 'Formula 1') {
      scheduleLastSavedFormat = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    }

    if (widget.raceUrl != null) {
      timeToRace = -1;
      raceUrl = widget.raceUrl!;
    } else {
      race = widget.race!;
      if (championship == 'Formula 1') {
        savedData = Hive.box('requests')
            .get('f1Race-${race.round}', defaultValue: {}) as Map;
      } else {
        savedData = Hive.box('requests')
            .get('feRace-${race.meetingId}', defaultValue: {}) as Map;
      }
      if (championship == 'Formula 1') {
        if (scheduleLastSavedFormat == 'ergast' || widget.isFromRaceHub) {
          raceFullDateParsed = DateTime.parse("${race.date} ${race.raceHour}");
        } else {
          raceFullDateParsed = DateTime.parse(race.date);
        }
      } else {
        if (race.raceHour != '') {
          raceFullDateParsed = DateTime.parse("${race.date} ${race.raceHour}");
        } else {
          raceFullDateParsed = DateTime.parse(race.date);
        }
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
        championship == 'Formula 1' ? 4 : race.sessionDates.length - 1,
        AppLocalizations.of(context)!.race,
        update: _setState,
      );
    } else {
      String raceResultsLastSavedFormat = '';
      if (championship == 'Formula 1') {
        raceResultsLastSavedFormat = Hive.box('requests')
            .get('f1RaceResultsLastSavedFormat', defaultValue: 'ergast');
      }
      return raceUrl != ''
          ? FutureBuilder<List<DriverResult>>(
              future: championship == 'Formula 1'
                  ? getRaceStandingsFromApi(
                      meetingId: raceUrl.startsWith('http')
                          ? raceUrl.split('/')[7]
                          : widget.raceId,
                      raceUrl: raceUrl,
                    )
                  : getRaceStandingsFromFE(widget.raceId!, raceUrl),
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
                                AppLocalizations.of(context)!
                                    .watchHighlightsOnYoutube,
                                textAlign: TextAlign.center,
                              ),
                              onTap: () async {
                                var yt = YoutubeExplode();
                                final raceYear = widget.raceUrl != null
                                    ? DateTime.now()
                                    : race.date.split('-')[0];
                                final List<Video> searchResults =
                                    await yt.search.search(
                                  "$championship Race Highlights ${race.raceName} $raceYear",
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
              future: getRaceStandingsFromApi(race: race),
              builder: (context, snapshot) => snapshot.hasError
                  ? savedData[championship == 'Formula 1'
                              ? raceResultsLastSavedFormat == 'ergast' ||
                                      widget.isFromRaceHub
                                  ? 'MRData'
                                  : 'raceResultsRace'
                              : 'results'] !=
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
                                championship == 'Formula 1'
                                    ? raceResultsLastSavedFormat == 'ergast' ||
                                            widget.isFromRaceHub
                                        ? ErgastApi()
                                            .formatRaceStandings(savedData)
                                        : Formula1()
                                            .formatRaceStandings(savedData)
                                    : FormulaE().formatRaceStandings(savedData),
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
                                  AppLocalizations.of(context)!
                                      .watchHighlightsOnYoutube,
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {
                                  var yt = YoutubeExplode();
                                  final raceYear = widget.raceUrl != null
                                      ? DateTime.now()
                                      : race.date.split('-')[0];
                                  final List<Video> searchResults =
                                      await yt.search.search(
                                    "$championship Race Highlights ${race.raceName} $raceYear",
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
                      : savedData[championship == 'Formula 1'
                                  ? raceResultsLastSavedFormat == 'ergast' ||
                                          widget.isFromRaceHub
                                      ? 'MRData'
                                      : 'raceResultsRace'
                                  : 'results'] !=
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
                                    championship == 'Formula 1'
                                        ? raceResultsLastSavedFormat ==
                                                    'ergast' ||
                                                widget.isFromRaceHub
                                            ? ErgastApi()
                                                .formatRaceStandings(savedData)
                                            : Formula1()
                                                .formatRaceStandings(savedData)
                                        : FormulaE()
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
  Future<List<DriverResult>> getSprintStandings({
    Race? race,
    String? meetingId,
  }) async {
    if (meetingId != null) {
      // same as race results...
      return await Formula1().getSprintStandings(meetingId);
    } else {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (useOfficialDataSoure) {
        return await Formula1().getSprintStandings(race!.meetingId);
      } else {
        return await ErgastApi().getSprintStandings(race!.round);
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
        : FutureBuilder<List<DriverResult>>(
            future: widget.raceUrl != null
                ? getSprintStandings(
                    meetingId: widget.raceUrl!.split('/')[7],
                  )
                : getSprintStandings(
                    race: widget.race!,
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
                                          .watchHighlightsOnYoutube,
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
  final String? sessionId;
  const QualificationResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
    this.hasSprint,
    this.isSprintQualifying,
    this.sessionId,
  }) : super(key: key);

  @override
  State<QualificationResultsProvider> createState() =>
      _QualificationResultsProviderState();
}

class _QualificationResultsProviderState
    extends State<QualificationResultsProvider> {
  Future<List> getQualificationStandings({
    Race? race,
    String? meetingId,
  }) async {
    if (meetingId != null) {
      if (widget.hasSprint ?? false) {
        return await Formula1().getSprintQualifyingStandings(meetingId);
      } else {
        return await Formula1().getQualificationStandings(meetingId);
      }
    } else {
      String championship = Hive.box('settings')
          .get('championship', defaultValue: 'Formula 1') as String;
      if (championship == 'Formula 1') {
        bool useOfficialDataSoure = Hive.box('settings')
            .get('useOfficialDataSoure', defaultValue: true) as bool;
        if (widget.isSprintQualifying ?? false) {
          return await Formula1().getSprintQualifyingStandings(race!.meetingId);
        } else {
          if (useOfficialDataSoure) {
            return await Formula1().getQualificationStandings(race!.meetingId);
          } else {
            return await ErgastApi().getQualificationStandings(
              race!.meetingId,
            );
          }
        }
      }
      return await FormulaE().getQualificationStandings(
        widget.race!.meetingId,
        widget.sessionId!,
      );
    }
  }

  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
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
        : FutureBuilder<List>(
            future: widget.raceUrl != null
                ? getQualificationStandings(
                    meetingId: widget.raceUrl!.startsWith('http')
                        ? widget.raceUrl!.split('/')[7]
                        : widget.sessionId,
                  )
                : getQualificationStandings(
                    race: widget.race!,
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
                        championship == 'Formula 1'
                            ? widget.isSprintQualifying ?? false
                                ? 1
                                : 3
                            : 2,
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
                        ? championship == 'Formula 1'
                            ? QualificationDriversResultsList(
                                snapshot.data!,
                                widget.race,
                                widget.raceUrl,
                                widget.isSprintQualifying,
                              )
                            : FreePracticeResultsList(
                                snapshot.data!,
                                DateTime.parse(widget.race!.date).year,
                                widget.race!.raceName,
                                10,
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
                            : (championship == 'Formula 1'
                                    ? widget.race!.sessionDates[3]
                                        .isBefore(DateTime.now())
                                    : widget
                                        .race!
                                        .sessionDates[
                                            widget.race!.sessionDates.length -
                                                2]
                                        .isBefore(DateTime.now()))
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
                                    championship == 'Formula 1'
                                        ? 3
                                        : widget.race!.sessionDates.length - 2,
                                    AppLocalizations.of(context)!.qualifyings,
                                    update: _setState,
                                  )
                    : const LoadingIndicatorUtil(),
          );
  }
}

class StartingGridProvider extends StatelessWidget {
  final String meetingId;
  const StartingGridProvider(
    this.meetingId, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<List>(
      future: Formula1().getStartingGrid(
        meetingId,
      ), //FormulaOneScraper().scrapeStartingGrid(raceUrl),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data![1] != ''
                      ? snapshot.data![0].length + 2
                      : snapshot.data![0].length + 1,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) => index == 0
                      ? Container(
                          color: Theme.of(context).colorScheme.onSecondary,
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    AppLocalizations.of(context)!.time,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : (index == snapshot.data![0].length + 1) &&
                              (snapshot.data![1] != '')
                          ? ListTile(
                              title: Text(
                                snapshot.data![1],
                                textAlign: TextAlign.justify,
                                style: TextStyle(fontSize: 15),
                              ),
                              tileColor: useDarkMode
                                  ? HSLColor.fromColor(
                                      Theme.of(context).colorScheme.onSecondary,
                                    ).withLightness(0.18).toColor()
                                  : HSLColor.fromColor(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ).withLightness(0.82).toColor(),
                            )
                          : StartingGridPositionItem(
                              snapshot.data![0][index - 1],
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
  const StartingGridPositionItem(
    this.startingGridPosition,
    this.index, {
    super.key,
  });

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColor(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(startingGridPosition.team);
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return Container(
      color: index % 2 == 1
          ? useDarkMode
              ? HSLColor.fromColor(
                  Theme.of(context).colorScheme.onSecondary,
                ).withLightness(0.26).toColor()
              : HSLColor.fromColor(
                  Theme.of(context).colorScheme.onPrimary,
                ).withLightness(0.88).toColor()
          : useDarkMode
              ? HSLColor.fromColor(
                  Theme.of(context).colorScheme.onSecondary,
                ).withLightness(0.18).toColor()
              : HSLColor.fromColor(
                  Theme.of(context).colorScheme.onPrimary,
                ).withLightness(0.82).toColor(),
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
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: BoxBoxVerticalDivider(
                color: startingGridPosition.teamColor != null
                    ? Color(
                        int.parse(
                          'FF${startingGridPosition.teamColor}',
                          radix: 16,
                        ),
                      )
                    : finalTeamColors,
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
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Text(
                  startingGridPosition.teamFullName,
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
                    color: index % 2 == 1
                        ? useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.31).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.84).toColor()
                        : useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.23).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.78).toColor(),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      startingGridPosition.time,
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
  final bool isFromRaceHub;
  const SessionCountdownTimer(
    this.race,
    this.sessionIndex,
    this.sessionName, {
    super.key,
    this.update,
    this.isFromRaceHub = false,
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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String scheduleLastSavedFormat = '';
    if (championship == 'Formula 1') {
      scheduleLastSavedFormat = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    }
    String languageCode = Localizations.localeOf(context).languageCode;

    late int timeToRace;
    late int days;
    late int hours;
    late int minutes;
    late int seconds;
    late DateTime raceFullDateParsed;

    Race race = widget.race!;
    if (widget.sessionIndex == 4) {
      if (scheduleLastSavedFormat == 'ergast' || widget.isFromRaceHub) {
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

    // time to race in seconds
    timeToRace = timeBetween(
      DateTime.now(),
      raceFullDateParsed,
    );
    days = (timeToRace / 60 / 60 / 24).round();
    hours = (timeToRace / 60 / 60 - days * 24 - 1).round();
    minutes = (timeToRace / 60 - days * 24 * 60 - hours * 60 + 60).round();
    seconds = timeToRace - days * 24 * 60 * 60 - hours * 60 * 60 - minutes * 60;

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
                padding: const EdgeInsets.only(top: 18, bottom: 19),
                child: Text(
                  scheduleLastSavedFormat == 'ergast' || widget.isFromRaceHub
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
                  onPressed: () async {
                    a2c.Event event = a2c.Event(
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
                    await a2c.Add2Calendar.addEvent2Cal(event);
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
