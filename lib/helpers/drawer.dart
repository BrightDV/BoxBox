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

import 'package:boxbox/Screens/FormulaYou/home.dart';
import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/Compare/compare_home.dart';
import 'package:boxbox/Screens/hall_of_fame.dart';
import 'package:boxbox/Screens/history.dart';
import 'package:boxbox/Screens/MixedNews/mixed_news.dart';
import 'package:boxbox/Screens/LivetimingArchive/live_timing.dart';
import 'package:boxbox/Screens/settings.dart';
import 'package:boxbox/Screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainDrawer extends StatefulWidget {
  final Function homeSetState;
  const MainDrawer(this.homeSetState, {Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
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
        canvasColor: useDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
      ),
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Box, Box!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Formula You',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.account_circle_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalizedHomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.newsMix,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.dynamic_feed_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MixedNewsScreen(),
                  ),
                );
              },
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
                    builder: (context) => const HallOfFameScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
              leading: Icon(
                Icons.history_outlined,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
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
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            enableExperimentalFeatures
                ? ListTile(
                    title: Text(
                      'Live Timing Feed',
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
                          builder: (context) => const LiveTimingScreen(),
                        ),
                      );
                    },
                  )
                : Container(),
            enableExperimentalFeatures
                ? ListTile(
                    title: Text(
                      'Article Test Screen',
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
                          builder: (context) => const TestScreen(),
                        ),
                      );
                    },
                  )
                : Container(),
            enableExperimentalFeatures
                ? ListTile(
                    title: Text(
                      'Compare',
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    leading: Icon(
                      Icons.compare_arrows_outlined,
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompareHomeScreen(),
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
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            snapshot.data!.version,
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : const Text(''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
