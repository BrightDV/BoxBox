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
    /* Map sessionInfo = await getSessionInfo();
    details["trackStatus"] = await getTrackStatus(sessionInfo);
    details["lapCount"] = await getLapCount(sessionInfo);
    details["timingData"] = await getTimingData(sessionInfo); */
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
    var b64decoded = base64.decode(base64Encoded);
    var filter = RawZLibFilter.inflateFilter(
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
    /*  var url = Uri.parse(
        'https://livetiming.formula1.com/static/${sessionDataPath["Path"]}Position.z.jsonStream');
    var response = await http.get(url);
    Map<String, dynamic> responseAsJson = {};
    List responseAsList = utf8.decode(response.bodyBytes).split('\n');
    responseAsList.removeAt(responseAsList.length - 1);
    for (String line in responseAsList) {
      responseAsJson[line.split('"')[0].split('.')[0]] = json.decode(
        decodeZlibCompressed(line.split('"')[1]),
      );
    }
    print(responseAsJson); */
    Map responseAsJson = {
      "ErgastFormatedRaceName": "jeddah",
      "Position": [
        {
          "Timestamp": "2023-03-19T18:04:41.560678Z",
          "Entries": {
            "1": {"Status": "OnTrack", "X": -3267, "Y": 2324, "Z": 114},
            "2": {"Status": "OnTrack", "X": -4236, "Y": 11778, "Z": 113},
            "4": {"Status": "OnTrack", "X": -4562, "Y": 10039, "Z": 131},
            "10": {"Status": "OnTrack", "X": -3513, "Y": 19724, "Z": 112},
            "11": {"Status": "OnTrack", "X": -3928, "Y": -1160, "Z": 113},
            "14": {"Status": "OnTrack", "X": -5055, "Y": 11580, "Z": 115},
            "16": {"Status": "OnTrack", "X": -4310, "Y": 19625, "Z": 119},
            "18": {"Status": "OnTrack", "X": -4574, "Y": 21646, "Z": 121},
            "20": {"Status": "OnTrack", "X": -4070, "Y": 15050, "Z": 117},
            "21": {"Status": "OnTrack", "X": -4332, "Y": 11206, "Z": 120},
            "22": {"Status": "OnTrack", "X": -3849, "Y": 15833, "Z": 119},
            "23": {"Status": "OnTrack", "X": -2237, "Y": 2597, "Z": 118},
            "24": {"Status": "OnTrack", "X": -4247, "Y": 11456, "Z": 115},
            "27": {"Status": "OnTrack", "X": -4777, "Y": 12794, "Z": 130},
            "31": {"Status": "OnTrack", "X": -3666, "Y": 21174, "Z": 118},
            "44": {"Status": "OnTrack", "X": -5230, "Y": 15623, "Z": 120},
            "55": {"Status": "OnTrack", "X": -4209, "Y": 17745, "Z": 114},
            "63": {"Status": "OnTrack", "X": -5795, "Y": 14420, "Z": 117},
            "77": {"Status": "OnTrack", "X": -517, "Y": -5609, "Z": 114},
            "81": {"Status": "OnTrack", "X": -4152, "Y": 9411, "Z": 123}
          }
        },
        {
          "Timestamp": "2023-03-19T18:04:41.9416201Z",
          "Entries": {
            "1": {"Status": "OnTrack", "X": -3420, "Y": 2015, "Z": 117},
            "2": {"Status": "OnTrack", "X": -4292, "Y": 12081, "Z": 115},
            "4": {"Status": "OnTrack", "X": -4599, "Y": 10289, "Z": 132},
            "10": {"Status": "OnTrack", "X": -3531, "Y": 20090, "Z": 113},
            "11": {"Status": "OnTrack", "X": -3835, "Y": -1537, "Z": 113},
            "14": {"Status": "OnTrack", "X": -4999, "Y": 11212, "Z": 117},
            "16": {"Status": "OnTrack", "X": -4196, "Y": 19324, "Z": 118},
            "18": {"Status": "OnTrack", "X": -4574, "Y": 21646, "Z": 121},
            "20": {"Status": "OnTrack", "X": -3953, "Y": 15299, "Z": 117},
            "21": {"Status": "OnTrack", "X": -4244, "Y": 11479, "Z": 115},
            "22": {"Status": "OnTrack", "X": -3772, "Y": 16130, "Z": 118},
            "23": {"Status": "OnTrack", "X": -2237, "Y": 2597, "Z": 118},
            "24": {"Status": "OnTrack", "X": -4234, "Y": 11753, "Z": 113},
            "27": {"Status": "OnTrack", "X": -4961, "Y": 13012, "Z": 132},
            "31": {"Status": "OnTrack", "X": -3739, "Y": 21409, "Z": 115},
            "44": {"Status": "OnTrack", "X": -5466, "Y": 15546, "Z": 119},
            "55": {"Status": "OnTrack", "X": -4333, "Y": 17414, "Z": 115},
            "63": {"Status": "OnTrack", "X": -5790, "Y": 14114, "Z": 118},
            "77": {"Status": "OnTrack", "X": -366, "Y": -5641, "Z": 113},
            "81": {"Status": "OnTrack", "X": -4314, "Y": 9552, "Z": 127}
          }
        },
        {
          "Timestamp": "2023-03-19T18:04:42.2015806Z",
          "Entries": {
            "1": {"Status": "OnTrack", "X": -3481, "Y": 1894, "Z": 118},
            "2": {"Status": "OnTrack", "X": -4323, "Y": 12199, "Z": 116},
            "4": {"Status": "OnTrack", "X": -4602, "Y": 10392, "Z": 132},
            "10": {"Status": "OnTrack", "X": -3539, "Y": 20234, "Z": 114},
            "11": {"Status": "OnTrack", "X": -3797, "Y": -1685, "Z": 113},
            "14": {"Status": "OnTrack", "X": -4986, "Y": 11066, "Z": 118},
            "16": {"Status": "OnTrack", "X": -4165, "Y": 19198, "Z": 117},
            "18": {"Status": "OnTrack", "X": -4574, "Y": 21646, "Z": 121},
            "20": {"Status": "OnTrack", "X": -3926, "Y": 15415, "Z": 117},
            "21": {"Status": "OnTrack", "X": -4232, "Y": 11597, "Z": 114},
            "22": {"Status": "OnTrack", "X": -3738, "Y": 16248, "Z": 117},
            "23": {"Status": "OnTrack", "X": -2237, "Y": 2597, "Z": 118},
            "24": {"Status": "OnTrack", "X": -4247, "Y": 11869, "Z": 113},
            "27": {"Status": "OnTrack", "X": -5000, "Y": 13124, "Z": 133},
            "31": {"Status": "OnTrack", "X": -3779, "Y": 21487, "Z": 115},
            "44": {"Status": "OnTrack", "X": -5540, "Y": 15477, "Z": 118},
            "55": {"Status": "OnTrack", "X": -4390, "Y": 17287, "Z": 116},
            "63": {"Status": "OnTrack", "X": -5783, "Y": 13990, "Z": 120},
            "77": {"Status": "OnTrack", "X": -305, "Y": -5636, "Z": 114},
            "81": {"Status": "OnTrack", "X": -4372, "Y": 9626, "Z": 128}
          }
        },
        {
          "Timestamp": "2023-03-19T18:04:42.481538Z",
          "Entries": {
            "1": {"Status": "OnTrack", "X": -3578, "Y": 1703, "Z": 119},
            "2": {"Status": "OnTrack", "X": -4374, "Y": 12378, "Z": 120},
            "4": {"Status": "OnTrack", "X": -4593, "Y": 10553, "Z": 131},
            "10": {"Status": "OnTrack", "X": -3554, "Y": 20464, "Z": 116},
            "11": {"Status": "OnTrack", "X": -3737, "Y": -1915, "Z": 114},
            "14": {"Status": "OnTrack", "X": -4976, "Y": 10836, "Z": 122},
            "16": {"Status": "OnTrack", "X": -4132, "Y": 18997, "Z": 116},
            "18": {"Status": "OnTrack", "X": -4574, "Y": 21646, "Z": 121},
            "20": {"Status": "OnTrack", "X": -3902, "Y": 15553, "Z": 119},
            "21": {"Status": "OnTrack", "X": -4236, "Y": 11784, "Z": 113},
            "22": {"Status": "OnTrack", "X": -3681, "Y": 16435, "Z": 115},
            "23": {"Status": "OnTrack", "X": -2237, "Y": 2597, "Z": 118},
            "24": {"Status": "OnTrack", "X": -4283, "Y": 12047, "Z": 115},
            "27": {"Status": "OnTrack", "X": -5036, "Y": 13357, "Z": 135},
            "31": {"Status": "OnTrack", "X": -3853, "Y": 21594, "Z": 116},
            "44": {"Status": "OnTrack", "X": -5636, "Y": 15342, "Z": 116},
            "55": {"Status": "OnTrack", "X": -4509, "Y": 17032, "Z": 117},
            "63": {"Status": "OnTrack", "X": -5764, "Y": 13795, "Z": 122},
            "77": {"Status": "OnTrack", "X": -222, "Y": -5611, "Z": 114},
            "81": {"Status": "OnTrack", "X": -4448, "Y": 9747, "Z": 129}
          }
        }
      ]
    };
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
