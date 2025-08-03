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

import 'package:boxbox/api/event_tracker.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventTrackerFormatProvider {
  String formatMeetingName(Event event) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      String meetingName;
      event.meetingName == 'United States'
          ? meetingName = 'USA'
          : meetingName = event.meetingName;
      if (meetingName != 'Great Britain') {
        meetingName = meetingName.replaceAll(' ', '_');
      } else {
        meetingName = event.meetingName;
      }
      return meetingName;
    } else {
      return "";
    }
  }

  int formatFreePracticeSessionIndex(Session session) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return int.parse(session.sessionsAbbreviation.substring(1));
    } else {
      return int.parse(session.sessionsAbbreviation.split(' ').last);
    }
  }

  String? formatFreePracticeSessionUrl(Session session) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return session.baseUrl?.replaceAll(
            'session-type',
            'practice-${session.sessionsAbbreviation.substring(1)}',
          ) ??
          null;
    } else {
      return session.baseUrl;
    }
  }

  String? formatFreePracticeSessionId(Session session) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula E') {
      return session.baseUrl;
    } else {
      return null;
    }
  }

  String? formatQualificationsSessionUrl(Session session) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (session.sessionsAbbreviation == 'ss') {
        return 'sprint-qualifying';
      } else {
        return 'qualifying';
      }
    } else {
      return session.baseUrl;
    }
  }

  String? formatRaceSessionUrl(Session session) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (session.sessionsAbbreviation == 'r') {
        return 'race';
      } else {
        return 'sprint-results';
      }
    } else {
      return session.baseUrl;
    }
  }
}
