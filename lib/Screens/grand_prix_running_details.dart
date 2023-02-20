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

import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/fia.dart';
import 'package:boxbox/Screens/session_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class GrandPrixRunningScreen extends StatefulWidget {
  final Event event;
  const GrandPrixRunningScreen(
    this.event, {
    Key? key,
  }) : super(key: key);
  @override
  State<GrandPrixRunningScreen> createState() => _GrandPrixRunningScreenState();
}

class _GrandPrixRunningScreenState extends State<GrandPrixRunningScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    late String meetingName;
    widget.event.meetingName == 'United States'
        ? meetingName = 'USA'
        : meetingName = widget.event.meetingName;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: Marquee(
            text: widget.event.meetingOfficialName,
            pauseAfterRound: const Duration(seconds: 1),
            startAfter: const Duration(seconds: 1),
            velocity: 85,
            blankSpace: 100,
          ),
        ),
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: SlidingUpPanel(
        backdropEnabled: true,
        color: useDarkMode ? const Color(0xff22222c) : Colors.white,
        parallaxEnabled: true,
        panelBuilder: (scrollController) => Center(
          child: FutureBuilder<List<SessionDocument>>(
            future: FIAScraper().scrapeSessionDocuments(),
            builder: (context, snapshot) => snapshot.hasError
                ? RequestErrorWidget(snapshot.error.toString())
                : snapshot.hasData
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        controller: scrollController,
                        itemBuilder: (context, index) => index == 0
                            ? Padding(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    "Grand-Prix documents",
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () =>
                                    !snapshot.data![index].src.endsWith('pdf')
                                        ? {}
                                        : Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PdfViewer(
                                                snapshot.data![index].src,
                                                snapshot.data![index].name,
                                              ),
                                            ),
                                          ),
                                child: Card(
                                  color: useDarkMode
                                      ? const Color.fromARGB(255, 45, 45, 58)
                                      : Colors.white,
                                  elevation: 5,
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data?[index].name ?? '',
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Published on ${snapshot.data?[index].postedDate}',
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.picture_as_pdf_outlined,
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            "Grand-Prix documents",
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
          ),
        ),
        body: ListView(
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$meetingName.jpg.transform/12col/image.jpg',
              placeholder: (context, url) => SizedBox(
                height: MediaQuery.of(context).size.width / 16 / 9,
                child: const LoadingIndicatorUtil(),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error_outlined,
              ),
              fadeOutDuration: const Duration(seconds: 1),
              fadeInDuration: const Duration(seconds: 1),
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
            Container(height: 160),
          ],
        ),
      ),
    );
  }
}

class PdfViewer extends StatefulWidget {
  final String documentTitle;
  final String src;
  const PdfViewer(this.src, this.documentTitle, {Key? key}) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.documentTitle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        widget.src,
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

class SessionItem extends StatefulWidget {
  final Session session;
  final String raceId;
  final String meetingCountryName;

  const SessionItem(
    this.session,
    this.raceId,
    this.meetingCountryName, {
    Key? key,
  }) : super(key: key);
  @override
  State<SessionItem> createState() => _SessionItemState();
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
        padding: const EdgeInsets.only(top: 10),
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
                      color:
                          useDarkMode ? Colors.white : const Color(0xff171717),
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    months[widget.session.startTime.month - 1],
                    style: TextStyle(
                      color:
                          useDarkMode ? Colors.white : const Color(0xff171717),
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
                      color:
                          useDarkMode ? Colors.white : const Color(0xff171717),
                      fontSize: 20,
                    ),
                  ),
                  widget.session.endTime.isBefore(DateTime.now())
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                  color: useDarkMode
                                      ? Colors.white
                                      : const Color(0xff171717),
                                ),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .sessionCompletedShort,
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.white
                                    : const Color(0xff171717),
                              ),
                            ),
                          ],
                        )
                      : widget.session.startTime.isBefore(DateTime.now())
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
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
                                  AppLocalizations.of(context)!.sessionRunning,
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : const Color(0xff171717),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '$startTime - $endTime',
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.white
                                    : const Color(0xff171717),
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
