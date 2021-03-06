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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/Screens/driver_details.dart';

class Driver {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String points;

  Driver(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.points,
  );
}

class DriverResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String time;

  DriverResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.time,
  );
}

class DriverQualificationResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String timeq1;
  final String timeq2;
  final String timeq3;

  DriverQualificationResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.timeq1,
    this.timeq2,
    this.timeq3,
  );
}

class DriversList extends StatelessWidget {
  final List<Driver> items;

  DriversList({Key key, this.items});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return DriverItem(item: items[index]);
      },
    );
  }
}

class DriverItem extends StatelessWidget {
  DriverItem({this.item});

  final Driver item;

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(this.item.team);
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(
              this.item.driverId,
              this.item.givenName,
              this.item.familyName,
            ),
          ),
        );
      },
      child: Container(
        height: 120,
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
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              this.item.position,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: useDarkMode ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: VerticalDivider(
                              color: finalTeamColors,
                              thickness: 9,
                              width: 30,
                              //endIndent: 20,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    this.item.givenName,
                                    style: TextStyle(
                                      color: useDarkMode ? Colors.white54 : Colors.black54,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    this.item.familyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 19,
                                      color: useDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: int.parse(this.item.points) == 0 || int.parse(this.item.points) == 1
                                        ? Text(
                                            "${this.item.points} Point",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: useDarkMode ? Colors.white : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            "${this.item.points} Points",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: useDarkMode ? Colors.white : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
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
                ],
              ),
            ),
            DriverImageProvider(
              this.item.driverId,
            ),
          ],
        ),
      ),
    );
  }
}

class DriverImageProvider extends StatelessWidget {
  Future<String> getDriverImageUrl(String driverId) async {
    return await DriverResultsImage().getDriverImageURL(driverId);
  }

  final String driverId;
  DriverImageProvider(this.driverId);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDriverImageUrl(this.driverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) print("${snapshot.error}\nSnapshot Error :/ : $snapshot.data");
        return snapshot.hasData
            ? CachedNetworkImage(
                imageUrl: snapshot.data,
                placeholder: (context, url) => LoadingIndicatorUtil(),
                errorWidget: (context, url, error) => Icon(Icons.error_outlined),
                fadeOutDuration: Duration(milliseconds: 500),
                fadeInDuration: Duration(milliseconds: 500),
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}
