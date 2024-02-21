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
  final List<Session> sessions;

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
    this.sessions,
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
    Map formatedResponse = jsonDecode(
      utf8.decode(res.bodyBytes),
    );
    Hive.box('requests').put('event-tracker', formatedResponse);

    return formatedResponse;
  }

  Future<Event> parseEvent() async {
    Map eventAsJson = await fetchEvent();
    if (eventAsJson['event'].isNotEmpty) {
      return plainEventParser(eventAsJson, 'event', 'event');
    } else {
      return plainEventParser(eventAsJson, 'seasonContext', 'race');
    }
  }

  Event plainEventParser(Map eventAsJson, String path, String secondPath) {
    String gmtOffset = eventAsJson[path]['timetables'][0]['gmtOffset'];
    DateTime meetingStartDate = DateTime.parse(
      eventAsJson['race']['meetingStartDate'].substring(0, 23),
    ).toLocal().subtract(
          const Duration(
            hours: 8,
          ),
        );
    DateTime meetingEndDate = DateTime.parse(
      eventAsJson['race']['meetingEndDate'].substring(0, 23),
    ).toLocal().add(
          const Duration(
            hours: 8,
          ),
        );
    if (path == 'event') {
      meetingStartDate = DateTime.parse(
        eventAsJson['event']['meetingStartDate'].substring(0, 19),
      ).toLocal().subtract(
            const Duration(
              hours: 8,
            ),
          );
      meetingEndDate = DateTime.parse(
        eventAsJson['event']['meetingEndDate'].substring(0, 19),
      ).toLocal().add(
            const Duration(
              hours: 8,
            ),
          );
    }
    bool isRunning = isEventRunning(
      meetingStartDate,
      meetingEndDate,
    );

    String baseUrl =
        'https://www.formula1.com/en/results.html/${DateTime.now().year}/races/${eventAsJson['fomRaceId']}/${eventAsJson['circuitSmallImage']['title'].toLowerCase().replaceAll('.png', '')}/session-type.html';
    List<Session> sessions = [];
    for (var session in eventAsJson[path]['timetables']) {
      sessions.add(
        Session(
          session['state'],
          session['session'],
          DateTime.parse(
            session['endTime'] + gmtOffset,
          ).toLocal(),
          DateTime.parse(
            session['startTime'] + gmtOffset,
          ).toLocal(),
          baseUrl,
        ),
      );
    }

    sessions.sort(
      (a, b) {
        var adate = a.startTime;
        var bdate = b.startTime;
        return -adate.compareTo(bdate);
      },
    );

    Event event = Event(
      eventAsJson['fomRaceId'],
      eventAsJson[secondPath]['meetingCountryName'],
      eventAsJson[secondPath]['meetingOfficialName'],
      eventAsJson[secondPath]['meetingCountryName'],
      meetingStartDate,
      meetingEndDate,
      eventAsJson['circuitSmallImage']['url'],
      eventAsJson['raceResults'],
      isRunning,
      sessions,
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
    Map formatedResponse = jsonDecode(
      utf8.decode(res.bodyBytes),
    );

    return formatedResponse;
  }
}
