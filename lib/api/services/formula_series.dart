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

import 'dart:convert';

import 'package:boxbox/classes/article.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/classes/team.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/providers/circuit/format.dart';
import 'package:boxbox/providers/results/format.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FormulaSeries {
  final String defaultEndpoint = Constants().F1_API_URL;

  List<News> formatResponse(Map responseAsJson) {
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    List finalJson = responseAsJson['items'];
    List<News> newsList = [];

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
          '${Constants().FORMULA_SERIES_BASE_URLS[championship]}/Latest/${element['id']}/${element['slug']}',
          isBreaking: element['breaking'],
        ),
      );
    }
    return newsList;
  }

  Future<List<News>> getMoreNews(
    int offset, {
    String? tagId,
    String? articleType,
  }) async {
    Uri url;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipIdentifier = Constants().FORMULA_SERIES[championship];

    url = Uri.parse(
      endpoint != defaultEndpoint
          ? '$endpoint/fs/v1/f2f3-editorial/articles?limit=16&offset=$offset'
          : '$endpoint/v1/f2f3-editorial/articles?website=${championshipIdentifier}&limit=16&offset=$offset',
    );

    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
              "locale": "en",
            },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    if (offset == 0 && tagId == null && articleType == null) {
      Hive.box('requests').put('${championshipIdentifier}News', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }

  Future<Article> getArticleData(String articleId) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Uri url = Uri.parse(
      endpoint != defaultEndpoint
          ? '$endpoint/fs/v1/f2f3-editorial/articles/$articleId'
          : '$endpoint/v1/f2f3-editorial/articles/$articleId?website=$championshipId',
    );
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
              "locale": "en",
            },
    );
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    List body = responseAsJson['body'];
    for (Map item in body) {
      if (item['contentType'] == 'atomRichText') {
        item['fields']['richTextBlock'] =
            item['fields']['richTextBlock'].replaceAll(' __\n', '__\n');
      }
    }
    Article article = Article(
      responseAsJson['id'],
      responseAsJson['slug'],
      responseAsJson['title'],
      DateTime.parse(responseAsJson['createdAt']),
      responseAsJson['articleTags'],
      responseAsJson['hero'] ?? {},
      responseAsJson['body'],
      responseAsJson['latest'],
      responseAsJson['author'] ?? {},
    );
    return article;
  }

  List<Driver> formatLastStandings(Map responseAsJson) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    List<Driver> drivers = [];
    List finalJson = responseAsJson['Standings'];
    for (var element in finalJson) {
      if (!element['DisplayName'].contains('WCD')) {
        String lastName = element['DisplayName'].split('.')[1].substring(1);
        String firstName = element['FullName'].substring(
          0,
          element['FullName'].indexOf(lastName) - 1,
        );
        String formatedCarNumber = element['CarNumber'].toString();
        if (formatedCarNumber.length == 1) {
          formatedCarNumber = '0' + formatedCarNumber;
        }
        String driverImage;
        if (championshipId == 'f2') {
          driverImage =
              'https://res.cloudinary.com/prod-f2f3/c_fill,dpr_1.0,f_auto,g_auto,h_65,w_100/v1/$championshipId/global/drivers/${DateTime.now().year}/Official/${formatedCarNumber}_${lastName}';
        } else if (championshipId == 'fa') {
          driverImage =
              'https://res.cloudinary.com/prod-f2f3/image/upload/v1741276107/FA/Global/drivers/${DateTime.now().year}/Cutouts/${firstName}_Cutout.png';
        } else {
          driverImage = driverImage =
              'https://res.cloudinary.com/prod-f2f3/c_fill,dpr_1.0,f_auto,g_auto,h_65,w_100/v1/$championshipId/global/drivers/${DateTime.now().year}/${DateTime.now().year} Driver profiles/${formatedCarNumber}_${lastName}';
        }
        drivers.add(
          Driver(
            element['DriverID'].toString(),
            element['Position'].toString(),
            element['CarNumber'].toString(),
            firstName,
            lastName,
            element['TLA'],
            element['TeamName'],
            (element['TotalPoints'] ?? 0).toString(),
            driverImage: driverImage,
          ),
        );
      }
    }
    return drivers;
  }

  Future<List<Driver>> getLastStandings() async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Map driversStandings = Hive.box('requests')
        .get('${championshipId}DriversStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      '${championshipId}DriversStandingsLatestQuery',
      defaultValue: DateTime.now(),
    ) as DateTime;

    if (latestQuery
            .add(
              const Duration(minutes: 10),
            )
            .isAfter(DateTime.now()) &&
        driversStandings.isNotEmpty) {
      return formatLastStandings(driversStandings);
    } else {
      String endpoint = Hive.box('settings')
          .get('server', defaultValue: defaultEndpoint) as String;
      var url = Uri.parse(
        //endpoint != defaultEndpoint
        //   ? '$endpoint/f1/v2/fom-results/driverstandings/season=${DateTime.now().year}'
        '$endpoint/v1/f2f3-fom-results/driverstandings?website=${championshipId}',
      );
      var response = await http.get(
        url,
        headers: endpoint == defaultEndpoint
            ? {
                "Accept": "application/json",
                "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
                "locale": "en",
              }
            : {
                "Accept": "application/json",
              },
      );
      Map<String, dynamic> responseAsJson = jsonDecode(
        utf8.decode(
          response.bodyBytes,
        ),
      );
      List<Driver> drivers = formatLastStandings(responseAsJson);
      Hive.box('requests')
          .put('${championshipId}DriversStandings', responseAsJson);
      Hive.box('requests')
          .put('${championshipId}DriversStandingsLatestQuery', DateTime.now());
      return drivers;
    }
  }

  List<Team> formatLastTeamsStandings(Map responseAsJson) {
    List<Team> teams = [];
    List finalJson = responseAsJson['Standings'];
    for (var element in finalJson) {
      String formatedCarNumber = element['Position'].toString();
      if (formatedCarNumber.length == 1) {
        formatedCarNumber = '0' + formatedCarNumber;
      }
      teams.add(
        Team(
          element['TeamID'].toString(),
          element['Position'].toString(),
          element['DisplayName'],
          (element['TotalPoints'] ?? '0').toString(),
          '',
        ),
      );
    }
    return teams;
  }

  Future<List<Team>> getLastTeamsStandings() async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Map teamsStandings = Hive.box('requests')
        .get('${championshipId}TeamsStandings', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      '${championshipId}TeamsStandingsLatestQuery',
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
      String endpoint = Hive.box('settings')
          .get('server', defaultValue: defaultEndpoint) as String;
      Uri url = Uri.parse(
        // endpoint != defaultEndpoint
        //    ? '$endpoint/f1/v1/editorial-constructorlisting/listing'
        '$endpoint/v1/f2f3-fom-results/teamstandings?website=$championshipId',
      );
      var response = await http.get(
        url,
        headers: endpoint == defaultEndpoint
            ? {
                "Accept": "application/json",
                "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
                "locale": "en",
              }
            : {
                "Accept": "application/json",
              },
      );
      Map<String, dynamic> responseAsJson = jsonDecode(response.body);
      List<Team> teams = formatLastTeamsStandings(responseAsJson);
      Hive.box('requests')
          .put('${championshipId}TeamsStandings', responseAsJson);
      Hive.box('requests')
          .put('${championshipId}TeamsStandingsLatestQuery', DateTime.now());
      return teams;
    }
  }

  List<Race> formatLastSchedule(Map responseAsJson, bool toCome) {
    List<Race> races = [];
    List finalJson = responseAsJson['Races'];
    if (toCome) {
      for (var element in finalJson) {
        DateTime raceDate =
            DateTime.parse(element['Sessions'].first['SessionStartTime'])
                .toLocal();
        DateTime raceEndDate;
        if (element['Sessions'].last['SessionEndTime'] != null) {
          raceEndDate =
              DateTime.parse(element['Sessions'].last['SessionEndTime'])
                  .toLocal()
                  .subtract(
                    Duration(hours: 2),
                  );
        } else {
          raceEndDate = raceDate.add(Duration(hours: 3));
        }
        DateTime now = DateTime.now();

        if (now.compareTo(raceEndDate) < 0) {
          races.add(
            Race(
              element['RoundNumber'].toString(),
              element['RaceId'].toString(),
              element['CircuitShortName'],
              raceDate.toIso8601String(),
              DateFormat.Hm().format(raceDate),
              element['CircuitName'],
              element['CircuitName'],
              '',
              element['CountryName'],
              [],
              isFirst: races.isEmpty,
              raceCoverUrl:
                  'https://res.cloudinary.com/prod-f2f3/ar_16:9,c_fill,dpr_1.0,f_auto,g_auto,h_500/v1/' +
                      element['CircuitImagePath'],
            ),
          );
        }
      }
    } else {
      for (var element in finalJson) {
        DateTime raceDate =
            DateTime.parse(element['Sessions'].first['SessionStartTime'])
                .toLocal();
        DateTime raceEndDate;
        if (element['Sessions'].last['SessionEndTime'] != null) {
          raceEndDate =
              DateTime.parse(element['Sessions'].last['SessionEndTime'])
                  .toLocal()
                  .subtract(
                    Duration(hours: 2),
                  );
        } else {
          raceEndDate = raceDate.add(Duration(hours: 3));
        }
        DateTime now = DateTime.now();

        if (now.compareTo(raceEndDate) > 0) {
          races.add(
            Race(
              element['RoundNumber'].toString(),
              element['RaceId'].toString(),
              element['CircuitShortName'],
              raceDate.toIso8601String(),
              DateFormat.Hm().format(raceDate),
              element['CircuitName'],
              element['CircuitName'],
              '',
              element['CountryName'],
              [],
              isFirst: races.isEmpty,
              raceCoverUrl:
                  'https://res.cloudinary.com/prod-f2f3/ar_16:9,c_fill,dpr_1.0,f_auto,g_auto,h_500/v1/' +
                      element['CircuitImagePath'],
            ),
          );
        }
      }
    }
    return races;
  }

  Future<List<Race>> getLastSchedule(bool toCome) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Map schedule =
        Hive.box('requests').get('${championshipId}Schedule', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      '${championshipId}ScheduleLatestQuery',
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
      String endpoint = Hive.box('settings')
          .get('server', defaultValue: defaultEndpoint) as String;
      Uri url = Uri.parse(
        '$endpoint/v1/f2f3-fom-results/races?website=${championshipId}',
      );
      var response = await http.get(
        url,
        headers: endpoint == defaultEndpoint
            ? {
                "Accept": "application/json",
                "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
                "locale": "en",
              }
            : {
                "Accept": "application/json",
              },
      );
      Map<String, dynamic> responseAsJson = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List<Race> races = formatLastSchedule(responseAsJson, toCome);
      Hive.box('requests').put('${championshipId}Schedule', responseAsJson);
      Hive.box('requests')
          .put('${championshipId}ScheduleLatestQuery', DateTime.now());
      return races;
    }
  }

  Future<RaceDetails> getCircuitDetails(String meetingId) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Map details = Hive.box('requests')
        .get('${championshipId}CircuitDetails-$meetingId', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      '${championshipId}CircuitDetails-$meetingId-LatestQuery',
      defaultValue: DateTime.now().subtract(
        const Duration(hours: 1),
      ),
    ) as DateTime;
    Map formatedResponse;
    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        details.isNotEmpty) {
      formatedResponse = details;
    } else {
      String endpoint = Hive.box('settings')
          .get('server', defaultValue: defaultEndpoint) as String;

      Uri uri = Uri.parse(
        '$endpoint/v1/f2f3-fom-results/races/${meetingId}?website=$championshipId',
      );

      http.Response res = await http.get(
        uri,
        headers: endpoint != defaultEndpoint
            ? {
                "Accept": "application/json",
              }
            : {
                "Accept": "application/json",
                "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
                "locale": "en",
              },
      );
      formatedResponse = jsonDecode(
        utf8.decode(res.bodyBytes),
      );
      Hive.box('requests')
          .put('${championshipId}CircuitDetails-$meetingId', formatedResponse);
      Hive.box('requests').put(
        '${championshipId}CircuitDetails-$meetingId-LatestQuery',
        DateTime.now(),
      );
    }
    return CircuitFormatProvider().formatCircuitData(formatedResponse);
  }

  List<DriverResult> formatResults(List res) {
    List<DriverResult> results = [];
    for (Map result in res) {
      String gap = result['Gap'] ?? '';
      try {
        int.parse(gap.substring(0, 1));
        gap = '+' + gap;
      } catch (_) {}
      results.add(
        DriverResult(
          result['DriverId'].toString(),
          result['DisplayFinishPosition'].toString(),
          result['CarNumber'].toString(),
          result['DriverForename'],
          result['DriverSurname'],
          result['TLA'],
          result['TeamName'],
          result['TimeOrFinishReason'],
          gap,
          result['Position'] == 1,
          result['Best'] ?? '',
          result['Best'] ?? '',
          lapsDone: result['LapsCompleted'].toString(),
          status: result['ResultStatus'],
        ),
      );
    }
    return results;
  }

  Future<List<DriverResult>> getSessionResults(
    String meetingId, {
    String? sessionIndex,
    String? sessionName,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipId = Constants().FORMULA_SERIES[championship];
    Map details = Hive.box('requests')
        .get('${championshipId}CircuitDetails-$meetingId', defaultValue: {});
    DateTime latestQuery = Hive.box('requests').get(
      '${championshipId}CircuitDetails-$meetingId-LatestQuery',
      defaultValue: DateTime.now().subtract(
        const Duration(hours: 1),
      ),
    ) as DateTime;
    Map formatedResponse;
    if (latestQuery
            .add(
              const Duration(minutes: 30),
            )
            .isAfter(DateTime.now()) &&
        details.isNotEmpty) {
      formatedResponse = details;
    } else {
      String endpoint = Hive.box('settings')
          .get('server', defaultValue: defaultEndpoint) as String;

      Uri uri = Uri.parse(
        '$endpoint/v1/f2f3-fom-results/races/${meetingId}?website=$championshipId',
      );

      http.Response res = await http.get(
        uri,
        headers: endpoint != defaultEndpoint
            ? {
                "Accept": "application/json",
              }
            : {
                "Accept": "application/json",
                "apikey": Constants().FORMULA_SERIES_APIKEYS[championship],
                "locale": "en",
              },
      );
      formatedResponse = jsonDecode(
        utf8.decode(res.bodyBytes),
      );
      Hive.box('requests')
          .put('${championshipId}CircuitDetails-$meetingId', formatedResponse);
      Hive.box('requests').put(
        '${championshipId}CircuitDetails-$meetingId-LatestQuery',
        DateTime.now(),
      );
    }

    List sessionResults = formatedResponse['SessionResults'];
    if (sessionIndex == null) {
      sessionIndex = ResultsFormatProvider()
          .getSessionIndexForFormulaSeries(
            sessionResults,
            sessionName!,
          )
          .toString();
    }

    return formatResults(
      sessionResults[int.parse(sessionIndex)]['Results'],
    );
  }
}
