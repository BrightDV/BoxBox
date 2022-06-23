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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/news.dart';

class NewsFeedWidget extends StatelessWidget {
  final String tagId;
  Future<List> getLatestNewsItems({String tagId}) async {
    return await F1NewsFetcher().getLatestNews(tagId: tagId);
  }

  NewsFeedWidget({Key key, this.tagId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Map latestNews = Hive.box('requests').get('news', defaultValue: {}) as Map;
    if (tagId != null) {
      latestNews = {};
    }
    return FutureBuilder(
      future: getLatestNewsItems(tagId: tagId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return latestNews['items'] != null
              ? NewsList(
                  items: F1NewsFetcher().formatResponse(latestNews),
                )
              : RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? NewsList(
                items: snapshot.data,
              )
            : latestNews['items'] != null
                ? NewsList(
                    items: F1NewsFetcher().formatResponse(latestNews),
                  )
                : LoadingIndicatorUtil();
      },
    );
  }
}
