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

import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/providers/results/format.dart';
import 'package:boxbox/providers/results/requests.dart';
import 'package:boxbox/providers/results/ui.dart';
import 'package:boxbox/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
    String scheduleLastSavedFormat =
        ResultsRequestsProvider().getScheduleLastSavedFormat();

    if (widget.raceUrl != null) {
      timeToRace = -1;
      raceUrl = widget.raceUrl!;
    } else {
      race = widget.race!;
      savedData = ResultsRequestsProvider().getSavedRaceResultsData(race);
      raceFullDateParsed = ResultsFormatProvider().formatRaceDate(
        race,
        scheduleLastSavedFormat,
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
        ResultsRequestsProvider().getRaceSessionIndex(race),
        AppLocalizations.of(context)!.race,
        update: _setState,
      );
    } else {
      String raceResultsLastSavedFormat =
          ResultsRequestsProvider().getRaceResultsLastSavedFormat();
      return raceUrl != ''
          ? FutureBuilder<List<DriverResult>>(
              future: ResultsRequestsProvider().getRaceStandingsFromApi(
                meetingId: widget.raceId,
                raceUrl: raceUrl,
              ),
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
              future: ResultsRequestsProvider().getRaceStandingsFromApi(
                race: race,
              ),
              builder: (context, snapshot) => snapshot.hasError
                  ? ResultsUIProvider().getRaceResultsWidget(
                      snapshot,
                      context,
                      widget.isFromRaceHub,
                      raceResultsLastSavedFormat,
                      savedData,
                      true,
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
                      : ResultsUIProvider().getRaceResultsWidget(
                          snapshot,
                          context,
                          widget.isFromRaceHub,
                          raceResultsLastSavedFormat,
                          savedData,
                          false,
                        ),
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
        : FutureBuilder<List<DriverResult>>(
            future: widget.raceUrl != null
                ? ResultsRequestsProvider().getSprintStandings(
                    meetingId: widget.raceUrl!.split('/')[7],
                  )
                : ResultsRequestsProvider().getSprintStandings(
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
                                        "$championship Sprint Highlights ${widget.race!.raceName} $raceYear",
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
        : FutureBuilder<List>(
            future: widget.raceUrl != null
                ? ResultsRequestsProvider().getQualificationStandings(
                    widget.hasSprint,
                    widget.isSprintQualifying,
                    widget.sessionId,
                    meetingId: widget.raceUrl!.startsWith('http')
                        ? widget.raceUrl!.split('/')[7]
                        : widget.sessionId,
                  )
                : ResultsRequestsProvider().getQualificationStandings(
                    widget.hasSprint,
                    widget.isSprintQualifying,
                    widget.sessionId,
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
                        ResultsRequestsProvider().getQualifyingSessionIndex(
                          widget.isSprintQualifying,
                          widget.race,
                        ),
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
                        ? ResultsUIProvider().getQualificationResultsWidget(
                            snapshot,
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
                            : ResultsRequestsProvider()
                                    .checkIfQualificationIsFinished(
                                widget.race!,
                              )
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
                                    ResultsRequestsProvider()
                                        .getQualifyingSessionIndex(
                                      widget.hasSprint,
                                      widget.race,
                                    ),
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
      future: ResultsRequestsProvider().getStartingGrid(meetingId),
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
    String scheduleLastSavedFormat =
        ResultsRequestsProvider().getScheduleLastSavedFormat();
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
