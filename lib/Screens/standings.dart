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

import 'dart:async';

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StandingsScreen extends StatefulWidget {
  final bool? switchToTeamStandings;
  final ScrollController? scrollController;
  StandingsScreen({
    Key? key,
    this.switchToTeamStandings,
    this.scrollController,
  }) : super(key: key);

  @override
  _StandingsScreenState createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return DefaultTabController(
      length: 2,
      initialIndex: widget.switchToTeamStandings != null ? 1 : 0,
      child: Scaffold(
        backgroundColor:
            useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
        body: TabBarView(
          children: [
            DriversStandingsWidget(scrollController: widget.scrollController),
            TeamsStandingsWidget(scrollController: widget.scrollController),
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
                    AppLocalizations.of(context)!.drivers,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.teams,
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

class DriversStandingsWidget extends StatelessWidget {
  final ScrollController? scrollController;

  DriversStandingsWidget({Key? key, this.scrollController}) : super(key: key);

  Future<List<Driver>> getDriversList() async {
    return await ErgastApi().getLastStandings();
  }

  @override
  Widget build(BuildContext context) {
    Map driversStandings =
        Hive.box('requests').get('driversStandings', defaultValue: {}) as Map;
    return FutureBuilder<List<Driver>>(
      future: getDriversList(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          driversStandings['MRData'] != null
              ? DriversList(
                  items: ErgastApi().formatLastStandings(driversStandings),
                  scrollController: scrollController,
                )
              : RequestErrorWidget(snapshot.error.toString());
        return snapshot.hasData
            ? DriversList(
                items: snapshot.data!,
                scrollController: scrollController,
              )
            : driversStandings['MRData'] != null
                ? DriversList(
                    items: ErgastApi().formatLastStandings(driversStandings),
                    scrollController: scrollController,
                  )
                : LoadingIndicatorUtil();
      },
    );
  }
}

class TeamsStandingsWidget extends StatelessWidget {
  final ScrollController? scrollController;

  TeamsStandingsWidget({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  Future<List<Team>> getLastTeamsStandings() async {
    return await ErgastApi().getLastTeamsStandings();
  }

  @override
  Widget build(BuildContext context) {
    Map teamsStandings =
        Hive.box('requests').get('teamsStandings', defaultValue: {}) as Map;
    return FutureBuilder<List<Team>>(
      future: getLastTeamsStandings(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          teamsStandings['MRData'] != null
              ? TeamsList(
                  items: ErgastApi().formatLastTeamsStandings(teamsStandings),
                  scrollController: scrollController,
                )
              : RequestErrorWidget(snapshot.error.toString());
        return snapshot.hasData
            ? TeamsList(
                items: snapshot.data!,
                scrollController: scrollController,
              )
            : teamsStandings['MRData'] != null
                ? TeamsList(
                    items: ErgastApi().formatLastTeamsStandings(teamsStandings),
                    scrollController: scrollController,
                  )
                : LoadingIndicatorUtil();
      },
    );
  }
}
