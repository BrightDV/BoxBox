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
import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/settings/settings_list.dart';

class MainDrawer extends StatefulWidget {
  final Function homeSetState;
  const MainDrawer(this.homeSetState);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
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
                  'Paramètres',
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
                }),
            ListTile(
                title: Text(
                  'À propos',
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
                }),
          ],
        ),
      ),
    );
  }
}
