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

import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class FormulaOneScraper {
  Future<List<ScraperRaceResult>> scrapeResults(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String originalCircuitName,
  }) async {
    String circuitId;
    String circuitName;

    if (fromErgast) {
      circuitId =
          Converter().circuitIdFromErgastToFormulaOne(originalCircuitId);
      circuitName =
          Converter().circuitNameFromErgastToFormulaOne(originalCircuitId);
    } else {
      circuitId = originalCircuitId;
      circuitName = originalCircuitName;
    }

    final Uri resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results.html/2022/races/$circuitId/$circuitName/$sessionName.html');

    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<ScraperRaceResult> results = [];
    List<dom.Element> _tempResults = document.getElementsByTagName('tr');
    _tempResults.removeAt(0);
    _tempResults.forEach(
      (result) {
        results.add(
          ScraperRaceResult(
            result.children[1].text,
            result.children[2].text,
            [
              result.children[3].children[0].text,
              result.children[3].children[1].text,
              result.children[3].children[2].text,
            ],
            result.children[4].text,
            result.children[5].text,
            result.children[6].text,
            result.children[7].text,
          ),
        );
      },
    );
    return results;
  }

  Future<List<ScraperQualifyingResult>> scrapeQualifyingResults(
    String originalCircuitId,
    int practiceSession,
    String sessionName,
    bool fromErgast, {
    String originalCircuitName,
  }) async {
    String circuitId;
    String circuitName;

    if (fromErgast) {
      circuitId =
          Converter().circuitIdFromErgastToFormulaOne(originalCircuitId);
      circuitName =
          Converter().circuitNameFromErgastToFormulaOne(originalCircuitId);
    } else {
      circuitId = originalCircuitId;
      circuitName = originalCircuitName;
    }

    final Uri resultsUrl = Uri.parse(
        'https://www.formula1.com/en/results.html/2022/races/$circuitId/$circuitName/$sessionName.html');

    http.Response response = await http.get(resultsUrl);
    dom.Document document = parser.parse(response.body);
    List<dom.Element> _tempResults = document.getElementsByTagName('tr');
    List<ScraperQualifyingResult> results = [];
    _tempResults.removeAt(0);
    _tempResults.forEach(
      (result) {
        results.add(
          ScraperQualifyingResult(
            result.children[1].text,
            result.children[2].text,
            [
              result.children[3].children[0].text,
              result.children[3].children[1].text,
              result.children[3].children[2].text,
            ],
            result.children[4].text,
            result.children[5].text,
            result.children[6].text,
            result.children[7].text,
            result.children[8].text,
          ),
        );
      },
    );
    return results;
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
          element.attributes['href'].split('.')[2],
          element.children[0].children[0].attributes['style']
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
        if (!element.children[0].children[0].attributes['data-path'].startsWith(
          ('https://'),
        )) {
          imageUrl = 'https://formula1.com' +
              element.children[0].children[0].attributes['data-path'];
        } else {
          imageUrl = element.children[0].children[0].attributes['data-path'];
        }
        imageUrl += '.img.640.medium.' +
            element.children[0].children[0].attributes['data-extension'] +
            element.children[0].children[0].attributes['data-suffix'];
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
