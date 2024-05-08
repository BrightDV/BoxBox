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
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class Formula1 {
  final String defaultEndpoint = "https://api.formula1.com";
  final String apikey = "qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP";

  List<News> formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['items'];
    List<News> newsList = [];
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;

    for (var element in finalJson) {
      element['title'] = element['title'].replaceAll("\n", "");
      if (element['metaDescription'] != null) {
        element['metaDescription'] =
            element['metaDescription'].replaceAll("\n", "");
      }
      String imageUrl = "";
      if (element['thumbnail'] != null) {
        imageUrl = element['thumbnail']['image']['url'];
        if (useDataSaverMode) {
          if (element['thumbnail']['image']['renditions'] != null) {
            imageUrl =
                element['thumbnail']['image']['renditions']['2col-retina'];
          } else {
            imageUrl += '.transform/2col-retina/image.jpg';
          }
        }
      }
      newsList.add(
        News(
          element['id'],
          element['articleType'],
          element['slug'],
          element['title'],
          element['metaDescription'] ?? '',
          DateTime.parse(element['updatedAt']),
          imageUrl,
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
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (tagId != null) {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&offset=$offset&tags=$tagId');
    } else if (articleType != null) {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&offset=$offset&articleTypes=$articleType');
    } else {
      url =
          Uri.parse('$endpoint/v1/editorial/articles?limit=16&offset=$offset');
    }
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    if (offset == 0 && tagId == null && articleType == null) {
      Hive.box('requests').put('news', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }

  Future<Map<String, dynamic>> getRawPersonalizedFeed(
    List tags, {
    String? articleType,
  }) async {
    Uri url;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (articleType != null) {
      url = Uri.parse(
        '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}&articleTypes=$articleType',
      );
    } else {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}');
    }
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    return responseAsJson;
  }

  Future<Article> getArticleData(String articleId) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    Uri url = Uri.parse('$endpoint/v1/editorial/articles/$articleId');
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    Article article = Article(
      responseAsJson['id'],
      responseAsJson['slug'],
      responseAsJson['title'],
      DateTime.parse(responseAsJson['createdAt']),
      responseAsJson['articleTags'],
      responseAsJson['hero'] ?? {},
      responseAsJson['body'],
      responseAsJson['relatedArticles'],
      responseAsJson['author'] ?? {},
    );
    return article;
  }

  Future<bool> saveLoginCookie(String cookieValue) async {
    String cookies = 'reese84=$cookieValue;';
    String body =
        '{"Login": "${utf8.decode(base64.decode('eWlrbmFib2RyYUBndWZ1bS5jb20='))}","Password": "${utf8.decode(base64.decode('UGxlYXNlRG9uJ3RTdGVhbCExMjM='))}","DistributionChannel": "d861e38f-05ea-4063-8776-a7e2b6d885a4"}';

    Uri url = Uri.parse(
        '$defaultEndpoint/v2/account/subscriber/authenticate/by-password');

    var response = await http.post(
      url,
      body: body,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
        'Origin': 'https://account.formula1.com',
        'Referer': 'https://account.formula1.com/',
        'Host': 'api.formula1.com',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'Sec-GPC': '1',
        'Connection': 'keep-alive',
        'Content-Length': '130',
        'DNT': '1',
        'apiKey': 'fCUCjWrKPu9ylJwRAv8BpGLEgiAuThx7',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/json',
        'Cookie': cookies,
      },
    );

    if (response.statusCode == '403') {
      Hive.box('requests').put('webViewCookie', '');
      Hive.box('requests').put('loginCookie', '');
      return false;
    }

    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    String token = responseAsJson['data']['subscriptionToken'];
    String loginCookie = '{"data": {"subscriptionToken":"$token"}}';
    Hive.box('requests').put('loginCookie', loginCookie);
    Hive.box('requests').put('loginCookieLatestQuery', DateTime.now());

    return true;
  }

  List<DriverResult> formatRaceStandings(Map raceStandings) {
    List<DriverResult> formatedRaceStandings = [];
    List jsonResponse = raceStandings['raceResultsRace']['results'];
    String time;
    String fastestLapDriverName = "";
    String fastestLapTime = "";
    for (var award in raceStandings["raceResultsRace"]["awards"]) {
      // find fastest_lap award, as its index may not be static
      if (award['type'].toLowerCase() == 'fastest_lap') {
        fastestLapDriverName = award['winnerName'];
        fastestLapTime = award['winnerTime'];
        break;
      }
    }
    for (var element in jsonResponse) {
      if (element['completionStatusCode'] != 'OK') {
        // DNF (maybe DSQ?)
        time = element['completionStatusCode'];
      } else if (element['positionNumber'] == '1') {
        time = element['raceTime'];
      } else if (element['lapsBehindLeader'] != null) {
        // finished & lapped cars
        if (element['lapsBehindLeader'] == "0") {
          time = "+" + element['gapToLeader'];
        } else if (element['lapsBehindLeader'] == "1") {
          // one
          time = "+1 Lap";
        } else {
          // more laps
          time = "+${element['lapsBehindLeader']} Laps";
        }
      } else {
        // finished & non-lapped cars
        if (element['positionNumber'] == "1") {
          //first
          time = element["raceTime"];
        } else {
          time = element["gapToLeader"];
        }
      }

      String fastestLapRank = "0";
      if (element['driverLastName'].toLowerCase() == fastestLapDriverName) {
        fastestLapRank = "1";
      }
      formatedRaceStandings.add(
        DriverResult(
          // TODO: find another driverId?
          '', //element['Driver']['driverId'],
          element['positionNumber'],
          element['racingNumber'],
          element['driverFirstName'],
          element['driverLastName'],
          element['driverTLA'],
          Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
          time,
          fastestLapRank != '0' ? true : false,
          fastestLapRank != '0' ? fastestLapTime : "",
          "", // data not available
          // TODO: new UI when lapsDone missing for race results, gap to previous instead?
          //lapsDone: element['laps'],
          points: element['racePoints'].toString(),
          status: element['completionStatusCode'],
        ),
      );
    }
    return formatedRaceStandings;
  }

  FutureOr<List<DriverResult>> getRaceStandings(
      String meetingId, String round) async {
    Map results = Hive.box('requests').get('race-$round', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      'race-$round-latestQuery',
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
      var url = Uri.parse(
        '$defaultEndpoint/v1/fom-results/race?meeting=$meetingId',
      );
      var response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "apikey": apikey,
          "locale": "en",
        },
      );
      Map<String, dynamic> responseAsJson = jsonDecode(response.body);
      List<DriverResult> driversResults = formatRaceStandings(responseAsJson);
      Hive.box('requests').put('raceResultsLastSavedFormat', 'f1');
      Hive.box('requests').put('race-$round', responseAsJson);
      Hive.box('requests').put(
        'race-$round-latestQuery',
        DateTime.now(),
      );

      return driversResults;
    }
  }

  FutureOr<List<DriverQualificationResult>> getQualificationStandings(
      String meetingId) async {
    List<DriverQualificationResult> driversResults = [];
    var url = Uri.parse(
      '$defaultEndpoint/v1/fom-results/qualifying?meeting=$meetingId',
    );
    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "apikey": apikey,
        "locale": "en",
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    if (responseAsJson['raceResultsQualifying']['state'] != 'completed') {
      return [];
    } else {
      List finalJson = responseAsJson['raceResultsQualifying']['results'];
      for (var element in finalJson) {
        driversResults.add(
          DriverQualificationResult(
            '',
            element['positionNumber'],
            element['racingNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
            element['q1']['completionStatusCode'] != 'OK'
                ? element['q1']['completionStatusCode']
                : element['q1']['classifiedTime'],
            element['q2'] == null
                ? '--'
                : element['q2']['completionStatusCode'] != 'OK'
                    ? element['q2']['completionStatusCode']
                    : element['q2']['classifiedTime'],
            element['q3'] == null
                ? '--'
                : element['q3']['completionStatusCode'] != 'OK'
                    ? element['q3']['completionStatusCode']
                    : element['q3']['classifiedTime'],
          ),
        );
      }

      return driversResults;
    }
  }

  Future<List<DriverResult>> getFreePracticeStandings(
      String meetingId, int session) async {
    List<DriverResult> driversResults = [];
    var url = Uri.parse(
      '$defaultEndpoint/v1/fom-results/practice?meeting=$meetingId&session=$session',
    );
    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "apikey": apikey,
        "locale": "en",
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    if (responseAsJson['raceResultsPractice$session']['state'] != 'completed') {
      return [];
    } else {
      List finalJson = responseAsJson['raceResultsPractice$session']['results'];
      for (var element in finalJson) {
        driversResults.add(
          DriverResult(
            // TODO: find another driverId?
            '',
            element['positionNumber'],
            element['racingNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
            element['classifiedTime'],
            false,
            "",
            "+" + element['gapToLeader'] + "s",
            lapsDone: element['lapsCompleted'],
            points: element['racePoints'].toString(),
            status: element['completionStatusCode'],
          ),
        );
      }

      return driversResults;
    }
  }

  FutureOr<List<DriverQualificationResult>> getSprintQualifyingStandings(
      String meetingId) async {
    List<DriverQualificationResult> driversResults = [];
    var url = Uri.parse(
      '$defaultEndpoint/v1/fom-results/sprint-shootout?meeting=$meetingId',
    );
    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "apikey": apikey,
        "locale": "en",
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    if (responseAsJson['raceResultsSprintShootout']['state'] != 'completed') {
      return [];
    } else {
      List finalJson = responseAsJson['raceResultsSprintShootout']['results'];
      for (var element in finalJson) {
        driversResults.add(
          DriverQualificationResult(
            '',
            element['positionNumber'],
            element['racingNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
            element['q1']['completionStatusCode'] != 'OK'
                ? element['q1']['completionStatusCode']
                : element['q1']['classifiedTime'],
            element['q2'] == null
                ? '--'
                : element['q2']['completionStatusCode'] != 'OK'
                    ? element['q2']['completionStatusCode']
                    : element['q2']['classifiedTime'],
            element['q3'] == null
                ? '--'
                : element['q3']['completionStatusCode'] != 'OK'
                    ? element['q3']['completionStatusCode']
                    : element['q3']['classifiedTime'],
          ),
        );
      }

      return driversResults;
    }
  }

  FutureOr<List<DriverResult>> getSprintStandings(
      String meetingId, String session) async {
    List<DriverResult> driversResults = [];
    String time;
    var url = Uri.parse(
      '$defaultEndpoint/v1/fom-results/sprint?meeting=$meetingId',
    );
    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "apikey": apikey,
        "locale": "en",
      },
    );
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    if (responseAsJson['raceResultsSprint']['state'] != 'completed') {
      return [];
    } else {
      List finalJson = responseAsJson['raceResultsSprint']['results'];
      for (var element in finalJson) {
        if (element['completionStatusCode'] != 'OK') {
          // DNF (maybe DSQ?)
          time = element['completionStatusCode'];
        } else if (element['positionNumber'] == '1') {
          time = element['sprintQualifyingTime'];
        } else if (element['lapsBehindLeader'] != null) {
          // finished & lapped cars
          if (element['lapsBehindLeader'] == "0") {
            time = "+" + element['gapToLeader'];
          } else if (element['lapsBehindLeader'] == "1") {
            // one
            time = "+1 Lap";
          } else {
            // more laps
            time = "+${element['lapsBehindLeader']} Laps";
          }
        } else {
          // finished & non-lapped cars
          if (element['positionNumber'] == "1") {
            //first
            time = element["raceTime"];
          } else {
            time = element["gapToLeader"];
          }
        }
        driversResults.add(
          DriverResult(
            // TODO: find another driverId?
            '',
            element['positionNumber'],
            element['racingNumber'],
            element['driverFirstName'],
            element['driverLastName'],
            element['driverTLA'],
            Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
            element['sprintQualifyingTime'] ?? '--',
            false,
            time,
            time,
            lapsDone: "NA",
            points: element['sprintQualifyingPoints'].toString(),
            status: element['completionStatusCode'],
          ),
        );
      }

      return driversResults;
    }
  }

  List<Driver> formatLastStandings(Map responseAsJson) {
    List<Driver> drivers = [];
    List finalJson = responseAsJson['drivers'];
    for (var element in finalJson) {
      drivers.add(
        Driver(
          '',
          element['positionNumber'],
          element['racingNumber'],
          element['driverFirstName'],
          element['driverLastName'],
          element['driverTLA'],
          Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
          element['championshipPoints'].toString(),
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
    if (latestQuery
            .add(
              const Duration(minutes: 5),
            )
            .isAfter(DateTime.now()) &&
        driverStandings.isNotEmpty) {
      return formatLastStandings(driverStandings);
    } else {
      var url = Uri.parse(
        '$defaultEndpoint/v1/editorial-driverlisting/listing',
      );
      var response = await http.get(url);
      Map<String, dynamic> responseAsJson = jsonDecode(response.body);
      List<Driver> drivers = formatLastStandings(responseAsJson);
      Hive.box('requests').put('driversStandings', responseAsJson);
      Hive.box('requests').put('driversStandingsLatestQuery', DateTime.now());
      Hive.box('requests').put('driverStandingsLastSavedFormat', 'f1');
      return drivers;
    }
  }

  List<Team> formatLastTeamsStandings(Map responseAsJson) {
    List<Team> drivers = [];
    List finalJson = responseAsJson['MRData']['StandingsTable']
        ['StandingsLists'][0]['ConstructorStandings'];
    for (var element in finalJson) {
      drivers.add(
        Team(
          Convert().teamsFromFormulaOneApiToErgast(element['teamName']),
          element['positionNumber'],
          element['teamName'],
          element['seasonPoints'].toString(),
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
    if (latestQuery
            .add(
              const Duration(minutes: 10),
            )
            .isAfter(DateTime.now()) &&
        teamsStandings.isNotEmpty) {
      return formatLastTeamsStandings(teamsStandings);
    } else {
      var url = Uri.parse(
        '$defaultEndpoint/v1/editorial-constructorlisting/listing',
      );
      var response = await http.get(url);
      Map<String, dynamic> responseAsJson = jsonDecode(response.body);
      List<Team> teams = formatLastTeamsStandings(responseAsJson);
      Hive.box('requests').put('teamsStandings', responseAsJson);
      Hive.box('requests').put('teamsStandingsLatestQuery', DateTime.now());
      Hive.box('requests').put('teamStandingsLastSavedFormat', 'f1');
      return teams;
    }
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
              Convert().circuitIdFromErgastToFormulaOne(
                element['Circuit']['circuitId'],
              ),
              element['raceName'],
              element['date'],
              element['time'] ?? '15:00:00Z', // temporary time
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
        // TODO: possible bug in the future
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
        if (now.compareTo(raceDate) > 0) {
          races.add(
            Race(
              element['round'],
              Convert().circuitIdFromErgastToFormulaOne(
                element['Circuit']['circuitId'],
              ),
              element['raceName'],
              element['date'],
              element['time'],
              element['Circuit']['circuitId'],
              element['Circuit']['circuitName'],
              element['Circuit']['url'],
              element['Circuit']['Location']['country'],
              raceDates,
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
        const Duration(hours: 2),
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
      var url = Uri.parse('$defaultEndpoint/v1/editorial-eventlisting/events');
      var response = await http.get(url);
      Map<String, dynamic> responseAsJson = jsonDecode(response.body);
      List<Race> races = formatLastSchedule(responseAsJson, toCome);
      Hive.box('requests').put('schedule', responseAsJson);
      Hive.box('requests').put('scheduleLatestQuery', DateTime.now());
      Hive.box('requests').put('scheduleLastSavedFormat', 'f1');
      return races;
    }
  }
}

class News {
  final String newsId;
  final String newsType;
  final String slug;
  final String title;
  final String subtitle;
  final DateTime datePosted;
  final String imageUrl;

  News(
    this.newsId,
    this.newsType,
    this.slug,
    this.title,
    this.subtitle,
    this.datePosted,
    this.imageUrl,
  );
}

class Article {
  final String articleId;
  final String articleSlug;
  final String articleName;
  final DateTime publishedDate;
  final List articleTags;
  final Map articleHero;
  final List articleContent;
  final List relatedArticles;
  final Map authorDetails;

  Article(
    this.articleId,
    this.articleSlug,
    this.articleName,
    this.publishedDate,
    this.articleTags,
    this.articleHero,
    this.articleContent,
    this.relatedArticles,
    this.authorDetails,
  );
}
