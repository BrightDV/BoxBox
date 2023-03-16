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

import 'package:boxbox/Screens/Compare/compare_drivers.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CompareHomeScreen extends StatefulWidget {
  const CompareHomeScreen({super.key});

  @override
  State<CompareHomeScreen> createState() => _CompareHomeScreenState();
}

class _CompareHomeScreenState extends State<CompareHomeScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: useDarkMode
                      ? const Color(0xff1d1d28)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Compare Drivers',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompareDriversScreen(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: useDarkMode
                      ? const Color(0xff1d1d28)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Compare Teams',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Scaffold(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
