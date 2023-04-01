// ignore_for_file: avoid_print

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

import 'package:boxbox/Screens/LivetimingArchive/drivers_map.dart';
import 'package:boxbox/api/live_feed.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';

class LiveTimingScreen extends StatelessWidget {
  const LiveTimingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Timing Archive'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriversMapScreen(),
                    ),
                  ),
              icon: const Icon(Icons.map_outlined))
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map>(
        future: LiveFeedFetcher().getSessionDetails(),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? LiveTimingScreenFragment(snapshot.data!)
                : const LoadingIndicatorUtil(),
      ),
    );
  }
}

class LiveTimingScreenFragment extends StatefulWidget {
  final Map sessionDetails;
  const LiveTimingScreenFragment(this.sessionDetails, {Key? key})
      : super(key: key);

  @override
  State<LiveTimingScreenFragment> createState() =>
      _LiveTimingScreenFragmentState();
}

class _LiveTimingScreenFragmentState extends State<LiveTimingScreenFragment> {
  late Timer timer;
  double sliderValue = 0;
  Duration currentDuration = const Duration();
  List driverNumbers = [
    "1",
    "2",
    "4",
    "10",
    "11",
    "14",
    "16",
    "18",
    "20",
    "21",
    "22",
    "23",
    "24",
    "27",
    "31",
    "44",
    "55",
    "63",
    "77",
    "81",
  ];
  Map trackStatus = {};
  Map lapCount = {};
  Map timingData = {};
  Map timingStats = {};
  int totalLaps = 0;
  Map trackStatuses = {
    'AllClear': '1',
    'Yellow': '2',
    'SCDeployed': '4',
    'Red': '5',
    'VSCDeployed': '6',
    'VSCEnding': '7'
  };

  Widget _updateTrackStatus(String currentDurationFormated) {
    if (widget.sessionDetails["trackStatus"][currentDurationFormated] != null) {
      trackStatus =
          widget.sessionDetails["trackStatus"][currentDurationFormated];
    }
    return Container(
      height: 50,
      color: trackStatus['Status'] == '1'
          ? Colors.green
          : trackStatus['Status'] == '5'
              ? Colors.red
              : (trackStatus['Status'] == '2') ||
                      (trackStatus['Status'] == '3') ||
                      (trackStatus['Status'] == '4')
                  ? Colors.yellow
                  : Colors.white,
    );
  }

  Widget _updateLapCount(String currentDurationFormated) {
    // needs a global string
    if (widget.sessionDetails["lapCount"][currentDurationFormated] != null) {
      lapCount = widget.sessionDetails["lapCount"][currentDurationFormated];
      if ((totalLaps == 0) && (lapCount['TotalLaps'] != null)) {
        totalLaps = lapCount['TotalLaps'];
      }
    }
    if ((lapCount != {}) && (totalLaps != 0)) {
      return Text("LAP ${lapCount['CurrentLap'].toString()} / $totalLaps");
    } else {
      return const Text("LAP .. / ..");
    }
  }

