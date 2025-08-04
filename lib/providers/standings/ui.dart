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
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StandingsUIProvider {
  Widget getDriversStandingsWidget(
    AsyncSnapshot snapshot,
    String driversStandingsLastSavedFormat,
    Map driversStandings,
    ScrollController? scrollController,
    bool hasError,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (driversStandingsLastSavedFormat == 'ergast') {
        if (driversStandings['MRData'] != null) {
          return DriversList(
            items: ErgastApi().formatLastStandings(driversStandings),
            scrollController: scrollController,
          );
        }
      } else {
        if (driversStandings['drivers'] != null) {
          return DriversList(
            items: Formula1().formatLastStandings(driversStandings),
            scrollController: scrollController,
          );
        }
      }
    } else if (championship == 'Formula E') {
      if (driversStandings['drivers'] != null) {
        return DriversList(
          items: FormulaE().formatLastStandings(driversStandings),
          scrollController: scrollController,
        );
      }
    }
    if (hasError) {
      return RequestErrorWidget(snapshot.error.toString());
    } else {
      return LoadingIndicatorUtil();
    }
  }

  Widget getTeamsStandingsWidget(
    AsyncSnapshot snapshot,
    String teamsStandingsLastSavedFormat,
    Map teamsStandings,
    ScrollController? scrollController,
    bool hasError,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (teamsStandingsLastSavedFormat == 'ergast') {
        if (teamsStandings['MRData'] != null) {
          return TeamsList(
            items: ErgastApi().formatLastTeamsStandings(teamsStandings),
            scrollController: scrollController,
          );
        }
      } else {
        if (teamsStandings['constructors'] != null) {
          return TeamsList(
            items: Formula1().formatLastTeamsStandings(teamsStandings),
            scrollController: scrollController,
          );
        }
      }
    } else if (championship == 'Formula E') {
      if (teamsStandings['constructors'] != null) {
        return TeamsList(
          items: FormulaE().formatLastTeamsStandings(teamsStandings),
          scrollController: scrollController,
        );
      }
    }
    if (hasError) {
      return RequestErrorWidget(snapshot.error.toString());
    } else {
      return LoadingIndicatorUtil();
    }
  }
}
