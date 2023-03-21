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

import 'package:http/http.dart' as http;

class LiveFeedFetcher {
  Future<bool> getSessionStatus() async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/StreamingStatus.json');
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
    return responseAsJson;
  }

  Future<Map> getSessionDetails() async {
    Map details = {};
    Map sessionInfo = await getSessionInfo();
    details["trackStatus"] = await getTrackStatus(sessionInfo);
    details["lapCount"] = await getLapCount(sessionInfo);
    details["timingData"] = await getTimingData(sessionInfo);
    return details;
  }

  Future<Map> getTrackStatus(Map sessionDataPath) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}TrackStatus.jsonStream');
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

  Future<Map> getLapCount(Map sessionDataPath) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}LapCount.jsonStream');
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
    print(responseAsJson);
    print("#### Lap Count ####");
    return responseAsJson;
  }

  Future<Map> getTimingData(Map sessionDataPath) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}TimingData.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
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

  Future<Map> getTimingStats(Map sessionDataPath) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}TimingStats.jsonStream');
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
    final b64decoded = base64.decode(base64Encoded);
    final filter = RawZLibFilter.inflateFilter(
      windowBits: -ZLibOption.maxLevel,
    );
    filter.process(b64decoded, 0, b64decoded.length);
    return utf8.decode(filter.processed() ?? []);
  }

  Future<Map> getDetailsForTheMap() async {
    Map sessionInfo = await getSessionInfo();
    return getPosition(sessionInfo);
  }

  Future<Map> getPosition(Map sessionDataPath) async {
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}Position.z.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('{')[0].split('.')[0]] = json.decode(
        decodeZlibCompressed(line),
      );
    }
    print(responseAsJson);
    return responseAsJson;
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
