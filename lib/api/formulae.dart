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
              '',
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
              '',
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
