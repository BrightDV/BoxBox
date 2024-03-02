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

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FreePracticeScreen extends StatelessWidget {
  final String sessionTitle;
  final int sessionIndex;
  final String circuitId;
  final int raceYear;
  final String raceName;
  final String? raceUrl;

  const FreePracticeScreen(
    this.sessionTitle,
    this.sessionIndex,
    this.circuitId,
    this.raceYear,
    this.raceName, {
    Key? key,
    this.raceUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionTitle),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<DriverResult>>(
        future: raceUrl != null
            ? FormulaOneScraper().scrapeFreePracticeResult(
                '',
                0,
                '',
                false,
                raceUrl: raceUrl,
              )
            : FormulaOneScraper().scrapeFreePracticeResult(
                circuitId,
                sessionIndex,
                'practice-$sessionIndex',
                true,
              ),
        builder: (context, snapshot) => snapshot.hasError
            ? snapshot.error.toString() == 'RangeError: Value not in range: 0'
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        AppLocalizations.of(context)!.dataNotAvailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RequestErrorWidget(
                    snapshot.error.toString() +
                        '\n' +
                        snapshot.stackTrace.toString(),
                  )
            : snapshot.hasError
                ? RequestErrorWidget(snapshot.error.toString())
                : snapshot.hasData
                    ? FreePracticeResultsList(
                        snapshot.data!,
                        raceYear,
                        raceName,
                        sessionIndex,
                      )
                    : const LoadingIndicatorUtil(),
      ),
    );
  }
}

class FreePracticeResultsList extends StatelessWidget {
  final List<DriverResult> results;
  final int raceYear;
  final String raceName;
  final int sessionIndex;

  const FreePracticeResultsList(
    this.results,
    this.raceYear,
    this.raceName,
    this.sessionIndex, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length + 2,
      itemBuilder: (context, index) => index == 0
          ? ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.youtube,
              ),
              title: Text(
                AppLocalizations.of(context)!.watchOnYoutube,
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                var yt = YoutubeExplode();
                final List<Video> searchResults = await yt.search.search(
                  "Formula 1 Free Practice $sessionIndex $raceName $raceYear",
                );
                final Video bestVideoMatch = searchResults[0];
                await launchUrl(
                  Uri.parse(
                    "https://youtube.com/watch?v=${bestVideoMatch.id.value}",
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
              tileColor: Theme.of(context).colorScheme.onSecondary,
            )
          : index == 1
              ? Container(
                  color: Theme.of(context).colorScheme.onSecondary,
                  height: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            AppLocalizations.of(context)!.positionAbbreviation,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            AppLocalizations.of(context)!.driverAbbreviation,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            AppLocalizations.of(context)!.time,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            AppLocalizations.of(context)!.gap,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            AppLocalizations.of(context)!.laps,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : FreePracticeResultItem(
                  results[index - 2],
                  index - 2,
                ),
    );
  }
}

class FreePracticeResultItem extends StatelessWidget {
  final DriverResult result;
  final int index;

  const FreePracticeResultItem(
    this.result,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Container(
      color: index % 2 == 1
          ? useDarkMode
              ? HSLColor.fromColor(
                  Theme.of(context).colorScheme.onSecondary,
                ).withLightness(0.26).toColor()
              : HSLColor.fromColor(
                  Theme.of(context).colorScheme.onPrimary,
                ).withLightness(0.88).toColor()
          : useDarkMode
              ? HSLColor.fromColor(
                  Theme.of(context).colorScheme.onSecondary,
                ).withLightness(0.18).toColor()
              : HSLColor.fromColor(
                  Theme.of(context).colorScheme.onPrimary,
                ).withLightness(0.82).toColor(),
      height: 45,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                result.time == '' ? 'DNF' : result.position,
                style: result.time == ''
                    ? TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.w600,
                      )
                    : TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: VerticalDivider(
                color: TeamBackgroundColor().getTeamColor(
                  result.team,
                ),
                thickness: 8,
                width: 25,
                indent: 7,
                endIndent: 7,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                result.code,
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xffff00ff)
                        : index % 2 == 1
                            ? useDarkMode
                                ? HSLColor.fromColor(
                                    Theme.of(context).colorScheme.onSecondary,
                                  ).withLightness(0.31).toColor()
                                : HSLColor.fromColor(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ).withLightness(0.84).toColor()
                            : useDarkMode
                                ? HSLColor.fromColor(
                                    Theme.of(context).colorScheme.onSecondary,
                                  ).withLightness(0.23).toColor()
                                : HSLColor.fromColor(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ).withLightness(0.78).toColor(),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.time == '' ? '--' : result.time,
                      style: TextStyle(
                        color: index == 0 || result.time == ''
                            ? Colors.white
                            : const Color(0xff00ff00),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 1
                        ? useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.31).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.84).toColor()
                        : useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.23).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.78).toColor(),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.fastestLap == '' ? '--' : result.fastestLap,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 1
                        ? useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.31).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.84).toColor()
                        : useDarkMode
                            ? HSLColor.fromColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ).withLightness(0.23).toColor()
                            : HSLColor.fromColor(
                                Theme.of(context).colorScheme.onPrimary,
                              ).withLightness(0.78).toColor(),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.lapsDone!,
                      textAlign: TextAlign.center,
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
