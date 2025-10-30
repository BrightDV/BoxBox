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

import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultsFormatProvider {
  DateTime formatRaceDate(Race race, String scheduleLastSavedFormat) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (scheduleLastSavedFormat == 'ergast') {
        return DateTime.parse("${race.date} ${race.raceHour}");
      } else {
        return DateTime.parse(race.date);
      }
    } else if (championship == 'Formula E') {
      if (race.raceHour != '') {
        return DateTime.parse("${race.date} ${race.raceHour}");
      } else {
        return DateTime.parse(race.date);
      }
    } else {
      return DateTime.now();
    }
  }

  Color formatTeamColor(DriverResult result) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (result.teamColor != null) {
        return Color(
          int.parse(
            'FF${result.teamColor}',
            radix: 16,
          ),
        );
      } else {
        return TeamBackgroundColor().getTeamColor(
          result.team,
        );
      }
    } else if (championship == 'Formula E') {
      return FormulaE().getTeamColor(result.team);
    } else {
      return Colors.transparent;
    }
  }

  int getSessionIndexForFormulaSeries(List sessions, String search) {
    int c = 0;
    for (var session in sessions) {
      if (session['SessionName'].toLowerCase().contains(search.toLowerCase())) {
        return c;
      }
      c++;
    }
    return 0;
  }
}
