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
import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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
          ? RaceListHeaderItem(item, index)
          : RaceListItem(item, index),
    );
  }
}

class RaceListHeaderItem extends StatelessWidget {
  final Race item;
  final int index;
  const RaceListHeaderItem(this.item, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String scheduleLastSavedFormat = '';
    if (championship == 'Formula 1') {
      scheduleLastSavedFormat = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    }
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
    int month;
    String day;
    DateTime raceDate;
    String formatedRaceDate;

    if (scheduleLastSavedFormat == 'ergast') {
      month = int.parse(item.date.split("-")[1]);
      day = item.date.split("-")[2];
      raceDate = DateTime.parse('${item.date} ${item.raceHour}').toLocal();

      formatedRaceDate = shouldUse12HourClock
          ? DateFormat.jm().format(raceDate)
          : DateFormat.Hm().format(raceDate);
    } else {
      raceDate = DateTime.parse(item.date);
      month = raceDate.month;
      day = raceDate.day.toString();
      formatedRaceDate = shouldUse12HourClock
          ? DateFormat.jm().format(raceDate)
          : DateFormat.Hm().format(raceDate);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: ImageRenderer(
            item.raceCoverUrl != null
                ? item.raceCoverUrl!
                : RaceTracksUrls().getRaceCoverImageUrl(item.circuitId),
            inSchedule: true,
          ),
        ),
        Column(
          children: [
            Text(
              item.country,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                item.circuitName,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Text(
              formatedRaceDate +
                  ' ∙ ' +
                  day +
                  ' ' +
                  months[month - 1].toLowerCase(),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
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

  // From https://stackoverflow.com/a/58711821
  String formattedTimeZoneOffset(DateTime time) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final duration = time.timeZoneOffset,
        hours = duration.inHours,
        minutes = duration.inMinutes.remainder(60).abs().toInt();

    return '${hours > 0 ? '+' : '-'}${twoDigits(hours.abs())}:${twoDigits(minutes)}';
  }

  Future<void> scheduledNotification(String meetingId) async {
    List<NotificationModel> notifications =
        await AwesomeNotifications().listScheduledNotifications();
    if (notifications.isNotEmpty &&
        notifications[0].content?.payload?['meetingId'] == meetingId) {
      return;
    }

    RaceDetails race = await Formula1().getCircuitDetails(meetingId);
    for (var session in race.sessions) {
      if (session.startTime.isAfter(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: createUniqueId(),
            channelKey: 'eventTracker',
            title: race.meetingCompleteName,
            body: "Be ready! ${session.sessionFullName} is starting soon!",
            payload: {
              'meetingId': meetingId,
              'session': session.sessionAbbreviation,
            },
          ),
          schedule: NotificationCalendar(
            allowWhileIdle: true,
            repeats: false,
            millisecond: 0,
            preciseAlarm: true,
            second: session.startTime.second,
            minute: session.startTime.minute,
            hour: session.startTime.hour,
            day: session.startTime.day,
            month: session.startTime.month,
            timeZone: 'GMT${formattedTimeZoneOffset(DateTime.now())}',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool notificationsEnabled = Hive.box('settings')
        .get('notificationsEnabled', defaultValue: false) as bool;
    if (items.isNotEmpty && isUpNext && !isCache && notificationsEnabled) {
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
