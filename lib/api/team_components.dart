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
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/helpers/team_car_image.dart';

class Team {
  final String constructorId;
  final String position;
  final String name;
  final String points;
  final String wins;

  Team(
    this.constructorId,
    this.position,
    this.name,
    this.points,
    this.wins,
  );
  factory Team.fromMap(Map<String, dynamic> json) {
    return Team(json['constructorId'], json['position'], json['name'], json['points'], json['wins']);
  }
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(json['constructorId'], json['position'], json['name'], json['points'], json['wins']);
  }
}

class TeamItem extends StatelessWidget {
  TeamItem({this.item});

  final Team item;

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  Widget build(BuildContext context) {
    Color finalTeamColors = getTeamColors(this.item.constructorId);
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${this.item.position}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: VerticalDivider(
              color: finalTeamColors,
              thickness: 9,
              width: 40,
              indent: 30,
              endIndent: 30,
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${this.item.name}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                int.parse(this.item.points) == 0 || int.parse(this.item.points) == 1
                    ? Text(
                        "${this.item.points} Point",
                        style: TextStyle(
                          fontSize: 18,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      )
                    : Text(
                        "${this.item.points} Points",
                        style: TextStyle(
                          fontSize: 18,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: int.parse(this.item.wins) == 0 || int.parse(this.item.wins) == 1
                      ? Text(
                          "${this.item.wins} Victoire",
                          style: TextStyle(
                            fontSize: 17,
                            color: useDarkMode ? Colors.white : Colors.black,
                          ),
                        )
                      : Text(
                          "${this.item.wins} Victoires",
                          style: TextStyle(
                            fontSize: 17,
                            color: useDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: TeamCarImageProvider(
              this.item.constructorId,
            ),
          ),
        ],
      ),
    );
  }
}

class TeamCarImageProvider extends StatelessWidget {
  Future<String> getCircuitImageUrl(String teamId) async {
    return await TeamCarImage().getTeamCarImageURL(teamId);
  }

  final String teamId;
  TeamCarImageProvider(this.teamId);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCircuitImageUrl(this.teamId),
      builder: (context, snapshot) {
        if (snapshot.hasError) print("${snapshot.error}\nSnapshot Error :/ : $snapshot.data");
        return snapshot.hasData
            ? AspectRatio(
                aspectRatio: 200 / 100,
                child: Transform(
                  transform: Matrix4.rotationY(60.0),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment(0.9, 0.0),
                        image: CachedNetworkImageProvider(
                          snapshot.data,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}

class TeamsList extends StatelessWidget {
  final List<Team> items;

  TeamsList({Key key, this.items});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TeamItem(item: items[index]);
      },
    );
  }
}
