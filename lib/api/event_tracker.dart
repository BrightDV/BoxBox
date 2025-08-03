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
 * Copyright (c) 2022-2025, BrightDV
 */

import 'dart:async';
import 'dart:convert';

import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

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
  final Map? liveBlog;

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
    this.sessions, {
    this.liveBlog,
  });
}

class Session {
  final String state;
  final String sessionsAbbreviation;
  final DateTime endTime;
  final DateTime startTime;
  final String? baseUrl;
  final bool isRunning;

  const Session(
    this.state,
    this.sessionsAbbreviation,
    this.endTime,
    this.startTime,
    this.baseUrl,
    this.isRunning,
  );
}

class EventTracker {
  final String defaultEndpoint = Constants().F1_API_URL;
  final String apikey = Constants().getOfficialApiKey();
  final String feEndpoint = Constants().FE_API_URL;

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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Map formatedResponse = {};

    if (championship == 'Formula 1') {
      Uri uri = Uri.parse(
        endpoint != defaultEndpoint
            ? '$endpoint/f1/v1/event-tracker'
            : '$endpoint/v1/event-tracker',
      );
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
      formatedResponse = jsonDecode(
        utf8.decode(res.bodyBytes),
      );
      Hive.box('requests').put('f1-event-tracker', formatedResponse);
    } else {
      List<Race> racesToCome = await FormulaE().getLastSchedule(true);
      racesToCome = racesToCome.reversed.toList();

      bool isRunning = false;
      String raceId = '';
      DateTime now = DateTime.now();
      for (Race race in racesToCome) {
        DateTime raceDate = DateTime.parse(race.date);
        if (raceDate.subtract(Duration(days: 2)).isBefore(now) &&
            raceDate.add(Duration(days: 1)).isAfter(now)) {
          isRunning = true;
          raceId = race.meetingId;
        }
      }

      if (raceId == '') {
        formatedResponse = {'event': {}, 'timetables': {}, 'isRunning': false};
      } else {
        String endpoint = Hive.box('settings')
            .get('server', defaultValue: defaultEndpoint) as String;
        Response res = await get(
          Uri.parse(
            endpoint != defaultEndpoint
                ? '$endpoint/fe/formula-e/v1/races/$raceId'
                : '$feEndpoint/formula-e/v1/races/$raceId',
          ),
          headers: {
            'Accept': 'application/json',
            'User-Agent':
                'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
          },
        );
        Map raceInfo = jsonDecode(
          utf8.decode(res.bodyBytes),
        );
        Map sessions = await FormulaE().getSessions(raceId);
        formatedResponse = {
          'event': raceInfo,
          'timetables': sessions,
          'isRunning': isRunning,
        };
        Hive.box('requests').put('fe-event-tracker', formatedResponse);
      }
    }

