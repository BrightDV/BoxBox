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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'dart:async';
import 'dart:convert';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class FormulaE {
  final String defaultEndpoint = "https://api.formula-e.pulselive.com";
  final String championshipId = "84467676-4d5d-4c97-ae07-0b7520bb95ea";
  // TODO: needs update for a new season ?

  List<News> formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['content'];
    List<News> newsList = [];

    for (var element in finalJson) {
      element['title'] = element['title'].trim();
      if (element['description'] != null) {
        element['description'] = element['description'].trim();
      }
      String newsType = '';
      for (var tag in element['tags']) {
        if (tag['label'].contains('label')) {
          newsType = tag['label'].split(':')[1].toString().capitalize();
        }
      }

      newsList.add(
        News(
          element['id'].toString(),
          newsType,
          '',
          element['title'],
          element['description'] ?? '',
          DateTime.fromMillisecondsSinceEpoch(element['publishFrom']),
          element['imageUrl'],
          author: element['author'],
        ),
      );
    }
    return newsList;
  }

  FutureOr<List<News>> getMoreNews(
    int offset, {
    String? tagId,
    String? articleType,
  }) async {
    Uri url;
    int page = offset ~/ 12;

    url = Uri.parse(
      '$defaultEndpoint/content/formula-e/text/EN/?page=$page&pageSize=16&tagNames=content-type%3Anews&tagExpression=&playlistTypeRestriction=&playlistId=&detail=&size=16&championshipId=&sort=',
    );

    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    if (offset == 0 && tagId == null && articleType == null) {
      Hive.box('requests').put('news', responseAsJson);
      Hive.box('requests').put('newsLastSavedFormat', 'fe');
    }
    return formatResponse(responseAsJson);
  }

  List<Driver> formatLastStandings(Map responseAsJson) {
    List<Driver> drivers = [];
    List finalJson = responseAsJson['drivers'];
    for (var element in finalJson) {
      drivers.add(
        Driver(
          element['driverId'],
          element['driverPosition'].toString(),
          '',
          element['driverFirstName'],
          element['driverLastName'],
          element['driverTLA'],
          element['driverTeamName'],
          element['driverPoints'].toString(),
        ),
      );
    }
    return drivers;
  }

  FutureOr<List<Driver>> getLastStandings() async {
    Map driverStandings =
        Hive.box('requests').get('driversStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'driversStandingsLatestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;
    String driverStandingsLastSavedFormat = Hive.box('requests')
        .get('driverStandingsLastSavedFormat', defaultValue: 'ergast');

    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        driverStandings.isNotEmpty &&
        driverStandingsLastSavedFormat == 'fe') {
      return formatLastStandings(driverStandings);
    } else {
      var url = Uri.parse(
        '$defaultEndpoint/formula-e/v1/standings/drivers?championshipId=$championshipId',
      );
      var response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
        },
      );
      String bodyAsMap = '{"drivers": ${utf8.decode(response.bodyBytes)}}';

      Map<String, dynamic> responseAsJson = jsonDecode(bodyAsMap);
      List<Driver> drivers = formatLastStandings(responseAsJson);
      Hive.box('requests').put('driversStandings', responseAsJson);
      Hive.box('requests').put('driversStandingsLatestQuery', DateTime.now());
      Hive.box('requests').put('driverStandingsLastSavedFormat', 'fe');
      return drivers;
    }
  }

  List<Team> formatLastTeamsStandings(Map responseAsJson) {
    List<Team> drivers = [];
    List finalJson = responseAsJson['constructors'];
    for (var element in finalJson) {
      drivers.add(
        Team(
          element['teamId'],
          element['teamPosition'].toString(),
          element['teamName'],
          element['teamPoints'].toString(),
          'NA',
        ),
      );
    }
    return drivers;
  }

  FutureOr<List<Team>> getLastTeamsStandings() async {
    Map teamsStandings =
        Hive.box('requests').get('teamsStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'teamsStandingsLatestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;
    String teamStandingsLastSavedFormat = Hive.box('requests')
        .get('teamStandingsLastSavedFormat', defaultValue: 'ergast');

    if (latestQuery
            .add(
              const Duration(minutes: 10),
            )
            .isAfter(DateTime.now()) &&
        teamsStandings.isNotEmpty &&
        teamStandingsLastSavedFormat == 'fe') {
      return formatLastTeamsStandings(teamsStandings);
    } else {
      var url = Uri.parse(
        '$defaultEndpoint/formula-e/v1/standings/teams?championshipId=$championshipId',
      );
      var response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
        },
      );
      String bodyAsMap = '{"constructors": ${utf8.decode(response.bodyBytes)}}';

      Map<String, dynamic> responseAsJson = jsonDecode(bodyAsMap);
      List<Team> teams = formatLastTeamsStandings(responseAsJson);
      Hive.box('requests').put('teamsStandings', responseAsJson);
      Hive.box('requests').put('teamsStandingsLatestQuery', DateTime.now());
      Hive.box('requests').put('teamStandingsLastSavedFormat', 'fe');
      return teams;
    }
  }

  List<Race> formatLastSchedule(Map responseAsJson, bool toCome) {
    List<Race> races = [];
    List finalJson = responseAsJson['races'];
    if (toCome) {
      for (var element in finalJson) {
        DateTime raceDate = DateTime.parse(element['date']);
        DateTime raceEndDate = raceDate.add(Duration(days: 1));
        DateTime now = DateTime.now();

        if (now.compareTo(raceEndDate) < 0) {
          races.add(
            Race(
              element['sequence'].toString(),
              element['id'],
              element['name'],
              element['date'],
              '',
              element['name'],
              element['name'],
              '',
              element['circuit']['circuitName'],
              [],
              isFirst: races.isEmpty,
              raceCoverUrl: 'none',
              hasRaceHour: false,
            ),
          );
        }
      }
    } else {
      for (var element in finalJson) {
        DateTime raceDate = DateTime.parse(element['date']);
        DateTime raceEndDate = raceDate.add(Duration(days: 1));
        DateTime now = DateTime.now();

        if (now.compareTo(raceEndDate) > 0) {
          races.add(
            Race(
              element['sequence'].toString(),
              element['id'],
              element['name'],
              element['date'],
              '',
              element['name'],
              element['name'],
              '',
              element['city'],
              [],
              isFirst: races.isEmpty,
              raceCoverUrl: 'none',
              hasRaceHour: false,
            ),
          );
        }
      }
    }
    return races;
  }

  Future<List<Race>> getLastSchedule(bool toCome) async {
    Map schedule = Hive.box('requests').get('schedule', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'scheduleLatestQuery',
      defaultValue: DateTime.now().subtract(
        const Duration(hours: 1),
      ),
    ) as DateTime;
    String scheduleLastSavedFormat = Hive.box('requests')
        .get('scheduleLastSavedFormat', defaultValue: 'ergast');

    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        schedule.isNotEmpty &&
        scheduleLastSavedFormat == 'fe') {
      return formatLastSchedule(schedule, toCome);
    } else {
      var url = Uri.parse(
        '$defaultEndpoint/formula-e/v1/races?championshipId=$championshipId',
      );
      var response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
        },
      );
      Map<String, dynamic> responseAsJson = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List<Race> races = formatLastSchedule(responseAsJson, toCome);
      Hive.box('requests').put('schedule', responseAsJson);
      Hive.box('requests').put('scheduleLatestQuery', DateTime.now());
      Hive.box('requests').put('scheduleLastSavedFormat', 'fe');
      return races;
    }
  }

  Future<Map> getSessions(Race race) async {
    var url = Uri.parse(
      '$defaultEndpoint/formula-e/v1/races/${race.meetingId}/sessions',
    );
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    List<DateTime> sessionDates = [];
    List sessionStates = [];
    List sessionIds = [];
    for (var session in responseAsJson['sessions']) {
      if ((session['sessionName'].startsWith('Free Practice') ||
          (session['sessionName'] == 'Race'))) {
        if (session['offsetGMT'].startsWith('-')) {
          if (session['offsetGMT'].length < 6) {
            session['offsetGMT'] = session['offsetGMT'].substring(0, 1) +
                '0' +
                session['offsetGMT'].substring(1);
          }
        } else {
          session['offsetGMT'] = '+' + session['offsetGMT'];
        }

        sessionDates.add(
          DateTime.parse(
            session['sessionDate'] +
                ' ' +
                session['startTime'] +
                session['offsetGMT'],
          ),
        );
        sessionStates.add(session['sessionLiveStatus']);
        sessionIds.add(session['id']);
      } else if (session['sessionNme'] == 'Qual Group A') {
        if (session['offsetGMT'].startsWith('-')) {
          if (session['offsetGMT'].length < 6) {
            session['offsetGMT'] = session['offsetGMT'].substring(0, 1) +
                '0' +
                session['offsetGMT'].substring(1);
          }
        } else {
          session['offsetGMT'] = '+' + session['offsetGMT'];
        }

        sessionDates.add(
          DateTime.parse(
            session['sessionDate'] +
                ' ' +
                session['startTime'] +
                session['offsetGMT'],
          ),
        );
      } else if (session['sessionName'] == 'Qual Final') {
        sessionStates.add(session['sessionLiveStatus']);
      } else if (session['sessionName'] == 'Combined qualifying') {
        sessionIds.add(session['id']);
      }
    }

    Race raceWithSessions = Race(
      race.round,
      race.meetingId,
      race.raceName,
      race.date,
      responseAsJson['sessions'].last['startTime'],
      race.circuitId,
      race.circuitName,
      race.circuitUrl,
      race.country,
      sessionDates,
      raceCoverUrl: race.raceCoverUrl,
      sessionStates: sessionStates,
    );

    Map formatedMap = {
      'raceCustomBBParameter': raceWithSessions,
      'sessionsIdsCustomBBParameter': sessionIds,
    };
    return formatedMap;
  }

  List<DriverResult> formatRaceStandings(Map raceStandings) {
    List<DriverResult> formatedRaceStandings = [];
    List jsonResponse = raceStandings['results'];
    for (var element in jsonResponse) {
      String time = element['delay'];
      while (time.startsWith('0:')) {
        time = time.substring(2);
      }
      if (time.startsWith('00')) {
        time = time.substring(1);
      }
      if (time == '-') {
        time = '';
      } else {
        time = '+' + time + 's';
      }

      if (time.lastIndexOf(':') != -1) {
        time = time.replaceFirst(':', '.', time.lastIndexOf(':'));
      }

      formatedRaceStandings.add(
        DriverResult(
          element['driverId'],
          element['driverPosition'].toString(),
          element['driverNumber'],
          element['driverFirstName'],
          element['driverLastName'],
          element['driverTLA'],
          element['team']['id'],
          time,
          element['fastestLap'] ?? false,
          element['bestTime'] ?? '',
          '',
          points: element['points'].toString(),
          status: (element['dnf'] ?? false)
              ? 'DNF'
              : (element['dnq'] ?? false)
                  ? 'DNQ'
                  : (element['dns'] ?? false)
                      ? 'DNS'
                      : (element['dsq'] ?? false)
                          ? 'DSQ'
                          : (element['exc'] ?? false)
                              ? 'EXC'
                              : null,
          lapsDone: '--',
        ),
      );
    }
    return formatedRaceStandings;
  }

  Future<Map<String, dynamic>> _getSessionStandings(
      String raceId, String sessionId) async {
    var url = Uri.parse(
      '$defaultEndpoint/formula-e/v1/races/$raceId/sessions/$sessionId/results',
    );
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    String bodyAsMap = '{"results": ${utf8.decode(response.bodyBytes)}}';
    Map<String, dynamic> responseAsJson = jsonDecode(bodyAsMap);

    return responseAsJson;
  }

  Future<List<DriverResult>> getRaceStandings(
      String raceId, String sessionId) async {
    Map results = Hive.box('requests').get('fe-race-$raceId', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'fe-race-$raceId-latestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;

    if (latestQuery
            .add(
              const Duration(minutes: 5),
            )
            .isAfter(DateTime.now()) &&
        results.isNotEmpty) {
      return formatRaceStandings(results);
    } else {
      Map<String, dynamic> responseAsJson =
          await _getSessionStandings(raceId, sessionId);

      List<DriverResult> driversResults = formatRaceStandings(responseAsJson);
      Hive.box('requests').put('fe-race-$raceId', responseAsJson);
      Hive.box('requests').put(
        'fe-race-$raceId-latestQuery',
        DateTime.now(),
      );
      return driversResults;
    }
  }

  FutureOr<List<DriverResult>> getQualificationStandings(
      String raceId, String sessionId) async {
    List<DriverResult> driversResults = [];
    Map<String, dynamic> responseAsJson =
        await _getSessionStandings(raceId, sessionId);

    if (responseAsJson['results'].isEmpty) {
      return [];
    } else {
      List finalJson = responseAsJson['results'];
      for (var element in finalJson) {
        String time = element['sessionTime'];
        while (time.startsWith('0:')) {
          time = time.substring(2);
        }
        time = time.replaceFirst(':', '.', time.lastIndexOf(':'));

        String gap = element['delay'];
        while (gap.startsWith('0:')) {
          gap = gap.substring(2);
        }
        if (gap.startsWith('00')) {
          gap = gap.substring(1);
        }
        if (gap == '-') {
          gap = '';
        } else {
          gap = '+' + gap + 's';
        }
        if (gap.lastIndexOf(':') != -1) {
          gap = gap.replaceFirst(':', '.', gap.lastIndexOf(':'));
        }

        driversResults.add(
          DriverResult(
            element['driverId'],
            element['driverPosition'].toString(),
            element['driverNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            element['team']['id'],
            time, // TODO
            element['fastestLap'] ?? false,
            element['bestTime'] ?? '',
            gap,
            points: element['points'].toString(),
            status: (element['dnf'] ?? false)
                ? 'DNF'
                : (element['dnq'] ?? false)
                    ? 'DNQ'
                    : (element['dns'] ?? false)
                        ? 'DNS'
                        : (element['dsq'] ?? false)
                            ? 'DSQ'
                            : (element['exc'] ?? false)
                                ? 'EXC'
                                : null,
            lapsDone: '--',
          ),
        );
      }

      return driversResults;
    }
  }

  Future<List<DriverResult>> getFreePracticeStandings(
      String raceId, String sessionId) async {
    List<DriverResult> driversResults = [];

    Map<String, dynamic> responseAsJson =
        await _getSessionStandings(raceId, sessionId);
    if (responseAsJson['results'].isEmpty) {
      return [];
    } else {
      List finalJson = responseAsJson['results'];
      for (var element in finalJson) {
        String time = element['sessionTime'];
        while (time.startsWith('0:')) {
          time = time.substring(2);
        }
        time = time.replaceFirst(':', '.', time.lastIndexOf(':'));

        String gap = element['delay'];
        while (gap.startsWith('0:')) {
          gap = gap.substring(2);
        }
        if (gap.startsWith('00')) {
          gap = gap.substring(1);
        }
        if (gap == '-') {
          gap = '';
        } else {
          gap = '+' + gap + 's';
        }
        if (gap.lastIndexOf(':') != -1) {
          gap = gap.replaceFirst(':', '.', gap.lastIndexOf(':'));
        }

        driversResults.add(
          DriverResult(
            element['driverId'],
            element['driverPosition'].toString(),
            element['driverNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            element['team']['id'],
            time, // TODO
            element['fastestLap'] ?? false,
            element['bestTime'] ?? '',
            gap,
            points: element['points'].toString(),
            status: (element['dnf'] ?? false)
                ? 'DNF'
                : (element['dnq'] ?? false)
                    ? 'DNQ'
                    : (element['dns'] ?? false)
                        ? 'DNS'
                        : (element['dsq'] ?? false)
                            ? 'DSQ'
                            : (element['exc'] ?? false)
                                ? 'EXC'
                                : null,
            lapsDone: '--',
          ),
        );
      }

      return driversResults;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
