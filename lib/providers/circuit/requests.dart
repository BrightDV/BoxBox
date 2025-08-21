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

import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/api/services/formula_series.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/providers/circuit/format.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CircuitRequestsProvider {
  RaceDetails? getSavedDetails(String meetingId) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      Map details = Hive.box('requests').get(
        'f1CircuitDetails-$meetingId',
        defaultValue: {},
      );
      if (details.isNotEmpty) {
        return CircuitFormatProvider().formatCircuitData(details);
      }
    } else if (championship == 'Formula E') {
      Map details = Hive.box('requests').get(
        'feCircuitDetails-$meetingId',
        defaultValue: {},
      );
      if (details.isNotEmpty) {
        return CircuitFormatProvider().formatCircuitData(details);
      }
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      String championshipId = Constants().FORMULA_SERIES[championship];
      Map details = Hive.box('requests').get(
        '${championshipId}CircuitDetails-$meetingId',
        defaultValue: {},
      );
      if (details.isNotEmpty) {
        return CircuitFormatProvider().formatCircuitData(details);
      }
    }
    return null;
  }

  Future<RaceDetails> getCircuitDetails(String meetingId) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Formula1().getCircuitDetails(meetingId);
    } else if (championship == 'Formula E') {
      return FormulaE().getCircuitDetails(meetingId);
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return FormulaSeries().getCircuitDetails(meetingId);
    } else {
      return RaceDetails(
        '',
        '',
        '',
        [],
        false,
      );
    }
  }

  String getCircuitCountryName(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return details['race']['meetingCountryName'];
    } else if (championship == 'Formula E') {
      return details['race']['city'];
    } else {
      return '';
    }
  }

  String getCircuitOfficialName(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return details['race']['meetingOfficialName'];
    } else if (championship == 'Formula E') {
      return details['race']['name'];
    } else {
      return '';
    }
  }
}
