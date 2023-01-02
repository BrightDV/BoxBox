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

import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/Screens/grand_prix_running_details.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class LiveSessionStatusIndicator extends StatelessWidget {
  LiveSessionStatusIndicator({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Event? eventTrackerSavedRequest;
    Map eventTrackerSavedRequestAsMap =
        Hive.box('requests').get('event-tracker', defaultValue: {}) as Map;
    if (eventTrackerSavedRequestAsMap['timetables'] != null) {
      eventTrackerSavedRequest = EventTracker().plainEventParser(
        eventTrackerSavedRequestAsMap,
      );
    }
    return FutureBuilder<Event>(
      future: EventTracker().parseEvent(),
      builder: (context, snapshot) {
        return snapshot.hasError
            ? eventTrackerSavedRequest != null
                ? EventTrackerItem(eventTrackerSavedRequest)
                : eventTrackerError(snapshot.error.toString())
            : snapshot.hasData
                ? snapshot.data!.isRunning
                    ? EventTrackerItem(snapshot.data!)
                    : Container()
                : Container();
      },
    );
  }

  Widget eventTrackerError(String snapshotError) {
    print("Live Session Status Indicator Error");
    print(snapshotError);
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
}

class EventTrackerItem extends StatelessWidget {
  final Event event;
  const EventTrackerItem(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return GestureDetector(
      child: Container(
        height: 138,
        color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Container(
                    width: 120,
                    child: Image.network(
                      event.circuitImage,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.meetingCountryName,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 150,
                        height: 20,
                        child: Marquee(
                          text: '${event.meetingOfficialName}',
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
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrandPrixRunningScreen(event),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'RACE HUB',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
