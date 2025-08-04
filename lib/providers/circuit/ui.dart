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

import 'package:boxbox/Screens/Racing/circuit.dart';
import 'package:boxbox/Screens/Racing/circuit_details.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CircuitUIProvider {
  Widget getHeadline(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (details['raceReview']?['headline'] != null) {
        return Headline(details['raceReview']['headline']);
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getHighlightsButton(Map details, BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (details['raceReview']?['links'] != null &&
          details['raceReview']['links'].isNotEmpty &&
          details['raceReview']['links'].length > 0) {
        return BoxBoxButton(
          AppLocalizations.of(context)!.viewHighlights,
          Icon(
            Icons.play_arrow_outlined,
          ),
          route: 'article',
          pathParameters: {
            'id': details['raceReview']['links'][1]['url'].endsWith('.html')
                ? details['raceReview']['links'][1]['url'].split('.')[4]
                : details['raceReview']['links'][1]['url'].split('.').last,
          },
          extra: {'isFromLink': true},
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getSessionResults(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (details['meetingSessionResults']?.last['sessionResults']
                  ?['raceResultsRace']?['results'] !=
              null &&
          details['meetingSessionResults']
              .last['sessionResults']?['raceResultsRace']?['results']
              .isNotEmpty) {
        return RaceResults(
          details['race']['meetingCountryName'],
          details['race']['meetingKey'],
          details['meetingSessionResults']
              .last['sessionResults']['raceResultsRace']['results']
              .sublist(0, 5),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getCuratedSection(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (details['raceReview'] != null &&
          details['raceReview']['curatedSection'] != null) {
        if (details['raceReview']['curatedSection']['items'].isNotEmpty) {
          return CuratedSection(
            details['raceReview']['curatedSection']['items'],
          );
        } else {
          return Container();
        }
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget getSessions(details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Sessions(details);
    } else {
      return Container();
    }
  }

  Widget getCircuitFacts(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return BoxBoxButton(
        'Circuit facts',
        Icon(
          Icons.info_outline,
        ),
        isRoute: false,
        widget: CircuitDetailsScreen(
          details['race']['meetingCountryName'],
          details['race']['circuitOfficialName'],
          details['circuitMapImage']['url'],
          details['circuitDescriptionText'],
          details['circuitMap']['links'],
        ),
      );
    } else {
      return Container();
    }
  }
}
