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

import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlayerSettingsScreen extends StatefulWidget {
  const PlayerSettingsScreen({super.key});

  @override
  State<PlayerSettingsScreen> createState() => _PlayerSettingsScreenState();
}

class _PlayerSettingsScreenState extends State<PlayerSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    int playerQuality =
        Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    bool swipeUpToEnterFullScreen = Hive.box('settings')
        .get('swipeUpToEnterFullScreen', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.player),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.playerQuality,
              style: TextStyle(),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.playerQualitySub,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: playerQuality,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      playerQuality = newValue;
                      Hive.box('settings').put('playerQuality', newValue);
                    },
                  );
                }
              },
              items: <int>[
                180,
                360,
                720,
              ].map<DropdownMenuItem<int>>(
                (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '${value}p',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          if (!kIsWeb)
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context)!.fullScreenGestures,
              ),
              value: swipeUpToEnterFullScreen,
              onChanged: (bool value) {
                setState(
                  () {
                    swipeUpToEnterFullScreen = value;
                    Hive.box('settings').put('swipeUpToEnterFullScreen', value);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
