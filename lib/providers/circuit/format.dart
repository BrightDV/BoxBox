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

import 'package:boxbox/classes/article.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/event_tracker.dart';
import 'package:boxbox/classes/race.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CircuitFormatProvider {
  RaceDetails formatCircuitData(Map details) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    if (championship == 'Formula 1') {
      List<Session> sessions = [];
      List<News> articles = [];
      String? headline;
      List<DriverResult> results = [];
      Map<String, List<Link>> sessionsLinks = {};
      String? highlightsArticleId;

      // sessions & sessions links
      for (var session
          in details['race']['meetingSessions'].reversed.toList()) {
        int state = SessionState().UNKNOWN;
        DateTime startDate =
            DateTime.parse(session['startTime'] + session['gmtOffset'])
                .toLocal();
        DateTime endDate =
            DateTime.parse(session['endTime'] + session['gmtOffset']).toLocal();
        if (DateTime.now().isBefore(startDate)) {
          state = SessionState().SCHEDULED;
        } else if (DateTime.now().isBefore(endDate) &&
            DateTime.now().isAfter(startDate)) {
          state = SessionState().RUNNING;
        } else if (DateTime.now().isAfter(endDate)) {
          state = SessionState().COMPLETED;
        }
        sessions.add(
          Session(
            session['state'],
            session['session'],
            endDate,
            startDate,
            null,
            state,
            sessionFullName: session['description'],
          ),
        );
        if (details['sessionLinkSets'][session['session']]['links'] != null) {
          if (sessionsLinks[session['session']] == null) {
            sessionsLinks[session['session']] = [];
          }
          for (Map link in details['sessionLinkSets'][session['session']]
              ['links']) {
            if (link['linkType'] != 'Replay' && link['linkType'] != 'Results') {
              sessionsLinks[session['session']]!.add(
                Link(
                  link['text'],
                  link['linkType'],
                  link['url'],
                ),
              );
            }
          }
        }
      }

      // articles
      if (details['raceReview'] != null &&
          details['raceReview']['curatedSection'] != null) {
        if (details['raceReview']['curatedSection']['items'].isNotEmpty) {
          for (Map article in details['raceReview']['curatedSection']
              ['items']) {
            articles.add(
              News(
                article['id'],
                article['articleType'],
                article['slug'],
                article['title'],
                article['metaDescription'] ?? ' ',
                DateTime.parse(article['updatedAt']),
                useDataSaverMode
                    ? article['thumbnail']['image']['renditions'] != null
                        ? article['thumbnail']['image']['renditions']['2col']
                        : article['thumbnail']['image']['url'] +
                            '.transform/2col-retina/image.jpg'
                    : article['thumbnail']['image']['url'],
                'https://www.formula1.com/en/latest/article/${article['slug']}.${article['id']}',
              ),
            );
          }
        }
      }

      // headline
      if (details['raceReview']?['headline'] != null) {
        headline = details['raceReview']['headline'];
      }

      // results
      if (details['meetingSessionResults']?.last['sessionResults']
                  ?['raceResultsRace']?['results'] !=
              null &&
          details['meetingSessionResults']
              .last['sessionResults']?['raceResultsRace']?['results']
              .isNotEmpty) {
        for (Map driverResults in details['meetingSessionResults']
            .last['sessionResults']['raceResultsRace']['results']
            .sublist(0, 5)) {
          results.add(
            DriverResult(
              '',
              driverResults['positionNumber'] == '66666'
                  ? 'DQ'
                  : driverResults['positionNumber'],
              '',
              '',
              '',
              driverResults['driverTLA'].toString(),
              '',
              driverResults['gapToLeader'] != "0.0" &&
                      driverResults['gapToLeader'] != "0"
                  ? '+${driverResults['gapToLeader']}'
                  : driverResults['raceTime'] ?? driverResults['positionValue'],
              false,
              '',
              '',
              teamColor: driverResults['teamColourCode'],
            ),
          );
        }
      }

      // highlights link
      if (details['raceReview']?['links'] != null &&
          details['raceReview']['links'].isNotEmpty &&
          details['raceReview']['links'].length > 0) {
        highlightsArticleId =
            details['raceReview']['links'][1]['url'].endsWith('.html')
                ? details['raceReview']['links'][1]['url'].split('.')[4]
                : details['raceReview']['links'][1]['url'].split('.').last;
      }

      return RaceDetails(
        details['race']['meetingKey'],
        details['race']['meetingLocation'],
        details['race']['meetingOfficialName'],
        sessions,
        true,
        articles: articles,
        raceImageUrl: details['raceImage']['url'],
        flagImageUrl: details['raceCountryFlag']['url'],
        headline: headline,
        highlightsArticleId: highlightsArticleId,
        results: results,
        sessionsLinks: sessionsLinks,
        circuitOfficialName: details['race']['circuitOfficialName'],
        circuitMapImageUrl: details['circuitMapImage']['url'],
        circuitDescriptionText: details['circuitDescriptionText'],
        circuitMapLinks: details['circuitMap']['links'],
      );
    } else if (championship == 'Formula E') {
      List<Session> sessions = [];
      List<News> articles = [];
      Map qualifyingSession = {
        'state': '',
        'sessionAbbreviation': '',
        'endTime': DateTime.now(),
        'startTime': DateTime.now(),
        'sessionState': SessionState().UNKNOWN,
        'sessionFullName': 'Qualifying',
      };
      if (details['sessions'] != null) {
        for (Map session in details['sessions']['sessions'].reversed.toList()) {
          if (session['sessionName'].toLowerCase().contains('qual')) {
            if (session['sessionName'] == 'Combined qualifying') {
              qualifyingSession['sessionAbbreviation'] = session['id'];
            } else if (session['sessionName'] == 'Qual Group A') {
              String gmtOffset = session['offsetGMT'];
              try {
                int.parse(gmtOffset.substring(0, 1));
                if (gmtOffset.length < 5) {
                  gmtOffset = '0' + gmtOffset;
                }
                gmtOffset = '+' + gmtOffset;
              } catch (error) {
                if (gmtOffset.length < 6) {
                  gmtOffset =
                      gmtOffset.substring(0, 1) + '0' + gmtOffset.substring(1);
                }
              }
              DateTime startDate = DateTime.parse(
                session['sessionDate'] +
                    'T' +
                    session['startTime'] +
                    ':00' +
                    gmtOffset,
              );
              qualifyingSession['startTime'] = startDate;
            } else if (session['sessionName'] == 'Qual Final') {
              String gmtOffset = session['offsetGMT'];
              try {
                int.parse(gmtOffset.substring(0, 1));
                if (gmtOffset.length < 5) {
                  gmtOffset = '0' + gmtOffset;
                }
                gmtOffset = '+' + gmtOffset;
              } catch (error) {
                if (gmtOffset.length < 6) {
                  gmtOffset =
                      gmtOffset.substring(0, 1) + '0' + gmtOffset.substring(1);
                }
              }
              DateTime endDate = DateTime.parse(
                session['sessionDate'] +
                    'T' +
                    session['finishTime'] +
                    ':00' +
                    gmtOffset,
              );
              qualifyingSession['endTime'] = endDate;
            }
          } else {
            if (session['sessionDate'] != null) {
              String gmtOffset = session['offsetGMT'];
              try {
                int.parse(gmtOffset.substring(0, 1));
                if (gmtOffset.length < 5) {
                  gmtOffset = '0' + gmtOffset;
                }
                gmtOffset = '+' + gmtOffset;
              } catch (error) {
                if (gmtOffset.length < 6) {
                  gmtOffset =
                      gmtOffset.substring(0, 1) + '0' + gmtOffset.substring(1);
                }
              }
              DateTime startDate = DateTime.parse(
                session['sessionDate'] +
                    'T' +
                    session['startTime'] +
                    ':00' +
                    gmtOffset,
              );
              DateTime endDate = DateTime.parse(
                session['sessionDate'] +
                    'T' +
                    session['finishTime'] +
                    ':00' +
                    gmtOffset,
              );
              int state = SessionState().UNKNOWN;
              if (DateTime.now().isBefore(startDate)) {
                state = SessionState().SCHEDULED;
              } else if (DateTime.now().isBefore(endDate) &&
                  DateTime.now().isAfter(startDate)) {
                state = SessionState().RUNNING;
              } else if (DateTime.now().isAfter(endDate)) {
                state = SessionState().COMPLETED;
              }

              sessions.add(
                Session(
                  session['sessionLiveStatus'] ?? '',
                  session['id'],
                  endDate,
                  startDate,
                  null,
                  state,
                  sessionFullName: session['sessionName'],
                ),
              );
            }
          }
        }
      }
      int qualiState = SessionState().UNKNOWN;
      if (DateTime.now().isBefore(qualifyingSession['startTime'])) {
        qualiState = SessionState().SCHEDULED;
      } else if (DateTime.now().isBefore(qualifyingSession['endTime']) &&
          DateTime.now().isAfter(qualifyingSession['startTime'])) {
        qualiState = SessionState().RUNNING;
      } else if (DateTime.now().isAfter(qualifyingSession['endTime'])) {
        qualiState = SessionState().COMPLETED;
      }
      sessions.insert(
        1,
        Session(
          qualifyingSession['state'],
          qualifyingSession['sessionAbbreviation'],
          qualifyingSession['endTime'],
          qualifyingSession['startTime'],
          null,
          qualiState,
          sessionFullName: qualifyingSession['sessionFullName'],
        ),
      );

      // articles
      for (Map article in details['content']) {
        articles.add(
          News(
            article['id'].toString(),
            article['type'],
            '',
            article['title'],
            article['description'] ?? ' ',
            DateTime.fromMillisecondsSinceEpoch(
              article['publishFrom'],
            ),
            article['imageUrl'],
            'https://www.fiaformulae.com/en/news/${article['id']}',
            author: article['author'] != null
                ? {'fullName': article['author']}
                : null,
          ),
        );
      }
      return RaceDetails(
        details['meetingId'],
        details['race']['city'],
        details['race']['name'],
        sessions,
        false,
        articles: articles,
        raceImageUrl: details['raceImageUrl'],
      );
    } else {
      return RaceDetails(
        '',
        '',
        '',
        [],
        false,
      );
    }
  }
}
