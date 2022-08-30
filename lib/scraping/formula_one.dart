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

import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class FormulaOneScraper {
  Future<List<ScraperRaceResult>> scrape(
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
    List<ScraperRaceResult> results = [];
    http.Response response = await http.get(resultsUrl);

    dom.Document document = parser.parse(response.body);
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
