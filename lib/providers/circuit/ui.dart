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

import 'package:boxbox/Screens/session_screen.dart';
import 'package:boxbox/classes/event_tracker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CircuitUIProvider {
  void onSessionTapAction(
    Session session,
    String meetingCountryName,
    String meetingOfficialName,
    String meetingId,
    BuildContext context,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (session.endTime.isAfter(DateTime.now()) ||
          session.sessionState == SessionState().RUNNING) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionScreen(
              session.sessionFullName!,
              session,
              meetingCountryName,
              meetingOfficialName,
              meetingId,
            ),
          ),
        );
      } else if (session.sessionAbbreviation.startsWith('p')) {
        context.pushNamed(
          'practice',
          pathParameters: {
            'meetingId': meetingId,
            'sessionIndex': session.sessionAbbreviation.substring(1)
          },
        );
      } else if (session.sessionAbbreviation == 'ss') {
        context.pushNamed(
          'sprint-shootout',
          pathParameters: {
            'meetingId': meetingId,
          },
        );
      } else if (session.sessionAbbreviation == 's') {
        context.pushNamed(
          'sprint',
          pathParameters: {
            'meetingId': meetingId,
          },
        );
      } else if (session.sessionAbbreviation == 'q') {
        context.pushNamed(
          'qualifyings',
          pathParameters: {
            'meetingId': meetingId,
          },
        );
      } else {
        context.pushNamed(
          'race',
          pathParameters: {
            'meetingId': meetingId,
          },
        );
      }
    } else if (championship == 'Formula E') {
      if (session.sessionFullName!.contains('Practice') ||
          session.sessionFullName!.contains('Qual')) {
        context.pushNamed(
          'practice',
          pathParameters: {
            'meetingId': meetingId,
            'sessionIndex': session.sessionAbbreviation,
          },
          extra: {
            'sessionTitle': session.sessionFullName,
            'sessionIndex': 0,
            'circuitId': '',
            'meetingId': meetingId,
            'raceYear': 0,
            'raceName': meetingOfficialName,
            'sessionId': session.sessionAbbreviation,
          },
        );
      } else if (session.sessionFullName! == 'Race') {
        context.pushNamed(
          'race',
          pathParameters: {
            'meetingId': meetingId,
          },
          extra: {
            'sessionId': session.sessionAbbreviation,
          },
        );
      }
    } else {
      return;
    }
  }

  void linkTapAction(
    String linkType,
    String url,
    BuildContext context,
    String meetingId,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (linkType == 'Article' || linkType == 'LiveBlog') {
        context.pushNamed(
          'article',
          pathParameters: {'id': url.split('.').last},
          extra: {
            'isFromLink': true,
          },
        );
      } else if (linkType == 'StartingGrid') {
        context.pushNamed(
          'starting-grid',
          pathParameters: {'meetingId': meetingId},
        );
      } else if (linkType == 'SprintGrid') {
        context.pushNamed(
          'sprint-shootout',
          pathParameters: {'meetingId': meetingId},
        );
      }
    }
  }
}
