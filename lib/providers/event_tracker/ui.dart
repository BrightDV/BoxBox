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

import 'package:boxbox/Screens/SessionWebView/unofficial_webview.dart';
import 'package:boxbox/Screens/SessionWebView/webview_manager.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/Screens/racehub.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:boxbox/providers/event_tracker/format.dart';
import 'package:boxbox/scraping/fia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class EventTrackerUIProvider {
  double getEventTrackerContainerHeight() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return 143;
    } else if (championship == 'Formula E') {
      return 115;
    } else {
      return 100;
    }
  }

  Widget getEventTrackerContainerCircuitImageWidget(Event event) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Padding(
        padding: const EdgeInsets.only(
          top: 3,
          left: 10,
          right: 10,
          bottom: 5,
        ),
        child: SizedBox(
          width: 120,
          height: 90,
          child: Image.network(
            event.circuitImage,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getEventTrackerContainerEventDetails(
      Event event, BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return SizedBox(
        width: MediaQuery.of(context).size.width - 160,
        height: 20,
        child: MediaQuery.of(context).size.width >= 768
            ? Text(
                event.meetingOfficialName,
                style: const TextStyle(
                  fontSize: 12,
                ),
              )
            : Marquee(
                text: event.meetingOfficialName,
                style: const TextStyle(
                  fontSize: 12,
                ),
                pauseAfterRound: const Duration(seconds: 1),
                startAfter: const Duration(seconds: 1),
                velocity: 85,
                blankSpace: 100,
              ),
      );
    } else if (championship == 'Formula E') {
      return SizedBox(
        height: 20,
        child: Text(
          event.meetingOfficialName,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubScreen(BuildContext context, Event event) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return SlidingUpPanel(
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
                                onTap: () => !snapshot.data![index - 1].src
                                        .endsWith('pdf')
                                    ? {}
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewer(
                                            snapshot.data![index - 1].src,
                                            snapshot.data![index - 1].name,
                                          ),
                                        ),
                                      ),
                                child: kIsWeb
                                    ? Hover(
                                        isRaceHubSession: true,
                                        builder: (isHovered) => Card(
                                          elevation: 5,
                                          color: isHovered
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary
                                              : null,
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
                                      )
                                    : Card(
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
      );
    } else {
      return RaceHubContent(event);
    }
  }

  Widget getRaceHubImage(BuildContext context, String meetingName) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return SizedBox(
        height: MediaQuery.of(context).size.width / (16 / 9),
        child: CachedNetworkImage(
          imageUrl:
              'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$meetingName.jpg.transform/fullbleed/image.jpg',
          placeholder: (context, url) => const LoadingIndicatorUtil(),
          errorWidget: (context, url, error) => const Icon(
            Icons.error_outlined,
          ),
          fadeOutDuration: const Duration(milliseconds: 300),
          fadeInDuration: const Duration(milliseconds: 300),
          fit: BoxFit.scaleDown,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubLargeImage(BuildContext context, String meetingName) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return CachedNetworkImage(
        imageUrl:
            'https://media.formula1.com/image/upload/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$meetingName.jpg.transform/fullbleed/image.jpg',
        placeholder: (context, url) => const SizedBox(
          height: 400,
          child: LoadingIndicatorUtil(),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.error_outlined,
        ),
        fadeOutDuration: const Duration(milliseconds: 300),
        fadeInDuration: const Duration(milliseconds: 300),
        fit: BoxFit.cover,
        colorBlendMode: BlendMode.darken,
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubDivider() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 10,
        ),
        child: Divider(),
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubInformation(BuildContext context, Event event) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return BoxBoxButton(
        AppLocalizations.of(context)!.information,
        Icon(
          Icons.arrow_forward_rounded,
        ),
        isRoute: true,
        route: 'racing',
        pathParameters: {'meetingId': event.raceId},
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubRaceProgramme() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      Future openRaceProgramme() async {
        launchUrl(
          Uri.parse(
            "https://web.formula1rp.com/",
          ),
        );
      }

      return BoxBoxButton(
        'Race Programme',
        Icon(Icons.open_in_new_outlined),
        toExecute: openRaceProgramme,
      );
    } else {
      return Container();
    }
  }

  Widget getRaceHubLiveBlog(BuildContext context, Event event) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (event.liveBlog != null) {
        return BoxBoxButton(
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
          isRoute: false,
          widget: Scaffold(
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
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              },
            ),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getRaceHubBottomSpace() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return const SizedBox(height: 200);
    } else {
      return Container();
    }
  }

  Widget getRaceHubFreePracticesWebview(
    BuildContext context,
    String sessionFullName,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    bool useOfficialWebview = Hive.box('settings')
        .get('useOfficialWebview', defaultValue: false) as bool;

    if (championship == 'Formula 1') {
      if (useOfficialWebview) {
        return WebViewManagerScreen(sessionFullName);
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            title: Text(
              sessionFullName,
            ),
          ),
          body: UnofficialWebviewScreen(),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
            sessionFullName,
          ),
        ),
        body: UnofficialWebviewScreen(),
      );
    }
  }

  Widget getRaceHubWebview(String sessionFullName) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialWebview = Hive.box('settings')
          .get('useOfficialWebview', defaultValue: false) as bool;
      if (useOfficialWebview) {
        return WebViewManagerScreen(sessionFullName);
      } else {
        return UnofficialWebviewScreen();
      }
    } else {
      return UnofficialWebviewScreen();
    }
  }

  Widget getRaceHubResultsProvider(
    Session session,
    String meetingId,
    String sessionFullName,
    String meetingOfficialName,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return QualificationResultsProvider(
        raceUrl: EventTrackerFormatProvider().formatQualificationsSessionUrl(
          session,
        ),
        sessionId: meetingId,
        hasSprint: session.sessionsAbbreviation == 'ss' ? true : false,
        isSprintQualifying: session.sessionsAbbreviation == 'ss' ? true : false,
      );
    } else if (championship == 'Formula E') {
      return FreePracticeResultsProvider(
        sessionFullName,
        10,
        '',
        meetingId,
        DateTime.now().year,
        meetingOfficialName,
        sessionId: session.baseUrl,
      );
    } else {
      return Container();
    }
  }
}
