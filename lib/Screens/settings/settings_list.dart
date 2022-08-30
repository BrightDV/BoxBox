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
import 'package:boxbox/Screens/settings/appearance.dart';
import 'package:boxbox/Screens/settings/player.dart';

class SettingsScreen extends StatefulWidget {
  final Function update;
  const SettingsScreen(this.update);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _settingsSetState() {
    setState(() {});
    widget.update();
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      backgroundColor: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Apparence',
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: Icon(
                    Icons.palette_outlined,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppearanceScreen(
                          _settingsSetState,
                        ),
                      ),
                    );
                    // video.id.value,
                  },
                ),
                ListTile(
                  title: Text(
                    'Lecteur',
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: Icon(
                    Icons.play_arrow_outlined,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(),
                      ),
                    );
                    // video.id.value,
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
