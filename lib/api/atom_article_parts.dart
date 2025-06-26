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

import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class AtomQuiz extends StatelessWidget {
  final Map element;
  const AtomQuiz(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return BoxBoxButton(
      AppLocalizations.of(context)!.openQuiz,
      Icon(
        Icons.bar_chart,
      ),
      isRoute: false,
      widget: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.quiz,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              "https://www.riddle.com/view/${element['fields']['riddleId']}",
            ),
          ),
          initialSettings: InAppWebViewSettings(
            preferredContentMode: UserPreferredContentMode.DESKTOP,
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
      verticalPadding: 20.0,
      horizontalPadding: 5.0,
    );
  }
}

class AtomSocialButton extends StatelessWidget {
  final Map element;
  const AtomSocialButton(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 40,
        child: TextButton.icon(
          onPressed: () async => await launchUrl(
            Uri.parse(element['fields']['postUrl']),
          ),
          icon: FaIcon(
            element['fields']['postType'] == 'Instagram'
                ? FontAwesomeIcons.instagram
                : element['fields']['postType'] == 'Twitter'
                    ? FontAwesomeIcons.twitter
                    : FontAwesomeIcons.newspaper,
          ),
          label: Text(
            element['fields']['postType'] == 'Instagram'
                ? "Instagram Post"
                : element['fields']['postType'] == 'Twitter'
                    ? "Tweet"
                    : element['fields']['postType'],
          ),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(
              Colors.white,
            ),
            backgroundColor: element['fields']['postType'] == 'Instagram'
                ? WidgetStateProperty.all<Color>(
                    const Color.fromARGB(
                      255,
                      241,
                      77,
                      90,
                    ),
                  )
                : element['fields']['postType'] == 'Twitter'
                    ? WidgetStateProperty.all<Color>(Color(0xFF1DA1F2))
                    : WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
            elevation: WidgetStateProperty.all<double>(5),
          ),
        ),
      ),
    );
  }
}

class AtomScribbleLive extends StatelessWidget {
  final Map element;
  const AtomScribbleLive(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            AppLocalizations.of(context)!.liveBlog,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              "https://embed.scribblelive.com/Embed/v7.aspx?Id=${element['fields']['scribbleEventId'].split('/')[2]}&ThemeId=37480",
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
      verticalPadding: 20.0,
      horizontalPadding: 5.0,
    );
  }
}

class AtomInteractiveExperience extends StatelessWidget {
  final Map element;
  const AtomInteractiveExperience(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            element['fields']['title'],
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              element['fields']['eventUrl'],
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
      verticalPadding: 20.0,
      horizontalPadding: 5.0,
    );
  }
}

