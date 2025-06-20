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

import 'package:boxbox/Screens/Racing/circuit_details.dart';
import 'package:boxbox/Screens/session_screen.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CircuitScreen extends StatelessWidget {
  final String meetingId;
  const CircuitScreen(this.meetingId, {super.key});

  @override
  Widget build(BuildContext context) {
    Map details = Hive.box('requests')
        .get('f1CircuitDetails-$meetingId', defaultValue: {});
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: Formula1().getCircuitDetails(meetingId),
        builder: (context, snapshot) => snapshot.hasError
            ? details.isNotEmpty
                ? CircuitScreenContent(details)
                : Column(
                    children: [
                      AppBar(),
                      RequestErrorWidget(snapshot.error.toString()),
                    ],
                  )
            : snapshot.hasData
                ? CircuitScreenContent(snapshot.data!)
                : Column(
                    children: [
                      AppBar(),
                      LoadingIndicatorUtil(),
                    ],
                  ),
      ),
    );
  }
}

class CircuitScreenContent extends StatelessWidget {
  final Map details;
  const CircuitScreenContent(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outlined),
                  fadeOutDuration: const Duration(milliseconds: 300),
                  fadeInDuration: const Duration(milliseconds: 300),
                  fit: BoxFit.cover,
                  imageUrl: details['raceImage']['url'],
                  placeholder: (context, url) => const LoadingIndicatorUtil(),
                  colorBlendMode: BlendMode.darken,
                  height: MediaQuery.of(context).size.height * (4 / 9),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (4 / 9) - 110),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                            errorWidget: (context, url, error) =>
                                SizedBox(width: 53),
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) => SizedBox(width: 53),
                            fit: BoxFit.cover,
                            imageUrl: details['raceCountryFlag']['url'],
                            height: 30,
                            width: 53,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            details['race']['meetingCountryName'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        details['race']['meetingOfficialName'],
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              AppBar(
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0.0,
              ),
            ],
          ),
          details['raceReview']?['headline'] != null
              ? Headline(details['raceReview']['headline'])
              : Container(),
          details['raceReview']?['links'] != null &&
                  details['raceReview']['links'].isNotEmpty &&
                  details['raceReview']['links'].length > 0
              ? BoxBoxButton(
                  AppLocalizations.of(context)!.viewHighlights,
                  Icon(
                    Icons.play_arrow_outlined,
                  ),
                  route: 'article',
                  pathParameters: {
                    'id': details['raceReview']['links'][1]['url']
                            .endsWith('.html')
                        ? details['raceReview']['links'][1]['url'].split('.')[4]
                        : details['raceReview']['links'][1]['url']
                            .split('.')
                            .last,
                  },
                  extra: {'isFromLink': true},
                )
              : Container(),
          details['meetingSessionResults'].last['sessionResults']
                          ?['raceResultsRace']?['results'] !=
                      null &&
                  details['meetingSessionResults']
                      .last['sessionResults']?['raceResultsRace']?['results']
                      .isNotEmpty
              ? RaceResults(
                  details['race']['meetingCountryName'],
                  details['race']['meetingKey'],
                  details['meetingSessionResults']
                      .last['sessionResults']['raceResultsRace']['results']
                      .sublist(0, 5),
                )
              : Container(),
          details['raceReview'] != null &&
                  details['raceReview']['curatedSection']['items'].isNotEmpty
              ? CuratedSection(
                  details['raceReview']['curatedSection']['items'],
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 5),
                      child: Text(
                        'Sessions',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    for (var session
                        in details['race']['meetingSessions'].reversed.toList())
                      SessionItemForCircuit(
                        session['description'],
                        Session(
                          session['state'],
                          session['session'],
                          DateTime.parse(session['endTime']),
                          DateTime.parse(session['startTime']),
                          null,
                          DateTime.now().isBefore(
                                  DateTime.parse(session['endTime'])) &&
                              DateTime.now().isAfter(
                                  DateTime.parse(session['startTime'])),
                        ),
                        details['race']['meetingCountryName'],
                        details['race']['meetingOfficialName'],
                        details['race']['meetingKey'],
                        links: details['sessionLinkSets'][session['session']]
                            ['links'],
                      ),
                  ],
                ),
              ),
            ),
          ),
          BoxBoxButton(
            'Circuit facts',
            Icon(
              Icons.info_outline,
            ),
            isRoute: false,
            widget: CircuitDetailsScreen(
              details['race']['meetingCountryName'],
              details['race']['circuitOfficialName'],
              details['circuitMapImage']['url'],
              details['circuitDescriptionText'],
              details['circuitMap']['links'],
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class SessionItemForCircuit extends StatelessWidget {
  final String sessionFullName;
  final Session session;
  final String meetingCountryName;
  final String meetingOfficialName;
  final String meetingId;
  final List? links;
  const SessionItemForCircuit(
    this.sessionFullName,
    this.session,
    this.meetingCountryName,
    this.meetingOfficialName,
    this.meetingId, {
    this.links,
    super.key,
  });

  List getUsefulLinks(List links) {
    List l = [];
    for (var link in links) {
      if (link['linkType'] != 'Replay' && link['linkType'] != 'Results') {
        l.add(link);
      }
    }
    return l;
  }

  void tapAction(String linkType, String url, BuildContext context) {
    if (linkType == 'Article' || linkType == 'LiveBlog') {
      context.pushNamed(
        'article',
        pathParameters: {'id': url.split('.').last},
        extra: {
          'isFromLink': true,
        },
      );
    } else if (linkType == 'StartingGrid') {
      context.pushNamed(
        'starting-grid',
        pathParameters: {'meetingId': meetingId},
      );
    } else if (linkType == 'SprintGrid') {
      context.pushNamed(
        'sprint-shootout',
        pathParameters: {'meetingId': meetingId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List months = [
      AppLocalizations.of(context)?.monthAbbreviationJanuary,
      AppLocalizations.of(context)?.monthAbbreviationFebruary,
      AppLocalizations.of(context)?.monthAbbreviationMarch,
      AppLocalizations.of(context)?.monthAbbreviationApril,
      AppLocalizations.of(context)?.monthAbbreviationMay,
      AppLocalizations.of(context)?.monthAbbreviationJune,
      AppLocalizations.of(context)?.monthAbbreviationJuly,
      AppLocalizations.of(context)?.monthAbbreviationAugust,
      AppLocalizations.of(context)?.monthAbbreviationSeptember,
      AppLocalizations.of(context)?.monthAbbreviationOctober,
      AppLocalizations.of(context)?.monthAbbreviationNovember,
      AppLocalizations.of(context)?.monthAbbreviationDecember,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () =>
            session.endTime.isAfter(DateTime.now()) || session.isRunning
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionScreen(
                        sessionFullName,
                        session,
                        meetingCountryName,
                        meetingOfficialName,
                        meetingId,
                      ),
                    ),
                  )
                : session.sessionsAbbreviation.startsWith('p')
                    ? context.pushNamed(
                        'practice',
                        pathParameters: {
                          'meetingId': meetingId,
                          'sessionIndex':
                              session.sessionsAbbreviation.substring(1)
                        },
                      )
                    : session.sessionsAbbreviation == 'ss'
                        ? context.pushNamed(
                            'sprint-shootout',
                            pathParameters: {
                              'meetingId': meetingId,
                            },
                          )
                        : session.sessionsAbbreviation == 's'
                            ? context.pushNamed(
                                'sprint',
                                pathParameters: {
                                  'meetingId': meetingId,
                                },
                              )
                            : session.sessionsAbbreviation == 'q'
                                ? context.pushNamed(
                                    'qualifyings',
                                    pathParameters: {
                                      'meetingId': meetingId,
                                    },
                                  )
                                : context.pushNamed(
                                    'race',
                                    pathParameters: {
                                      'meetingId': meetingId,
                                    },
                                  ),
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          height: 80,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1.0,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 5,
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 5),
                  child: session.isRunning
                      ? SizedBox(
                          height: 25,
                          width: 25,
                          child: LoadingIndicator(
                            indicatorType: Indicator.values[17],
                            colors: [
                              Theme.of(context).colorScheme.primary,
                            ],
                            strokeWidth: 2.0,
                          ),
                        )
                      : session.state == 'completed'
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: FaIcon(
                                FontAwesomeIcons.flagCheckered,
                              ),
                            )
                          : SizedBox(width: 25),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionFullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${DateFormat('dd').format(session.startTime)} ${months[session.startTime.month - 1]} • ${DateFormat('kk:mm').format(session.startTime)} - ${DateFormat('kk:mm').format(session.endTime)}",
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                    ),
                  ],
                ),
                Spacer(),
                links != null && links?.length != 1
                    ? IconButton(
                        icon: Icon(Icons.link_outlined),
                        iconSize: 25,
                        onPressed: () async => await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => BottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            onClosing: () {},
                            builder: (context) {
                              List modalLinks = getUsefulLinks(links!);
                              return SizedBox(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: modalLinks.length + 1,
                                  itemBuilder: (context, index) => index == 0
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: ListTile(
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .links,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                            ),
                                          ),
                                        )
                                      : ListTile(
                                          title: Text(
                                            modalLinks[index - 1]['text'] ==
                                                    'report'
                                                ? 'Report'
                                                : modalLinks[index - 1]
                                                            ['text'] ==
                                                        'highlights'
                                                    ? 'Highlights'
                                                    : modalLinks[index - 1]
                                                                ['text'] ==
                                                            'lapByLap'
                                                        ? 'Lap-by-lap'
                                                        : modalLinks[index - 1]
                                                                    ['text']
                                                                .contains(
                                                                    'Grid')
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .startingGrid
                                                            : modalLinks[index -
                                                                1]['text'],
                                          ),
                                          leading: modalLinks[index - 1]
                                                      ['text'] ==
                                                  'report'
                                              ? Icon(Icons.analytics_outlined)
                                              : modalLinks[index - 1]['text'] ==
                                                      'highlights'
                                                  ? Icon(
                                                      Icons.play_arrow_outlined)
                                                  : Icon(
                                                      Icons.article_outlined),
                                          onTap: () => tapAction(
                                            modalLinks[index - 1]['linkType'],
                                            modalLinks[index - 1]['url'],
                                            context,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Headline extends StatelessWidget {
  final String headline;
  const Headline(this.headline, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Text(
        headline,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class RaceResults extends StatelessWidget {
  final String meetingCountryName;
  final String meetingKey;
  final List results;
  const RaceResults(
    this.meetingCountryName,
    this.meetingKey,
    this.results, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        10,
      ),
      child: Container(
        height: 295,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
              ),
              child: Text(
                meetingCountryName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.race,
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
                children: [
                  Expanded(
                    flex: 5,
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
                ],
              ),
            ),
            for (Map driverResults in results)
              Padding(
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
                              'FF${driverResults['teamColourCode']}',
                              radix: 16,
                            ),
                          ),
                          thickness: 6,
                          width: 6,
                          border: BorderRadius.circular(2.75),
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
                        driverResults['gapToLeader'] != "0.0" &&
                                driverResults['gapToLeader'] != "0"
                            ? '+${driverResults['gapToLeader']}'
                            : driverResults['raceTime'] ??
                                driverResults['positionValue'],
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
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed(
                        'race',
                        pathParameters: {
                          'meetingId': meetingKey,
                        },
                      ),
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

class CuratedSection extends StatelessWidget {
  final List items;
  const CuratedSection(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (Map article in items)
              NewsItem(
                championship == 'Formula 1'
                    ? News(
                        article['id'],
                        article['articleType'],
                        article['slug'],
                        article['title'],
                        article['metaDescription'] ?? ' ',
                        DateTime.parse(article['updatedAt']),
                        useDataSaverMode
                            ? article['thumbnail']['image']['renditions'] !=
                                    null
                                ? article['thumbnail']['image']['renditions']
                                    ['2col']
                                : article['thumbnail']['image']['url'] +
                                    '.transform/2col-retina/image.jpg'
                            : article['thumbnail']['image']['url'],
                      )
                    : News(
                        article['id'].toString(),
                        '',
                        '',
                        article['title'],
                        article['description'] ?? ' ',
                        DateTime.fromMillisecondsSinceEpoch(
                          article['publishFrom'],
                        ),
                        article['imageUrl'],
                        author: article['author'] != null
                            ? {'fullName': article['author']}
                            : null,
                      ),
                true,
              ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
