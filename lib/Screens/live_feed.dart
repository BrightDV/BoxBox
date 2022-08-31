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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/api/live_feed.dart';

class LiveFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Feed',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SessionInfo(),
            Center(
              child: SessionStandings(),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionInfo extends StatelessWidget {
  Future<Map> getSessionInfo() async {
    return await LiveFeedFetcher().getSessionInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return FutureBuilder(
      future: getSessionInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                "${snapshot.error}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        return snapshot.hasData
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                      5,
                    ),
                    child: Text(
                      snapshot.data["Meeting"]["Name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Text(
                      snapshot.data["Meeting"]["OfficialName"],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                      5,
                    ),
                    child: Text(
                      snapshot.data["Type"],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}

class SessionStandings extends StatefulWidget {
  const SessionStandings({Key key}) : super(key: key);

  @override
  State<SessionStandings> createState() => _SessionStandingsState();
}

class _SessionStandingsState extends State<SessionStandings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        color: Colors.red,
        height: 200,
        width: 300,
      ),
    );
  }
}
