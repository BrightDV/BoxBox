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
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/race.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultsRequestsProvider {
  String getScheduleLastSavedFormat() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Hive.box('requests')
          .get('f1ScheduleLastSavedFormat', defaultValue: 'ergast');
    } else {
      return '';
    }
  }

  String getRaceResultsLastSavedFormat() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Hive.box('requests')
          .get('f1RaceResultsLastSavedFormat', defaultValue: 'ergast');
    } else {
      return '';
    }
  }

  Map getSavedRaceResultsData(Race race) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Hive.box('requests').get('f1Race-${race.round}', defaultValue: {})
          as Map;
    } else if (championship == 'Formula E') {
      return Hive.box('requests')
          .get('feRace-${race.meetingId}', defaultValue: {}) as Map;
    } else {
      return {};
    }
  }

  Future<List<DriverResult>> getFreePracticeResults(
    String? raceUrl,
    String meetingId,
    int sessionIndex,
    String? sessionId,
  ) async {
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
    } else if (championship == 'Formula E') {
      return FormulaE().getFreePracticeStandings(
        meetingId,
        sessionId!,
      );
    } else {
      return [];
    }
  }

  Future<List<DriverResult>> getRaceStandingsFromApi({
    Race? race,
    String? meetingId,
    String? raceUrl,
    String? sessionId,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (raceUrl != null) {
        if (raceUrl.startsWith('http')) {
          meetingId = raceUrl.split('/')[7];
        }
      }
      if (useOfficialDataSoure) {
        if (meetingId != null && raceUrl != null) {
          // starting to do like official api devs...
          if (raceUrl == 'race') {
            return await Formula1().getRaceStandings(meetingId, '66666');
          } else {
            return await Formula1().getSprintStandings(meetingId);
          }
        } else
          return await Formula1().getRaceStandings(race!.meetingId, race.round);
      } else {
        return await ErgastApi().getRaceStandings(race!.round);
      }
    } else if (championship == 'Formula E') {
      return await FormulaE().getRaceStandings(
        meetingId!,
        sessionId!,
      );
    } else {
      return [];
    }
  }

  Future<List<DriverResult>> getSprintStandings({
    Race? race,
    String? meetingId,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      if (useOfficialDataSoure) {
        if (meetingId != null) {
          // same as race results...
          return await Formula1().getSprintStandings(meetingId);
        } else {
          return await Formula1().getSprintStandings(race!.meetingId);
        }
      } else {
        return await ErgastApi().getSprintStandings(race!.round);
      }
    } else {
      return [];
    }
  }

  Future<List> getQualificationStandings(
    bool? hasSprint,
    bool? isSprintQualifying,
    String? sessionId, {
    Race? race,
    String? meetingId,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    if (championship == 'Formula 1') {
      bool useOfficialDataSoure = Hive.box('settings')
          .get('useOfficialDataSoure', defaultValue: true) as bool;
      {
        if (useOfficialDataSoure) {
          if (meetingId != null) {
            if (hasSprint ?? false) {
              return await Formula1().getSprintQualifyingStandings(meetingId);
            } else {
              return await Formula1().getQualificationStandings(meetingId);
            }
          } else if (isSprintQualifying ?? false) {
            return await Formula1()
                .getSprintQualifyingStandings(race!.meetingId);
          } else {
            return await Formula1().getQualificationStandings(race!.meetingId);
          }
        } else {
          return await ErgastApi().getQualificationStandings(
            race!.meetingId,
          );
        }
      }
    }
    return await FormulaE().getQualificationStandings(
      race!.meetingId,
      sessionId!,
    );
  }

  int getRaceSessionIndex(Race race) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return 4;
    } else if (championship == 'Formula E') {
      return race.sessionDates.length - 1;
    } else {
      return 0;
    }
  }

  int getQualifyingSessionIndex(bool? isSprintQualifying, Race? race) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (isSprintQualifying ?? false) {
        return 1;
      } else {
        return 3;
      }
    } else if (championship == 'Formula E') {
      return race!.sessionDates.length - 2;
    } else {
      return 0;
    }
  }

  bool checkIfQualificationIsFinished(Race race) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return race.sessionDates[3].isBefore(DateTime.now());
    } else if (championship == 'Formula E') {
      return race.sessionDates[race.sessionDates.length - 2]
          .isBefore(DateTime.now());
    } else {
      return false;
    }
  }

  Future<List> getStartingGrid(String meetingId) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Formula1().getStartingGrid(
        meetingId,
      );
    } else {
      return [];
    }
  }
}
