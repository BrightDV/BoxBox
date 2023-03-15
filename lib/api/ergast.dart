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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'dart:async';
import 'dart:convert';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class _ErgastApiCalls {
  List<DriverResult> formatRaceStandings(Map raceStandings) {
    List<DriverResult> formatedRaceStandings = [];
    List jsonResponse =
        raceStandings['MRData']['RaceTable']['Races'][0]['Results'];
    String time;
    for (var element in jsonResponse) {
      if (element['status'] != 'Finished') {
        if (element['status'].endsWith('Lap')) {
          time = element['status'];
        } else {
          time = "DNF";
        }
      } else {
        time = element["Time"]["time"];
      }
      String fastestLapRank = "1";
      if (element['FastestLap'] == null) {
        fastestLapRank = "0";
      }
      formatedRaceStandings.add(
        DriverResult(
          element['Driver']['driverId'],
          element['position'],
          element['Driver']['permanentNumber'],
          element['Driver']['givenName'],
          element['Driver']['familyName'],
          element['Driver']['code'],
          element['Constructor']['constructorId'],
          time,
          fastestLapRank != '0'
              ? element['FastestLap']['rank'].toString() == '1'
                  ? true
                  : false
              : false,
          fastestLapRank != '0'
              ? element['FastestLap']['Time']['time']
              : fastestLapRank,
          fastestLapRank != '0' ? element['FastestLap']['lap'] : fastestLapRank,
          lapsDone: element['laps'],
          points: element['points'],
        ),
      );
    }
    return formatedRaceStandings;
  }

  FutureOr<List<DriverResult>> getRaceStandings(String round) async {
    var url = Uri.parse(
        'https://ergast.com/api/f1/${DateTime.now().year}/$round/results.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    Hive.box('requests').put('race-$round', responseAsJson);
    List<DriverResult> driversResults = formatRaceStandings(responseAsJson);
    return driversResults;
  }

  FutureOr<List<DriverResult>> getSprintStandings(String round) async {
    var url = Uri.parse(
        'https://ergast.com/api/f1/${DateTime.now().year}/$round/sprint.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    List<DriverResult> formatedRaceStandings = [];
    if ((responseAsJson['MRData']['RaceTable']['Races'].isEmpty) ||
        (responseAsJson['MRData']['RaceTable']['Races'][0]['SprintResults'] ==
            null)) {
      return [];
    } else {
      List jsonResponse =
          responseAsJson['MRData']['RaceTable']['Races'][0]['SprintResults'];
      String time;
      for (var element in jsonResponse) {
        if (element['status'] != 'Finished') {
          if (element['status'].endsWith('Lap')) {
            time = element['status'];
          } else {
            time = "DNF";
          }
        } else {
          time = element["Time"]["time"];
        }
        String fastestLapRank = "1";
        if (element['FastestLap'] == null) {
          fastestLapRank = "0";
        }
        formatedRaceStandings.add(
          DriverResult(
            element['Driver']['driverId'],
            element['position'],
            element['Driver']['permanentNumber'],
            element['Driver']['givenName'],
            element['Driver']['familyName'],
            element['Driver']['code'],
            element['Constructor']['constructorId'],
            time,
            fastestLapRank != '0'
                ? element['FastestLap']['rank'].toString() == '1'
                    ? true
                    : false
                : false,
            fastestLapRank != '0'
                ? element['FastestLap']['Time']['time']
                : fastestLapRank,
            fastestLapRank != '0'
                ? element['FastestLap']['lap']
                : fastestLapRank,
            lapsDone: element['laps'],
            points: element['points'],
          ),
        );
      }
      return formatedRaceStandings;
    }
  }

  FutureOr<List<DriverQualificationResult>> getQualificationStandings(
      String round) async {
    List<DriverQualificationResult> driversResults = [];
    var url = Uri.parse(
      'https://ergast.com/api/f1/${DateTime.now().year}/$round/qualifying.json',
    );
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    if ((responseAsJson['MRData']['RaceTable']['Races'].isEmpty) ||
        (responseAsJson['MRData']['RaceTable']['Races'][0]
                ['QualifyingResults'] ==
            null)) {
      return [];
    } else {
      List finalJson = responseAsJson['MRData']['RaceTable']['Races'][0]
          ['QualifyingResults'];
      for (var element in finalJson) {
        driversResults.add(
          DriverQualificationResult(
            element['Driver']['driverId'],
            element['position'],
            element['Driver']['permanentNumber'],
            element['Driver']['givenName'],
            element['Driver']['familyName'],
            element['Driver']['code'],
            element['Constructor']['constructorId'],
            element['Q1'] == '' ? 'DNF' : element['Q1'],
            element['Q2'] ?? '--',
            element['Q3'] ?? '--',
          ),
        );
      }

      return driversResults;
    }
  }

  List<Driver> formatLastStandings(Map responseAsJson) {
    List<Driver> drivers = [];
    List finalJson = responseAsJson['MRData']['StandingsTable']
        ['StandingsLists'][0]['DriverStandings'];
    for (var element in finalJson) {
      drivers.add(
        Driver(
          element['Driver']['driverId'],
          element['position'],
          element['Driver']['permanentNumber'],
          element['Driver']['givenName'],
          element['Driver']['familyName'],
          element['Driver']['code'],
          element['Constructors'][0]['constructorId'],
          element['points'],
        ),
      );
    }
    return drivers;
  }

  FutureOr<List<Driver>> getLastStandings() async {
    var url =
        Uri.parse('https://ergast.com/api/f1/current/driverStandings.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    Hive.box('requests').put('driversStandings', responseAsJson);
    return formatLastStandings(responseAsJson);
  }

  List<Race> formatLastSchedule(Map responseAsJson, bool toCome) {
    List<Race> races = [];
    List finalJson = responseAsJson['MRData']['RaceTable']['Races'];
    if (toCome) {
      for (var element in finalJson) {
        List dateParts = element['date'].split('-');
        DateTime raceDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        ).add(
          const Duration(days: 1),
        );
        DateTime now = DateTime.now();
        List<DateTime> raceDates = [];
        List<String> sessionKeys = [
          'FirstPractice',
          'SecondPractice',
          'ThirdPractice',
          'Sprint',
          'Qualifying',
        ];
        for (String sessionKey in sessionKeys) {
          if (element[sessionKey] != null) {
            DateTime raceDate = DateTime.parse(
              '${element[sessionKey]['date']} ${element[sessionKey]['time']}',
            );
            raceDates.add(raceDate);
          }
        }
        if (now.compareTo(raceDate) < 0) {
          races.add(
            Race(
              element['round'],
              element['raceName'],
              element['date'],
              element['time'],
              element['Circuit']['circuitId'],
              element['Circuit']['circuitName'],
              element['Circuit']['url'],
              element['Circuit']['Location']['country'],
              raceDates,
              isFirst: races.isEmpty,
            ),
          );
        }
      }
    } else {
      for (var element in finalJson) {
        List dateParts = element['date'].split('-');
        DateTime raceDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        ).add(
          const Duration(
            days: 1,
          ),
        );
        DateTime now = DateTime.now();
        if (now.compareTo(raceDate) > 0) {
          races.add(
            Race(
              element['round'],
              element['raceName'].substring(
                0,
                element['raceName'].indexOf(' Grand Prix'),
              ),
              element['date'],
              element['time'],
              element['Circuit']['circuitId'],
              element['Circuit']['circuitName'],
              element['Circuit']['url'],
              element['Circuit']['Location']['country'],
              [],
            ),
          );
        }
      }
    }
    return races;
  }

  Future<List<DriverResult>> getDriverResults(String driverId) async {
    var url = Uri.parse(
      'https://ergast.com/api/f1/${DateTime.now().year}/drivers/$driverId/results.json',
    );
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    List races = responseAsJson['MRData']['RaceTable']['Races'];
    List<DriverResult> results = [];
    for (var race in races) {
      results.add(
        DriverResult(
          driverId,
          race['Results'][0]['position'],
          race['Results'][0]['number'],
          race['Results'][0]['Driver']['givenName'],
          race['Results'][0]['Driver']['familyName'],
          race['Results'][0]['Driver']['code'],
          race['Results'][0]['Constructor']['constructorId'],
          race['Results'][0]['Time']?['time'] ?? 'DNF',
          int.parse(race['Results'][0]['FastestLap']?['rank'] ?? '20') == 1
              ? true
              : false,
          race['Results'][0]['FastestLap']?['Time']['time'] ?? '00:00:00',
          race['Results'][0]['FastestLap']?['rank'] ?? '20',
          lapsDone: race['Results'][0]['laps'],
          points: race['Results'][0]['points'],
          raceId: race['Circuit']['circuitId'],
          raceName: race['raceName'],
        ),
      );
    }

    return results;
  }

  FutureOr<List<Race>> getLastSchedule(bool toCome) async {
    var url =
        Uri.parse('https://ergast.com/api/f1/${DateTime.now().year}.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    Hive.box('requests').put('schedule', responseAsJson);
    return formatLastSchedule(responseAsJson, toCome);
  }

  Future<Race> getRaceDetails(String round) async {
    var url = Uri.parse(
        'https://ergast.com/api/f1/${DateTime.now().year}/$round.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson =
        jsonDecode(response.body)['MRData']['RaceTable']['Races'][0];
    List<DateTime> raceDates = [];
    List<String> sessionKeys = [
      'FirstPractice',
      'SecondPractice',
      'ThirdPractice',
      'Qualifying',
    ];
    for (String sessionKey in sessionKeys) {
      DateTime raceDate = DateTime.parse(
        '${responseAsJson[sessionKey]['date']} ${responseAsJson[sessionKey]['time']}',
      );
      raceDates.add(raceDate);
    }
    Race race = Race(
      responseAsJson['round'],
      responseAsJson['raceName'].substring(
        0,
        responseAsJson['raceName'].indexOf(' Grand Prix'),
      ),
      responseAsJson['date'],
      responseAsJson['time'],
      responseAsJson['Circuit']['circuitId'],
      responseAsJson['Circuit']['circuitName'],
      responseAsJson['Circuit']['url'],
      responseAsJson['Circuit']['Location']['country'],
      raceDates,
    );
    return race;
  }

  List<Team> formatLastTeamsStandings(Map responseAsJson) {
    List<Team> drivers = [];
    List finalJson = responseAsJson['MRData']['StandingsTable']
        ['StandingsLists'][0]['ConstructorStandings'];
    for (var element in finalJson) {
      drivers.add(
        Team(
          element['Constructor']['constructorId'],
          element['position'],
          element['Constructor']['name'],
          element['points'],
          element['wins'],
        ),
      );
    }
    return drivers;
  }

  FutureOr<List<Team>> getLastTeamsStandings() async {
    var url = Uri.parse(
        'https://ergast.com/api/f1/current/constructorStandings.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    Hive.box('requests').put('teamsStandings', responseAsJson);
    return formatLastTeamsStandings(responseAsJson);
  }

  FutureOr<bool> hasSprintQualifyings(round) async {
    var url = Uri.parse(
        'https://ergast.com/api/f1/${DateTime.now().year}/$round/sprint.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    return !responseAsJson['MRData']['RaceTable']['Races'].isEmpty;
  }
}

class ErgastApi {
  FutureOr<List<DriverResult>> getRaceStandings(String round) async {
    var data = await _ErgastApiCalls().getRaceStandings(round);
    return data;
  }

  List<DriverResult> formatRaceStandings(Map responseAsJson) {
    var data = _ErgastApiCalls().formatRaceStandings(responseAsJson);
    return data;
  }

  FutureOr<List<DriverResult>> getSprintStandings(String round) async {
    var data = await _ErgastApiCalls().getSprintStandings(
      round,
    );
    return data;
  }

  FutureOr<List<DriverQualificationResult>> getQualificationStandings(
      String round) async {
    var data = await _ErgastApiCalls().getQualificationStandings(
      round,
    );
    return data;
  }

  List<Driver> formatLastStandings(Map responseAsJson) {
    var data = _ErgastApiCalls().formatLastStandings(responseAsJson);
    return data;
  }

  FutureOr<List<Driver>> getLastStandings() async {
    var data = await _ErgastApiCalls().getLastStandings();
    return data;
  }

  List<Race> formatLastSchedule(Map responseAsJson, bool toCome) {
    var data = _ErgastApiCalls().formatLastSchedule(responseAsJson, toCome);
    return data;
  }

  Future<List<DriverResult>> getDriverResults(String driverId) async {
    var data = await _ErgastApiCalls().getDriverResults(driverId);
    return data;
  }

  FutureOr<List<Race>> getLastSchedule(bool toCome) async {
    var data = await _ErgastApiCalls().getLastSchedule(toCome);
    return data;
  }

  List<Team> formatLastTeamsStandings(Map responseAsJson) {
    var data = _ErgastApiCalls().formatLastTeamsStandings(responseAsJson);
    return data;
  }

  FutureOr<List<Team>> getLastTeamsStandings() async {
    var data = await _ErgastApiCalls().getLastTeamsStandings();
    return data;
  }

  Future<bool> hasSprintQualifyings(String round) async {
    return await _ErgastApiCalls().hasSprintQualifyings(round);
  }

  Future<Race> getRaceDetails(String round) async {
    return await _ErgastApiCalls().getRaceDetails(round);
  }
}
