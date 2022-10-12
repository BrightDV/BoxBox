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

import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  ValueNotifier<List> itemsValueNotifier = ValueNotifier([]);

  Future<List> refreshedNews;

  @override
  void initState() {
    super.initState();
    refreshedNews = getLatestNewsItems(tagId: widget.tagId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showOfflineSnackBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    Map latestNews = Hive.box('requests').get('news', defaultValue: {}) as Map;
    return FutureBuilder(
      future: refreshedNews,
      builder: (context, snapshot) => RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          _refreshIndicatorKey.currentState?.show(atTop: false);
          List freshItems = await getLatestNewsItems(tagId: widget.tagId);
          itemsValueNotifier = ValueNotifier(freshItems);
          setState(() {
            refreshedNews = Future.value(freshItems);
          });
        },
        child: snapshot.hasError
            ? snapshot.error.toString() == 'XMLHttpRequest error.'
                ? NewsList(
                    items: F1NewsFetcher().formatResponse(latestNews),
                    itemsValueNotifier: itemsValueNotifier,
                  )
                : RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? NewsList(
                    items: snapshot.data,
                    itemsValueNotifier: itemsValueNotifier,
                  )
                : latestNews['items'] != null
                    ? NewsList(
                        items: F1NewsFetcher().formatResponse(latestNews),
                        itemsValueNotifier: itemsValueNotifier,
                      )
                    : LoadingIndicatorUtil(),
      ),
    );
  }

  void showOfflineSnackBar() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      SnackBar offlineSnackBar = SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.black,
              size: 32,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  AppLocalizations.of(context).offline,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.yellow,
      );
      ScaffoldMessenger.of(context).showSnackBar(offlineSnackBar);
    }
  }
}
