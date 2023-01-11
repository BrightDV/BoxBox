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

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/Screens/circuit.dart';
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
  final bool? isFirst;

  Race(
    this.round,
    this.raceName,
    this.date,
    this.raceHour,
    this.circuitId,
    this.circuitName,
    this.circuitUrl,
    this.country, {
    this.isFirst,
  });
}

class RaceItem extends StatelessWidget {
  final Race item;
  final int index;
  final bool isUpNext;

  RaceItem(
    this.item,
    this.index,
    this.isUpNext,
  );

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CircuitScreen(
            item,
          ),
        ),
      ),
      child: index == 0 && isUpNext
          ? Column(
              children: [
                FutureBuilder<String>(
                  future: RaceTracksUrls().getRaceCoverImageUrl(item.circuitId),
                  builder: (context, snapshot) => snapshot.hasData
                      ? ImageRenderer(
                          snapshot.data!,
                          inSchedule: true,
                        )
                      : LoadingIndicatorUtil(),
                ),
                RaceListItem(item, index),
              ],
            )
          : RaceListItem(item, index),
    );
  }
}

class RaceListItem extends StatelessWidget {
  final Race item;
  final int index;

  RaceListItem(
    this.item,
    this.index,
  );

  Widget build(BuildContext context) {
    int month = int.parse(this.item.date.split("-")[1]);
    String day = this.item.date.split("-")[2];
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
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
    return Container(
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
            padding: index == 0
                ? EdgeInsets.fromLTRB(10, 0, 10, 10)
                : EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: useDarkMode
                          ? index % 2 == 0
                              ? Color.fromARGB(255, 36, 36, 48)
                              : Color.fromARGB(255, 23, 23, 34)
                          : Color.fromARGB(255, 136, 135, 135),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            months[month - 1].toLowerCase(),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.item.country,
                          style: TextStyle(
                            color:
                                useDarkMode ? Colors.white : Color(0xff171717),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RacesList extends StatelessWidget {
  final List<Race> items;
  final bool isUpNext;
  final ScrollController? scrollController;

  RacesList(
    this.items,
    this.isUpNext, {
    Key? key,
    this.scrollController,
  });

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> scheduledNotification(Race race) async {
    DateTime date = DateTime.parse(race.date);
    date.subtract(
      Duration(
        days: 3,
      ),
    );
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'eventTracker',
        title: "A Grand-Prix is starting soon.",
        body: "Be ready for the Free Practices!",
      ),
      schedule: NotificationCalendar(
        allowWhileIdle: true,
        repeats: false,
        millisecond: 0,
        second: date.second,
        minute: date.minute,
        hour: date.hour,
        day: date.day,
        month: date.month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isUpNext
        ? FutureBuilder(
            future: scheduledNotification(items[0]),
            builder: (context, snapshot) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              controller: scrollController,
              itemBuilder: (context, index) => isUpNext
                  ? RaceItem(
                      items[index],
                      index,
                      isUpNext,
                    )
                  : RaceItem(
                      items[items.length - index - 1],
                      index,
                      isUpNext,
                    ),
              physics: ClampingScrollPhysics(),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: items.length,
            controller: scrollController,
            itemBuilder: (context, index) => isUpNext
                ? RaceItem(
                    items[index],
                    index,
                    isUpNext,
                  )
                : RaceItem(
                    items[items.length - index - 1],
                    index,
                    isUpNext,
                  ),
            physics: ClampingScrollPhysics(),
          );
  }
}
