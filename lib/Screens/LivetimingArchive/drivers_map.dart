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
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
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
      body: FutureBuilder<Map>(
        future: LiveFeedFetcher().getDetailsForTheMap(),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? DriversMapFragment(snapshot.data!)
                : const LoadingIndicatorUtil(),
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
    return CustomPaint(
      painter: CurvePainter(),
      child: Center(
        child: Text("Blade Runner"),
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
      ],
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
