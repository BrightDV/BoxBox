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

import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/providers/event_tracker/format.dart';
import 'package:boxbox/providers/event_tracker/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

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
        ? widget.session.startTime.isAfter(DateTime.now())
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
                        widget.session.endTime.isAfter(DateTime.now()) ||
                    widget.session.isRunning
                ? EventTrackerUIProvider().getRaceHubFreePracticesWebview(
                    context,
                    widget.sessionFullName,
                  )
                : FreePracticeScreen(
                    widget.sessionFullName,
                    EventTrackerFormatProvider().formatFreePracticeSessionIndex(
                      widget.session,
                    ),
                    '',
                    widget.meetingId,
                    0,
                    '',
                    raceUrl: EventTrackerFormatProvider()
                        .formatFreePracticeSessionUrl(
                      widget.session,
                    ),
                    sessionId: EventTrackerFormatProvider()
                        .formatFreePracticeSessionId(
                      widget.session,
                    ),
                  )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(
                widget.sessionFullName,
              ),
            ),
            body: widget.session.startTime.isAfter(DateTime.now())
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
                            raceUrl: EventTrackerFormatProvider()
                                .formatRaceSessionUrl(
                              widget.session,
                            ),
                            raceId: widget.meetingId,
                          )
                        : EventTrackerUIProvider().getRaceHubResultsProvider(
                            widget.session,
                            widget.meetingId,
                            widget.sessionFullName,
                            widget.meetingOfficialName,
                          )
                    : EventTrackerUIProvider().getRaceHubWebview(
                        widget.sessionFullName,
                      ),
          );
  }
}
