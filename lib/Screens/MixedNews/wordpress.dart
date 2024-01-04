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

import 'dart:async';

import 'package:boxbox/Screens/MixedNews/rss_feed_article.dart';
import 'package:boxbox/api/mixed_news.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class WordpressScreen extends StatefulWidget {
  final String feedName;
  final String feedUrl;
  const WordpressScreen(this.feedName, this.feedUrl, {Key? key})
      : super(key: key);

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _WordpressScreenState extends State<WordpressScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.feedName,
        ),
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: WordpressNewsList(widget.feedUrl),
    );
  }
}

class WordspressNewsItem extends StatelessWidget {
  final Map item;

  const WordspressNewsItem(
    this.item, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    Offset tapPosition = Offset.zero;

    void storePosition(TapDownDetails details) {
      tapPosition = details.globalPosition;
    }

    void showDetailsMenu() {
      final RenderObject overlay =
          Overlay.of(context).context.findRenderObject()!;

      showMenu(
        context: context,
        color: useDarkMode ? const Color(0xff1d1d28) : Colors.white,
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.openInBrowser,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.share,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        position: RelativeRect.fromRect(tapPosition & const Size(40, 40),
            Offset.zero & overlay.semanticBounds.size),
      ).then<void>(
        (int? delta) {
          if (delta == null) return;
          delta == 0
              ? launchUrl(
                  Uri.parse(
                    item['link'],
                  ),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  item['link'],
                );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: useDarkMode ? const Color(0xff1d1d28) : Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RssFeedArticleScreen(
                  item['title']['rendered']
                      .replaceAll('&#8211;', "'")
                      .replaceAll('&#8216;', "'")
                      .replaceAll('&#8217;', "'")
                      .replaceAll('&#8220;', '"')
                      .replaceAll('&#8221;', '"'),
                  item['link'],
                ),
              ),
            );
          },
          onTapDown: (position) => storePosition(position),
          onLongPress: () {
            Feedback.forLongPress(context);
            showDetailsMenu();
          },
          child: Column(
            children: [
              newsLayout != 'condensed' && newsLayout != 'small'
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: FutureBuilder<String>(
                        future: Wordpress().getImageUrl(
                          item['_links']['wp:featuredmedia'][0]['href'],
                        ),
                        builder: (context, imageSnapshot) =>
                            imageSnapshot.hasError
                                ? RequestErrorWidget(
                                    imageSnapshot.error.toString(),
                                  )
                                : imageSnapshot.hasData
                                    ? Image.network(
                                        imageSnapshot.data!,
                                      )
                                    : const LoadingIndicatorUtil(),
                      ),
                    )
                  : const SizedBox(
                      height: 0.0,
                      width: 0.0,
                    ),
              ListTile(
                title: Text(
                  item['title']['rendered']
                      .replaceAll('&#8211;', "'")
                      .replaceAll('&#8216;', "'")
                      .replaceAll('&#8217;', "'")
                      .replaceAll('&#8220;', '"')
                      .replaceAll('&#8221;', '"'),
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  textAlign: TextAlign.justify,
                ),
                subtitle: newsLayout != 'big' && newsLayout != 'condensed'
                    ? null
                    : Text(
                        item['excerpt']['rendered']
                            .replaceAll('&#8211;', "'")
                            .replaceAll('&#8216;', "'")
                            .replaceAll('&#8217;', "'")
                            .replaceAll('&#8220;', '"')
                            .replaceAll('&#8221;', '"')
                            .replaceAll('<p>', '')
                            .replaceAll('</p>', ''),
                        style: TextStyle(
                          color:
                              useDarkMode ? Colors.grey[400] : Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        textAlign: TextAlign.justify,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 16,
                  bottom: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: useDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey[800],
                        size: 20.0,
                      ),
                    ),
                    Text(
                      timeago.format(
                        DateTime.parse(item['date']),
                        locale: Localizations.localeOf(context).toString(),
                      ),
                      style: TextStyle(
                        color: useDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordpressNewsList extends StatefulWidget {
  final ScrollController? scrollController;
  final String baseUrl;

  const WordpressNewsList(
    this.baseUrl, {
    Key? key,
    this.scrollController,
  }) : super(key: key);
  @override
  State<WordpressNewsList> createState() => _WordpressNewsListState();
}

class _WordpressNewsListState extends State<WordpressNewsList> {
  static const _pageSize = 10;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((offset) {
      _fetchPage(offset);
    });
    super.initState();
  }

  Future<void> _fetchPage(int offset) async {
    try {
      List newItems = await Wordpress().getMoreWordpressNews(
        widget.baseUrl,
        offset,
      );
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = offset + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedListView<int, dynamic>(
        pagingController: _pagingController,
        scrollController: widget.scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) {
            return WordspressNewsItem(item);
          },
          firstPageProgressIndicatorBuilder: (_) =>
              const LoadingIndicatorUtil(),
          firstPageErrorIndicatorBuilder: (_) => FirstPageExceptionIndicator(
            title: AppLocalizations.of(context)!.errorOccurred,
            message: AppLocalizations.of(context)!.errorOccurredDetails,
            onTryAgain: () => _pagingController.refresh(),
          ),
          newPageProgressIndicatorBuilder: (_) => const LoadingIndicatorUtil(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
