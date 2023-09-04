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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:boxbox/helpers/circuit_points.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LiveFeedFetcher {
  Future<bool> getSessionStatus() async {
    var url = Uri.parse(
      'https://livetiming.formula1.com/static/StreamingStatus.json',
    );
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    String sessionStatus = responseAsJson['Status'];
    if (sessionStatus == "Available") {
      return true;
    } else {
      return false;
    }
  }

  Future<Map> getSessionInfo() async {
    var url =
        Uri.parse('https://livetiming.formula1.com/static/SessionInfo.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    // for test purposes (map)
    //responseAsJson['Path'] =
    //    "2023/2023-03-19_Saudi_Arabian_Grand_Prix/2023-03-19_Race/";
    return responseAsJson;
  }

  Future<Map> getSessionDetails(String path) async {
    Map details = {};
    details["trackStatus"] = await getTrackStatus(path);
    details["lapCount"] = await getLapCount(path);
    details["timingData"] = await getTimingData(path);
    return details;
  }

  Future<Map> getTrackStatus(String path) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${path}TrackStatus.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] = json.decode(
        line.substring(
          line.indexOf('{'),
        ),
      );
    }
    return responseAsJson;
  }

  Future<Map> getLapCount(String path) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${path}LapCount.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] = json.decode(
        line.substring(
          line.indexOf('{'),
        ),
      );
    }
    return responseAsJson;
  }

  Future<Map> getTimingData(String path) async {
    late Uint8List fileAsBytes;

    if (kDebugMode) {
      String assetPath = "assets/testAssets/TimingData.gz";
      ByteData bytes = await rootBundle.load(assetPath);
      fileAsBytes = decodeGlibCompressed(
        bytes.buffer.asUint8List(
          bytes.offsetInBytes,
          bytes.lengthInBytes,
        ),
      );
    } else {
      var url = Uri.parse(
          'https://livetiming.formula1.com/static/${path}TimingData.jsonStream');
      var response = await http.get(url);
      fileAsBytes = response.bodyBytes;
    }
    String fileContent = utf8.decode(fileAsBytes);
    List responseAsList = fileContent.split('\n');
    Map<String, dynamic> responseAsJson = {};
    responseAsList.removeAt(responseAsList.length - 1);
    if (kDebugMode) responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] != null
          ? responseAsJson[line.split('{')[0].split('.')[0]] += [
              json.decode(
                line.substring(
                  line.indexOf('{'),
                ),
              ),
            ]
          : responseAsJson[line.split('{')[0].split('.')[0]] = [
              json.decode(
                line.substring(
                  line.indexOf('{'),
                ),
              ),
            ];
    }
    return responseAsJson;
  }

  Future<Map> getTimingStats(String path) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${path}TimingStats.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] = json.decode(
        line.substring(
          line.indexOf('{'),
        ),
      );
    }
    return responseAsJson;
  }

  String decodeZlibCompressed(String base64Encoded) {
    var b64decoded = base64.decode(base64Encoded);
    var filter = RawZLibFilter.inflateFilter(
      windowBits: -ZLibOption.maxLevel,
    );
    filter.process(b64decoded, 0, b64decoded.length);
    return utf8.decode(filter.processed() ?? []);
  }

  Uint8List decodeGlibCompressed(Uint8List fileAsBytes) {
    return GZipCodec().decode(fileAsBytes) as Uint8List;
  }

  Future<Map> getDetailsForTheMap(String path, String ergastRaceName) async {
    Map positions = await getPosition(path, ergastRaceName);
    List points = await GetTrackGeoJSONPoints().getCircuitPoints(
      positions['ErgastFormatedRaceName'],
    );
    positions['Points'] = points;
    return positions;
  }

  Future<Map> getPosition(String path, String ergastRaceName) async {
    Map<String, dynamic> responseAsJson = {
      "ErgastFormatedRaceName": ergastRaceName,
      "Position": {},
    };
    late Uint8List fileAsBytes;

    if (kDebugMode) {
      String assetPath = "assets/testAssets/Position.gz";
      ByteData bytes = await rootBundle.load(assetPath);
      fileAsBytes = decodeGlibCompressed(
        bytes.buffer.asUint8List(
          bytes.offsetInBytes,
          bytes.lengthInBytes,
        ),
      );
    } else {
      var url = Uri.parse(
          'https://livetiming.formula1.com/static/${path}Position.z.jsonStream');
      var response = await http.get(url);
      fileAsBytes = response.bodyBytes;
    }
    String fileContent = utf8.decode(fileAsBytes);
    List responseAsList = fileContent.split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    if (kDebugMode) responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson['Position'][line.split('"')[0].split('.')[0]] =
          json.decode(
        decodeZlibCompressed(line.split('"')[1]),
      );
    }

    return responseAsJson;
  }

  Future<List> getContentStreams(String path) async {
    var url = Uri.parse(
      'https://livetiming.formula1.com/static/${path}ContentStreams.json',
    );
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson['Streams'];
  }

  Future<Map> getWeatherData(String path) async {
    var url = Uri.parse(
      'https://livetiming.formula1.com/static/${path}WeatherData.jsonStream',
    );
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] = json.decode(
        line.substring(
          line.indexOf('{'),
        ),
      );
    }
    return responseAsJson;
  }

  Future<Map> getData(String path, String ergastRaceName) async {
    Map data = {
      'sessionDetails': await getSessionDetails(path),
      'detailsForTheMap': await getDetailsForTheMap(path, ergastRaceName),
      'contentStreams': await getContentStreams(path),
      'weatherData': await getWeatherData(path),
    };
    return data;
  }
}

// pages = {
//  'session_data': 'SessionData.json',  # track + session status + lap count
//  'session_info': 'SessionInfo.json',  # more rnd
//  'archive_status': 'ArchiveStatus.json',  # rnd=1880327548
//  'heartbeat': 'Heartbeat.jsonStream',  # Probably time synchronization?
//  'audio_streams': 'AudioStreams.jsonStream',  # Link to audio commentary
//  'driver_list': 'DriverList.jsonStream',  # Driver info and line story
//  'extrapolated_clock': 'ExtrapolatedClock.jsonStream',  # Boolean
//  'race_control_messages': 'RaceControlMessages.json',  # Flags etc
//  'session_status': 'SessionStatus.jsonStream',  # Start and finish times
//  'team_radio': 'TeamRadio.jsonStream',  # Links to team radios
//  'timing_app_data': 'TimingAppData.jsonStream',  # Tyres and laps (juicy)
//  'timing_stats': 'TimingStats.jsonStream',  # 'Best times/speed' useless
//  'track_status': 'TrackStatus.jsonStream',  # SC, VSC and Yellow
//  'weather_data': 'WeatherData.jsonStream',  # Temp, wind and rain
//  'position': 'Position.z.jsonStream',  # Coordinates, not GPS? (.z)
//  'car_data': 'CarData.z.jsonStream',  # Telemetry channels (.z)
//  'content_streams': 'ContentStreams.jsonStream',  # Lap by lap feeds
//  'timing_data': 'TimingData.jsonStream',  # Gap to car ahead
//  'lap_count': 'LapCount.jsonStream',  # Lap counter
//  'championship_prediction': 'ChampionshipPrediction.jsonStream'  # Points
//}
//"""Known API requests"""
