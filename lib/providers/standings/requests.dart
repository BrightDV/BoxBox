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

import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/api/services/formula_series.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/team.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StandingsRequestsProvider {
  Future<List<Driver>> getDriversStandings() async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (useOfficialDataSoure) {
        return await Formula1().getLastStandings();
      } else {
        return await ErgastApi().getLastStandings();
      }
    } else if (championship == 'Formula E') {
      return await FormulaE().getLastStandings();
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return await FormulaSeries().getLastStandings();
    } else {
      return [];
    }
  }

  Future<List<Team>> getTeamsStandings() async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (useOfficialDataSoure) {
        return await Formula1().getLastTeamsStandings();
      } else {
        return await ErgastApi().getLastTeamsStandings();
      }
    } else if (championship == 'Formula E') {
      return await FormulaE().getLastTeamsStandings();
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return await FormulaSeries().getLastTeamsStandings();
    } else {
      return [];
    }
  }

  Map getSavedDriversStandings() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Map standings = {};
    if (championship == 'Formula 1') {
      standings['driversStandings'] = Hive.box('requests')
          .get('f1DriversStandings', defaultValue: {}) as Map;
      standings['driversStandingsLastSavedFormat'] = Hive.box('requests')
          .get('f1DriversStandingsLastSavedFormat', defaultValue: 'ergast');
    } else if (championship == 'Formula E') {
      standings['driversStandings'] = Hive.box('requests')
          .get('feDriversStandings', defaultValue: {}) as Map;
      standings['driversStandingsLastSavedFormat'] = '';
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      String championshipId = Constants().FORMULA_SERIES[championship];
      standings['driversStandings'] = Hive.box('requests')
          .get('${championshipId}DriversStandings', defaultValue: {}) as Map;
      standings['driversStandingsLastSavedFormat'] = '';
    } else {
      standings['driversStandings'] = {};
      standings['driversStandingsLastSavedFormat'] = '';
    }
    return standings;
  }

  Map getSavedTeamsStandings() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Map standings = {};
    if (championship == 'Formula 1') {
      standings['teamsStandings'] =
          Hive.box('requests').get('feTeamsStandings', defaultValue: {}) as Map;
      standings['teamsStandingsLastSavedFormat'] = Hive.box('requests')
          .get('feTeamsStandingsLastSavedFormat', defaultValue: 'ergast');
    } else if (championship == 'Formula E') {
      standings['teamsStandings'] =
          Hive.box('requests').get('feTeamsStandings', defaultValue: {}) as Map;
      standings['teamsStandingsLastSavedFormat'] = '';
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      String championshipId = Constants().FORMULA_SERIES[championship];
      standings['teamsStandings'] = Hive.box('requests')
          .get('${championshipId}DriversStandings', defaultValue: {}) as Map;
      standings['teamsStandingsLastSavedFormat'] = '';
    } else {
      standings['teamsStandings'] = {};
      standings['teamsStandingsLastSavedFormat'] = '';
    }
    return standings;
  }
}
