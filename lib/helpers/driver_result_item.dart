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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';

class DriverResultItem extends StatelessWidget {
  DriverResultItem({this.item, this.isRaceWinner});

  final DriverResult item;
  final bool isRaceWinner;

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(this.item.team);
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Container(
      height: isRaceWinner ? 140 : 60,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: useDarkMode ? Color(0xff343434) : Colors.grey[200],
            width: 0.5,
          ),
          bottom: BorderSide(
            color: useDarkMode ? Color(0xff343434) : Colors.grey[200],
            width: 0.5,
          ),
        ),
      ),
      child: isRaceWinner
          ? Row(
              children: <Widget>[
                DriverImageProvider(
                  this.item.driverId,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: VerticalDivider(
                                      color: finalTeamColors,
                                      thickness: 8,
                                      width: 30,
                                      endIndent: 10,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          this.item.givenName,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: useDarkMode ? Colors.white54 : Colors.black54,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          this.item.familyName,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: useDarkMode ? Colors.white : Colors.black,
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
                      ),
                      Text(
                        this.item.time,
                        style: TextStyle(
                          fontSize: 20,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              this.item.position,
                              style: TextStyle(
                                color: useDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: VerticalDivider(
                            color: finalTeamColors,
                            thickness: 7,
                            width: 30,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: VerticalDivider(
                            color: Colors.transparent,
                            thickness: 7,
                            width: 30,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                this.item.givenName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: useDarkMode ? Colors.white54 : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                this.item.familyName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: useDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            this.item.time,
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class RaceDriversResultsList extends StatelessWidget {
  final List<DriverResult> items;

  RaceDriversResultsList(this.items);
  @override
  Widget build(BuildContext context) {
    bool isRaceWinner = true;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index != 0 && index != 1 && index != 2) {
          isRaceWinner = false;
        } else {
          isRaceWinner = true;
        }
        return DriverResultItem(
          item: items[index],
          isRaceWinner: isRaceWinner,
        );
      },
    );
  }
}

class QualificationResultsItem extends StatelessWidget {
  final DriverQualificationResult item;
  QualificationResultsItem(this.item);

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(this.item.team);
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: useDarkMode ? Color(0xff343434) : Colors.grey[200],
          ),
          bottom: BorderSide(
            color: useDarkMode ? Color(0xff343434) : Colors.grey[200],
          ),
        ),
      ),
      height: 55,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                item.position,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
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
                width: 30,
                indent: 10,
                endIndent: 10,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.code,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: useDarkMode ? Color(0xff343434) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.timeq1,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: useDarkMode ? Color(0xff343434) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.timeq2,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: useDarkMode ? Color(0xff343434) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item.timeq3,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
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
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return QualificationResultsItem(
          items[index],
        );
      },
    );
  }
}
