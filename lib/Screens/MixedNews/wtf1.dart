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

class Wtf1Screen extends StatefulWidget {
  const Wtf1Screen({Key? key}) : super(key: key);

  @override
  State<Wtf1Screen> createState() => _Wtf1ScreenState();
}

class _Wtf1ScreenState extends State<Wtf1Screen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WTF1.com',
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Wtf1NewsList(),
    );
  }
}

class Wtf1NewsItem extends StatelessWidget {
  final Map item;

  Wtf1NewsItem(
    this.item,
  );

  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    Offset _tapPosition = Offset.zero;

    void _storePosition(TapDownDetails details) {
      _tapPosition = details.globalPosition;
    }

    void _showDetailsMenu() {
      final RenderObject overlay =
          Overlay.of(context)!.context.findRenderObject()!;

      showMenu(
        context: context,
        color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                Padding(
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
                Padding(
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
        position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
            Offset.zero & overlay.semanticBounds.size),
      ).then<void>(
        (int? delta) {
          if (delta == null) return;
          delta == 0
              ? launchUrl(
                  Uri.parse(
                    item['guid']['rendered'],
                  ),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  item['guid']['rendered'],
                );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RssFeedArticleScreen(
                  item['title']['rendered']
                      .replaceAll('&#8217;', "'")
                      .replaceAll('&#8216;', "'"),
                  item['guid']['rendered'],
                ),
              ),
            );
          },
          onTapDown: (position) => _storePosition(position),
          onLongPress: () {
            Feedback.forLongPress(context);
            _showDetailsMenu();
          },
          child: Column(
            children: [
              newsLayout != 'condensed' && newsLayout != 'small'
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: FutureBuilder<String>(
                        future: Wtf1().getImageUrl(
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
                                    : LoadingIndicatorUtil(),
                      ),
                    )
                  : Container(
                      height: 0.0,
                      width: 0.0,
                    ),
              ListTile(
                title: Text(
                  item['title']['rendered']
                      .replaceAll('&#8217;', "'")
                      .replaceAll('&#8216;', "'"),
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 16,
                  bottom: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
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

class Wtf1NewsList extends StatefulWidget {
  final ScrollController? scrollController;

  Wtf1NewsList({
    Key? key,
    this.scrollController,
  });
  @override
  _Wtf1NewsListState createState() => _Wtf1NewsListState();
}

class _Wtf1NewsListState extends State<Wtf1NewsList> {
  static const _pageSize = 10;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((offset) {
      print(offset);
      _fetchPage(offset);
    });
    super.initState();
  }

  Future<void> _fetchPage(int offset) async {
    try {
      List newItems = await Wtf1().getMoreWtf1News(
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
            return Wtf1NewsItem(item);
          },
          firstPageProgressIndicatorBuilder: (_) => LoadingIndicatorUtil(),
          firstPageErrorIndicatorBuilder: (_) => FirstPageExceptionIndicator(
            title: AppLocalizations.of(context)!.errorOccurred,
            message: AppLocalizations.of(context)!.errorOccurredDetails,
            onTryAgain: () => _pagingController.refresh(),
          ),
          newPageProgressIndicatorBuilder: (_) => LoadingIndicatorUtil(),
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

class FirstPageExceptionIndicator extends StatelessWidget {
  const FirstPageExceptionIndicator({
    required this.title,
    this.message,
    this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    final message = this.message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (message != null)
              const SizedBox(
                height: 16,
              ),
            if (message != null)
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            if (onTryAgain != null)
              const SizedBox(
                height: 48,
              ),
            if (onTryAgain != null)
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTryAgain,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.tryAgain,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
