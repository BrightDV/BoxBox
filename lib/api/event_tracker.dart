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
import 'package:http/http.dart';

class Event {
  final String raceId;
  final String meetingName;
  final String meetingOfficialName;
  final String meetingCountryName;
  final DateTime meetingStartDate;
  final DateTime meetingEndDate;
  final bool isRunning;
  final Session
      session5; // use session instead of race, fp1, etc because with a sprint the order
  final Session session4; // is race, sprint, fp2, qualifications, fp1
  final Session session3;
  final Session session2;
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

  bool isEventRunning(String meetingStartDate, String meetingEndDate) {
    DateTime startDate = DateTime.parse(meetingStartDate);
    DateTime endDate = DateTime.parse(meetingEndDate).add(
      Duration(hours: 3),
    );
    DateTime now = DateTime.now();
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
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
    Map formattedResponse = jsonDecode(res.body);

    return formattedResponse;
  }

  Future<Event> parseEvent() async {
    Map eventAsJson = await fetchEvent();
    bool isRunning = isEventRunning(
      eventAsJson['race']['meetingStartDate'],
      eventAsJson['race']['meetingEndDate'],
    );
    List<Session> sessions = [
      Session(
        eventAsJson['seasonContext']['timetables'][0]['state'],
        eventAsJson['seasonContext']['timetables'][0]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][0]['endTime'],
        ),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][0]['startTime'],
        ),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][1]['state'],
        eventAsJson['seasonContext']['timetables'][1]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][1]['endTime'],
        ),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][1]['startTime'],
        ),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][2]['state'],
        eventAsJson['seasonContext']['timetables'][2]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][2]['endTime'],
        ),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][2]['startTime'],
        ),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][3]['state'],
        eventAsJson['seasonContext']['timetables'][3]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][3]['endTime'],
        ),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][3]['startTime'],
        ),
      ),
      Session(
        eventAsJson['seasonContext']['timetables'][4]['state'],
        eventAsJson['seasonContext']['timetables'][4]['session'],
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][4]['endTime'],
        ),
        DateTime.parse(
          eventAsJson['seasonContext']['timetables'][4]['startTime'],
        ),
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
      DateTime.parse(
        eventAsJson['race']['meetingStartDate'],
      ),
      DateTime.parse(
        eventAsJson['race']['meetingEndDate'],
      ),
      isRunning,
      sessions[0],
      sessions[1],
      sessions[2],
      sessions[3],
      sessions[4],
    );
    return event;
  }
}
