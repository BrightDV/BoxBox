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

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/schedule_lands.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Race {
  final String round;
  final String raceName;
  final String date;
  final String raceHour;
  final String circuitId;
  final String circuitName;
  final String circuitUrl;
  final String country;

  Race(
    this.round,
    this.raceName,
    this.date,
    this.raceHour,
    this.circuitId,
    this.circuitName,
    this.circuitUrl,
    this.country,
  );
}

class RaceItem extends StatelessWidget {
  final Race item;
  final bool isFirst;
  final int index;

  RaceItem(
    this.item,
    this.isFirst,
    this.index,
  );

  Widget build(BuildContext context) {
    String finalDate = this.item.date.split("-").reversed.toList().join("/");
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaceDetailsScreen(
            item,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(2),
        height: isFirst ? 280 : 80,
        color: index % 2 == 1
            ? useDarkMode
                ? Color(0xff22222c)
                : Color(0xffffffff)
            : useDarkMode
                ? Color(0xff15151f)
                : Color(0xfff4f4f4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (isFirst)
              RaceImageProvider(
                this.item,
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        this.item.round,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Color(0xff171717),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            this.item.raceName,
                            style: TextStyle(
                              color: useDarkMode
                                  ? Colors.white
                                  : Color(0xff171717),
                            ),
                          ),
                          Text(
                            "${ScheduleLands().getLandName(this.item.country)} - $finalDate",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: useDarkMode
                                  ? Colors.white
                                  : Color(0xff171717),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RacesList extends StatelessWidget {
  final List<Race> items;
  final bool isUpNext;

  RacesList(this.items, this.isUpNext, {Key key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RaceItem(
          items[index],
          isUpNext ? index == 0 : false,
          index,
        );
      },
      physics: ClampingScrollPhysics(),
    );
  }
}

class RaceImageProvider extends StatelessWidget {
  final Race race;
  RaceImageProvider(this.race);

  Future<String> getCircuitImageUrl(Race race) async {
    return await RaceTracksUrls().getRaceTrackUrl(race.circuitId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCircuitImageUrl(this.race),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? Container(
                height: MediaQuery.of(context).size.width / (16 / 9),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      snapshot.data,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}
