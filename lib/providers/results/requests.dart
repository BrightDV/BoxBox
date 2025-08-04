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
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultsRequestsProvider {
  Future<List<DriverResult>> getFreePracticeResults(
    String? raceUrl,
    String meetingId,
    int sessionIndex,
    String? sessionId,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Formula1().getFreePracticeStandings(
        raceUrl != null ? raceUrl.split('/')[7] : meetingId,
        raceUrl != null
            ? int.parse(raceUrl
                .split('/')[9]
                .replaceAll('practice', '')
                .replaceAll('.html', '')
                .replaceAll('-', ''))
            : sessionIndex,
      );
    } else {
      return FormulaE().getFreePracticeStandings(
        meetingId,
        sessionId!,
      );
    }
  }
}
