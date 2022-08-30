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

import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/Screens/grand_prix_running_details.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';

class LiveSessionStatusIndicator extends StatelessWidget {
  LiveSessionStatusIndicator({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: EventTracker().parseEvent(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Live Session Status Indicator Error");
          print(snapshot.error);
          return Container(
            height: 0.0,
            width: 0.0,
          );
        }
        return snapshot.hasData
            ? snapshot.data.isRunning
                ? GestureDetector(
                    child: Container(
                      height: 50,
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                              left: 5,
                            ),
                            child: LoadingIndicator(
                              indicatorType: Indicator.values[17],
                              colors: [
                                Colors.white,
                              ],
                              strokeWidth: 2.0,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data.meetingName}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 60,
                                height: 20,
                                child: Marquee(
                                  text: '${snapshot.data.mettingOfficialName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  pauseAfterRound: Duration(seconds: 1),
                                  startAfter: Duration(seconds: 1),
                                  velocity: 85,
                                  blankSpace: 100,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GrandPrixRunningScreen(snapshot.data),
                      ),
                    ),
                  )
                : Container(
                    height: 0.0,
                    width: 0.0,
                  )
            : Container(
                height: 0.0,
                width: 0.0,
              );
      },
    );
  }
}
