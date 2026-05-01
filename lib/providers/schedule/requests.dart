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
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScheduleRequestsProvider {
  Future<List<Race>> getRacesList(bool toCome) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (useOfficialDataSoure) {
        return await Formula1().getLastSchedule(toCome);
      } else {
        return await ErgastApi().getLastSchedule(toCome);
      }
    } else if (championship == 'Formula E') {
      return await FormulaE().getLastSchedule(toCome);
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return await FormulaSeries().getLastSchedule(toCome);
    } else {
      return [];
    }
  }

  Map getSavedSchedule() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Map result = {};
    if (championship == 'Formula 1') {
      result['schedule'] =
          Hive.box('requests').get('f1Schedule', defaultValue: {}) as Map;
      result['scheduleLastSavedFormat'] = Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    } else if (championship == 'Formula E') {
      result['schedule'] =
          Hive.box('requests').get('feSchedule', defaultValue: {}) as Map;
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      String championshipId = Constants().FORMULA_SERIES[championship];
      result['schedule'] = Hive.box('requests')
          .get('${championshipId}Schedule', defaultValue: {}) as Map;
    } else {
      result['schedule'] = {};
    }
    return result;
  }
}
