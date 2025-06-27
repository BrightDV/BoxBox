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
import 'dart:io';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class FormulaOneScraper {
  final String defaultEndpoint = Constants().F1_API_URL;

  Future<List<DriverResult>> scrapeRaceResult(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String? originalCircuitName,
    String? raceUrl,
  }) async {
    late Uri resultsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (raceUrl != null) {
      if (endpoint != defaultEndpoint) {
        resultsUrl = Uri.parse(
          raceUrl.replaceAll(
            'https://www.formula1.com',
            endpoint,
          ),
        );
      } else {
        resultsUrl = Uri.parse(raceUrl);
      }
    } else {
      String circuitId;
      String circuitName;

      if (fromErgast) {
        circuitId =
            Convert().circuitIdFromErgastToFormulaOne(originalCircuitId);
        circuitName =
            Convert().circuitNameFromErgastToFormulaOne(originalCircuitId);
      } else {
        circuitId = originalCircuitId;
        circuitName = originalCircuitName!;
      }
      if (endpoint != defaultEndpoint) {
        resultsUrl = Uri.parse(
          '$endpoint/f1/results/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
        );
      } else {
        resultsUrl = Uri.parse(
          'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
        );
      }
    }
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<DriverResult> results = [];
    List<dom.Element> tempResults = document.getElementsByTagName('tr');
    tempResults.removeAt(0);
    for (var result in tempResults) {
      results.add(
        DriverResult(
          'driverId',
          result.children[1].text,
          result.children[2].text,
          result.children[3].children[0].text,
          result.children[3].children[1].text,
          result.children[3].children[2].text,
          Convert().teamsFromFormulaOneToErgast(
            result.children[4].text,
          ),
          result.children[6].text,
          false,
          '2:00.000',
          '2:00.000',
          lapsDone: result.children[5].text,
          points: result.children[7].text,
        ),
      );
    }
    return results;
  }

  Future<List<DriverQualificationResult>> scrapeQualifyingResults(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String? originalCircuitName,
    String? qualifyingResultsUrl,
    bool? hasSprint,
  }) async {
    late String circuitId;
    late String circuitName;
    late Uri resultsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (fromErgast) {
      circuitId = Convert().circuitIdFromErgastToFormulaOne(originalCircuitId);
      circuitName =
          Convert().circuitNameFromErgastToFormulaOne(originalCircuitId);
    } else if (qualifyingResultsUrl == null) {
      circuitId = originalCircuitId;
      circuitName = originalCircuitName!;
    }
    if (endpoint != defaultEndpoint) {
      resultsUrl = Uri.parse(
        qualifyingResultsUrl?.replaceAll(
              'https://www.formula1.com',
              endpoint,
            ) ??
            '$endpoint/f1/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
      );
    } else if (qualifyingResultsUrl == null) {
      resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
      );
    } else {
      resultsUrl = Uri.parse(qualifyingResultsUrl);
    }
    http.Response response = await http.get(
      resultsUrl,
      headers: {
        'user-agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      },
    );
    dom.Document document = parser.parse(response.body);
    if (hasSprint ?? false) {
      if (!document
          .getElementsByClassName('ResultsArchiveTitle')[0]
          .innerHtml
          .contains('SPRINT QUALIFYING')) {
        throw Exception();
      }
    }
    List<dom.Element> finishedSessions =
        document.getElementsByClassName('side-nav-item');
    finishedSessions.removeAt(0);
    bool isQualifyingsFinished = false;
    for (dom.Element element in finishedSessions) {
      if (element.text.trim().contains('Qualifying')) {
        isQualifyingsFinished = true;
      }
    }
    if (isQualifyingsFinished) {
      List<dom.Element> tempResults = document.getElementsByTagName('tr');
      List<DriverQualificationResult> results = [];

      tempResults.removeAt(0);

      for (var result in tempResults) {
        results.add(
          DriverQualificationResult(
            'driverId',
            result.children[1].text,
            result.children[2].text,
            result.children[3].children[0].text,
            result.children[3].children[1].text,
            result.children[3].children[2].text,
            Convert().teamsFromFormulaOneToErgast(
              result.children[4].text,
            ),
            result.children[5].text != '' ? result.children[5].text : '--',
            result.children[6].text != '' ? result.children[6].text : '--',
            result.children[7].text != '' ? result.children[7].text : '--',
          ),
        );
      }

      return results;
    } else {
      return [];
    }
  }

  Future<List<DriverResult>> scrapeFreePracticeResult(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String? originalCircuitName,
    String? raceUrl,
  }) async {
    late Uri resultsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (raceUrl != null) {
      resultsUrl = Uri.parse(raceUrl);
      if (endpoint != defaultEndpoint) {
        resultsUrl = Uri.parse(
          raceUrl.replaceAll(
            'https://www.formula1.com',
            endpoint,
          ),
        );
      } else {
        resultsUrl = Uri.parse(raceUrl);
      }
    } else {
      String circuitId;
      String circuitName;

      if (fromErgast) {
        circuitId =
            Convert().circuitIdFromErgastToFormulaOne(originalCircuitId);
        circuitName =
            Convert().circuitNameFromErgastToFormulaOne(originalCircuitId);
      } else {
        circuitId = originalCircuitId;
        circuitName = originalCircuitName!;
      }

      if (endpoint != defaultEndpoint) {
        resultsUrl = Uri.parse(
          '$endpoint/f1/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
        );
      } else {
        resultsUrl = Uri.parse(
          'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
        );
      }
    }
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    bool isFreePracticeFinished = false;
    List<dom.Element> finishedSessions =
        document.getElementsByClassName('side-nav-item');
    finishedSessions.removeAt(0);
    practiceSession = practiceSession == 0
        ? int.parse(raceUrl!.split('/')[9].split('-')[1].split('.')[0])
        : practiceSession;
    for (dom.Element element in finishedSessions) {
      if (element.text.substring(29).startsWith('Practice $practiceSession')) {
        isFreePracticeFinished = true;
      }
    }
    if (isFreePracticeFinished) {
      List<DriverResult> results = [];
      List<dom.Element> tempResults = document.getElementsByTagName('tr');
      tempResults.removeAt(0);
      for (var result in tempResults) {
        results.add(
          DriverResult(
            'driverId',
            result.children[1].text,
            result.children[2].text,
            result.children[3].children[0].text,
            result.children[3].children[1].text,
            result.children[3].children[2].text,
            Convert().teamsFromFormulaOneToErgast(
              result.children[4].text,
            ),
            result.children[5].text,
            false,
            result.children[6].text,
            result.children[6].text,
            lapsDone: result.children[7].text,
          ),
        );
      }
      return results;
    } else {
      return [
        DriverResult('', '', '', '', '', '', '', '', false, '', ''),
      ];
    }
  }

  Future<List<StartingGridPosition>> scrapeStartingGrid(
      String startingGridUrl) async {
    late Uri startingGridUri;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      startingGridUri = Uri.parse(
        startingGridUrl.replaceAll(
          'https://www.formula1.com',
          endpoint,
        ),
      );
    } else {
      startingGridUri = Uri.parse(
        startingGridUrl,
      );
    }
    http.Response response = await http.get(
      startingGridUri,
    );
    dom.Document document = parser.parse(response.body);
    List<dom.Element> tempResults = document.getElementsByTagName('tr');
    List<StartingGridPosition> results = [];

    tempResults.removeAt(0);
    for (var result in tempResults) {
      results.add(
        StartingGridPosition(
          result.children[1].text,
          result.children[2].text,
          result.children[3].children[1].text,
          Convert().teamsFromFormulaOneToErgast(
            result.children[4].text,
          ),
          result.children[4].text,
          result.children[5].text != '' ? result.children[5].text : '--',
        ),
      );
    }

    return results;
  }

  Future<List<List>> scrapeDriversDetails(
    String ergastDriverId,
    String? detailsPath,
  ) async {
    final String driverId = detailsPath != null
        ? detailsPath
        : Convert().driverIdFromErgast(ergastDriverId);
    late Uri driverDetailsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      driverDetailsUrl = Uri.parse("$endpoint/f1/en/drivers/${driverId}.html");
    } else {
      driverDetailsUrl = Uri.parse(
        "https://www.formula1.com/en/drivers/$driverId",
      );
    }
    http.Response response = await http.get(driverDetailsUrl);
    List<List> results = [
      [],
      [],
      [],
      [
        [],
        [],
      ],
      [],
    ];
    dom.Document document = parser.parse(
      utf8.decode(response.bodyBytes),
    );

    List<dom.Element> tempDetails = document.getElementsByTagName('dd');
    for (int i = 0; i < 10; i++) {
      results[0].add(tempDetails[i].text);
    }

    List<dom.Element> tempDriverArticles =
        document.getElementsByClassName('f1-driver-article-card');
    for (dom.Element element in tempDriverArticles) {
      if (element.attributes['href'] != null) {
        results[1].add(
          [
            element.attributes['href']!.split('.').last,
            element.getElementsByTagName("img").first.attributes['src']!,
            element.children[0].children[1].children[1].text,
            element.children[0].children[1].children[0].text,
          ],
        );
      }
    }

    List<dom.Element> tempBiography = document
        .getElementsByClassName('f1-driver-bio')[0]
        .children[document
                .getElementsByClassName('f1-driver-bio')[0]
                .children
                .length -
            1]
        .children;
    for (var element in tempBiography) {
      results[2].add(element.text);
    }

    List<dom.Element> tempDriverMedias =
        document.getElementsByClassName('f1-carousel__slide');
    for (var element in tempDriverMedias) {
      String imageUrl = element.firstChild!.firstChild!.attributes['src'] ?? '';
      results[3][0].add(imageUrl);
    }

    tempDriverMedias = document.getElementsByClassName('gallery-description');
    for (var element in tempDriverMedias) {
      results[3][1].add(element.text);
    }

    results[4].add(
      document.getElementsByClassName('f1-heading')[1].text,
    );

    return results;
  }

  Future<Map<String, dynamic>> scrapeTeamDetails(
      String ergastTeamId, String? detailsPath) async {
    final String teamId = detailsPath != null
        ? detailsPath
        : Convert().teamsFromErgastToFormulaOne(ergastTeamId);
    late Uri teamDetailsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      teamDetailsUrl = Uri.parse("$endpoint/f1/en/teams/$teamId.html");
    } else {
      teamDetailsUrl = Uri.parse(
        "https://www.formula1.com/en/teams/$teamId.html",
      );
    }
    http.Response response = await http.get(
      teamDetailsUrl,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );
    dom.Document document = parser.parse(
      utf8.decode(response.bodyBytes),
    );

    Map<String, dynamic> results = {};
    results["drivers"] = {"images": [], "names": []};
    results["teamStats"] = [];
    results["information"] = [];
    results["medias"] = [];
    results["articles"] = [];
    results["teamName"] = "";

    List<dom.Element> tempDetails =
        document.getElementsByClassName('f1-grid grid-cols-2')[0].children;
    for (int i = 0; i <= 1; i++) {
      results["drivers"]["images"].add(
        tempDetails[i].children[0].children[0].children[0].attributes['src'],
      );
      List names = [];
      for (var name
          in tempDetails[i].children[0].children[1].children[0].children) {
        names.add(name.text);
      }
      results["drivers"]["names"].add(
        names,
      );
    }

    tempDetails = document.getElementsByTagName('dd');
    if (tempDetails.length > 0) {
      for (var detail in tempDetails) {
        results["teamStats"].add(
          detail.text,
        );
      }
    }

    tempDetails = document
        .getElementsByClassName('f1-driver-bio')[0]
        .children[document
                .getElementsByClassName('f1-driver-bio')[0]
                .children
                .length -
            1]
        .children;
    results["information"].add("## In Profile");
    for (var element in tempDetails) {
      String formatedElement = "";
      if (element.text.trim().startsWith("20") ||
          element.text.trim().startsWith("Official ") ||
          element.text.trim().startsWith("Read ")) {
        formatedElement = "### ";
      }
      results["information"].add(
        formatedElement + element.text + "\n",
      );
    }

    List<dom.Element> tempDriverMedias =
        document.getElementsByClassName('f1-carousel__slide');
    for (var element in tempDriverMedias) {
      String imageUrl = element.firstChild!.firstChild!.attributes['src'] ?? '';
      results["medias"].add(imageUrl);
    }

    List<dom.Element> tempDriverArticles =
        document.getElementsByClassName('f1-driver-article-card');
    for (dom.Element element in tempDriverArticles) {
      if (element.attributes['href'] != null) {
        results["articles"].add(
          [
            element.attributes['href']!.split('.').last,
            element.getElementsByTagName("img").first.attributes['src']!,
            element.children[0].children[1].children[1].text,
            element.children[0].children[1].children[0].text,
          ],
        );
      }
    }

    results["teamName"] = document.getElementsByClassName('f1-heading')[0].text;

    return results;
  }

  Future<int> whichSessionsAreFinised(
    String circuitId,
    String circuitName,
  ) async {
    late Uri resultsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      resultsUrl = Uri.parse(
        '$endpoint/f1/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/race-result.html',
      );
    } else {
      resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results/${DateTime.now().year}/races/$circuitId/$circuitName/race-result',
      );
    }
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    if (document.getElementsByClassName("no-results").isNotEmpty) {
      return 0;
    } else {
      List<dom.Element>? tempResults = document
          .getElementsByClassName('f1-grid')[0]
          .getElementsByClassName('f1-menu-item');
      tempResults.removeAt(0);
      int maxSession = 0;
      for (dom.Element element in tempResults) {
        if (element.text.contains('Practice')) {
          if (int.parse(element.text.trim().replaceAll('Practice', '')) >
              maxSession) {
            maxSession =
                int.parse(element.text.trim().replaceAll('Practice', ''));
          }
        }
      }
      return maxSession;
    }
  }

  Future<List<HallOfFameDriver>> scrapeHallOfFame() async {
    List<HallOfFameDriver> results = [];

    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    String f1Endpoint = endpoint != defaultEndpoint
        ? endpoint + '/f1'
        : Constants().F1_WEBSITE_URL;
    Uri driverDetailsUrl = Uri.parse('$f1Endpoint/en/drivers/hall-of-fame');

    http.Response response = await http.get(driverDetailsUrl);
    if (response.statusCode == HttpStatus.ok) {
      dom.Document document = parser.parse(response.body);
      List<dom.Element> elements = document
          .querySelectorAll('a[href*="/en/information/drivers-hall-of-fame"]');

      for (dom.Element element in elements) {
        String driverName =
            element.getElementsByClassName('f1-heading')[0].text.trim();

        dom.Element imageElement = element.getElementsByTagName('img')[0];
        String driverImage = imageElement.attributes['src'] ?? '';

        String driverUrl = f1Endpoint + element.attributes['href']!;

        results.add(HallOfFameDriver(driverName, driverUrl, driverImage));
      }
    }

    return results;
  }

  Future<Map> scrapeHallOfFameDriverDetails(String pageUrl) async {
    Map results = {};
    final Uri driverDetailsUrl = Uri.parse(pageUrl);
    http.Response response = await http.get(driverDetailsUrl);
    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    dom.Element tempResult = document.getElementById('maincontent')!;
    dom.Element content = tempResult.getElementsByTagName('article')[1];

    results['metaDescription'] = content
        .getElementsByTagName('p')[0]
        .getElementsByTagName('strong')[0]
        .text;
    List parts = [];
    tempResult.getElementsByClassName('prose').forEach(
          (paragraph) => paragraph.getElementsByTagName('p').forEach(
                (element) => parts.add(element.text),
              ),
        );
    results['parts'] = parts.sublist(1);
    return results;
  }

  Future<Map> scrapeCircuitFactsAndHistory(
      String formulaOneCircuitName, BuildContext context) async {
    Map results = {"facts": {}, "history": {}};
    late Uri formulaOneCircuitPageUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      formulaOneCircuitPageUrl = Uri.parse(
        '$endpoint/f1/en/racing/${DateTime.now().year}/$formulaOneCircuitName/Circuit.html',
      );
    } else {
      formulaOneCircuitPageUrl = Uri.parse(
        'https://www.formula1.com/en/racing/${DateTime.now().year}/$formulaOneCircuitName/Circuit.html',
      );
    }
    http.Response response = await http.get(formulaOneCircuitPageUrl);

    // facts
    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    // dom.Element tempResult = document.getElementsByTagName('main')[0];
    document.getElementsByClassName('f1-grid')[1].children.forEach((element) {
      String originalFactLabel =
          element.getElementsByClassName("f1-text")[0].text;
      String factValue = element.getElementsByClassName("f1-heading")[0].text;
      if (originalFactLabel.startsWith('Lap')) {
        factValue = factValue.substring(0, 8) + '\n' + factValue.substring(8);
      }
      String factLabel = "";
      originalFactLabel == "First Grand Prix"
          ? factLabel = AppLocalizations.of(context)!.firstGrandPrix
          : originalFactLabel == "Number of Laps"
              ? factLabel = AppLocalizations.of(context)!.numberOfLaps
              : originalFactLabel == "Circuit Length"
                  ? factLabel = AppLocalizations.of(context)!.circuitLength
                  : originalFactLabel == "Race Distance"
                      ? factLabel = AppLocalizations.of(context)!.raceDistance
                      : factLabel = AppLocalizations.of(context)!.lapRecord;
      results["facts"][factLabel] = factValue;
    });

    // history
    String circuitHistory = document
        .getElementsByClassName('prose')[0]
        .innerHtml
        .replaceAll('<h2>', '__')
        .replaceAll('</h2>', '__\n')
        .replaceAll('<h3>', '*')
        .replaceAll('</h3>', '*\n')
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n')
        .replaceAll('  ', '');
    int position = circuitHistory.indexOf('<a ');
    while (position != -1) {
      int hrefPosition = circuitHistory.indexOf("href") + 6;
      String href = circuitHistory.substring(
        hrefPosition,
        circuitHistory.indexOf(
          '"',
          hrefPosition,
        ),
      );
      String anchor = circuitHistory.substring(
          circuitHistory.indexOf('">') + 2, circuitHistory.indexOf('</a>'));
      circuitHistory =
          '${circuitHistory.substring(0, position)}[$anchor]($href)${circuitHistory.substring(
        circuitHistory.indexOf('</a>') + 4,
      )}';
      position = circuitHistory.indexOf('<a ');
    }

    results["history"] = circuitHistory;

    return results;
  }

  Future<String> getMeetingIdFromTrack(
      String track, BuildContext context) async {
    late Uri url;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      url = Uri.parse(
        '$endpoint/f1/en/racing/${DateTime.now().year}/$track/Circuit.html',
      );
    } else {
      url = Uri.parse(
        'https://www.formula1.com/en/racing/${DateTime.now().year}/$track/Circuit.html',
      );
    }
    http.Response response = await http.get(url);
    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    int index = document.body!.innerHtml.indexOf('practice?meeting=') + 17;
    String meetingId = document.body!.innerHtml.substring(index, index + 4);
    context.pushReplacementNamed(
      'racing',
      pathParameters: {'meetingId': meetingId},
    );
    return meetingId;
  }
}

class HallOfFameDriver {
  String driverName;
/*   String years; */
  String detailsPageUrl;
  String imageUrl;

  HallOfFameDriver(
    this.driverName,
/*     this.years, */
    this.detailsPageUrl,
    this.imageUrl,
  );
}