  Widget _updateTimingData(String currentDurationFormated) {
    if (widget.sessionDetails["timingData"][currentDurationFormated] != null) {
      if (timingData.isEmpty &&
          widget
              .sessionDetails["timingData"][currentDurationFormated][0]['Lines']
              .isNotEmpty) {
        timingData =
            widget.sessionDetails["timingData"][currentDurationFormated][0];
      } else {
        // other ossible events
        // {"Lines":{"47":{"Sectors":{"0":{"Segments":{"1":{"Status":0},"2":{"Status":0},"3":{"Status":0},"4":{"Status":0}}},"1":{"Segments":{"0":{"Status":0},"1":{"Status":0},"2":{"Status":0},"3":{"Status":0},"4":{"Status":0},"5":{"Status":0},"6":{"Status":0},"7":{"Status":0},"8":{"Status":0}}},"2":{"Segments":{"0":{"Status":0},"1":{"Status":0},"2":{"Status":0},"3":{"Status":0},"4":{"Status":0},"5":{"Status":0},"6":{"Status":0},"7":{"Status":0},"8":{"Status":0}}}}}}}
        //
        for (Map element in widget.sessionDetails["timingData"]
            [currentDurationFormated]) {
          List<String> driverNumbers = element['Lines'].keys.toList();
          for (var driverNumber in driverNumbers) {
            if (timingData['Lines'][driverNumber] == null) {
              element['Lines'][driverNumber] = {};
            }
            if (element['Lines'][driverNumber]['InPit'] != null) {
              // example: 01:20:52.879{"Lines":{"23":{"InPit":true,"Status":80}}}
              timingData['Lines'][driverNumber]['InPit'] =
                  element['Lines'][driverNumber]['InPit'];
              timingData['Lines'][driverNumber]['Status'] =
                  element['Lines'][driverNumber]['Status'];
              if (element['Lines'][driverNumber]['NumberOfPitStops'] != null) {
                // update the number of pits
                // example: 01:20:52.879{"Lines":{"23":{"InPit":true,"Status":80,"NumberOfPitStops":1}}}
                timingData['Lines'][driverNumber]['NumberOfPitStops'] =
                    element['Lines'][driverNumber]['NumberOfPitStops'];
              }
            }
            if (element['Lines'][driverNumber]['GapToLeader'] != null) {
              // example: {"Lines":{"11":{"GapToLeader":"+0.238","IntervalToPositionAhead":{"Value":"+0.238"}}}}
              timingData['Lines'][driverNumber]['GapToLeader'] =
                  element['Lines'][driverNumber]['GapToLeader'];
              timingData['Lines'][driverNumber]['IntervalToPositionAhead'] =
                  element['Lines'][driverNumber]['IntervalToPositionAhead'];

              if (element['Lines'][driverNumber]['Sectors'] != null) {
                String sector =
                    element['Lines'][driverNumber]['Sectors'].keys.toList()[0];
                if ((element['Lines'][driverNumber]['Sectors'][sector]
                                ['Segments']
                            .runtimeType ==
                        List) &&
                    (element['Lines'][driverNumber]['Sectors'][sector]
                            ['Segments'][0]['Status'] !=
                        null)) {
                  // first values sent, they initiate the Segments' matrix
                  for (int i = 0; i < 3; i++) {
                    timingData['Lines'][driverNumber]['Sectors'][i]
                            ['Segments'] =
                        element['Lines'][driverNumber]['Sectors'][sector]
                            ['Segments'][i];
                  }
                } else if (element['Lines'][driverNumber]['Sectors'][sector]
                        ['Segments'] !=
                    null) {
                  // {31: {Sectors: {2: {Segments: {6: {Status: 2048}}}}}}
                  String segment = element['Lines'][driverNumber]['Sectors']
                          [sector]['Segments']
                      .keys
                      .toList()[0];
                  timingData['Lines'][driverNumber]['Sectors']
                      [int.parse(sector)]['Value'] = segment;
                  timingData['Lines'][driverNumber]['Sectors']
                      [int.parse(sector)]['Status'] = element['Lines']
                          [driverNumber]['Sectors'][sector]['Segments'][segment]
                      ['Status'];
                } else if (element['Lines'][driverNumber]['Speeds'] != null) {
                  // example: {11: {Sectors: {1: {Value: 39.188}}, Speeds: {I2: {Value: 295}}}}
                  List<String> speeds =
                      element['Lines'][driverNumber]['Speeds'].keys.toList();
                  for (String speed in speeds) {
                    timingData['Lines'][driverNumber]['Speeds'][speed]
                            ['Value'] =
                        element['Lines'][driverNumber]['Speeds'][speed]
                            ['Value'];
                    if (element['Lines'][driverNumber]['Speeds'][speed]
                            ['PersonalFastest'] !=
                        null) {
                      timingData['Lines'][driverNumber]['Speeds'][speed]
                              ['PersonalFastest'] =
                          element['Lines'][driverNumber]['Speeds'][speed]
                              ['PersonalFastest'];
                    }
                    if (element['Lines'][driverNumber]['Speeds'][speed]
                            ['OverallFastest'] !=
                        null) {
                      timingData['Lines'][driverNumber]['Speeds'][speed]
                              ['OverallFastest'] =
                          element['Lines'][driverNumber]['Speeds'][speed]
                              ['OverallFastest'];
                    }
                  }
                } else {
                  print("Unfound!");
                  print(element['Lines']);
                }
              }
            }
            if (element['Lines'][driverNumber]['Position'] != null) {
              // {"20":{"IntervalToPositionAhead":{"Value":""},"Line":17,"Position":"17"},"23":{"Line":18,"Position":"18"}}
              //print(
              //    '$driverNumber: From ${timingData['Lines'][driverNumber]['Position']}');

              timingData['Lines'][driverNumber]['Position'] =
                  element['Lines'][driverNumber]['Position'];
              timingData['Lines'][driverNumber]['Line'] =
                  element['Lines'][driverNumber]['Line'];
              //print('to ${timingData['Lines'][driverNumber]['Position']}\n');
            }
          }
        }
      }
    }
    return Leaderboard(timingData);
  }