    return formatedResponse;
  }

  Future<Event> parseF1Event() async {
    Map eventAsJson = await fetchEvent();
    if (eventAsJson['event'] != null) {
      return plainF1EventParser(eventAsJson, 'event', 'event');
    } else {
      return plainF1EventParser(eventAsJson, 'seasonContext', 'race');
    }
  }

  Future<Event> parseFEEvent() async {
    Map eventAsJson = await fetchEvent();
    if (eventAsJson['event'] != null) {
      return plainFEEventParser(eventAsJson);
    } else {
      return plainF1EventParser(eventAsJson, 'seasonContext', 'race');
    }
  }

  Event plainF1EventParser(Map eventAsJson, String path, String secondPath) {
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
          DateTime.now().isBefore(DateTime.parse(
                session['endTime'] + gmtOffset,
              ).toLocal()) &&
              DateTime.now().isAfter(DateTime.parse(
                session['startTime'] + gmtOffset,
              ).toLocal()),
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
      liveBlog: eventAsJson['seasonContext']?['liveBlog'] ?? {},
    );
    return event;
  }

  Event plainFEEventParser(Map eventAsJson) {
    if (eventAsJson['isRunning']) {
      DateTime meetingStartDate =
          eventAsJson['timetables']['sessionDates'].first.toLocal();
      DateTime meetingEndDate =
          eventAsJson['timetables']['sessionEndDates'].last.toLocal();

      List<Session> sessions = [];
      for (int c = 0; c < eventAsJson['timetables']['sessionIds'].length; c++) {
        sessions.add(
          Session(
            eventAsJson['timetables']['sessionStates'][c],
            eventAsJson['timetables']['sessionNames'][c],
            DateTime.parse(eventAsJson['timetables']['sessionEndDates'][c]),
            DateTime.parse(eventAsJson['timetables']['sessionDates'][c]),
            eventAsJson['timetables']['sessionIds'][c],
            DateTime.now().isBefore(DateTime.parse(
                    eventAsJson['timetables']['sessionEndDates'][c])) &&
                DateTime.now().isAfter(DateTime.parse(
                    eventAsJson['timetables']['sessionDates'][c])),
          ),
        );
      }

      Event event = Event(
        eventAsJson['event']['id'],
        eventAsJson['event']['city'],
        eventAsJson['event']['name'],
        eventAsJson['event']['city'],
        meetingStartDate,
        meetingEndDate,
        '',
        [],
        true,
        sessions,
      );
      return event;
    } else {
      return Event(
        '',
        '',
        '',
        '',
        DateTime.now().add(Duration(days: 365)),
        DateTime.now(),
        '',
        [],
        false,
        [],
      );
    }
  }

  Future<Map> getCircuitDetails(String formulaOneCircuitId,
      {Race? race, bool isFromRaceHub = false}) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: true) as bool;

    Uri uri = Uri.parse(
      endpoint != defaultEndpoint
          ? '$endpoint/f1/v1/event-tracker/meeting/$formulaOneCircuitId'
          : '$endpoint/v1/event-tracker/meeting/$formulaOneCircuitId',
    );

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
    if (isFromRaceHub) {
      List<DateTime> sessionDates = [];
      List sessionStates = [];
      for (var session in formatedResponse['meetingContext']['timetables']) {
        sessionDates.add(
          DateTime.parse(
            session['startTime'] + session['gmtOffset'],
          ),
        );
        sessionStates.add(session['state']);
      }
      String gmtOffset = formatedResponse['meetingContext']['timetables'][0]
              ?['gmtOffset'] ??
          '';
      DateTime raceDate = DateTime.parse(
        formatedResponse['race']['meetingEndDate'].replaceAll('.000Z', '') +
            gmtOffset,
      ).toLocal().subtract(Duration(hours: 3));

      String detailsPath =
          formatedResponse['race']['url'].split('/').last.split('.').first;
      if (formatedResponse['race']['meetingCountryName'] == 'Emilia-Romagna') {
        detailsPath = 'EmiliaRomagna';
      } else if (formatedResponse['race']['meetingCountryName'] == 'Miami') {
        detailsPath = 'Miami';
      } else if (formatedResponse['race']['meetingCountryName'] ==
          'Great Britain') {
        detailsPath = 'Great_Britain';
      } else if (formatedResponse['race']['meetingCountryName'] ==
          'Las Vegas') {
        detailsPath = 'Las_Vegas';
      }
      String coverUrl =
          'https://media.formula1.com/image/upload/f_auto,c_limit,w_1440,q_auto/f_auto/q_auto/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/${formatedResponse['race']['meetingCountryName'].replaceAll(" ", "_")}.jpg';

      Race raceWithSessions = Race(
        '',
        formatedResponse['meetingContext']['meetingKey'],
        formatedResponse['race']['meetingCountryName'],
        formatedResponse['race']['meetingEndDate'].replaceAll('.000Z', ''),
        DateFormat.Hm().format(raceDate),
        '',
        '',
        '',
        formatedResponse['race']['meetingCountryName'],
        sessionDates,
        isFirst: false,
        raceCoverUrl: coverUrl,
        detailsPath: detailsPath,
        isPreSeasonTesting: formatedResponse['meetingContext']['isTestEvent'],
        sessionStates: sessionStates,
      );

      formatedResponse['raceCustomBBParameter'] = raceWithSessions;
    } else if (useOfficialDataSoure) {
      List<DateTime> sessionDates = [];
      List sessionStates = [];
      for (var session in formatedResponse['meetingContext']['timetables']) {
        sessionDates.add(
          DateTime.parse(
            session['startTime'] + session['gmtOffset'],
          ),
        );
        sessionStates.add(session['state']);
      }
      Race raceWithSessions = Race(
        race!.round,
        race.meetingId,
        race.raceName,
        race.date,
        race.raceHour,
        race.circuitId,
        race.circuitName,
        race.circuitUrl,
        race.country,
        sessionDates,
        isFirst: race.isFirst,
        raceCoverUrl: race.raceCoverUrl,
        detailsPath: race.detailsPath,
        sessionStates: sessionStates,
        isPreSeasonTesting: race.isPreSeasonTesting,
      );

      formatedResponse['raceCustomBBParameter'] = raceWithSessions;
    }

    return formatedResponse;
  }
}
