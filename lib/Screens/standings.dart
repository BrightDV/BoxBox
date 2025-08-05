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

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:boxbox/providers/standings/requests.dart';
import 'package:boxbox/providers/standings/ui.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    Map standings = StandingsRequestsProvider().getSavedDriversStandings();
    Map driversStandings = standings['driversStandings'];
    String driversStandingsLastSavedFormat =
        standings['driversStandingsLastSavedFormat'] ?? '';

    return FutureBuilder<List<Driver>>(
        future: StandingsRequestsProvider().getDriversStandings(),
        builder: (context, snapshot) => snapshot.hasError
            ? StandingsUIProvider().getDriversStandingsWidget(
                snapshot,
                driversStandingsLastSavedFormat,
                driversStandings,
                scrollController,
                true,
              )
            : snapshot.hasData
                ? DriversList(
                    items: snapshot.data!,
                    scrollController: scrollController,
                  )
                : StandingsUIProvider().getDriversStandingsWidget(
                    snapshot,
                    driversStandingsLastSavedFormat,
                    driversStandings,
                    scrollController,
                    false,
                  ));
  }
}

class TeamsStandingsWidget extends StatelessWidget {
  final ScrollController? scrollController;

  const TeamsStandingsWidget({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map standings = StandingsRequestsProvider().getSavedTeamsStandings();
    Map teamsStandings = standings['teamsStandings'];
    String teamsStandingsLastSavedFormat =
        standings['teamsStandingsLastSavedFormat'];

    return FutureBuilder<List<Team>>(
      future: StandingsRequestsProvider().getTeamsStandings(),
      builder: (context, snapshot) => snapshot.hasError
          ? StandingsUIProvider().getTeamsStandingsWidget(
              snapshot,
              teamsStandingsLastSavedFormat,
              teamsStandings,
              scrollController,
              true,
            )
          : snapshot.hasData
              ? TeamsList(
                  items: snapshot.data!,
                  scrollController: scrollController,
                )
              : StandingsUIProvider().getTeamsStandingsWidget(
                  snapshot,
                  teamsStandingsLastSavedFormat,
                  teamsStandings,
                  scrollController,
                  false,
                ),
    );
  }
}
