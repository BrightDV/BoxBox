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
import 'package:boxbox/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

class Notifications {
  Constraints getConstraints() {
    String networkConnectionType = Hive.box('settings')
        .get('networkConnectionType', defaultValue: 'Wi-Fi') as String;
    if (networkConnectionType == 'Wi-Fi') {
      return Constraints(networkType: NetworkType.unmetered);
    } else {
      return Constraints(networkType: NetworkType.connected);
    }
  }

  Future<void> registerPeriodicTask() async {
    int refreshInterval =
        Hive.box('settings').get('refreshInterval', defaultValue: 6) as int;

    await Workmanager().initialize(
      callbackDispatcher,
    );
    await Workmanager().registerPeriodicTask(
      'newsLoader',
      "Load news in background",
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: Duration(hours: refreshInterval),
      initialDelay: Duration(hours: refreshInterval),
      constraints: Notifications().getConstraints(),
    );
  }

  Future<void> initializeNotifications() async {
    bool notificationsEnabled = Hive.box('settings')
        .get('notificationsEnabled', defaultValue: false) as bool;
    bool newsNotificationsEnabled = Hive.box('settings')
        .get('newsNotificationsEnabled', defaultValue: false) as bool;

    if (notificationsEnabled) {
      await AwesomeNotifications().initialize(
        'resource://drawable/notification_icon',
        [
          NotificationChannel(
            channelKey: 'eventTracker',
            channelName: 'New Grand Prix notifications',
            channelDescription: 'Show a notification before each GP.',
            importance: NotificationImportance.High,
            channelShowBadge: true,
          ),
          NotificationChannel(
            channelKey: 'newArticle',
            channelName: 'New article',
            channelDescription:
                'Show a notification when a new article is published.',
            importance: NotificationImportance.High,
            channelShowBadge: true,
          ),
        ],
      );
    }

    if (notificationsEnabled && newsNotificationsEnabled) {
      await registerPeriodicTask();
    }
  }

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> showArticleNotification(
      Map article, bool useDataSaverMode) async {
    String imageUrl = article['thumbnail']['image']['url'];
    if (useDataSaverMode) {
      if (article['thumbnail']['image']['renditions'] != null) {
        imageUrl = article['thumbnail']['image']['renditions']['2col-retina'];
      } else {
        imageUrl += '.transform/2col-retina/image.jpg';
      }
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'newArticle',
        title: article['title'],
        body: article['metaDescription'],
        largeIcon: imageUrl,
        bigPicture: imageUrl,
        hideLargeIconOnExpand: true,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'id': article['id'],
          'title': article['title'],
        },
      ),
    );
  }
}
