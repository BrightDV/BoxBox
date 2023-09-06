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
import 'package:boxbox/helpers/livetiming_tracks_coefficients.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';

class DriversMapFragment extends StatefulWidget {
  final Map positions;
  final String currentDuration;
  final String circuitId;
  const DriversMapFragment(
    this.positions,
    this.currentDuration,
    this.circuitId, {
    super.key,
  });

  @override
  State<DriversMapFragment> createState() => _DriversMapFragmentState();
}

class _DriversMapFragmentState extends State<DriversMapFragment> {
  late Timer timer;
  final PictureRecorder recorder = PictureRecorder();
  double sliderValue = 0;
  Map currentPositions = {};

  Widget _updatePositions(String currentDurationFormated, Map coefficients) {
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
          coefficients,
        ),
        painter: BackgroundCurvePainter(
          widget.positions['Points'][0],
          coefficients,
        ),
      ),
    );
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
    Map coefficients = LiveTimingTracksCoefficients().getCoefficients(
      widget.circuitId,
    );
    return _updatePositions(widget.currentDuration, coefficients);
  }
}

class CurvePainter extends CustomPainter {
  final Map points;
  final Map coefficients;
  const CurvePainter(
    this.points,
    this.coefficients,
  );

  Offset getOffset(int x, int y) {
    return Offset(
      coefficients['drivers']['x'](x),
      coefficients['drivers']['y'](y),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> positions = [];
    // TODO: if points[key]["Status"] != "Pit"/"on track" -> do not show it on the map.
    points.forEach(
      (key, value) => positions.add(
        getOffset(points[key]['X'], points[key]['Y']),
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
  final Map coefficients;
  const BackgroundCurvePainter(
    this.points,
    this.coefficients,
  );

  Offset getOffset(double x, double y) {
    return Offset(
      coefficients['map']['x'](x),
      coefficients['map']['y'](y),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> positions = [];
    for (var point in points) {
      positions.add(
        getOffset(point[0], point[1]),
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
