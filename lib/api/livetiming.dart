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

import 'package:http/http.dart' as http;

class LiveTiming {
  Future<Map> sessionInfo() async {
    var url =
        Uri.parse('https://livetiming.formula1.com/static/SessionInfo.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  Future<Map> spFeed(Map sessionInfo) async {
    String sessionDataPath = sessionInfo['Path'];
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath}SPFeed.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  Future<Map> trackStatus(Map sessionInfo) async {
    String sessionDataPath = sessionInfo['Path'];
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath}TrackStatus.json');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  Future<Map> timingData(Map sessionInfo) async {
    String sessionDataPath = sessionInfo['Path'];
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath}TimingData.json');
    var response = await http.get(url);
    Map responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    )['Lines'];
    return responseAsJson;
  }

  Future<Map> weather(Map sessionInfo) async {
    String sessionDataPath = sessionInfo['Path'];
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath}WeatherData.json');
    var response = await http.get(url);
    Map responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  Future<Map> scribbleBlogUrl(Map sessionInfo) async {
    String sessionDataPath = sessionInfo['Path'];
    var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath}ContentStreams.json');
    var response = await http.get(url);
    Map responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  Future<String> scribbleBlogRawContent(String scribbleEmbedBlogUrl) async {
    var url = Uri.parse(scribbleEmbedBlogUrl);
    var response = await http.get(url);
    String rawBlogContent = utf8.decode(response.bodyBytes);
    return rawBlogContent;
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
