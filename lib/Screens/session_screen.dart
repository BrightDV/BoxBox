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

import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:boxbox/Screens/SessionWebView/unofficial_webview.dart';
import 'package:boxbox/Screens/SessionWebView/webview_manager.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SessionScreen extends StatefulWidget {
  final String sessionFullName;
  final Session session;
  final String meetingCountryName;
  final String meetingOfficialName;
  final String meetingId;

  const SessionScreen(
    this.sessionFullName,
    this.session,
    this.meetingCountryName,
    this.meetingOfficialName,
    this.meetingId, {
    Key? key,
  }) : super(key: key);
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  Widget build(BuildContext context) {
    bool useOfficialWebview = Hive.box('settings')
        .get('useOfficialWebview', defaultValue: true) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    int timeBetween(DateTime from, DateTime to) {
      return to.difference(from).inSeconds;
    }

    DateTime now = DateTime.now();

    int timeToRace = timeBetween(
      now,
      widget.session.startTime,
    );
    int days = (timeToRace / 60 / 60 / 24).round();
    int hours = (timeToRace / 60 / 60 - days * 24 - 1).round();
    int minutes = (timeToRace / 60 - days * 24 * 60 - hours * 60 + 60).round();
    int seconds =
        (timeToRace - days * 24 * 60 * 60 - hours * 60 * 60 - minutes * 60);

    return widget.session.sessionsAbbreviation.startsWith('p') ||
            widget.session.sessionsAbbreviation.startsWith('Free Practice')
        ? widget.session.state == 'upcoming' ||
                widget.session.startTime.isAfter(DateTime.now())
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  title: Text(
                    widget.sessionFullName,
                  ),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.sessionStartsIn,
                          style: TextStyle(
                            fontSize: 20,
                          ),
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
                      ),
                      colonsTextStyle: TextStyle(
                        fontSize: 23,
                      ),
                      descriptionTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                      ),
                      spacerWidth: 15,
                      daysDescription:
                          AppLocalizations.of(context)!.dayFirstLetter,
                      hoursDescription:
                          AppLocalizations.of(context)!.hourFirstLetter,
                      minutesDescription:
                          AppLocalizations.of(context)!.minuteAbbreviation,
                      secondsDescription:
                          AppLocalizations.of(context)!.secondAbbreviation,
                      onEnd: () {
                        setState(() {});
                      },
                    ),
                    !kIsWeb
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextButton.icon(
                              label: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
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
                                calendar.Event event = calendar.Event(
                                  title:
                                      '${widget.sessionFullName} - ${widget.meetingOfficialName}',
                                  location: widget.meetingCountryName,
                                  startDate: DateTime(
                                    widget.session.startTime.toLocal().year,
                                    widget.session.startTime.toLocal().month,
                                    widget.session.startTime.toLocal().day,
                                    widget.session.startTime.toLocal().hour,
                                    widget.session.startTime.toLocal().minute,
                                    widget.session.startTime.toLocal().second,
                                  ),
                                  endDate: DateTime(
                                    widget.session.startTime.toLocal().year,
                                    widget.session.startTime.toLocal().month,
                                    widget.session.startTime.toLocal().day,
                                    widget.session.startTime.toLocal().hour +
                                        (widget.session.sessionsAbbreviation ==
                                                'r'
                                            ? 3
                                            : 1),
                                    widget.session.startTime.toLocal().minute,
                                    widget.session.startTime.toLocal().second,
                                  ),
                                );
                                calendar.Add2Calendar.addEvent2Cal(event);
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            : widget.session.startTime.isBefore(DateTime.now()) &&
                    widget.session.endTime.isAfter(DateTime.now())
                ? championship == 'Formula 1'
                    ? useOfficialWebview
                        ? WebViewManagerScreen(widget.sessionFullName)
                        : Scaffold(
                            appBar: AppBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              title: Text(
                                widget.sessionFullName,
                              ),
                            ),
                            body: UnofficialWebviewScreen(),
                          )
                    : Scaffold(
                        appBar: AppBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          title: Text(
                            widget.sessionFullName,
                          ),
                        ),
                        body: UnofficialWebviewScreen(),
                      )
                : FreePracticeScreen(
                    widget.sessionFullName,
                    int.parse(
                      championship == 'Formula 1'
                          ? widget.session.sessionsAbbreviation.substring(1)
                          : widget.session.sessionsAbbreviation.split(' ').last,
                    ),
                    '',
                    championship == 'Formula 1' ? '' : widget.meetingId,
                    0,
                    '',
                    raceUrl: championship == 'Formula 1'
                        ? widget.session.baseUrl.replaceAll(
                            'session-type',
                            'practice-${widget.session.sessionsAbbreviation.substring(1)}',
                          )
                        : widget.session.baseUrl,
                    sessionId: championship == 'Formula 1'
                        ? null
                        : widget.session.baseUrl,
                  )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(
                widget.sessionFullName,
              ),
            ),
            body: widget.session.state == 'upcoming' ||
                    widget.session.startTime.isAfter(DateTime.now())
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.sessionStartsIn,
                            style: TextStyle(
                              fontSize: 20,
                            ),
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
                        ),
                        colonsTextStyle: TextStyle(
                          fontSize: 23,
                        ),
                        descriptionTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                        ),
                        spacerWidth: 15,
                        daysDescription:
                            AppLocalizations.of(context)!.dayFirstLetter,
                        hoursDescription:
                            AppLocalizations.of(context)!.hourFirstLetter,
                        minutesDescription:
                            AppLocalizations.of(context)!.minuteAbbreviation,
                        secondsDescription:
                            AppLocalizations.of(context)!.secondAbbreviation,
                        onEnd: () {
                          setState(() {});
                        },
                      ),
                      !kIsWeb
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: TextButton.icon(
                                label: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: Text(
                                    AppLocalizations.of(context)!.addToCalendar,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add_alert_outlined,
                                ),
                                style: TextButton.styleFrom(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                onPressed: () {
                                  calendar.Event event = calendar.Event(
                                    title:
                                        '${widget.sessionFullName} - ${widget.meetingOfficialName}',
                                    location: widget.meetingCountryName,
                                    startDate: DateTime(
                                      widget.session.startTime.toLocal().year,
                                      widget.session.startTime.toLocal().month,
                                      widget.session.startTime.toLocal().day,
                                      widget.session.startTime.toLocal().hour,
                                      widget.session.startTime.toLocal().minute,
                                      widget.session.startTime.toLocal().second,
                                    ),
                                    endDate: DateTime(
                                      widget.session.startTime.toLocal().year,
                                      widget.session.startTime.toLocal().month,
                                      widget.session.startTime.toLocal().day,
                                      widget.session.startTime.toLocal().hour +
                                          (widget.session
                                                      .sessionsAbbreviation ==
                                                  'r'
                                              ? 3
                                              : 1),
                                      widget.session.startTime.toLocal().minute,
                                      widget.session.startTime.toLocal().second,
                                    ),
                                  );
                                  calendar.Add2Calendar.addEvent2Cal(event);
                                },
                              ),
                            )
                          : Container(),
                    ],
                  )
                : widget.session.state == 'completed' ||
                        widget.session.endTime.isBefore(DateTime.now())
                    ? widget.session.sessionsAbbreviation == 'r' ||
                            widget.session.sessionsAbbreviation == 's' ||
                            widget.session.sessionsAbbreviation == 'Race'
                        ? RaceResultsProvider(
                            raceUrl: championship == 'Formula 1'
                                ? widget.session.sessionsAbbreviation == 'r'
                                    ? 'race'
                                    : 'sprint-results'
                                : widget.session.baseUrl,
                            raceId: widget.meetingId,
                          )
                        : championship == 'Formula 1'
                            ? QualificationResultsProvider(
                                raceUrl: championship == 'Formula 1'
                                    ? widget.session.sessionsAbbreviation ==
                                            'ss'
                                        ? 'sprint-qualifying'
                                        : 'qualifying'
                                    : widget.session.baseUrl,
                                sessionId: widget.meetingId,
                                hasSprint:
                                    widget.session.sessionsAbbreviation == 'ss'
                                        ? true
                                        : false,
                                isSprintQualifying:
                                    widget.session.sessionsAbbreviation == 'ss'
                                        ? true
                                        : false,
                              )
                            : FreePracticeResultsProvider(
                                widget.sessionFullName,
                                10,
                                '',
                                widget.meetingId,
                                DateTime.now().year,
                                widget.meetingOfficialName,
                                sessionId: widget.session.baseUrl,
                              )
                    : useOfficialWebview && championship == 'Formula 1'
                        ? WebViewManagerScreen(widget.sessionFullName)
                        : UnofficialWebviewScreen(),
          );
  }
}
