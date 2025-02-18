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

import 'package:boxbox/Screens/circuit.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/fia.dart';
import 'package:boxbox/Screens/session_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class RaceHubScreen extends StatelessWidget {
  final Event event;
  const RaceHubScreen(
    this.event, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
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
      body: championship == 'Formula 1'
          ? SlidingUpPanel(
              backdropEnabled: true,
              color: Theme.of(context).colorScheme.surface,
              collapsed: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        "Grand-Prix documents",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              panel: Center(
                child: FutureBuilder<List<SessionDocument>>(
                  future: FIAScraper().scrapeSessionDocuments(),
                  builder: (context, snapshot) => snapshot.hasError
                      ? RequestErrorWidget(snapshot.error.toString())
                      : snapshot.hasData
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length + 1,
                              itemBuilder: (context, index) => index == 0
                                  ? Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Center(
                                          child: Text(
                                            "Grand-Prix documents",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () => !snapshot
                                              .data![index - 1].src
                                              .endsWith('pdf')
                                          ? {}
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PdfViewer(
                                                  snapshot.data![index - 1].src,
                                                  snapshot
                                                      .data![index - 1].name,
                                                ),
                                              ),
                                            ),
                                      child: Card(
                                        elevation: 5,
                                        child: ListTile(
                                          title: Text(
                                            snapshot.data![index - 1].name,
                                          ),
                                          subtitle: Text(
                                            snapshot
                                                .data![index - 1].postedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          leading: Icon(
                                            Icons.picture_as_pdf_outlined,
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
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                ),
              ),
              body: RaceHubContent(event),
            )
          : RaceHubContent(event),
    );
  }
}

class RaceHubContent extends StatelessWidget {
  final Event event;
  const RaceHubContent(this.event, {super.key});

  Future openRaceProgramme() async {
    launchUrl(
      Uri.parse(
        "https://web.formula1rp.com/",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    late String meetingName;
    if (championship == 'Formula 1') {
      event.meetingName == 'United States'
          ? meetingName = 'USA'
          : meetingName = event.meetingName;
      if (meetingName != 'Great Britain') {
        meetingName = meetingName.replaceAll(' ', '_');
      } else {
        meetingName = event.meetingName;
      }
    }
    return MediaQuery.of(context).size.width > 1000
        ? SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      championship == 'Formula 1'
                          ? CachedNetworkImage(
                              imageUrl:
                                  'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$meetingName.jpg.transform/fullbleed/image.jpg',
                              placeholder: (context, url) => const SizedBox(
                                height: 400,
                                child: LoadingIndicatorUtil(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error_outlined,
                              ),
                              fadeOutDuration: const Duration(seconds: 1),
                              fadeInDuration: const Duration(seconds: 1),
                              fit: BoxFit.cover,
                              colorBlendMode: BlendMode.darken,
                              color: Colors.black.withOpacity(0.5),
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                            )
                          : Container(),
                      Text(
                        event.meetingName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w500,
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
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          20,
                                          10,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .information,
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // TODO: TESTEST
                                    onTap: () => context.pushNamed(
                                      'racing',
                                      pathParameters: {
                                        'meetingId': event.raceId
                                      },
                                      extra: {'isFetched': bool},
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          20,
                                          10,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Race Programme',
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.open_in_new_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () => launchUrl(
                                      Uri.parse(
                                        "https://raceprogramme.formula1.com/#/catalogue",
                                      ),
                                    ),
                                  ),
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
                  championship == 'Formula 1'
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width / (16 / 9),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$meetingName.jpg.transform/fullbleed/image.jpg',
                            placeholder: (context, url) =>
                                const LoadingIndicatorUtil(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error_outlined,
                            ),
                            fadeOutDuration: const Duration(seconds: 1),
                            fadeInDuration: const Duration(seconds: 1),
                            fit: BoxFit.scaleDown,
                          ),
                        )
                      : Container(),
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
                  championship == 'Formula 1'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          child: Divider(),
                        )
                      : Container(),
                  championship == 'Formula 1'
                      ? BoxBoxButton(
                          AppLocalizations.of(context)!.information,
                          Icon(
                            Icons.arrow_forward_rounded,
                          ),
                          CircuitScreen(
                            Race(
                              '0',
                              event.raceId,
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              [],
                            ),
                            isFetched: false,
                          ),
                        )
                      : Container(),
                  championship == 'Formula 1'
                      ? BoxBoxButton(
                          'Race Programme',
                          Icon(Icons.open_in_new_outlined),
                          Container(),
                          toExecute: openRaceProgramme,
                        )
                      : Container(),
                  championship == 'Formula 1' && event.liveBlog != null
                      ? BoxBoxButton(
                          AppLocalizations.of(context)!.openLiveBlog,
                          SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballScaleMultiple,
                              colors: [
                                Theme.of(context).colorScheme.onPrimary,
                              ],
                            ),
                          ),
                          Scaffold(
                            appBar: AppBar(
                              title: SizedBox(
                                height: AppBar().preferredSize.height,
                                width: AppBar().preferredSize.width,
                                child: Marquee(
                                  text: event.liveBlog!['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startAfter: const Duration(seconds: 1),
                                  velocity: 85,
                                  blankSpace: 100,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            body: InAppWebView(
                              initialUrlRequest: URLRequest(
                                url: WebUri(
                                  event.liveBlog!['eventUrl'],
                                ),
                              ),
                              gestureRecognizers: {
                                Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer()),
                                Factory<HorizontalDragGestureRecognizer>(
                                    () => HorizontalDragGestureRecognizer()),
                                Factory<ScaleGestureRecognizer>(
                                    () => ScaleGestureRecognizer()),
                              },
                            ),
                          ),
                        )
                      : Container(),
                  championship == 'Formula 1'
                      ? const SizedBox(height: 200)
                      : Container(),
                ],
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
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
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
                    height: 70,
                    decoration: BoxDecoration(
                      color: isHovered
                          ? useDarkMode
                              ? const Color(0xff1d1d28)
                              : Colors.grey.shade400
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 3.0,
                      ),
                    ),
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
                                        session.sessionsAbbreviation] ??
                                    session.sessionsAbbreviation,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              session.endTime.isBefore(DateTime.now())
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
                                  : session.startTime.isBefore(DateTime.now())
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
                                                    useDarkMode
                                                        ? Colors.white
                                                        : Colors.grey,
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
                isRaceHubSession: true,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionScreen(
                    sessionsAbbreviations[session.sessionsAbbreviation] ??
                        session.sessionsAbbreviation,
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
                          sessionsAbbreviations[session.sessionsAbbreviation] ??
                              session.sessionsAbbreviation,
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
                                              useDarkMode
                                                  ? Colors.white
                                                  : Colors.grey,
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
                    sessionsAbbreviations[session.sessionsAbbreviation] ??
                        session.sessionsAbbreviation,
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
