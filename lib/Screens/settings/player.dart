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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen();
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    int playerQuality =
        Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecteur',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: 5,
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Qualité du lecteur',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Qualité du lecteur utilisée pour les vidéos dans les actualités..',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: playerQuality,
                dropdownColor: useDarkMode
                    ? Theme.of(context).backgroundColor
                    : Colors.white,
                onChanged: (newValue) {
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
                        value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
