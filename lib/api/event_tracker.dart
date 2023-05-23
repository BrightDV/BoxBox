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
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';

class Event {
  final String raceId;
  late final String meetingName;
  final String meetingOfficialName;
  final String meetingCountryName;
  final DateTime meetingStartDate;
  final DateTime meetingEndDate;
  final String circuitImage;
  final List raceResults;
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
    this.circuitImage,
    this.raceResults,
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
  final String baseUrl;

  const Session(
    this.state,
    this.sessionsAbbreviation,
    this.endTime,
    this.startTime,
    this.baseUrl,
  );
}

class EventTracker {
  final String defaultEndpoint = "https://api.formula1.com";
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
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    Uri uri;
    if (endpoint != defaultEndpoint) {
      uri = Uri.parse(
        '$endpoint/v1/event-tracker',
      );
    } else {
      uri = Uri.parse(
        '$defaultEndpoint/v1/event-tracker',
      );
    }
    Response res = await get(
      uri,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );
    Map formatedResponse = jsonDecode(res.body);
    Hive.box('requests').put('event-tracker', formatedResponse);

    return formatedResponse;
  }

  Future<Event> parseEvent() async {
    Map eventAsJson = await fetchEvent();
    return plainEventParser(eventAsJson);
  }

  Event plainEventParser(Map eventAsJson) {
    String gmtOffset =
        eventAsJson['seasonContext']['timetables'][0]['gmtOffset'];
    DateTime meetingStartDate = DateTime.parse(
      eventAsJson['race']['meetingStartDate'].substring(0, 23),
    ).toLocal();
    DateTime meetingEndDate = DateTime.parse(
      eventAsJson['race']['meetingEndDate'].substring(0, 23),
    ).toLocal().add(
          const Duration(
            hours: 4,
          ),
        );

    bool isRunning = isEventRunning(
      meetingStartDate,
      meetingEndDate,
    );
    String baseUrl =
        'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/${eventAsJson['fomRaceId']}/${eventAsJson['circuitSmallImage']['title'].toLowerCase().replaceAll('.png', '')}/session-type.html';
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
        baseUrl,
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
        baseUrl,
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
        baseUrl,
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
        baseUrl,
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
        baseUrl,
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
      eventAsJson['circuitSmallImage']['url'],
      eventAsJson['raceResults'],
      isRunning,
      sessions[0],
      sessions[1],
      sessions[2],
      sessions[3],
      sessions[4],
    );
    return event;
  }

  Future<Map> getCircuitDetails(String formulaOneCircuitId) async {
    Uri uri;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;

    if (endpoint != defaultEndpoint) {
      uri = Uri.parse(
        '$endpoint/v1/event-tracker/meeting/$formulaOneCircuitId',
      );
    } else {
      uri = Uri.parse(
        '$defaultEndpoint/v1/event-tracker/meeting/$formulaOneCircuitId',
      );
    }
    Response res = await get(
      uri,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );
    Map formatedResponse = jsonDecode(res.body);

    return formatedResponse;
  }
}
