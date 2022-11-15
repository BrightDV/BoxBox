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

import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/hall_of_fame.dart';
import 'package:boxbox/Screens/links.dart';
import 'package:boxbox/Screens/settings.dart';
import 'package:boxbox/Screens/signalr_client.dart';
import 'package:boxbox/Screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainDrawer extends StatefulWidget {
  final Function homeSetState;
  const MainDrawer(this.homeSetState);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  bool useDarkMode =
      Hive.box('settings').get('darkMode', defaultValue: true) as bool;
  bool enableExperimentalFeatures = Hive.box('settings')
      .get('enableExperimentalFeatures', defaultValue: false) as bool;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor:
            useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      ),
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Box, Box!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.hallOfFame,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.emoji_events_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HallOfFameScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.links,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.open_in_new_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LinksScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.settings_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      widget.homeSetState,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.about,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.info_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutScreen(),
                  ),
                );
              },
            ),
            enableExperimentalFeatures
                ? ListTile(
                    title: Text(
                      'SignalR Client',
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    leading: Icon(
                      Icons.settings_outlined,
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignalRClientScreen(),
                        ),
                      );
                    },
                  )
                : Container(),
            enableExperimentalFeatures
                ? ListTile(
                    title: Text(
                      'Article tests screen',
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    leading: Icon(
                      Icons.settings_outlined,
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestScreen(),
                        ),
                      );
                    },
                  )
                : Container(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            snapshot.data!.version,
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : Text(''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
