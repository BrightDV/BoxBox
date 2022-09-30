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

import 'package:boxbox/Screens/race_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final int index;

  RaceItem(
    this.item,
    this.index,
  );

  Widget build(BuildContext context) {
    int month = int.parse(this.item.date.split("-")[1]);
    String day = this.item.date.split("-")[2];
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    List months = [
      AppLocalizations.of(context).monthAbbreviationJanuary,
      AppLocalizations.of(context).monthAbbreviationFebruary,
      AppLocalizations.of(context).monthAbbreviationMarch,
      AppLocalizations.of(context).monthAbbreviationApril,
      AppLocalizations.of(context).monthAbbreviationMay,
      AppLocalizations.of(context).monthAbbreviationJune,
      AppLocalizations.of(context).monthAbbreviationJuly,
      AppLocalizations.of(context).monthAbbreviationAugust,
      AppLocalizations.of(context).monthAbbreviationSeptember,
      AppLocalizations.of(context).monthAbbreviationOctober,
      AppLocalizations.of(context).monthAbbreviationNovember,
      AppLocalizations.of(context).monthAbbreviationDecember,
    ];
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
        height: 80,
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
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.item.country,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Color(0xff171717),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          this.item.circuitName,
                          style: TextStyle(
                            color: Color.fromARGB(255, 136, 135, 135),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(), // TODO: container background
                  Text(
                    '$day ${months[month - 1].toLowerCase()} ',
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Color(0xff171717),
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
          index,
        );
      },
      physics: ClampingScrollPhysics(),
    );
  }
}
