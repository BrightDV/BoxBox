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

import 'package:boxbox/Screens/DriverDetails/details.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DriverResultItem extends StatelessWidget {
  final DriverResult item;
  final int index;

  const DriverResultItem(this.item, this.index, {Key? key}) : super(key: key);

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
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
        color: item.isFastest
            ? const Color(0xffff00ff)
            : index % 2 == 1
                ? const Color(0xff22222c)
                : const Color(0xff15151f),
        height: 45,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.position,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: VerticalDivider(
                  color: finalTeamColors,
                  thickness: 8,
                  width: 25,
                  indent: 7,
                  endIndent: 7,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.code,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isFastest
                          ? const Color(0xffab01ab)
                          : const Color(0xff383840),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, bottom: 7),
                      child: Text(
                        item.time,
                        style: TextStyle(
                          color: item.isFastest
                              ? Colors.white
                              : item.time == 'DNF'
                                  ? Colors.yellow
                                  : const Color(0xff00ff00),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isFastest
                          ? const Color(0xffab01ab)
                          : const Color(0xff383840),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        item.lapsDone!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isFastest
                          ? const Color(0xffab01ab)
                          : const Color(0xff383840),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        item.points!,
                        style: const TextStyle(
                          color: Colors.white,
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

class RaceDriversResultsList extends StatelessWidget {
  final List<DriverResult> items;

  const RaceDriversResultsList(this.items, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length + 1,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
          ? Container(
              color: const Color(0xff383840),
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppLocalizations.of(context)?.positionAbbreviation ??
                            ' POS',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
                        AppLocalizations.of(context)?.driverAbbreviation ??
                            'DRI',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        AppLocalizations.of(context)?.time ?? 'TIME',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppLocalizations.of(context)?.laps ?? 'Laps',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppLocalizations.of(context)?.pointsAbbreviation ??
                            'PTS',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
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
        color:
            index % 2 == 1 ? const Color(0xff22222c) : const Color(0xff15151f),
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
                    item.position,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: VerticalDivider(
                  color: finalTeamColors,
                  thickness: 8,
                  width: 25,
                  indent: 7,
                  endIndent: 7,
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
                    style: const TextStyle(
                      color: Colors.white,
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
                      color: (winningTimeQOne == item.timeq1) &&
                              (item.timeq1 != '--')
                          ? const Color(0xffff00ff)
                          : const Color(0xff383840),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        item.timeq1,
                        style: TextStyle(
                          color: winningTimeQOne == item.timeq1
                              ? Colors.white
                              : item.timeq1 != '--' && item.timeq1 != 'DNF'
                                  ? const Color(0xff00ff00)
                                  : item.timeq1 == 'DNF'
                                      ? Colors.yellow
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
                          : const Color(0xff383840),
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
                                  ? const Color(0xff00ff00)
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
                          : const Color(0xff383840),
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
                                  ? const Color(0xff00ff00)
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
  final List<DriverQualificationResult> items;

  const QualificationDriversResultsList(this.items, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
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
      itemCount: items.length + 1,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
          ? Container(
              color: const Color(0xff383840),
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
                          style: const TextStyle(
                            color: Colors.white,
                          ),
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
                          AppLocalizations.of(context)?.driverAbbreviation ??
                              'DRI',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}1",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}2",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}3",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : QualificationResultsItem(
              items[index - 1],
              index - 1,
              resultsQOne.isNotEmpty ? resultsQOne[0] : '--',
              resultsQTwo.isNotEmpty ? resultsQTwo[0] : '--',
            ),
    );
  }
}
