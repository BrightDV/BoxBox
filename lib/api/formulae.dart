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
import 'package:boxbox/api/videos.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class FormulaE {
  final String defaultEndpoint = "https://api.formula-e.pulselive.com";
  late final String championshipId = Hive.box('settings').get(
    'feChampionshipId',
    defaultValue: '84467676-4d5d-4c97-ae07-0b7520bb95ea',
  );

  Future<News> getArticle(String articleId) async {
    Uri url = Uri.parse(
      '$defaultEndpoint/content/formula-e/text/EN/$articleId',
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

    return News(
      responseAsJson['id'].toString(),
      '',
      '',
      responseAsJson['title'],
      responseAsJson['description'] ?? '',
      DateTime.fromMillisecondsSinceEpoch(responseAsJson['publishFrom']),
      responseAsJson['imageUrl'],
      author: responseAsJson['author'] != null
          ? {'fullName': responseAsJson['author']}
          : null,
    );
  }

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
          author: element['author'] != null
              ? {'fullName': element['author']}
              : null,
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

  List<Video> formatVideos(Map responseAsJson) {
    List finalJson = responseAsJson['items'];
    List<Video> videosList = [];

    for (var element in finalJson) {
      String formatedDuration;
      Duration duration = Duration(seconds: element['response']['duration']);
      if (duration.inHours > 0) {
        String hours = duration.inHours.toString().padLeft(2, '0');
        String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
        String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        formatedDuration = '$hours:$minutes:$seconds';
      } else {
        String minutes = duration.inMinutes.toString().padLeft(2, '0');
        String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        formatedDuration = '$minutes:$seconds';
      }
      videosList.add(
        Video(
          element['response']['mediaId'].toString(),
          'https://fiaformulae.com/en/video/${element['response']['id']}',
          element['response']['title'],
          element['response']['description'] ?? '',
          formatedDuration,
          element['response']['imageUrl'],
          DateTime.fromMillisecondsSinceEpoch(
            element['response']['publishFrom'],
          ),
        ),
      );
    }
    return videosList;
  }

  Future<List<Video>> getLatestVideos(int limit, int offset) async {
    int page = offset ~/ limit;
    Uri url = Uri.parse(
      '$defaultEndpoint/content/formula-e/playlist/EN/15?page=$page&pageSize=$limit&detail=DETAILED&size=$limit',
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
    return formatVideos(responseAsJson);
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
    Map driversStandings =
        Hive.box('requests').get('feDriversStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'feDriversStandingsLatestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;

    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        driversStandings.isNotEmpty) {
      return formatLastStandings(driversStandings);
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
      Hive.box('requests').put('feDriversStandings', responseAsJson);
      Hive.box('requests').put('feDriversStandingsLatestQuery', DateTime.now());
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
        Hive.box('requests').get('feTeamsStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'feTeamsStandingsLatestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;

    if (latestQuery
            .add(
              const Duration(minutes: 10),
            )
            .isAfter(DateTime.now()) &&
        teamsStandings.isNotEmpty) {
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
      Hive.box('requests').put('feTeamsStandings', responseAsJson);
      Hive.box('requests').put('feTeamsStandingsLatestQuery', DateTime.now());
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
    Map schedule = Hive.box('requests').get('feSchedule', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'feScheduleLatestQuery',
      defaultValue: DateTime.now().subtract(
        const Duration(hours: 1),
      ),
    ) as DateTime;

    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        schedule.isNotEmpty) {
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
      Hive.box('requests').put('feSchedule', responseAsJson);
      Hive.box('requests').put('feScheduleLatestQuery', DateTime.now());
      return races;
    }
  }

  Future<Map> getSessions(String raceId) async {
    if (raceId != '') {
      var url = Uri.parse(
        '$defaultEndpoint/formula-e/v1/races/$raceId/sessions',
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
      List<DateTime> sessionEndDates = [];
      List sessionStates = [];
      List sessionIds = [];
      List sessionNames = [];
      bool hasCombinedQualifs = false;
      Map qualifFinal = {};
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
          sessionEndDates.add(
            DateTime.parse(
              session['sessionDate'] +
                  ' ' +
                  session['finishTime'] +
                  session['offsetGMT'],
            ),
          );
          sessionStates.add(session['sessionLiveStatus']);
          sessionIds.add(session['id']);
          sessionNames.add(session['sessionName']);
        } else if (session['sessionName'] == 'Qual Group A') {
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
          if (session['offsetGMT'].startsWith('-')) {
            if (session['offsetGMT'].length < 6) {
              session['offsetGMT'] = session['offsetGMT'].substring(0, 1) +
                  '0' +
                  session['offsetGMT'].substring(1);
            }
          } else {
            session['offsetGMT'] = '+' + session['offsetGMT'];
          }
          sessionEndDates.add(
            DateTime.parse(
              session['sessionDate'] +
                  ' ' +
                  session['finishTime'] +
                  session['offsetGMT'],
            ),
          );
          if (!hasCombinedQualifs) {
            qualifFinal = session;
          }
        } else if (session['sessionName'] == 'Combined qualifying') {
          hasCombinedQualifs = true;
          qualifFinal = session;
        }
      }

      sessionIds.insert(sessionIds.length - 1, qualifFinal['id']);
      sessionNames.insert(sessionNames.length - 1, 'Combined qualifying');

      return {
        'sessionDates': sessionDates,
        'sessionEndDates': sessionEndDates,
        'sessionStates': sessionStates,
        'sessionIds': sessionIds,
        'original': responseAsJson,
        'sessionNames': sessionNames,
      };
    } else {
      return {};
    }
  }

  Future<Map> getSessionsAndRaceDetails(Race race) async {
    Map sessions = await getSessions(race.meetingId);

    Race raceWithSessions = Race(
      race.round,
      race.meetingId,
      race.raceName,
      race.date,
      sessions['original']['sessions'].last['startTime'],
      race.circuitId,
      race.circuitName,
      race.circuitUrl,
      race.country,
      sessions['sessionDates'],
      raceCoverUrl: race.raceCoverUrl,
      sessionStates: sessions['sessionStates'],
    );

    Uri url = Uri.parse(
      '$defaultEndpoint/content/formula-e/EN?contentTypes=video&contentTypes=news&page=0&pageSize=10&references=FORMULA_E_RACE:${race.meetingId}&onlyRestrictedContent=false&detail=DETAILED',
    );
    http.Response response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    Map responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    Map formatedMap = {
      'raceCustomBBParameter': raceWithSessions,
      'sessionsIdsCustomBBParameter': sessions['sessionIds'],
      'contentsCustomBBParameter': responseAsJson['content'],
    };
    return formatedMap;
  }

  List<DriverResult> formatRaceStandings(Map raceStandings) {
    List<DriverResult> formatedRaceStandings = [];
    List jsonResponse = raceStandings['results'];
    for (var element in jsonResponse) {
      String time = element['delay'];
      if (time == '-') {
        time = element['sessionTime'];
      }
      while (time.startsWith('0:')) {
        time = time.substring(2);
      }
      if (time.startsWith('00')) {
        time = time.substring(1);
      }
      if (time == '') {
        time = 'DNF';
      } else if (element['delay'] != '-') {
        time = '+$time';
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
          element['team']?['name'] ?? '',
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
    Map results = Hive.box('requests').get('feRace-$raceId', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'feRace-$raceId-latestQuery',
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
      Hive.box('requests').put('feRace-$raceId', responseAsJson);
      Hive.box('requests').put(
        'feRace-$raceId-latestQuery',
        DateTime.now(),
      );
      return driversResults;
    }
  }

  Future<List<DriverResult>> getQualificationStandings(
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
        if (time.lastIndexOf(':') != -1) {
          time = time.replaceFirst(':', '.', time.lastIndexOf(':'));
        }
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
            element['team']?['name'] ?? '',
            time,
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
        if (time.lastIndexOf(':') != -1) {
          time = time.replaceFirst(':', '.', time.lastIndexOf(':'));
        }

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
            element['team']?['name'] ?? '',
            time,
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

  String getDriverImageURL(String driverId) {
    return 'https://static-files.formula-e.pulselive.com/drivers/$championshipId/right/small/$driverId.png';
  }

  String getTeamCarImageURL(String teamId) {
    return 'https://static-files.formula-e.pulselive.com/cars/$championshipId/$teamId.png';
  }

  Color getTeamColor(String teamName) {
    Map colors = {
      'jaguar': Color(0xff000000),
      'tag': Color(0xffd5001c),
      'nissan': Color(0xffc3002f),
      'ds': Color(0xffcba65f),
      'andretti': Color(0xffed3124),
      'neom': Color(0xffff8000),
      'maserati': Color(0xff001489),
      'envision': Color(0xff00be26),
      'ert': Color(0xff3c3c3c),
      'abt': Color(0xff194997),
      'mahindra': Color(0xffdd052b),
    };
    return colors[teamName.split(' ')[0].toLowerCase()] ?? Colors.transparent;
  }

  Future<String> getCircuitImageUrl(String raceId) async {
    var url = Uri.parse(
      '$defaultEndpoint/content/formula-e/photo/en/?references=FORMULA_E_RACE:$raceId&tagNames=race:bg-image',
    );
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);

    return responseAsJson['content'][0]['imageUrl'];
  }

  Future<Map> getLatestChampionship() async {
    var url = Uri.parse(
      '$defaultEndpoint/formula-e/v1/championships/latest',
    );
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(
      utf8.decode(
        response.bodyBytes,
      ),
    );
    return responseAsJson;
  }

  Future<void> updateChampionshipId() async {
    Map latestData = await getLatestChampionship();
    Hive.box('settings').put('feChampionshipId', latestData['id']);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
