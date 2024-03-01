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

import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class SessionScreen extends StatefulWidget {
  final String sessionFullName;
  final Session session;

  const SessionScreen(this.sessionFullName, this.session, {Key? key})
      : super(key: key);
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final List<ContentBlocker> contentBlockers = [];
  final CookieManager cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      final expiresDate =
          DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch;

      cookieManager.setCookie(
        url: WebUri('https://www.formula1.com/en/live-experience-webview.html'),
        name: "login-session",
        value:
            '{"data":{"subscriptionToken":"eyJraWQiOiIxIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJFeHRlcm5hbEF1dGhvcml6YXRpb25zQ29udGV4dERhdGEiOiIiLCJTdWJzY3JpcHRpb25TdGF0dXMiOiJpbmFjdGl2ZSIsIlN1YnNjcmliZXJJZCI6IjIwMjE0MjczMiIsIkZpcnN0TmFtZSI6IiIsIkxhc3ROYW1lIjoiIiwiZXhwIjoxNzA4ODYzMTU3LCJTZXNzaW9uSWQiOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpJVXpJMU5pSjkuZXlKemFTSTZJall3WVRsaFpEZzBMV1U1TTJRdE5EZ3daaTA0TUdRMkxXRm1NemMwT1RSbU1tVXlNaUlzSW1KMUlqb2lNVEF3TVRFaUxDSnBaQ0k2SWpNek56Y3haRGxrTFdJNVlqRXROREV3TnkwNE5UUXlMVFUxTWpjellqQXlaams1TlNJc0ltd2lPaUpsYmkxSFFpSXNJbVJqSWpvaU16WTBOQ0lzSW5RaU9pSXhJaXdpWVdWa0lqb2lNakF5TkMwd015MHdNbFF4TWpveE1qb3dPUzQ0TlRkYUlpd2laV1FpT2lJeU1ESTBMVEF6TFRBeVZERXlPakV5T2pBNUxqZzFOMW9pTENKalpXUWlPaUl5TURJMExUQXlMVEl5VkRFeU9qRXlPakE1TGprd05Wb2lMQ0p1WVcxbGFXUWlPaUl5TURJeE5ESTNNeklpTENKa2RDSTZJalFpTENKcGNDSTZJakU0TlM0eE1EY3VOVFl1TnpZaUxDSmpieUk2SWs1TVJDSXNJbU1pT2lKU1QwOVRSVTVFUVVGTUlpd2ljM1FpT2lKT1FpSXNJbkJqSWpvaU5EY3dNU0lzSW1semN5STZJbUZ6WTJWdVpHOXVMblIySWl3aVlYVmtJam9pWVhOalpXNWtiMjR1ZEhZaUxDSmxlSEFpT2pFM01Ea3pPREUxTWprc0ltNWlaaUk2TVRjd09EVXhOelV5T1gwLkd0OURFM2RoZlViMTEzeFZLZDF0WjlueXhLZ1NRV2xDNmpaN0RMaHNrUjAiLCJpYXQiOjE3MDg1MTc1NTcsIlN1YnNjcmliZWRQcm9kdWN0IjoiIiwianRpIjoiOGRkZmExYjUtNGNiYi00NmFlLTk3NzEtZGNiZDY1Mzc0YWIzIn0.Zo_FVoER16uHTHmfiAwhGmHRzK5Mri9frFrYzUz3Hzsgv99HI_SQfBMpB4q-j1s7s6egnxTZiGMuwenIRmFqHzxuVyexuH7UIt6nlsyn15MfkO2eU3vJynMSjBMj0qOTfNPxr9k4GWw8RJWZrVm8qCc5XIwluaT-RAyP0iLZSVUbafwBGYIHg5lkkmdsFrIvoBg0NU5RTxI7ItXgCte57vjueLL3NA3VOy6u9eZpJueASzQBBxd3dmFHYkgqF6ssLOfVKAKcEoOcotu1_A7pmCLYHBL9i9_AaHzasmXl6ekUK8U1XqxBXKwf8jqHBkBH50GMMs5D162B0dtjBlcmEw"}}',
        expiresDate: expiresDate,
        isSecure: false,
        path: '/',
        isHttpOnly: false,
        domain: '.formula1.com',
        sameSite: HTTPCookieSameSitePolicy.LAX,
      );
      ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
          unlessDomain: ["formula1.com"],
          resourceType: [
            ContentBlockerTriggerResourceType.SCRIPT,
            ContentBlockerTriggerResourceType.RAW,
          ],
        ),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.BLOCK,
        ),
      );
      List<String> selectors = [
        ".bs-sticky",
        ".bs-block",
        ".unic",
      ];
      contentBlockers.add(
        ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: ".*",
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: selectors.join(', '),
          ),
        ),
      );
    }
  }

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

    return widget.session.sessionsAbbreviation.startsWith('p')
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
                  ],
                ),
              )
            : widget.session.startTime.isBefore(DateTime.now()) &&
                    widget.session.endTime.isAfter(DateTime.now())
                ? Scaffold(
                    appBar: AppBar(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      title: Text(
                        widget.sessionFullName,
                      ),
                    ),
                    body: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(
                          "https://www.formula1.com/en/live-experience-webview.html",
                        ),
                        headers: {
                          'User-Agent':
                              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0',
                        },
                      ),
                      gestureRecognizers: {
                        Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer(),
                        ),
                        Factory<HorizontalDragGestureRecognizer>(
                          () => HorizontalDragGestureRecognizer(),
                        ),
                        Factory<ScaleGestureRecognizer>(
                          () => ScaleGestureRecognizer(),
                        ),
                      },
                    ),
                  )
                : FreePracticeScreen(
                    widget.sessionFullName,
                    int.parse(
                      widget.session.sessionsAbbreviation.substring(1),
                    ),
                    '',
                    0,
                    '',
                    raceUrl: widget.session.baseUrl.replaceAll(
                      'session-type',
                      'practice-${widget.session.sessionsAbbreviation.substring(1)}',
                    ),
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
                    ],
                  )
                : widget.session.state == 'completed' ||
                        widget.session.endTime.isBefore(DateTime.now())
                    ? widget.session.sessionsAbbreviation == 'r' ||
                            widget.session.sessionsAbbreviation == 's'
                        ? RaceResultsProvider(
                            raceUrl: widget.session.sessionsAbbreviation == 'r'
                                ? widget.session.baseUrl
                                    .replaceAll('session-type', 'race-result')
                                : widget.session.baseUrl.replaceAll(
                                    'session-type',
                                    'sprint-results',
                                  ),
                          )
                        : QualificationResultsProvider(
                            raceUrl: widget.session.baseUrl.replaceAll(
                              'session-type',
                              widget.session.sessionsAbbreviation == 'ss'
                                  ? 'sprint-shootout'
                                  : 'qualifying',
                            ),
                          )
                    : InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(
                            "https://www.formula1.com/en/live-experience-webview.html",
                          ),
                          headers: {
                            'User-Agent':
                                'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0',
                          },
                        ),
                        gestureRecognizers: {
                          Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer(),
                          ),
                          Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer(),
                          ),
                          Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer(),
                          ),
                        },
                      ),
          );
  }
}
