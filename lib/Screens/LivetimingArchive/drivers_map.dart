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

import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';

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
  Map currentPositions = {};

  Widget _updatePositions(String currentDurationFormated) {
    if (widget.positions['Position'][currentDurationFormated] != null) {
      currentPositions = widget.positions['Position'][currentDurationFormated]
          ['Position'][0]['Entries'];
      // TODO: needs a more precise check -> multiple values per second or a transition animation
    }
    return SizedBox(
      height: 750,
      child: CustomPaint(
        foregroundPainter: CurvePainter(
          currentPositions,
        ),
        painter: BackgroundCurvePainter(
          widget.positions['Points'][0],
        ),
      ),
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
        _updatePositions(currentDurationFormated);
      }
    } else {
      i = targetTimeInSeconds - 3;
      for (i; i < targetTimeInSeconds; i++) {
        Duration k = Duration(seconds: i + j.inSeconds);
        String currentDurationFormated =
            "${k.toString().padLeft(2, '0')}:${k.inMinutes.remainder(60).toString().padLeft(2, '0')}:${k.inSeconds.remainder(60).toString().padLeft(2, '0')}";
        _updatePositions(currentDurationFormated);
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
    // TODO: if points[key]["Status"] != "Pit"/"on track" -> do not show it on the map.
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
