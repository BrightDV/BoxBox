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

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class Race {
  final String round;
  final String meetingId;
  final String raceName;
  final String date;
  final String raceHour;
  final String circuitId;
  final String circuitName;
  final String circuitUrl;
  final String country;
  final List<DateTime> sessionDates;
  final bool? isFirst;
  final String? raceCoverUrl;
  final String? detailsPath;
  final List? sessionStates;
  final bool? isPreSeasonTesting;
  final bool? hasRaceHour;

  Race(
    this.round,
    this.meetingId,
    this.raceName,
    this.date,
    this.raceHour,
    this.circuitId,
    this.circuitName,
    this.circuitUrl,
    this.country,
    this.sessionDates, {
    this.isFirst,
    this.raceCoverUrl,
    this.detailsPath,
    this.sessionStates,
    this.isPreSeasonTesting,
    this.hasRaceHour,
  });
}

class RaceItem extends StatelessWidget {
  final Race item;
  final int index;
  final bool isUpNext;

  const RaceItem(this.item, this.index, this.isUpNext, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'racing',
        pathParameters: {'meetingId': item.meetingId},
      ),
      child: index == 0 && isUpNext && (item.raceCoverUrl ?? '') != 'none'
          ? Column(
              children: [
                ImageRenderer(
                  item.raceCoverUrl != null
                      ? item.raceCoverUrl!
                      : RaceTracksUrls().getRaceCoverImageUrl(item.circuitId),
                  inSchedule: true,
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

  const RaceListItem(this.item, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String scheduleLastSavedFormat = '';
    if (championship == 'Formula 1') {
      scheduleLastSavedFormat = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    }
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool shouldUse12HourClock = Hive.box('settings')
        .get('shouldUse12HourClock', defaultValue: false) as bool;
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
    if (scheduleLastSavedFormat == 'ergast') {
      int month = int.parse(item.date.split("-")[1]);
      String day = item.date.split("-")[2];
      DateTime raceDate =
          DateTime.parse('${item.date} ${item.raceHour}').toLocal();

      String formatedRaceDate = shouldUse12HourClock
          ? DateFormat.jm().format(raceDate)
          : DateFormat.Hm().format(raceDate);

      return Container(
        padding: const EdgeInsets.all(2),
        height: 84,
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: index == 0
                  ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                  : const EdgeInsets.only(left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: useDarkMode
                            ? index % 2 == 0
                                ? HSLColor.fromColor(
                                    Theme.of(context).colorScheme.surface,
                                  ).withLightness(0.2).toColor()
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                            : const Color.fromARGB(255, 136, 135, 135),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              months[month - 1].toLowerCase(),
                              style: const TextStyle(
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
                    child: ListTile(
                      title: Text(
                        item.country,
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.circuitName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.hasRaceHour ?? true) Text(formatedRaceDate),
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
    } else {
      DateTime raceDate = DateTime.parse(item.date);
      int month = raceDate.month;
      String day = raceDate.day.toString();
      String formatedRaceDate = shouldUse12HourClock
          ? DateFormat.jm().format(raceDate)
          : DateFormat.Hm().format(raceDate);

      return Container(
        padding: const EdgeInsets.all(2),
        height: 84,
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: index == 0
                  ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                  : const EdgeInsets.only(left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: useDarkMode
                            ? index % 2 == 0
                                ? HSLColor.fromColor(
                                    Theme.of(context).colorScheme.surface,
                                  ).withLightness(0.2).toColor()
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                            : const Color.fromARGB(255, 136, 135, 135),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              months[month - 1].toLowerCase(),
                              style: const TextStyle(
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
                    child: ListTile(
                      title: Text(
                        item.country,
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.circuitName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.hasRaceHour ?? true) Text(formatedRaceDate),
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
}

class RacesList extends StatelessWidget {
  final List<Race> items;
  final bool isUpNext;
  final ScrollController? scrollController;
  final bool isCache;

  const RacesList(
    this.items,
    this.isUpNext, {
    Key? key,
    this.scrollController,
    this.isCache = false,
  }) : super(key: key);

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> scheduledNotification(String meetingId) async {
    List<NotificationModel> notifications =
        await AwesomeNotifications().listScheduledNotifications();
    if (notifications.isNotEmpty &&
        notifications[0].content?.payload?['meetingId'] == meetingId) {
      return;
    }

    Map race = await Formula1().getCircuitDetails(meetingId);
    for (var session in race['race']['meetingSessions']) {
      DateTime sessionDate = DateTime.parse(
        session['startTime'] + session['gmtOffset'],
      ).toLocal().subtract(
            Duration(minutes: 5),
          );

      if (sessionDate.isAfter(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: createUniqueId(),
            channelKey: 'eventTracker',
            title: race['race']['meetingName'],
            body: "Be ready! ${session['description']} is starting soon!",
            payload: {'meetingId': meetingId, 'session': session['session']},
          ),
          schedule: NotificationCalendar(
            allowWhileIdle: true,
            repeats: false,
            millisecond: 0,
            preciseAlarm: true,
            second: sessionDate.second,
            minute: sessionDate.minute,
            hour: sessionDate.hour,
            day: sessionDate.day,
            month: sessionDate.month,
            timeZone: 'GMT${session['gmtOffset']}',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty && isUpNext && !isCache) {
      scheduledNotification(items[0].meetingId);
    }
    return isUpNext
        ? ListView.builder(
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
            physics: const ClampingScrollPhysics(),
            //),
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
            physics: const ClampingScrollPhysics(),
          );
  }
}
