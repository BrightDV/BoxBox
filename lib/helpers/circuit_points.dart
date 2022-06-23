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

import 'package:http/http.dart' as http;

class GetTrackGeoJSONPoints {
  Map<String, String> circuitIdEncoder = {
    "bahrain": "bh-2002",
    "jeddah": "sa-2021",
    "albert_park": "au-1953",
    "imola": "it-1953",
    "miami": "unavailable",
    "catalunya": "es-1991",
    "monaco": "mc-1929",
    "baku": "az-2016",
    "villeneuve": "ca-1978",
    "silverstone": "gb-1948",
    "red_bull_ring": "at-1969",
    "ricard": "fr-1969",
    "hungaroring": "hu-1986",
    "spa": "be-1925",
    "zandvoort": "nl-1948",
    "monza": "it-1922",
    "marina_bay": "sg-2008",
    "suzuka": "jp-1962",
    "americas": "us-2012",
    "rodriguez": "mx-1962",
    "interlagos": "br-1940",
    "yas_marina": "ae-2009",
  };
  Future<List<List>> getCircuitPoints(String circuitId) async {
    String encodedCircuitName = circuitIdEncoder[circuitId];
    Uri url;
    if (circuitId == 'miami') {
      url = Uri.parse('https://raw.githubusercontent.com/eribradl/f1-circuits/master/circuits/mi-2022.geojson');
    } else {
      url = Uri.parse('https://raw.githubusercontent.com/bacinger/f1-circuits/master/circuits/${encodedCircuitName}.geojson');
    }
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);
    List trackPoints = responseAsJson["features"][0]["geometry"]["coordinates"];
    List _tempMapCenter = responseAsJson["features"][0]["bbox"];
    double latitude = _tempMapCenter[1] - (_tempMapCenter[1] - _tempMapCenter[3]) / 2;
    double longitude = _tempMapCenter[0] - (_tempMapCenter[0] - _tempMapCenter[2]) / 2;
    List mapCenter = [
      latitude,
      longitude
    ];
    List<List> circuitPoints = [
      trackPoints,
      mapCenter,
    ];
    return circuitPoints;
  }
}
