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

import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:boxbox/Screens/video.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HandleRoute {
  static Route? handleRoute(String? url) {
    if (url == null) return null;

    return PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => ArticleUrlHandler(url),
    );
  }
}

class ArticleUrlHandler extends StatelessWidget {
  final String sharedUrl;
  const ArticleUrlHandler(
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
    } else if (url.startsWith('/en/latest/article.')) {
      return ArticleScreen(
        url.split('.').last,
        '',
        true,
      );
    } else if (url.startsWith('/en/latest/video.')) {
      String videoId = url.split('.')[2];
      return Scaffold(
        body: FutureBuilder<Video>(
          future: F1VideosFetcher().getVideoDetails(videoId),
          builder: (context, snapshot) => snapshot.hasError
              ? RequestErrorWidget(
                  snapshot.error.toString(),
                )
              : snapshot.hasData
                  ? VideoScreen(snapshot.data!)
                  : const Center(
                      child: LoadingIndicatorUtil(),
                    ),
        ),
      );
    } else if (url.startsWith('/en/racing/$year')) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.schedule,
          ),
        ),
        body: const ScheduleScreen(),
      );
    } else if (url == '/en/results.html/$year/drivers') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.schedule,
          ),
        ),
        body: const StandingsScreen(),
      );
    } else if (url == '/en/results.html/$year/teams') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.schedule,
          ),
        ),
        body: const StandingsScreen(
          switchToTeamStandings: true,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Intent'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SelectableText(
              'Url shared: $url\nYou can make an issue on github to ask that the application can open this link.',
            ),
          ),
        ),
      );
    }
  }
}
