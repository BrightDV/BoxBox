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

import 'dart:convert';
import 'dart:io';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class FormulaOneScraper {
  final String defaultEndpoint = "https://api.formula1.com";

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
          '$endpoint/results/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
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
            '$endpoint/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
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
          '$endpoint/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html',
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
      driverDetailsUrl = Uri.parse("$endpoint/en/drivers/${driverId}.html");
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
      teamDetailsUrl = Uri.parse("$endpoint/en/teams/$teamId.html");
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
    results["teamStats"] = {"attributes": [], "values": []};
    results["information"] = [];
    results["medias"] = {"images": [], "captions": []};
    results["articles"] = [];

    List<dom.Element> tempDetails =
        document.getElementsByClassName('fom-adaptiveimage');
    tempDetails = document.getElementsByClassName('driver-teaser');
    for (int i = 0; i <= 1; i++) {
      results["drivers"]["images"].add(
        tempDetails[i]
            .children[0]
            .children[0]
            .children[0]
            .children[0]
            .children[0]
            .attributes['data-path'],
      );
      results["drivers"]["names"].add(
        tempDetails[i]
            .children[0]
            .children[1]
            .text
            .replaceAll("  ", "")
            .replaceAll("\n\n\n", "")
            .replaceAll("\n\n", "\n")
            .trim(),
      );
    }
    tempDetails = document.getElementsByTagName('tr');
    if (tempDetails.length > 0) {
      for (int i = 0; i < 11; i++) {
        results["teamStats"]["attributes"].add(
          tempDetails[i].children[0].text.trim(),
        );
        results["teamStats"]["values"].add(
          tempDetails[i].children[1].text.trim(),
        );
      }
    }
    tempDetails = document.getElementsByClassName('information');
    for (int i = 0; i < tempDetails.length; i++) {
      for (var element in tempDetails[i].children) {
        results["information"].add(
          element.innerHtml
              .trim()
              .replaceAll("\n", "")
              .replaceAll("<h3>", "# ")
              .replaceAll("</h3>", "\n")
              .replaceAll("<p>", "\n")
              .replaceAll("</p>", "\n")
              .replaceAll("<a href=\"", "")
              .replaceAll("</a>", "")
              .replaceAll("<h4><strong>", "\n\n### ")
              .replaceAll("</strong></h4>", "\n")
              .replaceAll("<strong>", "")
              .replaceAll("</strong>", "")
              .replaceAll("<br>", ""),
        );
      }
    }
    List<dom.Element> tempTeamMedias =
        document.getElementsByClassName('swiper-slide');
    for (var element in tempTeamMedias) {
      String imageUrl;
      if (!element.children[0].children[0].attributes['data-path']!.startsWith(
        ('https://'),
      )) {
        imageUrl =
            'https://formula1.com${element.children[0].children[0].attributes['data-path']!}';
      } else {
        imageUrl = element.children[0].children[0].attributes['data-path']!;
      }
      imageUrl +=
          '.img.640.medium.${element.children[0].children[0].attributes['data-extension']!}${element.children[0].children[0].attributes['data-suffix']!}';
      results["medias"]["images"].add(imageUrl);
    }

    tempTeamMedias = document.getElementsByClassName('gallery-description');
    for (var element in tempTeamMedias) {
      results["medias"]["captions"].add(element.text);
    }

    List<dom.Element> tempTeamArticles = document
        .getElementsByClassName('articles')[0]
        .getElementsByClassName('article-teaser-link');
    for (var element in tempTeamArticles) {
      results["articles"].add(
        [
          element.attributes['href']!.split('.')[2],
          element.children[0].children[0].attributes['style']!
              .split('(')[1]
              .split(')')[0],
          element.children[0].children[1].children[1].text,
          element.children[0].children[1].children[0].text.trim(),
        ],
      );
    }
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
        '$endpoint/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName.html',
      );
    } else {
      resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName.html',
      );
    }
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    if (document.getElementsByClassName("no-results").isNotEmpty) {
      return 0;
    } else {
      List<dom.Element>? tempResults =
          document.getElementsByClassName('side-nav-item');
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
    String f1Endpoint =
        endpoint != defaultEndpoint ? endpoint : 'https://www.formula1.com';
    Uri driverDetailsUrl =
        Uri.parse('$f1Endpoint/en/drivers/hall-of-fame.html');

    http.Response response = await http.get(driverDetailsUrl);
    if (response.statusCode == HttpStatus.ok) {
      dom.Document document = parser.parse(response.body);
      List<dom.Element> elements = document.querySelectorAll(
          'a.column.column-4[href*="/en/drivers/hall-of-fame/"][href\$=".html"]');

      for (dom.Element element in elements) {
        List<String> driverInfo = element
            .getElementsByClassName('teaser-info-title')
            .first
            .text
            .trim()
            .split(' - ');
        String driverName = driverInfo[0];
        String driverYears = driverInfo[1];

        dom.Element imageElement = element
            .getElementsByTagName('img')
            .firstWhere((e) => e.classes.contains('hidden'));
        String driverImage = imageElement.attributes['src'] ?? '';

        String driverUrl = f1Endpoint + element.attributes['href']!;

        results.add(
            HallOfFameDriver(driverName, driverYears, driverUrl, driverImage));
      }
    }

    return results;
  }

  Future<Map> scrapeHallOfFameDriverDetails(String pageUrl) async {
    Map results = {};
    final Uri driverDetailsUrl = Uri.parse(pageUrl);
    http.Response response = await http.get(driverDetailsUrl);
    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    if (pageUrl.endsWith('Max_Verstappen.html')) {
      dom.Element tempResult =
          document.getElementsByClassName('f1-article--content')[1];
      results['metaDescription'] = tempResult
          .getElementsByClassName('f1-article--rich-text')[0]
          .getElementsByTagName("strong")[0]
          .text;
      List parts = [];
      tempResult.getElementsByClassName('f1-article--rich-text').forEach(
            (paragraph) => paragraph.getElementsByTagName('p').forEach(
                  (element) => parts.add(element.text),
                ),
          );
      results['parts'] = parts.sublist(1);
      return results;
    } else {
      dom.Element tempResult = document.getElementsByTagName('main')[0];
      results['metaDescription'] =
          tempResult.getElementsByClassName('strapline')[0].text;
      List parts = [];
      tempResult.getElementsByClassName('text parbase').forEach(
            (paragraph) => paragraph.getElementsByTagName('p').forEach(
                  (element) => parts.add(element.text),
                ),
          );
      results['parts'] = parts;
      return results;
    }
  }

  Future<Map> scrapeCircuitFactsAndHistory(
      String formulaOneCircuitName, BuildContext context) async {
    Map results = {"facts": {}, "history": {}};
    late Uri formulaOneCircuitPageUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      formulaOneCircuitPageUrl = Uri.parse(
        '$endpoint/en/racing/${DateTime.now().year}/$formulaOneCircuitName/Circuit.html',
      );
    } else {
      formulaOneCircuitPageUrl = Uri.parse(
        'https://www.formula1.com/en/racing/${DateTime.now().year}/$formulaOneCircuitName/Circuit.html',
      );
    }
    http.Response response = await http.get(formulaOneCircuitPageUrl);

    // facts
    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    dom.Element tempResult = document.getElementsByTagName('main')[0];
    tempResult.getElementsByClassName('f1-stat').forEach((element) {
      String elementSubstring = element.innerHtml
          .replaceAll('  ', '')
          .replaceAll('<p class="misc--label">', '')
          .replaceAll('</p>', '')
          .replaceAll('<p class="f1-bold--stat">', '')
          .replaceAll('<span class="misc--label">', '')
          .replaceAll('</span>', '')
          .replaceAll('<span class="misc--label d-block d-md-inline">', ' — ');
      List<String> elementSubstringSplitted = elementSubstring.split('\n');
      String factLabel = "";
      elementSubstringSplitted[1] == "First Grand Prix"
          ? factLabel = AppLocalizations.of(context)!.firstGrandPrix
          : elementSubstringSplitted[1] == "Number of Laps"
              ? factLabel = AppLocalizations.of(context)!.numberOfLaps
              : elementSubstringSplitted[1] == "Circuit Length"
                  ? factLabel = AppLocalizations.of(context)!.circuitLength
                  : elementSubstringSplitted[1] == "Race Distance"
                      ? factLabel = AppLocalizations.of(context)!.raceDistance
                      : factLabel = AppLocalizations.of(context)!.lapRecord;
      results["facts"][factLabel] = elementSubstringSplitted[2];
    });

    // history
    tempResult = document.getElementsByTagName('main')[0];
    String circuitHistory = tempResult
        .getElementsByClassName('f1-race-hub--content')[0]
        .children[0]
        .children[0]
        .innerHtml
        .substring(160)
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
}

class HallOfFameDriver {
  String driverName;
  String years;
  String detailsPageUrl;
  String imageUrl;

  HallOfFameDriver(
    this.driverName,
    this.years,
    this.detailsPageUrl,
    this.imageUrl,
  );
}
