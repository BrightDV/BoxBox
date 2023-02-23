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

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaceDetailsScreen extends StatefulWidget {
  final Race race;
  final int? tab;

  const RaceDetailsScreen(this.race, {Key? key, this.tab}) : super(key: key);

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
      body: FutureBuilder<bool>(
        future: ErgastApi().hasSprintQualifyings(widget.race.round),
        builder: (context, snapshot) => snapshot.hasData ||
                snapshot.error.toString() == 'XMLHttpRequest error.' ||
                snapshot.error.toString() == "Failed host lookup: 'ergast.com'"
            ? DefaultTabController(
                length: snapshot.data ?? false ? 4 : 3,
                initialIndex: widget.tab != null
                    ? widget.tab == 10
                        ? snapshot.data ?? false
                            ? 3
                            : 2
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
                                tabs: snapshot.data ?? false
                                    ? <Widget>[
                                        Tab(
                                          text: AppLocalizations.of(context)!
                                              .freePracticeFirstLetter,
                                        ),
                                        Tab(
                                          text: AppLocalizations.of(context)!
                                              .qualifyingsFirstLetter,
                                        ),
                                        Tab(
                                          text: AppLocalizations.of(context)!
                                              .sprintFirstLetter
                                              .toUpperCase(),
                                        ),
                                        Tab(
                                          text: AppLocalizations.of(context)!
                                              .raceFirstLetter
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
                      body: snapshot.data ?? false
                          ? TabBarView(
                              children: [
                                FreePracticesResultsProvider(race),
                                SingleChildScrollView(
                                  child: QualificationResultsProvider(
                                    race: race,
                                  ),
                                ),
                                SprintResultsProvider(race: race),
                                RaceResultsProvider(race: race),
                              ],
                            )
                          : TabBarView(
                              children: [
                                FreePracticesResultsProvider(race),
                                SingleChildScrollView(
                                  child: QualificationResultsProvider(
                                    race: race,
                                  ),
                                ),
                                RaceResultsProvider(race: race),
                              ],
                            ),
                    );
                  },
                ),
              )
            : snapshot.hasError
                ? RequestErrorWidget(snapshot.error.toString())
                : const LoadingIndicatorUtil(),
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

class FreePracticesResultsProvider extends StatelessWidget {
  final Race race;
  const FreePracticesResultsProvider(this.race, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  itemCount: 3,
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
                          padding: const EdgeInsets.only(top: 100),
                          child: SessionCountdownTimer(race, index),
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
      return SessionCountdownTimer(race, 4);
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
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
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
            );
          }
          return snapshot.hasData
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
              : const LoadingIndicatorUtil();
        },
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
  const QualificationResultsProvider({
    Key? key,
    this.race,
    this.raceUrl,
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
              ? SessionCountdownTimer(race, 3)
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
                                "Formula 1 Qualification Highlights ${race!.raceName} $raceYear",
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
                  : SessionCountdownTimer(race, 3)
              : const LoadingIndicatorUtil(),
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
  const SessionCountdownTimer(this.race, this.sessionIndex, {super.key});

  @override
  State<SessionCountdownTimer> createState() => _SessionCountdownTimerState();
}

class _SessionCountdownTimerState extends State<SessionCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
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
                ? AppLocalizations.of(context)!.raceStartsIn
                : AppLocalizations.of(context)!.sessionStartsIn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        TimerCountdown(
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
          minutesDescription: AppLocalizations.of(context)!.minuteAbbreviation,
          secondsDescription: AppLocalizations.of(context)!.secondAbbreviation,
          onEnd: () {
            setState(() {});
          },
        ),
      ],
    );
  }
}