  void skipToTime(int currentTimeInSeconds, int targetTimeInSeconds) {
    int i = 1;
    final Duration j = Duration(seconds: currentTimeInSeconds);
    if (j.inSeconds < targetTimeInSeconds) {
      for (i; i + j.inSeconds < targetTimeInSeconds; i++) {
        Duration k = Duration(seconds: i + j.inSeconds);
        String currentDurationFormated =
            "${k.toString().padLeft(2, '0')}:${k.inMinutes.remainder(60).toString().padLeft(2, '0')}:${k.inSeconds.remainder(60).toString().padLeft(2, '0')}";
        _updateLapCount(currentDurationFormated);
        _updateTimingData(currentDurationFormated);
        _updateTrackStatus(currentDurationFormated);
      }
    } else {
      i = 320; // it should be equal to zero at first
      for (i; i < targetTimeInSeconds; i++) {
        Duration k = Duration(seconds: i + j.inSeconds);
        String currentDurationFormated =
            "${k.toString().padLeft(2, '0')}:${k.inMinutes.remainder(60).toString().padLeft(2, '0')}:${k.inSeconds.remainder(60).toString().padLeft(2, '0')}";
        _updateLapCount(currentDurationFormated);
        _updateTimingData(currentDurationFormated);
        _updateTrackStatus(currentDurationFormated);
      }
    }
    sliderValue = targetTimeInSeconds.toDouble();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => setState(
        () {},
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentDuration = Duration(
      seconds: timer.tick + sliderValue.toInt(),
    );
    if (currentDuration.inSeconds >= 10800) {
      // avoid going above 3 hours
      currentDuration = const Duration(seconds: 10800);
    }
    String currentDurationFormated =
        "${currentDuration.inHours.toString().padLeft(2, '0')}:${currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    return SingleChildScrollView(
      child: Column(
        children: [
          Slider(
            value: currentDuration.inSeconds.toDouble(),
            onChanged: (value) => currentDuration.inSeconds <
                    7 // time needed to initialize the values
                ? null
                : skipToTime(currentDuration.inSeconds, value.toInt()),
            max: 10800,
            activeColor: currentDuration.inSeconds <
                    7 // time needed to initialize the values
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Theme.of(context).primaryColor,
          ),
          Text(
            currentDurationFormated,
          ),
          _updateTrackStatus(
            currentDurationFormated,
          ),
          _updateLapCount(
            currentDurationFormated,
          ),
          _updateTimingData(
            currentDurationFormated,
          ),
        ],
      ),
    );
  }
}

class Leaderboard extends StatelessWidget {
  final Map items;
  Leaderboard(this.items, {Key? key}) : super(key: key);

  final Map<String, String> driverNumbersToCode = {
    "1": "VER",
    "2": "SAR",
    "4": "NOR",
    "10": "GAS",
    "11": "PER",
    "14": "ALO",
    "16": "LEC",
    "18": "STR",
    "20": "MAG",
    "21": "DEV",
    "22": "TSU",
    "23": "ALB",
    "24": "ZHO",
    "27": "HUL",
    "31": "OCO",
    "44": "HAM",
    "55": "SAI",
    "63": "RUS",
    "77": "BOT",
    "81": "PIA",
  };
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const LoadingIndicatorUtil();
    } else {
      if (items['Lines'] == null) {
        return const LoadingIndicatorUtil();
      } else {
        List values = items['Lines'].values.toList();
        values.sort(
          (a, b) => int.parse(
            a['Position'] ?? '20',
          ).compareTo(
            int.parse(
              b['Position'] ?? '20',
            ),
          ),
        );
        return ListView.builder(
          itemCount: items['Lines'].length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => ListTile(
            leading: Text(
              values[index]['Position'],
            ),
            title: Text(
              "${values[index]['RacingNumber']} - ${driverNumbersToCode[values[index]['RacingNumber']] ?? ''}",
            ),
            subtitle: Text(
              values[index]['IntervalToPositionAhead'] != null
                  ? values[index]['IntervalToPositionAhead']['Value'] == ''
                      ? '--'
                      : values[index]['IntervalToPositionAhead']['Value']
                  : '--',
            ),
          ),
        );
      }
    }
  }
}