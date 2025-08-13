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

import 'package:boxbox/classes/event_tracker.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/providers/event_tracker/format.dart';
import 'package:boxbox/providers/event_tracker/requests.dart';
import 'package:boxbox/providers/event_tracker/ui.dart';
import 'package:boxbox/Screens/session_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RaceHubScreen extends StatelessWidget {
  final Event event;
  const RaceHubScreen(
    this.event, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: MediaQuery.of(context).size.width > 1000
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(event.meetingOfficialName),
                )
              : Marquee(
                  text: event.meetingOfficialName,
                  pauseAfterRound: const Duration(seconds: 1),
                  startAfter: const Duration(seconds: 1),
                  velocity: 85,
                  blankSpace: 100,
                ),
        ),
      ),
      body: EventTrackerUIProvider().getRaceHubScreen(context, event),
    );
  }
}

class RaceHubWithoutEventScreen extends StatelessWidget {
  const RaceHubWithoutEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: EventTrackerRequestsProvider().parseEvent(),
      builder: (context, snapshot) => snapshot.hasError
          ? Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: RequestErrorWidget(snapshot.error.toString()),
            )
          : snapshot.hasData
              ? RaceHubScreen(snapshot.data!)
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  body: LoadingIndicatorUtil(),
                ),
    );
  }
}

class RaceHubContent extends StatefulWidget {
  final Event event;
  const RaceHubContent(this.event, {super.key});

  @override
  State<RaceHubContent> createState() => _RaceHubContentState();
}

class _RaceHubContentState extends State<RaceHubContent> {
  bool isRefreshed = false;
  late Event event;

  @override
  Widget build(BuildContext context) {
    if (!isRefreshed) {
      isRefreshed = true;
      event = widget.event;
    }
    String meetingName = EventTrackerFormatProvider().formatMeetingName(event);

    return RefreshIndicator(
      onRefresh: () async {
        event = await EventTrackerRequestsProvider().parseEvent();
      },
      child: MediaQuery.of(context).size.width > 1000
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        EventTrackerUIProvider().getRaceHubLargeImage(
                          context,
                          meetingName,
                        ),
                        Text(
                          event.meetingName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 1000,
                      maxWidth: 1200,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var session in event.sessions)
                                  SessionItem(
                                    session,
                                    event.raceId,
                                    event.meetingCountryName,
                                    event.meetingOfficialName,
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  EventTrackerUIProvider()
                                      .getRaceHubInformation(
                                    context,
                                    event,
                                  ),
                                  EventTrackerUIProvider()
                                      .getRaceHubRaceProgramme(),
                                  EventTrackerUIProvider().getRaceHubLiveBlog(
                                    context,
                                    event,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 160),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 300,
                  maxWidth: 800,
                ),
                child: ListView(
                  children: [
                    EventTrackerUIProvider()
                        .getRaceHubImage(context, meetingName),
                    for (var session in event.sessions)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: SessionItem(
                          session,
                          event.raceId,
                          event.meetingCountryName,
                          event.meetingOfficialName,
                        ),
                      ),
                    EventTrackerUIProvider().getRaceHubDivider(),
                    EventTrackerUIProvider()
                        .getRaceHubInformation(context, event),
                    EventTrackerUIProvider().getRaceHubRaceProgramme(),
                    EventTrackerUIProvider().getRaceHubLiveBlog(context, event),
                    EventTrackerUIProvider().getRaceHubBottomSpace(),
                  ],
                ),
              ),
            ),
    );
  }
}

class PdfViewer extends StatelessWidget {
  final String documentTitle;
  final String src;
  PdfViewer(this.src, this.documentTitle, {Key? key}) : super(key: key);

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final String defaultServer = Constants().F1_API_URL;
    String server = Hive.box('settings')
        .get('server', defaultValue: defaultServer) as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          documentTitle,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SfPdfViewer.network(
        server != defaultServer
            ? "$server/documents/${src.split('/').last}"
            : src,
        key: _pdfViewerKey,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          //print(details.error);
          //print(details.description);
          showErrorDialog(context, details.error, details.description);
        },
        canShowPaginationDialog: true,
      ),
    );
  }

  void showErrorDialog(BuildContext context, String error, String description) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error),
            content: Text(description),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}

