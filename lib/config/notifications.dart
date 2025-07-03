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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

class Notifications {
  Future<void> initializeNotifications() async {
    bool notificationsEnabled = Hive.box('settings')
        .get('notificationsEnabled', defaultValue: false) as bool;
    bool newsNotificationsEnabled = Hive.box('settings')
        .get('newsNotificationsEnabled', defaultValue: false) as bool;
    int refreshInterval =
        Hive.box('settings').get('refreshInterval', defaultValue: 6) as int;

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
      await Workmanager().initialize(
        callbackDispatcher,
      );
      await Workmanager().registerPeriodicTask(
        'newsLoader',
        "Load news in background",
        existingWorkPolicy: ExistingWorkPolicy.replace,
        frequency: Duration(hours: refreshInterval),
        initialDelay: Duration(hours: refreshInterval),
      );
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

  @pragma('vm:entry-point')
  void callbackDispatcher() {
    Workmanager().executeTask(
      (task, inputData) async {
        await Hive.initFlutter();
        Box hiveBox = await Hive.openBox("requests");
        Box settingsBox = await Hive.openBox("settings");
        Map cachedNews = hiveBox.get('news', defaultValue: {}) as Map;
        bool useDataSaverMode =
            settingsBox.get('useDataSaverMode', defaultValue: false) as bool;
        try {
          Map fetchedData = await Formula1().getRawNews(0);
          if (cachedNews.isNotEmpty &&
              fetchedData['items'][0]['id'] != cachedNews['items'][0]['id']) {
            bool hasBreaking = false;
            for (var article in fetchedData['items']) {
              if (article['id'] == cachedNews['items'][0]['id']) {
                break;
              } else if (article['breaking'] != null && article['breaking']) {
                showArticleNotification(article, useDataSaverMode);
                hasBreaking = true;
              }
            }
            if (!hasBreaking) {
              showArticleNotification(
                  fetchedData['items'][0], useDataSaverMode);
            }

            hiveBox.put('news', fetchedData);
          }
          return Future.value(true);
        } catch (error, _) {
          return Future.value(false);
        }
      },
    );
  }
}
