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

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:boxbox/api/live_feed.dart';
import 'package:boxbox/Screens/live_feed.dart';

class LiveSessionStatusIndicator extends StatelessWidget {
  LiveSessionStatusIndicator({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LiveFeedFetcher().getSessionStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            height: 0.0,
            width: 0.0,
          );
        }
        return snapshot.hasData
            ? "have to" == "migrate to event-tracker" //snapshot.data
                ? GestureDetector(
                    child: Container(
                      height: 40,
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LoadingIndicator(
                            indicatorType: Indicator.values[17],
                            colors: [
                              Colors.white,
                            ],
                            strokeWidth: 2.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'Session en cours',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveFeedScreen(),
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
