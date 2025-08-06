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

import 'package:boxbox/Screens/driver_details.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DriverResultItem extends StatelessWidget {
  final DriverResult item;
  final int index;

  const DriverResultItem(this.item, this.index, {Key? key}) : super(key: key);

  Color getTeamColors(String teamId) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Color tC;
    if (championship == 'Formula 1') {
      tC = TeamBackgroundColor().getTeamColor(teamId);
    } else {
      tC = FormulaE().getTeamColor(teamId);
    }
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String raceResultsLastSavedFormat = Hive.box('requests')
        .get('f1RaceResultsLastSavedFormat', defaultValue: 'ergast');
    Color finalTeamColors = getTeamColors(item.team);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(
              item.driverId,
              item.givenName,
              item.familyName,
            ),
          ),
        );
      },
      child: Container(
        color: item.isFastest
            ? const Color(0xffff00ff)
            : index % 2 == 1
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
                  item.position == '666' || item.position == '0'
                      ? 'DNF'
                      : item.position == '66666'
                          ? 'DSQ'
                          : item.position,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: BoxBoxVerticalDivider(
                  color: item.teamColor != null
                      ? Color(
                          int.parse(
                            'FF${item.teamColor}',
                            radix: 16,
                          ),
                        )
                      : finalTeamColors,
                  thickness: 8,
                  width: 25,
                  indent: 7,
                  endIndent: 7,
                  border: BorderRadius.circular(2.75),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.code,
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: GestureDetector(
                    onTap: () => (item.time == 'DNF' ||
                                item.time == 'DNS' ||
                                item.time == 'DSQ') &&
                            item.status != null
                        ? Fluttertoast.showToast(
                            msg: item.status!,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Colors.grey.shade500,
                            fontSize: 16.0,
                          )
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.isFastest
                            ? const Color(0xffab01ab)
                            : index % 2 == 1
                                ? useDarkMode
                                    ? HSLColor.fromColor(
                                        Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ).withLightness(0.31).toColor()
                                    : HSLColor.fromColor(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ).withLightness(0.84).toColor()
                                : useDarkMode
                                    ? HSLColor.fromColor(
                                        Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ).withLightness(0.23).toColor()
                                    : HSLColor.fromColor(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ).withLightness(0.78).toColor(),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7),
                        child: Text(
                          item.time,
                          style: TextStyle(
                            color: item.isFastest
                                ? Colors.white
                                : item.time == 'DNF' ||
                                        item.time == 'DNS' ||
                                        item.time == 'DSQ'
                                    ? Colors.yellow
                                    : const Color(0xff00ff00),
                            decoration: (item.time == 'DNF' ||
                                        item.time == 'DNS' ||
                                        item.time == 'DSQ') &&
                                    item.status != null
                                ? TextDecoration.underline
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              raceResultsLastSavedFormat == 'ergast'
                  ? Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.isFastest
                                ? const Color(0xffab01ab)
                                : index % 2 == 1
                                    ? useDarkMode
                                        ? HSLColor.fromColor(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                          ).withLightness(0.31).toColor()
                                        : HSLColor.fromColor(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ).withLightness(0.84).toColor()
                                    : useDarkMode
                                        ? HSLColor.fromColor(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                          ).withLightness(0.23).toColor()
                                        : HSLColor.fromColor(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ).withLightness(0.78).toColor(),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              item.lapsDone ?? 'NA',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                flex: raceResultsLastSavedFormat == 'ergast' ? 3 : 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isFastest
                          ? const Color(0xffab01ab)
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
                        item.points!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaceDriversResultsList extends StatelessWidget {
  final List<DriverResult> items;

  const RaceDriversResultsList(this.items, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String raceResultsLastSavedFormat = Hive.box('requests')
        .get('f1RaceResultsLastSavedFormat', defaultValue: 'ergast');
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length + 1,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
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
                      flex: 6,
                      child: Text(
                        AppLocalizations.of(context)!.time,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    raceResultsLastSavedFormat == 'ergast'
                        ? Expanded(
                            flex: 3,
                            child: Text(
                              AppLocalizations.of(context)!.laps,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                    Expanded(
                      flex: raceResultsLastSavedFormat == 'ergast' ? 3 : 6,
                      child: Text(
                        AppLocalizations.of(context)!.pointsAbbreviation,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : DriverResultItem(
              items[index - 1],
              index - 1,
            ),
    );
  }
}

class QualificationResultsItem extends StatelessWidget {
  final DriverQualificationResult item;
  final int index;
  final String winningTimeQOne;
  final String winningTimeQTwo;
  const QualificationResultsItem(
      this.item, this.index, this.winningTimeQOne, this.winningTimeQTwo,
      {Key? key})
      : super(key: key);

  Color getTeamColors(String teamId) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Color tC;
    if (championship == 'Formula 1') {
      tC = TeamBackgroundColor().getTeamColor(teamId);
    } else {
      tC = FormulaE().getTeamColor(teamId);
    }
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    Color finalTeamColors = getTeamColors(item.team);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(
              item.driverId,
              item.givenName,
              item.familyName,
            ),
          ),
        );
      },
      child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 7,
                  ),
                  child: Text(
                    item.position.startsWith('666') ? 'DNF' : item.position,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: BoxBoxVerticalDivider(
                  color: item.teamColor != null
                      ? Color(
                          int.parse(
                            'FF${item.teamColor}',
                            radix: 16,
                          ),
                        )
                      : finalTeamColors,
                  thickness: 8,
                  width: 25,
                  indent: 7,
                  endIndent: 7,
                  border: BorderRadius.circular(2.75),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 7,
                  ),
                  child: Text(
                    item.code,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (winningTimeQOne == item.timeq1) &&
                              (item.timeq1 != '--')
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
                        item.timeq1,
                        style: TextStyle(
                          color: winningTimeQOne == item.timeq1
                              ? Colors.white
                              : item.timeq1 != '--'
                                  ? item.timeq1 == 'DNF' || item.timeq1 == 'DNS'
                                      ? Colors.yellow
                                      : const Color(0xff00ff00)
                                  : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (winningTimeQTwo == item.timeq2) &&
                              (item.timeq2 != '--')
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
                        item.timeq2,
                        style: TextStyle(
                          color: winningTimeQTwo == item.timeq2
                              ? Colors.white
                              : item.timeq2 != '--'
                                  ? item.timeq2 == 'DNF' || item.timeq2 == 'DNS'
                                      ? Colors.yellow
                                      : const Color(0xff00ff00)
                                  : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (index == 0) && (item.timeq3 != '--')
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
                        item.timeq3,
                        style: TextStyle(
                          color: index == 0
                              ? Colors.white
                              : item.timeq3 != '--'
                                  ? item.timeq3 == 'DNF' || item.timeq3 == 'DNS'
                                      ? Colors.yellow
                                      : const Color(0xff00ff00)
                                  : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QualificationDriversResultsList extends StatelessWidget {
  final List items;
  final Race? race;
  final String? raceUrl;
  final bool? isSprintQualifying;

  const QualificationDriversResultsList(
    this.items,
    this.race,
    this.raceUrl,
    this.isSprintQualifying, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    List resultsQOne = [];
    List resultsQTwo = [];
    for (var element in items) {
      if (element.timeq1 != '' && element.timeq1 != 'DNF') {
        resultsQOne.add(element.timeq1);
      }
      if (element.timeq2 != '' && element.timeq2 != '--') {
        resultsQTwo.add(element.timeq2);
      }
    }
    resultsQOne.sort((a, b) => a.compareTo(b));
    resultsQTwo.sort((a, b) => a.compareTo(b));
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length + 2,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
          ? GestureDetector(
              child: ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.youtube,
                ),
                title: Text(
                  AppLocalizations.of(context)!.watchHighlightsOnYoutube,
                  textAlign: TextAlign.center,
                ),
                onTap: () async {
                  var yt = YoutubeExplode();
                  final raceYear = race?.date.split('-')[0];
                  final List<Video> searchResults = await yt.search.search(
                    (raceUrl?.contains('sprint-qualifying') ?? false) ||
                            (isSprintQualifying ?? false)
                        ? "Formula 1 Sprint Qualifying Highlights ${race!.raceName} $raceYear"
                        : "$championship Qualifying Highlights ${race!.raceName} $raceYear",
                  );
                  final Video bestVideoMatch = searchResults[0];
                  await launchUrl(
                    Uri.parse(
                      "https://youtube.com/watch?v=${bestVideoMatch.id.value}", // here
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
                tileColor: Theme.of(context).colorScheme.onSecondary,
              ),
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
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 7,
                            ),
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.positionAbbreviation
                                      .substring(0, 1) ??
                                  'P',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 7,
                            ),
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.driverAbbreviation ??
                                  'DRI',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}1",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}2",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}3",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : QualificationResultsItem(
                  items[index - 2],
                  index - 2,
                  resultsQOne.isNotEmpty ? resultsQOne[0] : '--',
                  resultsQTwo.isNotEmpty ? resultsQTwo[0] : '--',
                ),
    );
  }
}
