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
 * Copyright (c) 2022, BrightDV
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/news.dart';

class NewsFeedWidget extends StatefulWidget {
  final String tagId;

  NewsFeedWidget({Key key, this.tagId});
  @override
  _NewsFeedWidgetState createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  FutureOr<List> getLatestNewsItems({String tagId}) async {
    return await F1NewsFetcher().getLatestNews(tagId: tagId);
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Future<List> refreshedNews;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    refreshedNews = getLatestNewsItems(tagId: widget.tagId);
  }

  @override
  Widget build(BuildContext context) {
    Map latestNews = Hive.box('requests').get('news', defaultValue: {}) as Map;

    if (widget.tagId != null) {
      latestNews = {};
    }
    return FutureBuilder(
      future: refreshedNews,
      builder: (context, snapshot) => RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          _refreshIndicatorKey.currentState?.show(atTop: false);
          List freshItems = await getLatestNewsItems(tagId: widget.tagId);
          setState(() {
            refreshedNews = Future.value(freshItems);
          });
        },
        child: snapshot.hasError
            ? RequestErrorWidget(snapshot.error)
            : snapshot.hasData
                ? NewsList(
                    items: snapshot.data,
                  )
                : LoadingIndicatorUtil(),
      ),
    );
  }
}

// latestNews['items']

// NewsList(
              //items: F1NewsFetcher().formatResponse(latestNews),
            //)