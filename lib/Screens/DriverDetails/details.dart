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

import 'package:boxbox/Screens/DriverDetails/info.dart';
import 'package:boxbox/Screens/DriverDetails/results.dart';
import 'package:boxbox/Screens/DriverDetails/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DriverDetailsScreen extends StatefulWidget {
  final String driverId;
  final String givenName;
  final String familyName;
  const DriverDetailsScreen(
    this.driverId,
    this.givenName,
    this.familyName, {
    super.key,
  });

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.givenName} ${widget.familyName.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              TabItem(AppLocalizations.of(context)!.information),
              TabItem(AppLocalizations.of(context)!.results),
              TabItem(AppLocalizations.of(context)!.statistics),
            ],
          ),
        ),
        backgroundColor: useDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
        body: TabBarView(
          children: [
            DriverInfo(widget.driverId),
            DriverResults(widget.driverId),
            DriverStats(widget.driverId),
          ],
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String title;

  const TabItem(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Tab(
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

