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
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/classes/race.dart';
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
    } else {
      return await FormulaE().getLastSchedule(toCome);
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
    } else {
      result['schedule'] =
          Hive.box('requests').get('feSchedule', defaultValue: {}) as Map;
    }
    return result;
  }
}
