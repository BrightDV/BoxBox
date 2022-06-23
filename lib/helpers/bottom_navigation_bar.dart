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
import 'package:boxbox/helpers/drawer.dart';
import 'package:boxbox/Screens/home.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/standings.dart';

class MainBottomNavigationBar extends StatefulWidget {
  MainBottomNavigationBar({Key key}) : super(key: key);

  @override
  _MainBottomNavigationBarState createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;

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
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    List<Widget> _screens = [
      HomeScreen(),
      StandingsScreen(),
      ScheduleScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: useDarkMode ? Color(0xff202020) : Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: useDarkMode ? Colors.white : Colors.grey[600],
        currentIndex: _selectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed_outlined,
            ),
            activeIcon: Icon(
              Icons.feed,
            ),
            label: 'Actualités',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.emoji_events_outlined,
            ),
            activeIcon: Icon(
              Icons.emoji_events,
            ),
            label: 'Classements',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
            ),
            activeIcon: Icon(
              Icons.calendar_today,
            ),
            label: 'Calendrier',
          ),
        ],
        onTap: _onItemTapped,
      ),
      body: _screens.elementAt(_selectedIndex),
      backgroundColor: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
    );
  }
}
