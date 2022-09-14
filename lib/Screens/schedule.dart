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

import 'dart:async';

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor:
            useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
        body: TabBarView(
          children: [
            ScheduleWidget(false),
            ScheduleWidget(true),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: Size(200, 100),
          child: Container(
            height: 50,
            child: Card(
              elevation: 3,
              color: Theme.of(context).primaryColor,
              child: TabBar(
                tabs: [
                  Text(
                    AppLocalizations.of(context).previous,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).next,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleWidget extends StatelessWidget {
  final bool toCome;
  ScheduleWidget(this.toCome, {Key key}) : super(key: key);

  FutureOr<List<Race>> getRacesList(bool toCome) async {
    return await ErgastApi().getLastSchedule(toCome);
  }

  @override
  Widget build(BuildContext context) {
    Map schedule =
        Hive.box('requests').get('schedule', defaultValue: {}) as Map;
    return FutureBuilder<List<Race>>(
      future: getRacesList(toCome),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          schedule['MRData'] != null
              ? RacesList(
                  ErgastApi().formatLastSchedule(
                    schedule,
                    toCome,
                  ),
                  toCome,
                )
              : RequestErrorWidget(snapshot.error.toString());
        return snapshot.hasData
            ? RacesList(
                snapshot.data,
                toCome,
              )
            : schedule['MRData'] != null
                ? RacesList(
                    ErgastApi().formatLastSchedule(
                      schedule,
                      toCome,
                    ),
                    toCome,
                  )
                : LoadingIndicatorUtil();
      },
    );
  }
}
