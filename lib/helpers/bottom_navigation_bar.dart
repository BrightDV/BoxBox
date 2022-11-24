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

import 'package:boxbox/helpers/drawer.dart';
import 'package:boxbox/Screens/home.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hidable/hidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainBottomNavigationBar extends StatefulWidget {
  MainBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MainBottomNavigationBarState createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;
  final ScrollController scrollController = ScrollController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _homeSetState() {
    setState(() {});
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
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    List<Widget> _screens = [
      HomeScreen(scrollController),
      StandingsScreen(scrollController: scrollController),
      ScheduleScreen(scrollController: scrollController),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Box, Box!',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      drawer: MainDrawer(_homeSetState),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      bottomNavigationBar: Hidable(
        controller: scrollController,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              useDarkMode ? Color.fromARGB(255, 16, 16, 24) : Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: useDarkMode ? Colors.white : Colors.grey[600],
          currentIndex: _selectedIndex,
          elevation: 10.0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.feed_outlined,
              ),
              activeIcon: Icon(
                Icons.feed,
              ),
              label: AppLocalizations.of(context)?.news,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.emoji_events_outlined,
              ),
              activeIcon: Icon(
                Icons.emoji_events,
              ),
              label: AppLocalizations.of(context)?.standings,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_today_outlined,
              ),
              activeIcon: Icon(
                Icons.calendar_today,
              ),
              label: AppLocalizations.of(context)?.schedule,
            ),
          ],
          onTap: _onItemTapped,
        ),
      ),
      body: _screens.elementAt(_selectedIndex),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
    );
  }
}
