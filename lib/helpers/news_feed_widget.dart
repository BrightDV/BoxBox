// ignore_for_file: use_build_context_synchronously

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

import 'dart:async';

import 'package:boxbox/Screens/MixedNews/rss_feed.dart';
import 'package:boxbox/Screens/MixedNews/wordpress.dart';
import 'package:boxbox/api/news.dart';
import 'package:boxbox/api/rss.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NewsFeedWidget extends StatefulWidget {
  final String? tagId;
  final String? articleType;
  final ScrollController? scrollController;

  const NewsFeedWidget({
    Key? key,
    this.tagId,
    this.articleType,
    this.scrollController,
  }) : super(key: key);
  @override
  State<NewsFeedWidget> createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  Future<List<News>> getLatestNewsItems({
    String? tagId,
    String? articleType,
  }) async {
    return await F1NewsFetcher().getLatestNews(
      tagId: tagId,
      articleType: articleType,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showOfflineSnackBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    const String officialFeed = "https://api.formula1.com";
    Map latestNews = Hive.box('requests').get('news', defaultValue: {}) as Map;
    List savedFeedUrl = Hive.box('settings')
        .get('homeFeed', defaultValue: [officialFeed, 'bbs']) as List;
    return savedFeedUrl[1] == "bbs"
        ? FutureBuilder<List<News>>(
            future: getLatestNewsItems(
              tagId: widget.tagId,
              articleType: widget.articleType,
            ),
            builder: (context, snapshot) => snapshot.hasError
                ? (snapshot.error.toString() == 'XMLHttpRequest error.' ||
                            snapshot.error.toString() ==
                                "Failed host lookup: ${savedFeedUrl[0].removeAll(
                                      'http://',
                                    ).removeAll(
                                      'https://',
                                    )}") &&
                        latestNews['items'] != null &&
                        widget.tagId == null &&
                        widget.articleType == null
                    ? OfflineNewsList(
                        items: F1NewsFetcher().formatResponse(latestNews),
                        scrollController: widget.scrollController,
                      )
                    : RequestErrorWidget(
                        snapshot.error.toString(),
                      )
                : snapshot.hasData
                    ? NewsList(
                        items: snapshot.data!,
                        scrollController: widget.scrollController,
                        tagId: widget.tagId,
                        articleType: widget.articleType,
                      )
                    : widget.tagId == null &&
                            widget.articleType == null &&
                            latestNews['items'] != null
                        ? NewsList(
                            items: F1NewsFetcher().formatResponse(latestNews),
                            scrollController: widget.scrollController,
                            tagId: widget.tagId,
                          )
                        : const LoadingIndicatorUtil(),
          )
        : savedFeedUrl[1] == "rss"
            ? FutureBuilder<Map<String, dynamic>>(
                future: RssFeeds().getFeedArticles(
                  savedFeedUrl[0].contains('motorsport.com')
                      ? '${savedFeedUrl[0]}/rss/f1/news/'
                      : savedFeedUrl[0],
                ),
                builder: (context, snapshot) => snapshot.hasError
                    ? RequestErrorWidget(
                        snapshot.error.toString(),
                      )
                    : snapshot.hasData
                        ? RssFeedItemsList(
                            snapshot,
                            homeFeed: true,
                          )
                        : const LoadingIndicatorUtil(),
              )
            : WordpressNewsList(
                savedFeedUrl[0],
                scrollController: widget.scrollController,
              );
  }

  void showOfflineSnackBar() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      SnackBar offlineSnackBar = SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.black,
              size: 32,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  AppLocalizations.of(context)!.offline,
                  style: const TextStyle(
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
