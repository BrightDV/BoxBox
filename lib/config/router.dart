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

import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/helpers/bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class RouterLocalConfig {
  // TODO: test shared links again
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const MainBottomNavigationBar();
        },
        routes: [
          GoRoute(
            name: 'article',
            path: 'article/:id',
            builder: (context, state) {
              Map? extras = state.extra as Map;
              return ArticleScreen(
                state.pathParameters['id']!,
                state.uri.queryParameters['articleName'] ?? '',
                extras['isFromLink'] ?? true,
                update: extras['update'] ?? null,
                news: extras['news'] ?? null,
                championshipOfArticle:
                    state.uri.queryParameters['championshipOfArticle'] ?? '',
              );
            },
          ),
        ],
      ),
    ],
  );
}
