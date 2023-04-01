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
import 'dart:ui';

import 'package:boxbox/api/live_feed.dart';
import 'package:boxbox/helpers/circuit_points.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';

class DriversMapScreen extends StatelessWidget {
  const DriversMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers Map'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: FutureBuilder<Map>(
          future: LiveFeedFetcher().getDetailsForTheMap(),
          builder: (context, snapshot) => snapshot.hasError
              ? RequestErrorWidget(snapshot.error.toString())
              : snapshot.hasData
                  ? DriversMapFragment(snapshot.data!)
                  : const LoadingIndicatorUtil(),
        ),
      ),
    );
  }
}

class DriversMapFragment extends StatefulWidget {
  final Map positions;
  const DriversMapFragment(this.positions, {super.key});

  @override
  State<DriversMapFragment> createState() => _DriversMapFragmentState();
}

class _DriversMapFragmentState extends State<DriversMapFragment> {
  late Timer timer;
  final PictureRecorder recorder = PictureRecorder();
  Duration currentDuration = const Duration();
  double sliderValue = 0;

  Widget _updatePositions(String currentDurationFormated) {
    return FutureBuilder(
      future: GetTrackGeoJSONPoints().getCircuitPoints(
        widget.positions['ErgastFormatedRaceName'],
      ),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? SizedBox(
                  height: 750,
                  child: CustomPaint(
                    foregroundPainter: CurvePainter(
                      widget.positions['Position'][0]['Entries'],
                    ),
                    painter: BackgroundCurvePainter(
                      snapshot.data![0],
                    ),
                  ),
                )
              : const Center(child: LoadingIndicatorUtil()),
    );
  }

  void skipToTime(int currentTimeInSeconds, int targetTimeInSeconds) {
    int i = 1;
    final Duration j = Duration(seconds: currentTimeInSeconds);
    if (j.inSeconds < targetTimeInSeconds) {
      for (i; i + j.inSeconds < targetTimeInSeconds; i++) {
        Duration k = Duration(seconds: i + j.inSeconds);
        String currentDurationFormated =
            "${k.toString().padLeft(2, '0')}:${k.inMinutes.remainder(60).toString().padLeft(2, '0')}:${k.inSeconds.remainder(60).toString().padLeft(2, '0')}";
      }
    } else {
      i = 320; // it should be equal to zero at first
      for (i; i < targetTimeInSeconds; i++) {
        Duration k = Duration(seconds: i + j.inSeconds);
        String currentDurationFormated =
            "${k.toString().padLeft(2, '0')}:${k.inMinutes.remainder(60).toString().padLeft(2, '0')}:${k.inSeconds.remainder(60).toString().padLeft(2, '0')}";
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
    String currentDurationFormated =
        "${currentDuration.inHours.toString().padLeft(2, '0')}:${currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    return Column(
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
        _updatePositions(currentDurationFormated)
      ],
    );
  }
}

class CurvePainter extends CustomPainter {
  final Map points;
  const CurvePainter(
    this.points,
  );
  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> positions = [];
    final width = size.width;
    points.forEach(
      (key, value) => positions.add(
        Offset(
          points[key]['X'] / 55 + width / 2 + 5,
          -points[key]['Y'] / 55 + 480,
        ),
      ),
    );
    var paint = Paint();
    for (var element in positions) {
      var paint = Paint()
        ..color = TeamBackgroundColor().getTeamColors(
          Convert().driverCodeToTeam(
            points.keys.toList()[positions.indexOf(element)],
          ),
        );
      canvas.drawCircle(element, 5.0, paint);
    }
    canvas.drawPoints(
      PointMode.points,
      positions,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BackgroundCurvePainter extends CustomPainter {
  final List points;
  const BackgroundCurvePainter(
    this.points,
  );
  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> positions = [];
    for (var point in points) {
      String one = (point[0] * 1000000).round().toString();
      String two = (point[1] * 1000000).round().toString();
      positions.add(
        Offset(
          double.parse(one.substring(3, one.length)) / 49 - 120,
          -double.parse(two.substring(3, two.length)) / 49 + 1105,
        ),
      );
    }
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
      PointMode.polygon,
      positions,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
