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

import 'package:boxbox/Screens/404.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:boxbox/Screens/videos.dart';
import 'package:boxbox/config/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HandleRoute {
  void handleRoute(String? sharedUrl, BuildContext context) {
    if (sharedUrl == null) return null;
    int year = DateTime.now().year;
    String url = sharedUrl
        .replaceAll('https://www.formula1.com', '')
        .replaceAll('https://formula1.com', '')
        .replaceAll('.html', '');
    if (url.endsWith('/en') || url == '/en/latest/all') {
      return null;
    } else if (url == '/en/video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.videos,
              ),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: VideosScreen(ScrollController()),
          ),
        ),
      );
    } else if (url.startsWith('/en/latest/article/') ||
        url.startsWith('/en/latest/article.')) {
      RouterLocalConfig.router
          .goNamed('article', pathParameters: {'id': url.split('.').last});
    } else if (url.startsWith('/en/video/') ||
        url.startsWith('/en/latest/video.')) {
      RouterLocalConfig.router
          .goNamed('video', pathParameters: {'id': url.split('.').last});
    } else if (url.startsWith('/en/racing/$year')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.schedule,
              ),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: const ScheduleScreen(),
          ),
        ),
      );
    } else if (url == '/en/results/$year/drivers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.standings,
              ),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: const StandingsScreen(),
          ),
        ),
      );
    } else if (url == '/en/results/$year/teams') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.standings,
              ),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: const StandingsScreen(
              switchToTeamStandings: true,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorNotFoundScreen(
            route: url,
          ),
        ),
      );
    }
  }
}

class SharedLinkHandler extends StatelessWidget {
  final String sharedUrl;
  const SharedLinkHandler(
    this.sharedUrl, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int year = DateTime.now().year;
    String url = sharedUrl
        .replaceAll('https://www.formula1.com', '')
        .replaceAll('https://formula1.com', '')
        .replaceAll('.html', '');
    if (url.endsWith('/en') || url == '/en/latest/all') {
      return Container();
    } else if (url == '/en/video') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.videos,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: VideosScreen(ScrollController()),
      );
    } else if (url.startsWith('/en/latest/article/') ||
        url.startsWith('/en/latest/article.')) {
      context.goNamed('article', pathParameters: {'id': url.split('.').last});
      return Container();
    } else if (url.startsWith('/en/video/') ||
        url.startsWith('/en/latest/video.')) {
      context.goNamed('video', pathParameters: {'id': url.split('.').last});
      return Container();
    } else if (url.startsWith('/en/racing/$year')) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.schedule,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const ScheduleScreen(),
      );
    } else if (url == '/en/results/$year/drivers') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.standings,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const StandingsScreen(),
      );
    } else if (url == '/en/results/$year/teams') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.standings,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const StandingsScreen(
          switchToTeamStandings: true,
        ),
      );
    } else {
      return ErrorNotFoundScreen(
        route: sharedUrl,
      );
    }
  }
}
