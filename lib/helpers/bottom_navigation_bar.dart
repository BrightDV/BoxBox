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

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/Screens/videos.dart';
import 'package:boxbox/helpers/drawer.dart';
import 'package:boxbox/Screens/home.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:boxbox/providers/general/ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:hidable/hidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;
  List<Widget> actions = [];
  final ScrollController scrollController = ScrollController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        actions = [
          IconButton(
            icon: const Icon(
              Icons.close,
            ),
            onPressed: () {},
          ),
        ];
      } else {
        actions = [];
      }
    });
  }

  void _homeSetState() {
    setState(() {});
  }

  // ref: https://github.com/insolite-dev/hidable/issues/26#issuecomment-1752105018
  double customHidableVisibility(
      ScrollPosition position, double currentVisibility) {
    const double deltaFactor = 0.04;

    // scrolls down
    if (position.userScrollDirection == ScrollDirection.reverse) {
      return (currentVisibility - deltaFactor).clamp(0, 1);
    }

    // scrolls up
    if (position.userScrollDirection == ScrollDirection.forward) {
      return (currentVisibility + deltaFactor).clamp(0, 1);
    }
    return currentVisibility;
  }

  @override
  Widget build(BuildContext context) {
    int themeMode =
        Hive.box('settings').get('themeMode', defaultValue: 0) as int;

    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    themeMode == 0
        ? Hive.box('settings').put('darkMode', isDark)
        : themeMode == 1
            ? Hive.box('settings').put('darkMode', false)
            : Hive.box('settings').put('darkMode', true);
    if (!kIsWeb) {
      FileDownloader().configureNotification(
        running: TaskNotification(
          AppLocalizations.of(context)!.downloadRunning,
          '{displayName}',
        ),
        complete: TaskNotification(
          AppLocalizations.of(context)!.downloadComplete,
          '{displayName}',
        ),
        error: TaskNotification(
          AppLocalizations.of(context)!.downloadFailed,
          '{displayName}',
        ),
        paused: TaskNotification(
          AppLocalizations.of(context)!.downloadPaused,
          '{displayName}',
        ),
        progressBar: true,
      );
    }

    List<Widget> screens = [
      HomeScreen(scrollController),
      VideosScreen(scrollController),
      StandingsScreen(scrollController: scrollController),
      ScheduleScreen(scrollController: scrollController),
    ];
    if (_selectedIndex == 0) {
      actions = UIProvider().getNewsAppBarActions(context);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Box, Box!',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: actions,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: MainDrawer(_homeSetState),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 4,
      bottomNavigationBar: kIsWeb
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              elevation: 10.0,
              items: UIProvider().getBottomNavigationBarButtons(context),
              onTap: _onItemTapped,
            )
          : Hidable(
              controller: scrollController,
              visibility: (position, currentVisibility) =>
                  customHidableVisibility(
                position,
                currentVisibility,
              ),
              preferredWidgetSize: Size(double.infinity, 58),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                elevation: 10.0,
                items: UIProvider().getBottomNavigationBarButtons(context),
                onTap: _onItemTapped,
              ),
            ),
      body: screens.elementAt(_selectedIndex),
    );
  }
}
