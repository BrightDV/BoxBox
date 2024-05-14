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

import 'dart:async';

import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StandingsScreen extends StatelessWidget {
  final bool? switchToTeamStandings;
  final ScrollController? scrollController;
  const StandingsScreen({
    Key? key,
    this.switchToTeamStandings,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: switchToTeamStandings != null ? 1 : 0,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: TabBarView(
          children: [
            DriversStandingsWidget(scrollController: scrollController),
            TeamsStandingsWidget(scrollController: scrollController),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: const Size(200, 100),
          child: SizedBox(
            height: 50,
            child: Card(
              elevation: 3,
              child: TabBar(
                dividerColor: Colors.transparent,
                tabs: [
                  Text(
                    AppLocalizations.of(context)!.drivers,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.teams,
                    style: const TextStyle(
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

  const DriversStandingsWidget({Key? key, this.scrollController})
      : super(key: key);

  Future<List<Driver>> getDriversList() async {
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: false) as bool;
    if (useOfficialDataSoure) {
      return await Formula1().getLastStandings();
    } else {
      return await ErgastApi().getLastStandings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map driversStandings =
        Hive.box('requests').get('driversStandings', defaultValue: {}) as Map;
    String driverStandingsLastSavedFormat = Hive.box('requests')
        .get('driverStandingsLastSavedFormat', defaultValue: 'ergast');

    return FutureBuilder<List<Driver>>(
      future: getDriversList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          driversStandings[driverStandingsLastSavedFormat == 'ergast'
                      ? 'MRData'
                      : 'drivers'] !=
                  null
              ? DriversList(
                  items: driverStandingsLastSavedFormat == 'ergast'
                      ? ErgastApi().formatLastStandings(driversStandings)
                      : Formula1().formatLastStandings(driversStandings),
                  scrollController: scrollController,
                )
              : RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? DriversList(
                items: snapshot.data!,
                scrollController: scrollController,
              )
            : driversStandings[driverStandingsLastSavedFormat == 'ergast'
                        ? 'MRData'
                        : 'drivers'] !=
                    null
                ? DriversList(
                    items: driverStandingsLastSavedFormat == 'ergast'
                        ? ErgastApi().formatLastStandings(driversStandings)
                        : Formula1().formatLastStandings(driversStandings),
                    scrollController: scrollController,
                  )
                : const LoadingIndicatorUtil();
      },
    );
  }
}

class TeamsStandingsWidget extends StatelessWidget {
  final ScrollController? scrollController;

  const TeamsStandingsWidget({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  Future<List<Team>> getLastTeamsStandings() async {
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: false) as bool;
    if (useOfficialDataSoure) {
      return await Formula1().getLastTeamsStandings();
    } else {
      return await ErgastApi().getLastTeamsStandings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map teamsStandings =
        Hive.box('requests').get('teamsStandings', defaultValue: {}) as Map;
    String teamStandingsLastSavedFormat = Hive.box('requests')
        .get('teamStandingsLastSavedFormat', defaultValue: 'ergast');

    return FutureBuilder<List<Team>>(
      future: getLastTeamsStandings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          teamsStandings[teamStandingsLastSavedFormat == 'ergast'
                      ? 'MRData'
                      : 'drivers'] !=
                  null
              ? TeamsList(
                  items: teamStandingsLastSavedFormat == 'ergast'
                      ? ErgastApi().formatLastTeamsStandings(teamsStandings)
                      : Formula1().formatLastTeamsStandings(teamsStandings),
                  scrollController: scrollController,
                )
              : RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? TeamsList(
                items: snapshot.data!,
                scrollController: scrollController,
              )
            : teamsStandings[teamStandingsLastSavedFormat == 'ergast'
                        ? 'MRData'
                        : 'drivers'] !=
                    null
                ? TeamsList(
                    items: teamStandingsLastSavedFormat == 'ergast'
                        ? ErgastApi().formatLastTeamsStandings(teamsStandings)
                        : Formula1().formatLastTeamsStandings(teamsStandings),
                    scrollController: scrollController,
                  )
                : const LoadingIndicatorUtil();
      },
    );
  }
}
