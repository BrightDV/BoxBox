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
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool notificationsEnabled = Hive.box('settings')
        .get('notificationsEnabled', defaultValue: false) as bool;
    bool sessionNotificationsEnabled = Hive.box('settings')
        .get('sessionNotificationsEnabled', defaultValue: false) as bool;
    bool newsNotificationsEnabled = Hive.box('settings')
        .get('newsNotificationsEnabled', defaultValue: false) as bool;
    int refreshInterval =
        Hive.box('settings').get('refreshInterval', defaultValue: 6) as int;
    Map durations = {
      2: '2 hours',
      6: '6 hours',
      12: '12 hours',
      24: '24 hours',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Enable notifications',
            ),
            value: notificationsEnabled,
            onChanged: (bool value) async {
              if (value) {
                bool isAllowed =
                    await AwesomeNotifications().isNotificationAllowed();
                if (!isAllowed) {
                  bool isAllowedAfterRequest = await AwesomeNotifications()
                      .requestPermissionToSendNotifications();
                  if (isAllowedAfterRequest) {
                    notificationsEnabled = value;
                    Hive.box('settings').put('notificationsEnabled', value);
                  }
                } else {
                  notificationsEnabled = value;
                  Hive.box('settings').put('notificationsEnabled', value);
                }
              } else {
                await Workmanager().cancelAll();
                await AwesomeNotifications().cancelAll();
                notificationsEnabled = value;
                Hive.box('settings').put('notificationsEnabled', value);
              }
              setState(() {});
            },
          ),
          SwitchListTile(
            title: Text(
              'Articles notifications',
            ),
            value: newsNotificationsEnabled,
            onChanged: notificationsEnabled
                ? (bool value) async {
                    if (value) {
                      await Workmanager().registerPeriodicTask(
                        'newsLoader',
                        "Load news in background",
                        existingWorkPolicy: ExistingWorkPolicy.replace,
                        frequency: const Duration(seconds: 30),
                        initialDelay: const Duration(hours: 2),
                      );
                    } else {
                      Workmanager().cancelAll();
                    }
                    setState(
                      () {
                        newsNotificationsEnabled = value;
                        Hive.box('settings')
                            .put('newsNotificationsEnabled', value);
                      },
                    );
                  }
                : null,
          ),
          ListTile(
            title: Text(
              'Refresh interval',
              style: TextStyle(),
            ),
            enabled: notificationsEnabled && newsNotificationsEnabled,
            //onTap: () {},
            trailing: DropdownButton(
              value: refreshInterval,
              onChanged: notificationsEnabled && newsNotificationsEnabled
                  ? (int? newValue) {
                      if (newValue != null) {
                        setState(
                          () {
                            refreshInterval = newValue;
                            Hive.box('settings')
                                .put('refreshInterval', newValue);
                          },
                        );
                      }
                    }
                  : null,
              items: <int>[
                2,
                6,
                12,
                24,
              ].map<DropdownMenuItem<int>>(
                (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      durations[value],
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Sessions notifications',
            ),
            subtitle: Text(
              'You need to go to the schedule screen in order to initialize notifications for the next Grand-Prix.',
            ),
            value: sessionNotificationsEnabled,
            onChanged: notificationsEnabled
                ? (bool value) async {
                    if (!value) {
                      AwesomeNotifications().cancelAll();
                    }
                    setState(
                      () {
                        sessionNotificationsEnabled = value;
                        Hive.box('settings').put(
                          'sessionNotificationsEnabled',
                          value,
                        );
                      },
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
