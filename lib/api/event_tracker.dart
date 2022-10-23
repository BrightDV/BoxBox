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

import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
part 'event_tracker.g.dart';

@HiveType(typeId: 1)
class Event {
  @HiveField(0)
  final String raceId;
  @HiveField(1)
  late final String meetingName;
  @HiveField(2)
  final String meetingOfficialName;
  @HiveField(3)
  final String meetingCountryName;
  @HiveField(4)
  final DateTime meetingStartDate;
  @HiveField(5)
  final DateTime meetingEndDate;
  @HiveField(6)
  final bool isRunning;
  @HiveField(7)
  final Session
      session5; // use session instead of race, fp1, etc because with a sprint the order
  @HiveField(8) // is race, sprint, fp2, qualifications, fp1
  final Session session4;
  @HiveField(9)
  final Session session3;
  @HiveField(10)
  final Session session2;
  @HiveField(11)
  final Session session1;

  Event(
    this.raceId,
    this.meetingName,
    this.meetingOfficialName,
    this.meetingCountryName,
    this.meetingStartDate,
    this.meetingEndDate,
    this.isRunning,
    this.session5,
    this.session4,
    this.session3,
    this.session2,
    this.session1,
  );
}

class Session {
  final String state;
  final String sessionsAbbreviation;
  final DateTime endTime;
  final DateTime startTime;

  const Session(
    this.state,
    this.sessionsAbbreviation,
    this.endTime,
    this.startTime,
  );
}

class EventTracker {
  final String endpoint = "https://api.formula1.com";
  final String apikey = "qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP";

  bool isEventRunning(DateTime meetingStartDate, DateTime meetingEndDate) {
    DateTime now = DateTime.now();
    if (meetingStartDate.isBefore(now) && meetingEndDate.isAfter(now)) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map> fetchEvent() async {
    Uri uri = Uri.parse('$endpoint/v1/event-tracker');
    Response res = await get(
      uri,
      headers: {
        'Accept': 'application/json',
        'apikey': apikey,
        'locale': 'fr',
      },
    );
    Map formatedResponse = jsonDecode(res.body);

    return formatedResponse;
  }

  Future<Event> parseEvent() async {
    Map eventAsJson = await fetchEvent();
    String gmtOffset =
        eventAsJson['seasonContext']['timetables'][0]['gmtOffset'];
    DateTime meetingStartDate = DateTime.parse(
      eventAsJson['race']['meetingStartDate'].substring(0, 23),
    ).toLocal();
    DateTime meetingEndDate = DateTime.parse(
      eventAsJson['race']['meetingEndDate'].substring(0, 23),
    ).toLocal().add(
          Duration(
            hours: 4,
          ),
        );

    bool isRunning = isEventRunning(
      meetingStartDate,
      meetingEndDate,
    );
    List<Session> sessions = [
      Session(
        eventAsJson['seasonContext']['timetables'][0]['state'],
        eventAsJson['seasonContext']['timetables'][0]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][0]['endTime'] + gmtOffset,
        ).toLocal(),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][0]['startTime'] +
              gmtOffset,
        ).toLocal(),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][1]['state'],
        eventAsJson['seasonContext']['timetables'][1]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][1]['endTime'] + gmtOffset,
        ).toLocal(),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][1]['startTime'] +
              gmtOffset,
        ).toLocal(),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][2]['state'],
        eventAsJson['seasonContext']['timetables'][2]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][2]['endTime'] + gmtOffset,
        ).toLocal(),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][2]['startTime'] +
              gmtOffset,
        ).toLocal(),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][3]['state'],
        eventAsJson['seasonContext']['timetables'][3]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][3]['endTime'] + gmtOffset,
        ).toLocal(),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][3]['startTime'] +
              gmtOffset,
        ).toLocal(),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][4]['state'],
        eventAsJson['seasonContext']['timetables'][4]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][4]['endTime'] + gmtOffset,
        ).toLocal(),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][4]['startTime'] +
              gmtOffset,
        ).toLocal(),
      ),
    ];
    sessions.sort(
      (a, b) {
        var adate = a.startTime;
        var bdate = b.startTime;
        return -adate.compareTo(bdate);
      },
    );

    Event event = Event(
      eventAsJson['fomRaceId'],
      eventAsJson['race']['meetingCountryName'],
      eventAsJson['race']['meetingOfficialName'],
      eventAsJson['race']['meetingCountryName'],
      meetingStartDate,
      meetingEndDate,
      isRunning,
      sessions[0],
      sessions[1],
      sessions[2],
      sessions[3],
      sessions[4],
    );
    Hive.box('requests').put('event-tracker', event);
    return event;
  }
}
