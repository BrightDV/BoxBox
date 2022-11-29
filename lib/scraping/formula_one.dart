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
 * Copyright (c) 2022, BrightDV
 */

import 'dart:convert';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class FormulaOneScraper {
  Future<List<DriverResult>> scrapeRaceResult(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String? originalCircuitName,
    String? raceUrl,
  }) async {
    late Uri resultsUrl;
    if (raceUrl != null) {
      resultsUrl = Uri.parse(raceUrl);
    } else {
      String circuitId;
      String circuitName;

      if (fromErgast) {
        circuitId =
            Converter().circuitIdFromErgastToFormulaOne(originalCircuitId);
        circuitName =
            Converter().circuitNameFromErgastToFormulaOne(originalCircuitId);
      } else {
        circuitId = originalCircuitId;
        circuitName = originalCircuitName!;
      }

      resultsUrl = Uri.parse(
          'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/$circuitId/$circuitName/$sessionName.html');
    }
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<DriverResult> results = [];
    List<dom.Element> _tempResults = document.getElementsByTagName('tr');
    _tempResults.removeAt(0);
    _tempResults.forEach(
      (result) {
        results.add(
          DriverResult(
            'driverId',
            result.children[1].text,
            result.children[2].text,
            result.children[3].children[0].text,
            result.children[3].children[1].text,
            result.children[3].children[2].text,
            Converter().teamsFromFormulaOneToErgast(
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
      },
    );
    return results;
  }

  Future<List<DriverQualificationResult>> scrapeQualifyingResults(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String? originalCircuitName,
    String? qualifyingResultsUrl,
  }) async {
    late String circuitId;
    late String circuitName;

    if (fromErgast) {
      circuitId =
          Converter().circuitIdFromErgastToFormulaOne(originalCircuitId);
      circuitName =
          Converter().circuitNameFromErgastToFormulaOne(originalCircuitId);
    } else if (qualifyingResultsUrl == null) {
      circuitId = originalCircuitId;
      circuitName = originalCircuitName!;
    }
    final Uri resultsUrl = Uri.parse(qualifyingResultsUrl != null
        ? qualifyingResultsUrl
        : 'https://www.formula1.com/en/results.html/2022/races/$circuitId/$circuitName/$sessionName.html');

    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<dom.Element> finishedSessions =
        document.getElementsByClassName('side-nav-item');
    finishedSessions.removeAt(0);
    bool isQualifyingsFinished = false;
    for (dom.Element element in finishedSessions) {
      if (element.text.substring(29).startsWith('Qualifying')) {
        isQualifyingsFinished = true;
      }
    }
    if (isQualifyingsFinished) {
      List<dom.Element> _tempResults = document.getElementsByTagName('tr');
      List<DriverQualificationResult> results = [];

      _tempResults.removeAt(0);
      _tempResults.forEach(
        (result) {
          results.add(
            DriverQualificationResult(
              'driverId',
              result.children[1].text,
              result.children[2].text,
              result.children[3].children[0].text,
              result.children[3].children[1].text,
              result.children[3].children[2].text,
              Converter().teamsFromFormulaOneToErgast(
                result.children[4].text,
              ),
              result.children[5].text != '' ? result.children[5].text : '--',
              result.children[6].text != '' ? result.children[6].text : '--',
              result.children[7].text != '' ? result.children[7].text : '--',
            ),
          );
        },
      );

      return results;
    } else {
      return [
        DriverQualificationResult('', '', '', '', '', '', '', '', '', ''),
      ];
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
    if (raceUrl != null) {
      resultsUrl = Uri.parse(raceUrl);
    } else {
      String circuitId;
      String circuitName;

      if (fromErgast) {
        circuitId =
            Converter().circuitIdFromErgastToFormulaOne(originalCircuitId);
        circuitName =
            Converter().circuitNameFromErgastToFormulaOne(originalCircuitId);
      } else {
        circuitId = originalCircuitId;
        circuitName = originalCircuitName!;
      }

      resultsUrl = Uri.parse(
          'https://www.formula1.com/en/results.html/2022/races/$circuitId/$circuitName/$sessionName.html');
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
      List<dom.Element> _tempResults = document.getElementsByTagName('tr');
      _tempResults.removeAt(0);
      _tempResults.forEach(
        (result) {
          results.add(
            DriverResult(
              'driverId',
              result.children[1].text,
              result.children[2].text,
              result.children[3].children[0].text,
              result.children[3].children[1].text,
              result.children[3].children[2].text,
              Converter().teamsFromFormulaOneToErgast(
                result.children[4].text,
              ),
              result.children[5].text,
              false,
              result.children[6].text,
              result.children[6].text,
              lapsDone: result.children[7].text,
            ),
          );
        },
      );
      return results;
    } else {
      return [
        DriverResult('', '', '', '', '', '', '', '', false, '', ''),
      ];
    }
  }

  Future<List<List>> scrapeDriversDetails(
    String ergastDriverId,
  ) async {
    final String driverId = Converter().driverIdFromErgast(ergastDriverId);
    final Uri driverDetailsUrl =
        Uri.parse('https://www.formula1.com/en/drivers/$driverId.html');
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

    List<dom.Element> _tempDetails = document.getElementsByTagName('tr');
    for (int i = 0; i < 10; i++) {
      results[0].add(_tempDetails[i].children[1].text);
    }

    List<dom.Element> _tempDriverArticles = document
        .getElementsByClassName('articles')[0]
        .getElementsByClassName('article-teaser-link');
    _tempDriverArticles.forEach(
      (element) => results[1].add(
        [
          element.attributes['href']!.split('.')[2],
          element.children[0].children[0].attributes['style']!
              .split('(')[1]
              .split(')')[0],
          element.children[0].children[1].children[1].text,
          element.children[0].children[1].children[0].text,
        ],
      ),
    );

    List<dom.Element> _tempBiography = document
        .getElementsByClassName('biography')[0]
        .children[
            document.getElementsByClassName('biography')[0].children.length - 1]
        .children;
    _tempBiography.forEach(
      (element) {
        results[2].add(element.text);
      },
    );

    List<dom.Element> _tempDriverMedias =
        document.getElementsByClassName('swiper-slide');
    _tempDriverMedias.forEach(
      (element) {
        String imageUrl;
        if (!element.children[0].children[0].attributes['data-path']!
            .startsWith(
          ('https://'),
        )) {
          imageUrl = 'https://formula1.com' +
              element.children[0].children[0].attributes['data-path']!;
        } else {
          imageUrl = element.children[0].children[0].attributes['data-path']!;
        }
        imageUrl += '.img.640.medium.' +
            element.children[0].children[0].attributes['data-extension']! +
            element.children[0].children[0].attributes['data-suffix']!;
        results[3][0].add(imageUrl);
      },
    );

    _tempDriverMedias = document.getElementsByClassName('gallery-description');
    _tempDriverMedias.forEach(
      (element) {
        results[3][1].add(element.text);
      },
    );

    return results;
  }

  Future<int> whichSessionsAreFinised(
    String circuitId,
    String circuitName,
  ) async {
    final Uri resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results.html/2022/races/$circuitId/$circuitName.html');
    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<dom.Element>? _tempResults =
        document.getElementsByClassName('side-nav-item');
    _tempResults.remove(0);
    int maxSession = 0;
    for (dom.Element element in _tempResults) {
      if (element.text.contains('Practice')) {
        if (int.parse(element.text.substring(38, 40)) > maxSession) {
          maxSession = int.parse(element.text.substring(38, 40));
        }
      }
    }
    return maxSession;
  }

  Future<List<HallOfFameDriver>> scrapeHallOfFame() async {
    List<HallOfFameDriver> results = [];
    final Uri driverDetailsUrl =
        Uri.parse('https://www.formula1.com/en/drivers/hall-of-fame.html');
    http.Response response = await http.get(driverDetailsUrl);
    dom.Document document = parser.parse(response.body);
    List<dom.Element>? _tempResults =
        document.getElementsByClassName('fom-teaser');
    _tempResults.forEach(
      (element) => results.add(
        HallOfFameDriver(
          element.children[0].children[1].attributes['alt']!
              .toString()
              .split(' - ')[0],
          element.children[0].children[1].attributes['alt']!
              .toString()
              .split(' - ')[1],
          'https://www.formula1.com/content/fom-website/en/drivers/hall-of-fame/${element.children[0].children[1].attributes['alt']!.toString().split(' - ')[0].replaceAll(' ', '_')}.html',
          'https://www.formula1.com/content/fom-website/en/drivers/hall-of-fame/${element.children[0].children[1].attributes['alt']!.toString().split(' - ')[0].replaceAll(' ', '_')}/_jcr_content/image16x9.img.640.medium.jpg',
        ),
      ),
    );
    return results;
  }

  Future<Map> scrapeHallOfFameDriverDetails(String pageUrl) async {
    Map results = {};
    final Uri driverDetailsUrl = Uri.parse(pageUrl);
    http.Response response = await http.get(driverDetailsUrl);
    dom.Document document = parser.parse(response.body);
    dom.Element _tempResult = document.getElementsByTagName('main')[0];
    results['metaDescription'] =
        _tempResult.getElementsByClassName('strapline')[0].text;
    List parts = [];
    _tempResult.getElementsByClassName('text parbase').forEach(
          (paragraph) => paragraph.getElementsByTagName('p').forEach(
                (element) => parts.add(element.text),
              ),
        );
    results['parts'] = parts;
    return results;
  }
}

class ScraperRaceResult {
  final String position;
  final String number;
  final List driver;
  final String car;
  final String time;
  final String gap;
  final String laps;

  ScraperRaceResult(
    this.position,
    this.number,
    this.driver,
    this.car,
    this.time,
    this.gap,
    this.laps,
  );
}

class ScraperQualifyingResult {
  final String position;
  final String number;
  final List driver;
  final String car;
  final String timeq1;
  final String timeq2;
  final String timeq3;
  final String laps;

  ScraperQualifyingResult(
    this.position,
    this.number,
    this.driver,
    this.car,
    this.timeq1,
    this.timeq2,
    this.timeq3,
    this.laps,
  );
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
