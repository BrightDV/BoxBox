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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'package:boxbox/Screens/FormulaYou/home.dart';
import 'package:boxbox/Screens/LivetimingArchive/races_list.dart';
import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/Compare/compare_home.dart';
import 'package:boxbox/Screens/downloads.dart';
import 'package:boxbox/Screens/hall_of_fame.dart';
import 'package:boxbox/Screens/history.dart';
import 'package:boxbox/Screens/MixedNews/mixed_news.dart';
import 'package:boxbox/Screens/settings.dart';
import 'package:boxbox/Screens/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainDrawer extends StatelessWidget {
  final Function homeSetState;

  MainDrawer(this.homeSetState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool enableExperimentalFeatures = Hive.box('settings')
        .get('enableExperimentalFeatures', defaultValue: false) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Center(
              child: Text(
                'Box, Box!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          championship == 'Formula 1'
              ? ListTile(
                  title: Text(
                    'Formula You',
                  ),
                  leading: Icon(
                    Icons.account_circle_outlined,
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
                )
              : Container(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.newsMix,
            ),
            leading: Icon(
              Icons.dynamic_feed_outlined,
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
          championship == 'Formula 1'
              ? ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.hallOfFame,
                  ),
                  leading: Icon(
                    Icons.emoji_events_outlined,
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
                )
              : Container(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.history,
            ),
            leading: Icon(
              Icons.history_outlined,
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
          !kIsWeb
              ? ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.downloads,
                  ),
                  leading: Icon(
                    Icons.save_alt_rounded,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadsScreen(),
                      ),
                    );
                  },
                )
              : Container(),
          Divider(
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.settings,
            ),
            leading: Icon(
              Icons.settings_outlined,
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    homeSetState,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.about,
            ),
            leading: Icon(
              Icons.info_outlined,
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
                  ),
                  leading: Icon(
                    Icons.settings_outlined,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArchiveRacesListScreen(),
                      ),
                    );
                  },
                )
              : Container(),
          enableExperimentalFeatures
              ? ListTile(
                  title: Text(
                    'Article Test Screen',
                  ),
                  leading: Icon(
                    Icons.settings_outlined,
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
                  ),
                  leading: Icon(
                    Icons.compare_arrows_outlined,
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
                        ),
                      )
                    : const Text(''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
