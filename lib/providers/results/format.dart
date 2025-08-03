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

import 'dart:ui';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:hive_flutter/hive_flutter.dart';

String championship = Hive.box('settings')
    .get('championship', defaultValue: 'Formula 1') as String;

class ResultsFormatProvider {
  Color getTeamColor(DriverResult result) {
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
    } else {
      return FormulaE().getTeamColor(result.team);
    }
  }
}