class AtomSessionResults extends StatelessWidget {
  final Map element;
  const AtomSessionResults(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        10,
      ),
      child: Container(
        height: element['fields']['sessionType'].contains('Starting Grid')
            ? 428
            : 290,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
              ),
              child: Text(
                element['fields']['meetingCountryName'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              element['fields']['sessionType'] == 'Race'
                  ? AppLocalizations.of(context)!.race
                  : element['fields']['sessionType'] == 'Qualifying'
                      ? AppLocalizations.of(context)!.qualifyings
                      : element['fields']['sessionType'] == 'Sprint'
                          ? AppLocalizations.of(context)!.sprint
                          : element['fields']['sessionType'] ==
                                  'Sprint Shootout'
                              ? element['fields']['raceResultsSprintShootout']
                                          ['description'] ==
                                      'Sprint Qualifying'
                                  ? 'Sprint Qualifying'
                                  : 'Sprint Shootout'
                              : element['fields']['sessionType']
                                      .startsWith('Starting Grid')
                                  ? element['fields']['sessionType']
                                  : element['fields']['sessionType']
                                          .endsWith('1')
                                      ? AppLocalizations.of(context)!
                                          .freePracticeOne
                                      : element['fields']['sessionType']
                                              .endsWith('2')
                                          ? AppLocalizations.of(context)!
                                              .freePracticeTwo
                                          : AppLocalizations.of(context)!
                                              .freePracticeThree,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
                left: 15,
              ),
              child: Row(
                children: element['fields']['sessionType']
                        .startsWith('Starting Grid')
                    ? [
                        Expanded(
                          flex: 2,
                          child: Text(
                            AppLocalizations.of(context)!.positionAbbreviation,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            AppLocalizations.of(context)!.driverAbbreviation,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            AppLocalizations.of(context)!.team.toUpperCase(),
                          ),
                        ),
                      ]
                    : [
                        Expanded(
                          flex: element['fields']['sessionType'] == 'Race' ||
                                  element['fields']['sessionType'] == 'Sprint'
                              ? 5
                              : 4,
                          child: Text(
                            AppLocalizations.of(context)!.positionAbbreviation,
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 5,
                          child: Text(
                            AppLocalizations.of(context)!.time,
                          ),
                        ),
                        element['fields']['sessionType'] == 'Race' ||
                                element['fields']['sessionType'] == 'Sprint'
                            ? Expanded(
                                flex: 3,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .pointsAbbreviation,
                                ),
                              )
                            : Container(),
                      ],
              ),
            ),
            for (Map driverResults in element['fields']['sessionType']
                    .startsWith('Starting Grid')
                ? element['fields']['startingGrid']['results']
                : element['fields'][
                        'raceResults${element['fields']['sessionType'] == 'Sprint' ? 'SprintQualifying' : element['fields']['sessionType'] == 'Sprint Shootout' ? 'SprintShootout' : element['fields']['sessionType']}']
                    ['results'])
              element['fields']['sessionType'] == 'Race' ||
                      element['fields']['sessionType'] == 'Sprint'
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              driverResults['positionNumber'] == '66666'
                                  ? 'DQ'
                                  : driverResults['positionNumber'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 15,
                              child: BoxBoxVerticalDivider(
                                color: Color(
                                  int.parse(
                                    driverResults['teamColourCode'] == null
                                        ? '00FFFFFF'
                                        : 'FF${driverResults['teamColourCode']}',
                                    radix: 16,
                                  ),
                                ),
                                thickness: 5,
                                width: 5,
                                border: BorderRadius.circular(2.0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              driverResults['driverTLA'].toString(),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 6,
                            child: Text(
                              (driverResults['gapToLeader'] != "0.0" &&
                                      driverResults['gapToLeader'] != "0")
                                  ? '+${driverResults['gapToLeader']}'
                                  : element['fields']['sessionType'] == 'Race'
                                      ? driverResults['raceTime']
                                      : driverResults['sprintQualifyingTime'],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              element['fields']['sessionType'] == 'Race'
                                  ? (driverResults['racePoints'] ?? '0')
                                      .toString()
                                  : (driverResults['sprintQualifyingPoints'] ??
                                          '0')
                                      .toString(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : element['fields']['sessionType'].startsWith('Starting Grid')
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 7,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  driverResults['positionNumber'] == '66666'
                                      ? 'DQ'
                                      : driverResults['positionNumber'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 15,
                                  child: BoxBoxVerticalDivider(
                                    color: Color(
                                      int.parse(
                                        driverResults['teamColourCode'] == null
                                            ? '00FFFFFF'
                                            : 'FF${driverResults['teamColourCode']}',
                                        radix: 16,
                                      ),
                                    ),
                                    thickness: 5,
                                    width: 5,
                                    border: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  driverResults['driverLastName'],
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  driverResults['teamName'],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                            top: 7,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  driverResults['positionNumber'] == '66666'
                                      ? 'DQ'
                                      : driverResults['positionNumber'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 15,
                                  child: BoxBoxVerticalDivider(
                                    color: Color(
                                      int.parse(
                                        driverResults['teamColourCode'] == null
                                            ? '00FFFFFF'
                                            : 'FF${driverResults['teamColourCode']}',
                                        radix: 16,
                                      ),
                                    ),
                                    thickness: 5,
                                    width: 5,
                                    border: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  driverResults['driverTLA'].toString(),
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  element['fields']['sessionType']
                                          .startsWith('Practice')
                                      ? driverResults['classifiedTime'] ?? '--'
                                      : driverResults['q3']
                                              ?['classifiedTime'] ??
                                          '--',
                                ),
                              ),
                            ],
                          ),
                        ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 15,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(
                        15,
                      ),
                      bottomRight: Radius.circular(
                        15,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => element['fields']['sessionType']
                              .startsWith('Practice')
                          ? context.pushNamed(
                              'practice',
                              pathParameters: {
                                'sessionIndex': element['fields'][
                                            'raceResults${element['fields']['sessionType']}']
                                        ['session']
                                    .substring(1),
                                'meetingId': element['fields']['meetingKey'],
                              },
                              extra: {
                                'sessionTitle': element['fields'][
                                                'raceResults${element['fields']['sessionType']}']
                                            ['description']
                                        .endsWith('1')
                                    ? AppLocalizations.of(context)!
                                        .freePracticeOne
                                    : element['fields'][
                                                    'raceResults${element['fields']['sessionType']}']
                                                ['description']
                                            .endsWith('2')
                                        ? AppLocalizations.of(context)!
                                            .freePracticeTwo
                                        : AppLocalizations.of(context)!
                                            .freePracticeThree,
                                'sessionIndex': int.parse(
                                  element['fields'][
                                              'raceResults${element['fields']['sessionType']}']
                                          ['session']
                                      .substring(1),
                                ),
                                'circuitId': '',
                                'meetingId': element['fields']['meetingKey'],
                                'raceYear': int.parse(
                                  element['fields']['season'],
                                ),
                                'raceName': element['fields']
                                    ['meetingOfficialName'],
                              },
                            )
                          : element['fields']['sessionType'] == 'Race'
                              ? context.pushNamed('race', pathParameters: {
                                  'meetingId': element['fields']['meetingKey']
                                })
                              : element['fields']['sessionType'] == 'Sprint'
                                  ? context.pushNamed('sprint',
                                      pathParameters: {'meetingId': element['fields']['meetingKey']})
                                  : element['fields']['sessionType'] ==
                                          'Sprint Shootout'
                                      ? context.pushNamed('sprint-shootout',
                                          pathParameters: {'meetingId': element['fields']['meetingKey']})
                                      : element['fields']['sessionType'] ==
                                              'Starting Grid'
                                          ? context.pushNamed('starting-grid',
                                              pathParameters: {'meetingId': element['fields']['meetingKey']})
                                          : context.pushNamed('qualifyings',
                                              pathParameters: {
                                                  'meetingId': element['fields']
                                                      ['meetingKey']
                                                }),
                      style: ElevatedButton.styleFrom(
                        shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.viewResults,
                      ),
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

class AtomTableContent2 extends StatelessWidget {
  final Map element;
  const AtomTableContent2(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    element['fields']['title'] ?? element['fields']['name'],
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              for (List line in element['fields']['tableData']['tableContent'])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (Map tableCell in line)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          borderRadius: line ==
                                  element['fields']['tableData']['tableContent']
                                      .first
                              ? line.first == tableCell
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(
                                        15,
                                      ),
                                    )
                                  : line.last == tableCell
                                      ? BorderRadius.only(
                                          topRight: Radius.circular(
                                            15,
                                          ),
                                        )
                                      : BorderRadius.zero
                              : line ==
                                      element['fields']['tableData']
                                              ['tableContent']
                                          .last
                                  ? line.first == tableCell
                                      ? BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                            15,
                                          ),
                                        )
                                      : line.last == tableCell
                                          ? BorderRadius.only(
                                              bottomRight: Radius.circular(
                                                15,
                                              ),
                                            )
                                          : BorderRadius.zero
                                  : BorderRadius.zero,
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              tableCell['value'].toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AtomAudioBoom extends StatelessWidget {
  final Map element;
  const AtomAudioBoom(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding = width > 600 ? 30 : 0;
    String url = 'https:' + element['fields']['audioPodcast']['iFrameSrc'];
    url = url.replaceAll(
      element['fields']['audioPodcast']['slug'],
      element['fields']['eid'],
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: padding != 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                      ),
                      child: ImageRenderer(
                        element['fields']['audioPodcast']['postImage'],
                        isPodcastPreview: true,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            element['fields']['audioPodcast']['postTitle'],
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            element['fields']['audioPodcast']['channelTitle'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: padding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () async => await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  label: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 13),
                                    child: Text(
                                      AppLocalizations.of(context)!.listen,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.headphones_outlined,
                                    size: 25,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () async => await launchUrl(
                                    Uri.parse(element['fields']['audioPodcast']
                                        ['mp3Link']),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  label: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 13),
                                    child: Text(
                                      'MP3',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.music_note_outlined,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 120),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                          ),
                          child: ImageRenderer(
                            element['fields']['audioPodcast']['postImage'],
                            isPodcastPreview: true,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                element['fields']['audioPodcast']['postTitle'],
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: padding != 0 ? null : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                element['fields']['audioPodcast']
                                    ['channelTitle'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () async => await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        ),
                        label: Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            AppLocalizations.of(context)!.listen,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        icon: Icon(
                          Icons.headphones_outlined,
                          size: 25,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async => await launchUrl(
                          Uri.parse(
                              element['fields']['audioPodcast']['mp3Link']),
                          mode: LaunchMode.externalApplication,
                        ),
                        label: Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            'MP3',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        icon: Icon(
                          Icons.music_note_outlined,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class AtomLinkList extends StatelessWidget {
  final Map element;
  const AtomLinkList(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: element['fields']['items'].length + 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => index == 0
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Text(
                  element['fields']['title'],
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  String articleUrl =
                      element['fields']['items'][index - 1]['webUrl'];
                  String articleId = articleUrl
                      .substring(43, articleUrl.length - 5)
                      .split('.')[1];
                  context.pushNamed(
                    'article',
                    pathParameters: {'id': articleId},
                    extra: {
                      'articleName': element['fields']['items'][index - 1]
                          ['title'],
                      'isFromLink': true,
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    '• ${element['fields']['items'][index - 1]['title']}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class AtomPullQuote extends StatelessWidget {
  final Map element;
  const AtomPullQuote(this.element, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  '“',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Text(
                    element['fields']['quoteText'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  '”',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            element['fields']['quoteCitation'],
            style: TextStyle(
              color: useDarkMode ? Colors.grey[400] : Colors.grey[800],
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class UnsupportedWidget extends StatelessWidget {
  final Map element;
  final Article article;
  const UnsupportedWidget(this.element, this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: SelectableText(
          'Unsupported widget ¯\\_(ツ)_/¯\nType: ${element['contentType']}\nArticle id: ${article.articleId}',
        ),
      ),
    );
  }
}
