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
 * Copyright (c) 2022, BrightDV
 */

import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/Screens/session_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';

class GrandPrixRunningScreen extends StatefulWidget {
  final Event event;
  const GrandPrixRunningScreen(this.event);
  _GrandPrixRunningScreenState createState() => _GrandPrixRunningScreenState();
}

class _GrandPrixRunningScreenState extends State<GrandPrixRunningScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: Marquee(
            text: widget.event.meetingOfficialName,
            pauseAfterRound: Duration(seconds: 1),
            startAfter: Duration(seconds: 1),
            velocity: 85,
            blankSpace: 100,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: ListView(
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/${widget.event.meetingName}.jpg.transform/12col/image.jpg',
            placeholder: (context, url) => LoadingIndicatorUtil(),
            errorWidget: (context, url, error) => Icon(
              Icons.error_outlined,
            ),
            fadeOutDuration: Duration(seconds: 1),
            fadeInDuration: Duration(seconds: 1),
            fit: BoxFit.scaleDown,
          ),
          SessionItem(
            widget.event.session5,
            widget.event.raceId,
            widget.event.meetingCountryName,
          ),
          SessionItem(
            widget.event.session4,
            widget.event.raceId,
            widget.event.meetingCountryName,
          ),
          SessionItem(
            widget.event.session3,
            widget.event.raceId,
            widget.event.meetingCountryName,
          ),
          SessionItem(
            widget.event.session2,
            widget.event.raceId,
            widget.event.meetingCountryName,
          ),
          SessionItem(
            widget.event.session1,
            widget.event.raceId,
            widget.event.meetingCountryName,
          ),
        ],
      ),
    );
  }
}

class SessionItem extends StatefulWidget {
  final Session session;
  final String raceId;
  final String meetingCountryName;

  const SessionItem(
    this.session,
    this.raceId,
    this.meetingCountryName,
  );
  _SessionItemState createState() => _SessionItemState();
}

class _SessionItemState extends State<SessionItem> {
  @override
  Widget build(BuildContext context) {
    Map sessionsAbbreviations = {
      'r': AppLocalizations.of(context)!.race,
      'q': AppLocalizations.of(context)!.qualifyings,
      's': AppLocalizations.of(context)!.sprint,
      'sq': AppLocalizations.of(context)!.sprintQualifyings,
      'p1': AppLocalizations.of(context)!.freePracticeOne,
      'p2': AppLocalizations.of(context)!.freePracticeTwo,
      'p3': AppLocalizations.of(context)!.freePracticeThree,
    };
    List months = [
      AppLocalizations.of(context)!.monthAbbreviationJanuary,
      AppLocalizations.of(context)!.monthAbbreviationFebruary,
      AppLocalizations.of(context)!.monthAbbreviationMarch,
      AppLocalizations.of(context)!.monthAbbreviationApril,
      AppLocalizations.of(context)!.monthAbbreviationMay,
      AppLocalizations.of(context)!.monthAbbreviationJune,
      AppLocalizations.of(context)!.monthAbbreviationJuly,
      AppLocalizations.of(context)!.monthAbbreviationAugust,
      AppLocalizations.of(context)!.monthAbbreviationSeptember,
      AppLocalizations.of(context)!.monthAbbreviationOctober,
      AppLocalizations.of(context)!.monthAbbreviationNovember,
      AppLocalizations.of(context)!.monthAbbreviationDecember,
    ];
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String startTimeHour = widget.session.startTime.hour.toString();
    String startTimeMinute = widget.session.startTime.minute.toString();
    String endTimeHour = widget.session.endTime.hour.toString();
    String endTimeMinute = widget.session.endTime.minute.toString();
    if (widget.session.startTime.hour < 10) {
      startTimeHour = '0${widget.session.startTime.hour}';
    }
    if (widget.session.startTime.minute < 10) {
      startTimeMinute = '0${widget.session.startTime.minute}';
    }
    if (widget.session.endTime.hour < 10) {
      endTimeHour = '0${widget.session.endTime.hour}';
    }
    if (widget.session.endTime.minute < 10) {
      endTimeMinute = '0${widget.session.endTime.minute}';
    }
    String startTime = '$startTimeHour:$startTimeMinute';
    String endTime = '$endTimeHour:$endTimeMinute';
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(top: 10),
        height: 70,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    widget.session.startTime.day.toString(),
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Color(0xff171717),
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    months[widget.session.startTime.month - 1],
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Color(0xff171717),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: DottedLine(
                direction: Axis.vertical,
                dashLength: 3,
                dashGapLength: 3,
                lineThickness: 3,
                dashRadius: 8,
                dashColor: useDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
              ),
            ),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  Text(
                    sessionsAbbreviations[widget.session.sessionsAbbreviation],
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Color(0xff171717),
                      fontSize: 20,
                    ),
                  ),
                  widget.session.endTime.isBefore(DateTime.now())
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                                top: 5,
                              ),
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: FaIcon(
                                  FontAwesomeIcons.flagCheckered,
                                  color: useDarkMode
                                      ? Colors.white
                                      : Color(0xff171717),
                                ),
                              ),
                            ),
                            Text(
                              'Séance terminée',
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.white
                                    : Color(0xff171717),
                              ),
                            ),
                          ],
                        )
                      : widget.session.startTime.isBefore(DateTime.now())
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 5,
                                    top: 5,
                                  ),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.values[17],
                                      colors: [
                                        useDarkMode
                                            ? Colors.white
                                            : Colors.grey,
                                      ],
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Séance en cours',
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Color(0xff171717),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '$startTime - $endTime',
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.white
                                    : Color(0xff171717),
                                fontSize: 17,
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionScreen(
            sessionsAbbreviations[widget.session.sessionsAbbreviation],
            widget.session,
          ),
        ),
      ),
    );
  }
}
