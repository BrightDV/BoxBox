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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/Screens/grand_prix_running_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class LiveSessionStatusIndicator extends StatelessWidget {
  const LiveSessionStatusIndicator({Key? key}) : super(key: key);
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
    return const SizedBox(
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
    bool haveRunningSession = false;
    DateTime date = DateTime.now();
    if ((event.session1.startTime.isBefore(date) &&
        event.session1.endTime.isAfter(date))) {
      haveRunningSession = true;
    } else if ((event.session2.startTime.isBefore(date) &&
        event.session2.endTime.isAfter(date))) {
      haveRunningSession = true;
    } else if ((event.session3.startTime.isBefore(date) &&
        event.session3.endTime.isAfter(date))) {
      haveRunningSession = true;
    } else if ((event.session4.startTime.isBefore(date) &&
        event.session4.endTime.isAfter(date))) {
      haveRunningSession = true;
    } else if ((event.session5.startTime.isBefore(date) &&
        event.session5.endTime.isAfter(date))) {
      haveRunningSession = true;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Material(
        elevation: 10.0,
        color: Colors.transparent,
        child: GestureDetector(
          child: Container(
            height: 143,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: useDarkMode ? const Color(0xff1d1d28) : Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 3,
                        left: 10,
                        right: 10,
                        bottom: 5,
                      ),
                      child: SizedBox(
                        width: 120,
                        child: Image.network(
                          event.circuitImage,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.meetingCountryName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          haveRunningSession
                              ? Text(
                                  AppLocalizations.of(context)!.sessionRunning,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 160,
                            height: 20,
                            child: MediaQuery.of(context).size.width >= 768
                                ? Text(
                                    event.meetingOfficialName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  )
                                : Marquee(
                                    text: event.meetingOfficialName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    pauseAfterRound: const Duration(seconds: 1),
                                    startAfter: const Duration(seconds: 1),
                                    velocity: 85,
                                    blankSpace: 100,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrandPrixRunningScreen(event),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'RACE HUB',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