class SessionItem extends StatelessWidget {
  final Session session;
  final String raceId;
  final String meetingCountryName;
  final String meetingOfficialName;

  const SessionItem(
    this.session,
    this.raceId,
    this.meetingCountryName,
    this.meetingOfficialName, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map sessionsAbbreviations = {
      'r': AppLocalizations.of(context)!.race,
      'q': AppLocalizations.of(context)!.qualifyings,
      's': AppLocalizations.of(context)!.sprint,
      'ss': 'Sprint Qualifying',
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
    String startTimeHour = session.startTime.hour.toString();
    String startTimeMinute = session.startTime.minute.toString();
    String endTimeHour = session.endTime.hour.toString();
    String endTimeMinute = session.endTime.minute.toString();
    if (session.startTime.hour < 10) {
      startTimeHour = '0${session.startTime.hour}';
    }
    if (session.startTime.minute < 10) {
      startTimeMinute = '0${session.startTime.minute}';
    }
    if (session.endTime.hour < 10) {
      endTimeHour = '0${session.endTime.hour}';
    }
    if (session.endTime.minute < 10) {
      endTimeMinute = '0${session.endTime.minute}';
    }
    String startTime = '$startTimeHour:$startTimeMinute';
    String endTime = '$endTimeHour:$endTimeMinute';

    return kIsWeb
        ? Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              child: Hover(
                builder: (isHovered) => PhysicalModel(
                  color: Colors.transparent,
                  elevation: isHovered ? 16 : 0,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isHovered
                          ? Theme.of(context).colorScheme.onSecondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  session.startTime.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  months[session.startTime.month - 1],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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
                              dashColor: Theme.of(context).dividerColor,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sessionsAbbreviations[
                                          session.sessionAbbreviation] ??
                                      session.sessionAbbreviation,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                session.endTime.isBefore(DateTime.now()) &&
                                        session.sessionState !=
                                            SessionState().RUNNING
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              top: 5,
                                            ),
                                            child: SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: FaIcon(
                                                FontAwesomeIcons.flagCheckered,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .sessionCompletedShort,
                                            style: TextStyle(),
                                          ),
                                        ],
                                      )
                                    : session.startTime
                                                .isBefore(DateTime.now()) ||
                                            session.sessionState ==
                                                SessionState().RUNNING
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 5,
                                                ),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: LoadingIndicator(
                                                    indicatorType:
                                                        Indicator.values[17],
                                                    colors: [
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary,
                                                    ],
                                                    strokeWidth: 2.0,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .sessionRunning,
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '$startTime - $endTime',
                                            style: TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                isRaceHubSession: true,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionScreen(
                    sessionsAbbreviations[session.sessionAbbreviation] ??
                        session.sessionAbbreviation,
                    session,
                    meetingCountryName,
                    meetingOfficialName,
                    raceId,
                  ),
                ),
              ),
            ),
          )
        : Card(
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          session.startTime.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          months[session.startTime.month - 1],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                      child: DottedLine(
                        direction: Axis.vertical,
                        dashLength: 3,
                        dashGapLength: 3,
                        lineThickness: 3,
                        dashRadius: 8,
                        dashColor: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        Text(
                          sessionsAbbreviations[session.sessionAbbreviation] ??
                              session.sessionAbbreviation,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        session.endTime.isBefore(DateTime.now())
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                      top: 5,
                                    ),
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: FaIcon(
                                        FontAwesomeIcons.flagCheckered,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .sessionCompletedShort,
                                    style: TextStyle(),
                                  ),
                                ],
                              )
                            : session.startTime.isBefore(DateTime.now())
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                        ),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: LoadingIndicator(
                                            indicatorType: Indicator.values[17],
                                            strokeWidth: 2.0,
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .sessionRunning,
                                      ),
                                    ],
                                  )
                                : Text(
                                    '$startTime - $endTime',
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionScreen(
                    sessionsAbbreviations[session.sessionAbbreviation] ??
                        session.sessionAbbreviation,
                    session,
                    meetingCountryName,
                    meetingOfficialName,
                    raceId,
                  ),
                ),
              ),
            ),
          );
  }
}
