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
import 'package:boxbox/classes/article.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/event_tracker.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/bottom_sheet.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:boxbox/providers/circuit/requests.dart';
import 'package:boxbox/providers/circuit/ui.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CircuitScreen extends StatelessWidget {
  final String meetingId;
  const CircuitScreen(this.meetingId, {super.key});

  @override
  Widget build(BuildContext context) {
    RaceDetails? details = CircuitRequestsProvider().getSavedDetails(meetingId);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder<RaceDetails>(
        future: CircuitRequestsProvider().getCircuitDetails(meetingId),
        builder: (context, snapshot) => snapshot.hasError
            ? details != null
                ? CircuitScreenContent(details)
                : Column(
                    children: [
                      AppBar(),
                      RequestErrorWidget(snapshot.error.toString()),
                    ],
                  )
            : snapshot.hasData
                ? CircuitScreenContent(snapshot.data!)
                : details != null
                    ? CircuitScreenContent(details)
                    : Column(
                        children: [
                          AppBar(),
                          Center(
                            child: LoadingIndicatorUtil(),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class CircuitScreenContent extends StatelessWidget {
  final RaceDetails details;
  const CircuitScreenContent(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              if (details.raceImageUrl != null)
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: MediaQuery.of(context).size.width > 780
                          ? Alignment(
                              Alignment.bottomCenter.x,
                              Alignment.bottomCenter.y * 0.97,
                            )
                          : Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: CachedNetworkImage(
                    fadeOutDuration: const Duration(milliseconds: 300),
                    fadeInDuration: const Duration(milliseconds: 300),
                    fit: BoxFit.cover,
                    imageUrl: details.raceImageUrl!,
                    colorBlendMode: BlendMode.darken,
                    height: MediaQuery.of(context).size.width > 780
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height * (4 / 9),
                    width: MediaQuery.of(context).size.width > 780
                        ? MediaQuery.of(context).size.width
                        : null,
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (4 / 9) - 110,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (details.flagImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: CachedNetworkImage(
                              errorWidget: (context, url, error) =>
                                  SizedBox(width: 53),
                              fadeOutDuration:
                                  const Duration(milliseconds: 300),
                              fadeInDuration: const Duration(milliseconds: 300),
                              placeholder: (context, url) =>
                                  SizedBox(width: 53),
                              fit: BoxFit.cover,
                              imageUrl: details.flagImageUrl!,
                              height: MediaQuery.of(context).size.width > 780
                                  ? 60
                                  : 30,
                              width: MediaQuery.of(context).size.width > 780
                                  ? 106
                                  : 53,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: details.flagImageUrl != null
                                ? MediaQuery.of(context).size.width > 780
                                    ? 20
                                    : 15
                                : 0,
                            bottom: MediaQuery.of(context).size.width > 780
                                ? 10
                                : 3,
                          ),
                          child: Text(
                            details.meetingDisplayName,
                            style: TextStyle(
                              fontFamily: 'Northwell',
                              fontSize: MediaQuery.of(context).size.width > 780
                                  ? 120
                                  : 70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        details.meetingCompleteName,
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
          if (details.headline != null) Headline(details.headline!),
          if (details.highlightsArticleId != null)
            BoxBoxButton(
              AppLocalizations.of(context)!.viewHighlights,
              Icon(
                Icons.play_arrow_outlined,
              ),
              route: 'article',
              pathParameters: {
                'id': details.highlightsArticleId!,
              },
              extra: {'isFromLink': true},
            ),
          if (details.results?.isNotEmpty ?? false)
            RaceResults(
              details.meetingDisplayName,
              details.meetingId,
              details.results!,
            ),
          if (details.articles?.isNotEmpty ?? false)
            CuratedSection(details.articles!),
          Sessions(details),
          if (details.hasFacts)
            BoxBoxButton(
              'Circuit facts',
              Icon(
                Icons.info_outline,
              ),
              isRoute: false,
              widget: CircuitDetailsScreen(
                details.meetingDisplayName,
                details.circuitOfficialName!,
                details.circuitMapImageUrl!,
                details.circuitDescriptionText!,
                details.circuitMapLinks!,
              ),
            ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class SessionItemForCircuit extends StatelessWidget {
  final Session session;
  final String meetingCountryName;
  final String meetingOfficialName;
  final String meetingId;
  final int sessionIndex;
  final List<Link>? links;
  const SessionItemForCircuit(
    this.session,
    this.meetingCountryName,
    this.meetingOfficialName,
    this.meetingId,
    this.sessionIndex, {
    this.links,
    super.key,
  });

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
        onTap: () => CircuitUIProvider().onSessionTapAction(
          session,
          meetingCountryName,
          meetingOfficialName,
          meetingId,
          context,
          sessionIndex,
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
                  child: session.sessionState == SessionState().RUNNING
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
                      : session.sessionState == SessionState().COMPLETED
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
                      session.sessionFullName!,
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
                (links?.length ?? 0) > 1
                    ? IconButton(
                        icon: Icon(Icons.link_outlined),
                        iconSize: 25,
                        onPressed: () async => await showCustomBottomSheet(
                          context,
                          SizedBox(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                30,
                                15,
                                30,
                                MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: links!.length + 1,
                                itemBuilder: (context, index) => index == 0
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: ListTile(
                                          title: Text(
                                            AppLocalizations.of(context)!.links,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      )
                                    : ListTile(
                                        title: Text(
                                          links![index - 1].text == 'report'
                                              ? 'Report'
                                              : links![index - 1].text ==
                                                      'highlights'
                                                  ? 'Highlights'
                                                  : links![index - 1].text ==
                                                          'lapByLap'
                                                      ? 'Lap-by-lap'
                                                      : links![index - 1]
                                                              .text
                                                              .contains('Grid')
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .startingGrid
                                                          : links![index - 1]
                                                                      .text ==
                                                                  'driverOfTheDay'
                                                              ? 'Driver of the Day'
                                                              : links![
                                                                      index - 1]
                                                                  .text,
                                        ),
                                        leading: links![index - 1].text ==
                                                'report'
                                            ? Icon(Icons.analytics_outlined)
                                            : links![index - 1].text ==
                                                    'highlights'
                                                ? Icon(
                                                    Icons.play_arrow_outlined,
                                                  )
                                                : Icon(
                                                    Icons.article_outlined,
                                                  ),
                                        onTap: () =>
                                            CircuitUIProvider().linkTapAction(
                                          links![index - 1].type,
                                          links![index - 1].url,
                                          context,
                                          meetingId,
                                        ),
                                      ),
                              ),
                            ),
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
  final List<DriverResult> results;
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
            for (DriverResult result in results)
              Padding(
                padding: const EdgeInsets.only(
                  top: 7,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        result.position,
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
                              'FF${result.teamColor}',
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
                      child: Text(result.code),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 6,
                      child: Text(result.gap),
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
  final List<News> items;
  const CuratedSection(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (News article in items) NewsItem(article, true),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}

class CircuitScreenFromMeetingName extends StatelessWidget {
  final String meetingName;
  CircuitScreenFromMeetingName(this.meetingName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: FutureBuilder(
          future:
              FormulaOneScraper().getMeetingIdFromTrack(meetingName, context),
          builder: (context, snapshot) => snapshot.hasError
              ? RequestErrorWidget(snapshot.error.toString())
              : snapshot.hasData
                  ? Container()
                  : LoadingIndicatorUtil(),
        ),
      ),
    );
  }
}

class Sessions extends StatelessWidget {
  final RaceDetails details;
  const Sessions(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              for (Session session in details.sessions)
                SessionItemForCircuit(
                  session,
                  details.meetingDisplayName,
                  details.meetingCompleteName,
                  details.meetingId,
                  details.sessions.length -
                      details.sessions.indexOf(session) -
                      1,
                  links: details.sessionsLinks?[session.sessionAbbreviation],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
