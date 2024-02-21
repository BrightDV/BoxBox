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

import 'package:boxbox/Screens/Compare/compare_results.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CompareDriversScreen extends StatelessWidget {
  const CompareDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare drivers',
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          // multiple years support
          future: ErgastApi().getDriverList('current'),
          builder: (context, snapshot) => snapshot.hasError
              ? RequestErrorWidget(
                  snapshot.error.toString(),
                )
              : snapshot.hasData
                  ? DriverSelector(
                      snapshot.data!,
                      snapshot.data!,
                    )
                  : const LoadingIndicatorUtil(),
        ),
      ),
    );
  }
}

class DriverSelector extends StatefulWidget {
  final List<String> driverIds;
  final List<String> driverNames;
  const DriverSelector(this.driverIds, this.driverNames, {super.key});

  @override
  State<DriverSelector> createState() => _DriverSelectorState();
}

class _DriverSelectorState extends State<DriverSelector> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String firstDriverSelected = Hive.box('compare').get(
      'firstDriverSelected',
      defaultValue: widget.driverNames[0],
    ) as String;
    String secondDriverSelected = Hive.box('compare').get(
      'secondDriverSelected',
      defaultValue: widget.driverNames[1],
    ) as String;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Compare Drivers',
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            // textAlign: TextAlign.center,
          ),
        ),
        ListTile(
          title: Text(
            'First Driver',
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton<String>(
            value: firstDriverSelected,
            dropdownColor: useDarkMode
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white,
            onChanged: (String? newDriverId) {
              if (newDriverId != null) {
                setState(
                  () {
                    firstDriverSelected = newDriverId;
                    Hive.box('compare').put(
                      'firstDriverSelected',
                      firstDriverSelected,
                    );
                  },
                );
              }
            },
            items: widget.driverNames.map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
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
        ListTile(
          title: Text(
            'Second Driver',
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton<String>(
            value: secondDriverSelected,
            dropdownColor: useDarkMode
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white,
            onChanged: (String? newDriverId) {
              if (newDriverId != null) {
                setState(
                  () {
                    secondDriverSelected = newDriverId;
                    Hive.box('compare').put(
                      'secondDriverSelected',
                      secondDriverSelected,
                    );
                  },
                );
              }
            },
            items: widget.driverNames.map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
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
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompareResultsScreen(
                  'drivers',
                  firstDriverSelected,
                  secondDriverSelected,
                ),
              ),
            ),
            child: const Text('Compare !'),
          ),
        ),
      ],
    );
  }
}
