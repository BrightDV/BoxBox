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

import 'package:boxbox/Screens/404.dart';
import 'package:boxbox/Screens/FormulaYou/home.dart';
import 'package:boxbox/Screens/MixedNews/mixed_news.dart';
import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/circuit.dart';
import 'package:boxbox/Screens/downloads.dart';
import 'package:boxbox/Screens/driver_details.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/hall_of_fame.dart';
import 'package:boxbox/Screens/history.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/Screens/settings.dart';
import 'package:boxbox/Screens/team_details.dart';
import 'package:boxbox/Screens/video.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class RouterLocalConfig {
  // TODO: handle shared links here
  final router = GoRouter(
    errorBuilder: (context, state) => ErrorNotFoundScreen(
      route: state.uri.toString(),
    ),
    //debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const MainBottomNavigationBar();
        },
        routes: [
          // General routes
          GoRoute(
            name: 'article',
            path: 'article/:id',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
              }
              return ArticleScreen(
                state.pathParameters['id']!,
                extras?['articleName'] ?? '',
                extras == null ? true : extras['isFromLink'] ?? true,
                update: extras?['update'] ?? null,
                news: extras?['news'] ?? null,
                championshipOfArticle: extras?['championshipOfArticle'] ?? '',
              );
            },
          ),
          GoRoute(
            name: 'video',
            path: 'video/:id',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return VideoScreen(
                  extras['video'],
                  update: extras['update'] ?? null,
                  videoChampionship: extras['videoChampionship'] ?? '',
                );
              } else {
                return VideoScreenFromId(state.pathParameters['id']!);
              }
            },
          ),

          // Drawer routes
          GoRoute(
            name: 'formula-you',
            path: 'formula-you',
            builder: (context, state) => const PersonalizedHomeScreen(),
          ),
          GoRoute(
            name: 'mixed-news',
            path: 'mixed-news',
            builder: (context, state) => const MixedNewsScreen(),
          ),
          GoRoute(
            name: 'hall-of-fame',
            path: 'hall-of-fame',
            builder: (context, state) => const HallOfFameScreen(),
          ),
          GoRoute(
            name: 'history',
            path: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            name: 'downloads',
            path: 'downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            name: 'settings',
            path: 'settings',
            builder: (context, state) {
              Map? extras = state.extra as Map?;
              return SettingsScreen(update: extras?['update'] ?? null);
            },
          ),
          GoRoute(
            name: 'about',
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),

          // drivers and teams
          GoRoute(
            name: 'drivers',
            path: 'drivers/:driverId',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return DriverDetailsScreen(
                  state.pathParameters['driverId']!,
                  extras['givenName'],
                  extras['familyName'],
                  detailsPath: extras['detailsPath'],
                );
              } else {
                return DriverDetailsFromIdScreen(
                  state.pathParameters['driverId']!,
                );
              }
            },
          ),
          GoRoute(
            name: 'teams',
            path: 'teams/:teamId',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return TeamDetailsScreen(
                  state.pathParameters['teamId']!,
                  extras['teamFullName'],
                  detailsPath: extras['detailsPath'],
                );
              } else {
                return TeamDetailsFromIdScreen(
                  state.pathParameters['teamId']!,
                );
              }
            },
          ),

          // schedule & results
          GoRoute(
            name: 'racing',
            path: 'racing/:meetingId',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                if (extras['isFetched'] ?? true) {
                  return CircuitScreen(
                    extras['race'],
                    isFetched: extras['isFetched'],
                  );
                } else {
                  return CircuitScreen(
                    Race(
                      '',
                      state.pathParameters['meetingId']!,
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      [],
                    ),
                    isFetched: false,
                  );
                }
              } else {
                return CircuitScreen(
                  Race(
                    '',
                    state.pathParameters['meetingId']!,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    [],
                  ),
                  isFetched: false,
                );
              }
            },
            routes: [
              GoRoute(
                name: 'results',
                path: 'results',
                builder: (context, state) {
                  Map? extras;
                  if (state.extra != null) {
                    extras = state.extra as Map;
                    return RaceDetailsScreen(
                      extras['race'],
                      extras['hasSprint'],
                      tab: extras['tab'],
                      isFromRaceHub: extras['isFromRaceHub'],
                      sessions: extras['sessions'],
                    );
                  } else {
                    return RaceDetailsScreen(
                      Race(
                        '',
                        state.pathParameters['meetingId']!,
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        [],
                      ),
                      false,
                      isFromRaceHub: true,
                    );
                  }
                },
                routes: [
                  GoRoute(
                    name: 'practice',
                    path: 'practice/:sessionIndex',
                    builder: (context, state) {
                      Map? extras;
                      if (state.extra != null) {
                        extras = state.extra as Map;
                        return FreePracticeScreen(
                          extras['sessionTitle'],
                          extras['sessionIndex'],
                          extras['circuitId'],
                          extras['meetingId'],
                          extras['raceYear'],
                          extras['raceName'],
                          raceUrl: extras['raceUrl'],
                          sessionId: extras['sessionId'],
                        );
                      } else {
                        return FreePracticeScreen(
                          '',
                          0,
                          '',
                          state.pathParameters['meetingId']!,
                          0,
                          '',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
