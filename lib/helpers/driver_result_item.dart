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
 * Copyright (c) 2022, BrightDV
 */

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DriverResultItem extends StatelessWidget {
  final DriverResult item;
  final int index;

  DriverResultItem(
    this.item,
    this.index,
  );

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(item.team);
    return Container(
      color: item.isFastest
          ? Color(0xffff00ff)
          : index % 2 == 1
              ? Color(0xff22222c)
              : Color(0xff15151f),
      height: 45,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                item.position,
                style: TextStyle(
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
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        item.isFastest ? Color(0xffab01ab) : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 7, bottom: 7),
                    child: Text(
                      item.time,
                      style: TextStyle(
                        color: item.isFastest || item.time == 'DNF'
                            ? Colors.white
                            : Color(0xff00ff00),
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
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        item.isFastest ? Color(0xffab01ab) : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      item.lapsDone!,
                      style: TextStyle(
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
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        item.isFastest ? Color(0xffab01ab) : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      item.points!,
                      style: TextStyle(
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
    );
  }
}

class RaceDriversResultsList extends StatelessWidget {
  final List<DriverResult> items;

  RaceDriversResultsList(this.items);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length + 1,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
          ? Container(
              color: Color(0xff383840),
              height: 45,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppLocalizations.of(context)?.positionAbbreviation ??
                            ' POS',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppLocalizations.of(context)?.driverAbbreviation ??
                            'DRI',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        AppLocalizations.of(context)?.time ?? 'TIME',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppLocalizations.of(context)?.laps ?? 'Laps',
                        style: TextStyle(
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
                        style: TextStyle(
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
  QualificationResultsItem(
    this.item,
    this.index,
    this.winningTimeQOne,
    this.winningTimeQTwo,
  );

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(this.item.team);
    return Container(
      color: index % 2 == 1 ? Color(0xff22222c) : Color(0xff15151f),
      height: 45,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 7,
                ),
                child: Text(
                  item.position,
                  style: TextStyle(
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
                padding: EdgeInsets.only(
                  left: 7,
                ),
                child: Text(
                  item.code,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: winningTimeQOne == item.timeq1
                        ? Color(0xffff00ff)
                        : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      item.timeq1,
                      style: TextStyle(
                        color: winningTimeQOne == item.timeq1
                            ? Colors.white
                            : item.timeq1 != '- -' && item.timeq1 != 'DNF'
                                ? Color(0xff00ff00)
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
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: winningTimeQTwo == item.timeq2
                        ? Color(0xffff00ff)
                        : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      item.timeq2,
                      style: TextStyle(
                        color: winningTimeQTwo == item.timeq2
                            ? Colors.white
                            : item.timeq2 != '--'
                                ? Color(0xff00ff00)
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
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: index == 0 ? Color(0xffff00ff) : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      item.timeq3,
                      style: TextStyle(
                        color: index == 0
                            ? Colors.white
                            : item.timeq3 != '--'
                                ? Color(0xff00ff00)
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
    );
  }
}

class QualificationDriversResultsList extends StatelessWidget {
  final List<DriverQualificationResult> items;

  QualificationDriversResultsList(this.items);
  @override
  Widget build(BuildContext context) {
    List resultsQOne = [];
    List resultsQTwo = [];
    items.forEach(
      (element) {
        if (element.timeq1 != '' && element.timeq1 != 'DNF') {
          resultsQOne.add(element.timeq1);
        }
        if (element.timeq2 != '' && element.timeq2 != '--') {
          resultsQTwo.add(element.timeq2);
        }
      },
    );
    resultsQOne.sort((a, b) => a.compareTo(b));
    resultsQTwo.sort((a, b) => a.compareTo(b));
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length + 1,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) => index == 0
          ? Container(
              color: Color(0xff383840),
              height: 45,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 7,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                                  ?.positionAbbreviation
                                  .substring(0, 1) ??
                              'P',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 7,
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.driverAbbreviation ??
                              'DRI',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}1",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}2",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "${AppLocalizations.of(context)?.qualifyings.substring(0, 1)}3",
                        style: TextStyle(
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
              resultsQOne[0],
              resultsQTwo[0],
            ),
    );
  }
}
