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
import 'dart:convert';

import 'package:better_player/better_player.dart';
import 'package:boxbox/Screens/circuit.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/api/brightcove.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class F1NewsFetcher {
  final String endpoint = "https://api.formula1.com";
  final String apikey = "qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP";

  List<News> formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['items'];
    List<News> newsList = [];
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;

    for (var element in finalJson) {
      element['title'] = element['title'].replaceAll("\n", "");
      if (element['metaDescription'] != null) {
        element['metaDescription'] =
            element['metaDescription'].replaceAll("\n", "");
      }
      String imageUrl = element['thumbnail']['image']['url'];
      if (useDataSaverMode) {
        if (element['thumbnail']['image']['renditions'] != null) {
          imageUrl = element['thumbnail']['image']['renditions']['2col-retina'];
        } else {
          imageUrl += '.transform/2col-retina/image.jpg';
        }
      }
      newsList.add(
        News(
          element['id'],
          element['articleType'],
          element['slug'],
          element['title'],
          element['metaDescription'] ?? '',
          DateTime.parse(element['updatedAt']),
          imageUrl,
        ),
      );
    }
    return newsList;
  }

  Future<Map<String, dynamic>> getRawNews({
    String? tagId,
    String? articleType,
  }) async {
    Uri url;
    if (tagId != null) {
      url = Uri.parse('$endpoint/v1/editorial/articles?limit=16&tags=$tagId');
    } else if (articleType != null) {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&articleTypes=$articleType');
    } else {
      url = Uri.parse('$endpoint/v1/editorial/articles?limit=16');
    }
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });

    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return responseAsJson;
  }

  FutureOr<List<News>> getLatestNews(
      {String? tagId, String? articleType}) async {
    Map<String, dynamic> responseAsJson = await getRawNews(
      tagId: tagId,
      articleType: articleType,
    );

    if (tagId == null && articleType == null) {
      Hive.box('requests').put('news', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }

  FutureOr<List<News>> getMoreNews(
    int offset, {
    String? tagId,
    String? articleType,
  }) async {
    Uri url;
    if (tagId != null) {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&offset=$offset&tags=$tagId');
    } else if (articleType != null) {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&offset=$offset&articleTypes=$articleType');
    } else {
      url =
          Uri.parse('$endpoint/v1/editorial/articles?limit=16&offset=$offset');
    }
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    return formatResponse(responseAsJson);
  }

  Future<Map<String, dynamic>> getRawPersonalizedFeed(
    List tags, {
    String? articleType,
  }) async {
    Uri url;
    if (articleType != null) {
      url = Uri.parse(
        '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}&articleTypes=$articleType',
      );
    } else {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}');
    }
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    return responseAsJson;
  }

  Future<Article> getArticleData(String articleId) async {
    Uri url = Uri.parse('$endpoint/v1/editorial/articles/$articleId');
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });
    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));

    Article article = Article(
      responseAsJson['id'],
      responseAsJson['slug'],
      responseAsJson['title'],
      DateTime.parse(responseAsJson['createdAt']),
      responseAsJson['articleTags'],
      responseAsJson['hero'],
      responseAsJson['body'],
      responseAsJson['relatedArticles'],
    );
    return article;
  }
}

class News {
  final String newsId;
  final String newsType;
  final String slug;
  final String title;
  final String subtitle;
  final DateTime datePosted;
  final String imageUrl;

  News(
    this.newsId,
    this.newsType,
    this.slug,
    this.title,
    this.subtitle,
    this.datePosted,
    this.imageUrl,
  );
}

class Article {
  final String articleId;
  final String articleSlug;
  final String articleName;
  final DateTime publishedDate;
  final List articleTags;
  final Map articleHero;
  final List articleContent;
  final List relatedArticles;

  Article(
    this.articleId,
    this.articleSlug,
    this.articleName,
    this.publishedDate,
    this.articleTags,
    this.articleHero,
    this.articleContent,
    this.relatedArticles,
  );
}

class NewsItem extends StatefulWidget {
  final News item;
  final bool inRelated;
  final bool? showSmallDescription;

  const NewsItem(
    this.item,
    this.inRelated, {
    Key? key,
    this.showSmallDescription,
  }) : super(key: key);
  @override
  State<NewsItem> createState() => _NewsItemState();
}

class _NewsItemState extends State<NewsItem> {
  final String endpoint = 'https://formula1.com';
  final String articleLink = '/en/latest/article.';

  @override
  Widget build(BuildContext context) {
    final News item = widget.item;
    final bool inRelated = widget.inRelated;
    String imageUrl = item.imageUrl;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Offset tapPosition = Offset.zero;

    void storePosition(TapDownDetails details) {
      tapPosition = details.globalPosition;
    }

    void showDetailsMenu() {
      final RenderObject overlay =
          Overlay.of(context)!.context.findRenderObject()!;

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
                      "https://www.formula1.com/en/latest/article.${item.slug}.${item.newsId}.html"),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  "https://www.formula1.com/en/latest/article.${item.slug}.${item.newsId}.html",
                );
        },
      );
    }

    return inRelated
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width / 2.1 > 300 ? 160 : width / 2.1,
              maxWidth: 300,
              minHeight: 232,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleScreen(
                        item.newsId,
                        item.title,
                        false,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 5.0,
                  color: useDarkMode ? const Color(0xff1d1d28) : Colors.white,
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) => const SizedBox(
                          height: 90,
                          child: LoadingIndicatorUtil(),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outlined,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                        fadeOutDuration: const Duration(seconds: 1),
                        fadeInDuration: const Duration(seconds: 1),
                        cacheManager: CacheManager(
                          Config(
                            "newsImages",
                            stalePeriod: const Duration(days: 7),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: useDarkMode ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: useDarkMode ? const Color(0xff1d1d28) : Colors.white,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.0),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleScreen(
                        item.newsId,
                        item.title,
                        false,
                      ),
                    ),
                  ),
                  hoverColor: Colors.grey.shade700,
                  onTapDown: (position) => storePosition(position),
                  onLongPress: () {
                    Feedback.forLongPress(context);
                    showDetailsMenu();
                  },
                  child: Column(
                    children: [
                      newsLayout != 'condensed' && newsLayout != 'small'
                          ? Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: Hero(
                                    tag: widget.item.newsId,
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      placeholder: (context, url) => SizedBox(
                                        height: (widget.showSmallDescription ??
                                                false)
                                            ? height / (16 / 9) - 58
                                            : width / (16 / 9) - 10,
                                        child: const LoadingIndicatorUtil(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          SizedBox(
                                        height: 50,
                                        child: Icon(
                                          Icons.error_outlined,
                                          color: useDarkMode
                                              ? const Color(0xff1d1d28)
                                              : Colors.white,
                                        ),
                                      ),
                                      fadeOutDuration:
                                          const Duration(seconds: 1),
                                      fadeInDuration:
                                          const Duration(seconds: 1),
                                      cacheManager: CacheManager(
                                        Config(
                                          "newsImages",
                                          stalePeriod: const Duration(days: 7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Container(
                                    width: item.newsType == 'Podcast' ||
                                            item.newsType == 'Feature' ||
                                            item.newsType == 'Opinion' ||
                                            item.newsType == 'Report'
                                        ? 110
                                        : item.newsType == 'Technical' ||
                                                item.newsType == 'Live Blog' ||
                                                item.newsType == 'Interview'
                                            ? 120
                                            : item.newsType == 'Image Gallery'
                                                ? 150
                                                : 90,
                                    height: 27,
                                    alignment: Alignment.bottomLeft,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(3),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 2,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 6,
                                          ),
                                          child: Icon(
                                            item.newsType == 'Video'
                                                ? Icons.play_arrow_outlined
                                                : item.newsType ==
                                                        'Image Gallery'
                                                    ? Icons.image_outlined
                                                    : item.newsType == 'Podcast'
                                                        ? Icons
                                                            .podcasts_outlined
                                                        : item.newsType ==
                                                                'Poll'
                                                            ? Icons.bar_chart
                                                            : item.newsType ==
                                                                    'News'
                                                                ? Icons
                                                                    .feed_outlined
                                                                : item.newsType ==
                                                                        'Report'
                                                                    ? Icons
                                                                        .report_outlined
                                                                    : item.newsType ==
                                                                            'Interview'
                                                                        ? Icons
                                                                            .mic_outlined
                                                                        : item.newsType ==
                                                                                'Feature'
                                                                            ? Icons.star_outline_outlined
                                                                            : item.newsType == 'Opinion'
                                                                                ? Icons.chat_outlined
                                                                                : item.newsType == 'Technical'
                                                                                    ? Icons.construction_outlined
                                                                                    : item.newsType == 'Live Blog'
                                                                                        ? Icons.live_tv_outlined
                                                                                        : Icons.info_outlined,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            item.newsType,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 0.0,
                              width: 0.0,
                            ),
                      ListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: useDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines:
                              (widget.showSmallDescription ?? false) ? 3 : 5,
                          textAlign: TextAlign.justify,
                        ),
                        subtitle: (newsLayout != 'big' &&
                                    newsLayout != 'condensed') ||
                                (widget.showSmallDescription ?? false)
                            ? null
                            : Text(
                                item.subtitle,
                                style: TextStyle(
                                  color: useDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[800],
                                ),
                                textAlign: TextAlign.justify,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
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
                                item.datePosted,
                                locale:
                                    Localizations.localeOf(context).toString(),
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
            ),
          );
  }
}

class CachedNewsImage extends StatefulWidget {
  const CachedNewsImage({Key? key}) : super(key: key);

  @override
  State<CachedNewsImage> createState() => _CachedNewsImageState();
}

class _CachedNewsImageState extends State<CachedNewsImage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NewsList extends StatefulWidget {
  final List items;
  final ScrollController? scrollController;
  final String? tagId;
  final String? articleType;

  const NewsList({
    required this.items,
    this.scrollController,
    this.tagId,
    this.articleType,
    Key? key,
  }) : super(key: key);
  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  static const _pageSize = 16;
  final PagingController<int, News> _pagingController =
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
      List<News> newItems = await F1NewsFetcher().getMoreNews(
        offset,
        tagId: widget.tagId,
        articleType: widget.articleType,
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
    double width = MediaQuery.of(context).size.width;
    return width < 500
        ? RefreshIndicator(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
            child: PagedListView<int, News>(
              pagingController: _pagingController,
              scrollController: widget.scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              builderDelegate: PagedChildBuilderDelegate<News>(
                itemBuilder: (context, item, index) {
                  return NewsItem(item, false);
                },
                firstPageProgressIndicatorBuilder: (_) =>
                    const LoadingIndicatorUtil(),
                firstPageErrorIndicatorBuilder: (_) =>
                    FirstPageExceptionIndicator(
                  title: AppLocalizations.of(context)!.errorOccurred,
                  message: AppLocalizations.of(context)!.errorOccurredDetails,
                  onTryAgain: () => _pagingController.refresh(),
                ),
                newPageProgressIndicatorBuilder: (_) =>
                    const LoadingIndicatorUtil(),
              ),
            ),
          )
        : PagedGridView<int, News>(
            pagingController: _pagingController,
            scrollController: widget.scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width < 750
                  ? 2
                  : width < 1000
                      ? 3
                      : width < 1400
                          ? 4
                          : 5,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            builderDelegate: PagedChildBuilderDelegate<News>(
              itemBuilder: (context, item, index) {
                return NewsItem(
                  item,
                  false,
                  showSmallDescription: true,
                );
              },
              firstPageProgressIndicatorBuilder: (_) =>
                  const LoadingIndicatorUtil(),
              firstPageErrorIndicatorBuilder: (_) =>
                  FirstPageExceptionIndicator(
                title: AppLocalizations.of(context)!.errorOccurred,
                message: AppLocalizations.of(context)!.errorOccurredDetails,
                onTryAgain: () => _pagingController.refresh(),
              ),
              newPageProgressIndicatorBuilder: (_) =>
                  const LoadingIndicatorUtil(),
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
                    style: const TextStyle(
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

class OfflineNewsList extends StatefulWidget {
  final List items;
  final ScrollController? scrollController;

  const OfflineNewsList({
    required this.items,
    this.scrollController,
    Key? key,
  }) : super(key: key);
  @override
  State<OfflineNewsList> createState() => _OfflineNewsListState();
}

class _OfflineNewsListState extends State<OfflineNewsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map cachedNews = Hive.box('requests').get('news', defaultValue: {}) as Map;
    List<News> formatedNews = F1NewsFetcher().formatResponse(cachedNews);
    return ListView.builder(
      controller: widget.scrollController,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: formatedNews.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => index == formatedNews.length - 1
          ? const Padding(
              padding: EdgeInsets.all(15),
            )
          : NewsItem(
              formatedNews[index],
              false,
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class JoinArticlesParts extends StatelessWidget {
  final Article article;

  const JoinArticlesParts(this.article, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    List articleContent = article.articleContent;
    List<Widget> widgetsList = [];
    String heroImageUrl = "";

    if (article.articleHero['contentType'] == 'atomVideo') {
      heroImageUrl = article.articleHero['fields']['thumbnail']['url'];
    } else if (article.articleHero['contentType'] == 'atomVideoYouTube') {
      heroImageUrl = article.articleHero['fields']['image']['url'];
    } else if (article.articleHero['contentType'] == 'atomImageGallery') {
      List<Widget> galleryHeroWidgets = [];
      article.articleHero['fields']['imageGallery'].forEach(
        (element) => galleryHeroWidgets.add(
          ImageRenderer(
            useDataSaverMode
                ? element['renditions'] != null
                    ? element['renditions']['2col-retina']
                    : element['url'] + '.transform/3col-retina/image.jpg'
                : element['url'],
          ),
        ),
      );
      widgetsList.add(
        CarouselSlider(
          items: galleryHeroWidgets,
          options: CarouselOptions(
            viewportFraction: 1,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            autoPlay: true,
          ),
        ),
      );
      heroImageUrl = article.articleHero['fields']['imageGallery'][0]['url'];
    } else {
      widgetsList.add(
        Hero(
          tag: article.articleId,
          child: ImageRenderer(
            useDataSaverMode
                ? article.articleHero['fields']['image']['renditions'] != null
                    ? article.articleHero['fields']['image']['renditions']
                        ['2col-retina']
                    : article.articleHero['fields']['image']['url'] +
                        '.transform/2col-retina/image.jpg'
                : article.articleHero['fields']['image']['url'],
            isHero: true,
          ),
        ),
      );
      heroImageUrl = article.articleHero['fields']['image']['url'];
    }

    List articlesHistory =
        Hive.box('history').get('articlesHistory', defaultValue: []) as List;
    if (articlesHistory.isEmpty) {
      articlesHistory.add(
        {
          'imageUrl': heroImageUrl,
          'articleId': article.articleId,
          'articleTitle': article.articleName,
          'timeVisited': DateTime.now().toString(),
        },
      );
    } else {
      if (articlesHistory[articlesHistory.length - 1]['articleId'] !=
          article.articleId) {
        articlesHistory.add(
          {
            'imageUrl': heroImageUrl,
            'articleId': article.articleId,
            'articleTitle': article.articleName,
            'timeVisited': DateTime.now().toString(),
          },
        );
      }
    }
    Hive.box('history').put('articlesHistory', articlesHistory);
    articlesHistory =
        Hive.box('history').get('articlesHistory', defaultValue: []) as List;

    List<Widget> tagsList = [];
    for (var tag in article.articleTags) {
      tagsList.add(
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 5,
            right: 5,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(
                        tag['fields']['tagName'],
                      ),
                    ),
                    backgroundColor: useDarkMode
                        ? Theme.of(context).backgroundColor
                        : Colors.white,
                    body: NewsFeedWidget(tagId: tag['id']),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Text(
                  tag['fields']['tagName'],
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    widgetsList.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            children: tagsList,
          ),
        ),
      ),
    );

    for (var element in articleContent) {
      if (element['contentType'] == 'atomRichText') {
        widgetsList.add(
          TextParagraphRenderer(element['fields']['richTextBlock']),
        );
      } else if (element['contentType'] == 'atomVideo') {
        widgetsList.add(
          VideoRenderer(
            element['fields']['videoId'],
          ),
        );
      } else if (element['contentType'] == 'atomVideoYouTube') {
        widgetsList.add(
          VideoRenderer(
            '',
            youtubeId: element['fields']['youTubeVideoId'],
          ),
        );
      } else if (element['contentType'] == 'atomImage') {
        widgetsList.add(
          ImageRenderer(
            useDataSaverMode
                ? element['fields']['image']['renditions'] != null
                    ? element['fields']['image']['renditions']['2col-retina']
                    : element['fields']['image']['url'] +
                        '.transform/2col-retina/image.jpg'
                : element['fields']['image']['url'],
            caption: element['fields']['caption'] ?? '',
          ),
        );
      } else if (element['contentType'] == 'atomQuiz') {
        widgetsList.add(
          AspectRatio(
            aspectRatio: 748 / 598,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'https://www.riddle.com/view/${element['fields']['riddleId']}'),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  preferredContentMode: UserPreferredContentMode.DESKTOP,
                ),
              ),
              gestureRecognizers: {
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()),
                Factory<HorizontalDragGestureRecognizer>(
                    () => HorizontalDragGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              },
            ),
          ),
        );
      } else if (element['contentType'] == 'atomImageGallery') {
        List<Widget> galleryWidgets = [];
        element['fields']['imageGallery'].forEach(
          (element) => galleryWidgets.add(
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ImageRenderer(
                useDataSaverMode
                    ? element['renditions'] != null
                        ? element['renditions']['2col-retina']
                        : element['url'] + '.transform/2col-retina/image.jpg'
                    : element['url'],
              ),
            ),
          ),
        );
        widgetsList.add(
          CarouselSlider(
            items: galleryWidgets,
            options: CarouselOptions(
              viewportFraction: 1,
              aspectRatio: 16 / 9,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 7),
            ),
          ),
        );
      } else if (element['contentType'] == 'atomSocialPost' &&
          element['fields']['postType'] == 'Twitter') {
        widgetsList.add(
          SizedBox(
            height: 400,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                  data:
                      '<blockquote class="twitter-tweet"><a href="https://twitter.com/x/status/${element['fields']['postId']}"></a> </blockquote><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>'),
              gestureRecognizers: {
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()),
                Factory<HorizontalDragGestureRecognizer>(
                    () => HorizontalDragGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(transparentBackground: true),
              ),
            ),
          ),
        );
      } else if (element['contentType'] == 'atomSessionResults') {
        String sessionType = element['fields']['sessionType'] == 'Sprint'
            ? 'SprintQualifying'
            : element['fields']['sessionType'];
        List driversFields =
            element['fields']['raceResults$sessionType']['results'];
        widgetsList.add(
          Padding(
            padding: const EdgeInsets.all(
              10,
            ),
            child: Container(
              height: 255,
              decoration: BoxDecoration(
                border: Border.all(
                  color: useDarkMode
                      ? const Color(0xff1d1d28)
                      : Colors.grey.shade50,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                    ),
                    child: Text(
                      element['fields']['meetingCountryName'],
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    sessionType == 'Race'
                        ? AppLocalizations.of(context)!.race
                        : sessionType == 'Qualifying'
                            ? AppLocalizations.of(context)!.qualifyings
                            : sessionType == 'SprintQualifying'
                                ? AppLocalizations.of(context)!.sprint
                                : sessionType.endsWith('1')
                                    ? AppLocalizations.of(context)!
                                        .freePracticeOne
                                    : sessionType.endsWith('2')
                                        ? AppLocalizations.of(context)!
                                            .freePracticeTwo
                                        : AppLocalizations.of(context)!
                                            .freePracticeThree,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: sessionType == 'Race' ||
                                  sessionType == 'SprintQualifying'
                              ? 5
                              : 4,
                          child: Text(
                            AppLocalizations.of(context)!.positionAbbreviation,
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 5,
                          child: Text(
                            AppLocalizations.of(context)!.time,
                            style: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        sessionType == 'Race' ||
                                sessionType == 'SprintQualifying'
                            ? Expanded(
                                flex: 3,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .pointsAbbreviation,
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  for (Map driverResults in driversFields)
                    sessionType == 'Race' || sessionType == 'SprintQualifying'
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 7,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    driverResults['positionNumber'],
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 15,
                                    child: VerticalDivider(
                                      color: Color(
                                        int.parse(
                                            'FF${driverResults['teamColourCode']}',
                                            radix: 16),
                                      ),
                                      thickness: 5,
                                      width: 5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    driverResults['driverTLA'].toString(),
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    driverResults['gapToLeader'] != "0.0"
                                        ? '+${driverResults['gapToLeader']}'
                                        : sessionType == 'Race'
                                            ? driverResults['raceTime']
                                            : driverResults[
                                                'sprintQualifyingTime'],
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    sessionType == 'Race'
                                        ? driverResults['racePoints'].toString()
                                        : driverResults[
                                                'sprintQualifyingPoints']
                                            .toString(),
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              top: 7,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    driverResults['positionNumber'],
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 15,
                                    child: VerticalDivider(
                                      color: Color(
                                        int.parse(
                                          'FF${driverResults['teamColourCode']}',
                                          radix: 16,
                                        ),
                                      ),
                                      thickness: 5,
                                      width: 5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    driverResults['driverTLA'].toString(),
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    sessionType.startsWith('Practice')
                                        ? driverResults['classifiedTime']
                                        : driverResults['q3']['classifiedTime'],
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => sessionType
                                        .startsWith('Practice')
                                    ? FreePracticeScreen(
                                        element['fields'][
                                                        'raceResults$sessionType']
                                                    ['description']
                                                .endsWith('1')
                                            ? AppLocalizations.of(context)!
                                                .freePracticeOne
                                            : element['fields'][
                                                            'raceResults$sessionType']
                                                        ['description']
                                                    .endsWith('2')
                                                ? AppLocalizations.of(context)!
                                                    .freePracticeTwo
                                                : AppLocalizations.of(context)!
                                                    .freePracticeThree,
                                        int.parse(
                                          element['fields'][
                                                      'raceResults$sessionType']
                                                  ['session']
                                              .substring(1),
                                        ),
                                        '',
                                        int.parse(
                                          element['fields']['season'],
                                        ),
                                        element['fields']
                                            ['meetingOfficialName'],
                                        raceUrl: element['fields']['cta'],
                                      )
                                    : Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            sessionType == 'Race'
                                                ? AppLocalizations.of(context)!
                                                    .race
                                                : sessionType ==
                                                        'SprintQualifying'
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .sprint
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .qualifyings,
                                          ),
                                        ),
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                        body: sessionType == 'Race' ||
                                                sessionType ==
                                                    'SprintQualifying'
                                            ? RaceResultsProvider(
                                                raceUrl: element['fields']
                                                    ['cta'],
                                              )
                                            : SingleChildScrollView(
                                                child:
                                                    QualificationResultsProvider(
                                                  raceUrl: element['fields']
                                                      ['cta'],
                                                ),
                                              ),
                                      ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: const ContinuousRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.viewResults,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (element['contentType'] == 'atomTableContent') {
        Map<String, dynamic> fields = element['fields'];
        widgetsList.add(
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade700,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              height:
                  (fields['tableData']['tableContent'].length + 1) * 50.0 + 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          fields['title'],
                          style: TextStyle(
                            color: useDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    for (List driverItem in fields['tableData']['tableContent'])
                      Row(
                        children: <Widget>[
                          for (Map driverDetails in driverItem)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              width: 150,
                              height: 50,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    driverDetails['value'].toString(),
                                    style: TextStyle(
                                      color: useDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (element['contentType'] == 'atomAudioBoom') {
        widgetsList.add(
          SizedBox(
            height: 400,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(
                  'https:${element['fields']['audioPodcast']['iFrameSrc']}',
                ),
              ),
              gestureRecognizers: {
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()),
                Factory<HorizontalDragGestureRecognizer>(
                    () => HorizontalDragGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(transparentBackground: true),
              ),
            ),
          ),
        );
      } else if (element['contentType'] == 'atomLinkList') {
        widgetsList.add(
          Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: element['fields']['items'].length + 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => index == 0
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        element['fields']['title'],
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        String articleUrl =
                            element['fields']['items'][index - 1]['webUrl'];
                        String articleId = articleUrl
                            .substring(43, articleUrl.length - 5)
                            .split('.')[1];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleScreen(
                              articleId,
                              element['fields']['items'][index - 1]['title'],
                              true,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          '• ${element['fields']['items'][index - 1]['title']}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
        // atomLinkList
      } else {
        widgetsList.add(
          SizedBox(
            height: 100,
            child: Center(
              child: SelectableText(
                'Unsupported widget ¯\\_(ツ)_/¯\nType: ${element['contentType']}\nArticle id: ${article.articleId}',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      }
    }

    widgetsList.add(
      Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Share.share(
                          "https://www.formula1.com/en/latest/article.${article.articleSlug}.${article.articleId}.html",
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)?.share ?? 'Share',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.schedule,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        DateFormat('kk:mm\nyyyy-MM-dd')
                            .format(article.publishedDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    List<NewsItem> relatedArticles = [];
    for (var article in article.relatedArticles) {
      relatedArticles.add(
        NewsItem(
          News(
            article['id'],
            article['articleType'],
            article['slug'],
            article['title'],
            article['metaDescription'] ?? ' ',
            DateTime.parse(article['updatedAt']),
            useDataSaverMode
                ? article['thumbnail']['image']['renditions'] != null
                    ? article['thumbnail']['image']['renditions']['2col']
                    : article['thumbnail']['image']['url'] +
                        '.transform/2col-retina/image.jpg'
                : article['thumbnail']['image']['url'],
          ),
          true,
        ),
      );
    }
    widgetsList.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: relatedArticles,
        ),
      ),
    );
    return (article.articleHero['contentType'] == 'atomVideo') ||
            (article.articleHero['contentType'] == 'atomVideoYouTube')
        ? NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: PinnedVideoPlayer(
                    VideoRenderer(
                      article.articleHero['fields']['videoId'] ?? '',
                      autoplay: true,
                      youtubeId:
                          article.articleHero['fields']['youTubeVideoId'] ?? '',
                    ),
                    MediaQuery.of(context).size.width / (16 / 9),
                  ),
                ),
              ];
            },
            body: SafeArea(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: widgetsList,
                  ),
                ),
              ),
            ),
          )
        : MediaQuery.of(context).size.width > 600
            ? Scrollbar(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 300,
                        maxWidth: 800,
                      ),
                      child: Column(
                        children: widgetsList,
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: widgetsList,
                    ),
                  ),
                ),
              );
  }
}

class TextParagraphRenderer extends StatelessWidget {
  final String text;
  const TextParagraphRenderer(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useDefaultFontForArticles = Hive.box('settings')
        .get('useDefaultFontForArticles', defaultValue: false) as bool;
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: MarkdownBody(
        data: text,
        selectable: true,
        onTapLink: (text, url, title) {
          if (url!.startsWith('https://www.formula1.com/en/latest/article.')) {
            String articleId = url.substring(43, url.length - 5).split('.')[1];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleScreen(
                  articleId,
                  text,
                  true,
                ),
              ),
            );
          } else if (url.startsWith('https://www.formula1.com/en/results')) {
            String standingsType =
                url.substring(0, url.length - 5).split('/')[6];
            if (standingsType == "driver-standings" ||
                standingsType == "drivers") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        AppLocalizations.of(context)!.standings,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: const StandingsScreen(),
                  ),
                ),
              );
            } else if (standingsType == "constructor-standings" ||
                standingsType == "team") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        AppLocalizations.of(context)!.standings,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: const StandingsScreen(
                      switchToTeamStandings: true,
                    ),
                  ),
                ),
              );
            } else {
              launchUrl(Uri.parse(url));
            }
          } else if (url.startsWith("https://www.formula1.com/en/racing/202") ||
              url.startsWith(
                  "https://www.formula1.com/content/fom-website/en/racing/202")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CircuitScreen(
                  Race(
                    '0',
                    '',
                    '',
                    '',
                    url.split('/')[8].split('.')[0],
                    '',
                    '',
                    '',
                  ),
                  isFetched: false,
                ),
              ),
            );
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        styleSheet: MarkdownStyleSheet(
          strong: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          p: TextStyle(
            fontSize: 14,
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          pPadding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          a: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.normal,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          h1: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          h2: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          h3: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          h4: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
          listBullet: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: useDefaultFontForArticles ? 'Roboto' : 'Formula1',
          ),
        ),
      ),
    );
  }
}

class ImageRenderer extends StatefulWidget {
  final String imageUrl;
  final String? caption;
  final bool? inSchedule;
  final bool? isHero;

  const ImageRenderer(
    this.imageUrl, {
    Key? key,
    this.caption,
    this.inSchedule,
    this.isHero,
  }) : super(key: key);

  @override
  State<ImageRenderer> createState() => _ImageRendererState();
}

class _ImageRendererState extends State<ImageRenderer> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.inSchedule != null ? 0 : 10,
      ),
      child: widget.inSchedule != null
          ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => SizedBox(
                height: MediaQuery.of(context).size.width / (16 / 9),
                child: const LoadingIndicatorUtil(),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outlined),
              fadeOutDuration: const Duration(seconds: 1),
              fadeInDuration: const Duration(seconds: 1),
              cacheManager: CacheManager(
                Config(
                  "newsImages",
                  stalePeriod: const Duration(days: 7),
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.only(
                        top: 52,
                        bottom: 50,
                      ),
                      insetPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.transparent,
                      content: Builder(
                        builder: (context) {
                          return SizedBox(
                            width: double.infinity - 10,
                            child: InteractiveViewer(
                              minScale: 0.1,
                              maxScale: 8,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: widget.isHero != null &&
                                              widget.isHero!
                                          ? CachedNetworkImage(
                                              imageUrl: widget.imageUrl,
                                              placeholder: (context, url) =>
                                                  SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    (16 / 9),
                                                child:
                                                    const LoadingIndicatorUtil(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                          Icons.error_outlined),
                                              fadeOutDuration:
                                                  const Duration(seconds: 1),
                                              fadeInDuration: widget.isHero ??
                                                      false
                                                  ? const Duration(
                                                      milliseconds: 300)
                                                  : const Duration(seconds: 1),
                                              cacheManager: CacheManager(
                                                Config(
                                                  "newsImages",
                                                  stalePeriod:
                                                      const Duration(days: 7),
                                                ),
                                              ),
                                            )
                                          : Image(
                                              image: NetworkImage(
                                                widget.imageUrl,
                                              ),
                                              loadingBuilder: (context, child,
                                                      loadingProgress) =>
                                                  loadingProgress == null
                                                      ? child
                                                      : SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              (16 / 9),
                                                          child:
                                                              const LoadingIndicatorUtil(),
                                                        ),
                                              errorBuilder:
                                                  (context, url, error) => Icon(
                                                Icons.error_outlined,
                                                color: useDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                size: 30,
                                              ),
                                            )),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  widget.isHero != null && widget.isHero!
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          placeholder: (context, url) => SizedBox(
                            height:
                                MediaQuery.of(context).size.width / (16 / 9),
                            child: const LoadingIndicatorUtil(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error_outlined),
                          fadeOutDuration: const Duration(seconds: 1),
                          fadeInDuration: const Duration(seconds: 1),
                          cacheManager: CacheManager(
                            Config(
                              "newsImages",
                              stalePeriod: const Duration(days: 7),
                            ),
                          ),
                        )
                      : Image.network(
                          widget.imageUrl,
                          loadingBuilder: (context, child, loadingProgress) =>
                              loadingProgress == null
                                  ? child
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width /
                                              (16 / 9),
                                      child: const LoadingIndicatorUtil(),
                                    ),
                          errorBuilder: (context, url, error) => Icon(
                            Icons.error_outlined,
                            color: useDarkMode ? Colors.white : Colors.black,
                            size: 30,
                          ),
                        ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: widget.caption != null || widget.caption == ''
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),
                            color: Colors.black.withOpacity(0.7),
                            child: Text(
                              widget.caption ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
    );
  }
}

class VideoRenderer extends StatefulWidget {
  final String videoId;
  final bool? autoplay;
  final String? youtubeId;

  const VideoRenderer(
    this.videoId, {
    Key? key,
    this.autoplay,
    this.youtubeId,
  }) : super(key: key);
  @override
  State<VideoRenderer> createState() => _VideoRendererState();
}

class _VideoRendererState extends State<VideoRenderer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> getYouTubeVideoLinks(String videoId) async {
    Map<String, dynamic> urls = {};
    urls['videos'] = [];
    YoutubeExplode yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    urls['poster'] = 'https://img.youtube.com/vi/$videoId/0.jpg';

    for (var stream in manifest.muxed) {
      urls['videos'].add(stream.url.toString());
    }
    urls['videos'].add(manifest.muxed[1].url.toString());
    urls['videos'] = urls['videos'].reversed.toList();
    urls['videos'].add(manifest.muxed[1].url.toString());
    return urls;
  }

  @override
  Widget build(BuildContext build) {
    return FutureBuilder<Map<String, dynamic>>(
      future: (widget.youtubeId ?? '') != ''
          ? getYouTubeVideoLinks(widget.youtubeId!)
          : BrightCove().getVideoLinks(widget.videoId),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? BetterPlayerVideoPlayer(
                  snapshot.data!,
                  widget.autoplay == null ? false : widget.autoplay!,
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.width / (16 / 9),
                  child: const LoadingIndicatorUtil(),
                ),
    );
  }
}

class BetterPlayerVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> videoUrls;
  final bool autoplay;

  const BetterPlayerVideoPlayer(
    this.videoUrls,
    this.autoplay, {
    Key? key,
  }) : super(key: key);
  @override
  State<BetterPlayerVideoPlayer> createState() =>
      _BetterPlayerVideoPlayerState();
}

class _BetterPlayerVideoPlayerState extends State<BetterPlayerVideoPlayer> {
  late BetterPlayerController _betterPlayerController;
  final StreamController<bool> _placeholderStreamController =
      StreamController.broadcast();
  bool _showPlaceholder = true;
  bool useDarkMode =
      Hive.box('settings').get('darkMode', defaultValue: true) as bool;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrls['videos'][0],
      resolutions: {
        '720p': widget.videoUrls['videos'][1],
        '360p': widget.videoUrls['videos'][2],
        '180p': widget.videoUrls['videos'][3],
      },
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: widget.videoUrls['name'],
        author: "Formula 1",
        imageUrl: widget.videoUrls['poster'],
        activityName: "MainActivity",
      ),
    );
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoPlay: widget.autoplay,
      allowedScreenSleep: false,
      autoDetectFullscreenDeviceOrientation: true,
      fit: BoxFit.contain,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableAudioTracks: false,
        enableSubtitles: false,
        overflowModalColor:
            useDarkMode ? const Color(0xff1d1d28) : Colors.white,
        overflowMenuIconsColor: useDarkMode ? Colors.white : Colors.black,
        overflowModalTextColor: useDarkMode ? Colors.white : Colors.black,
        showControlsOnInitialize: false,
      ),
      placeholder: _buildVideoPlaceholder(),
      showPlaceholderUntilPlay: true,
    );
    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _setPlaceholderVisibleState(false);
      }
    });
  }

  void _setPlaceholderVisibleState(bool hidden) {
    _placeholderStreamController.add(hidden);
    _showPlaceholder = hidden;
  }

  Widget _buildVideoPlaceholder() {
    return StreamBuilder<bool>(
      stream: _placeholderStreamController.stream,
      builder: (context, snapshot) {
        return _showPlaceholder
            ? Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.dstATop,
                        ),
                        image: NetworkImage(widget.videoUrls['poster']),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_arrow_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext build) {
    return BetterPlayer(
      controller: _betterPlayerController,
    );
  }

  @override
  void dispose() {
    _placeholderStreamController.close();
    _betterPlayerController.dispose();
    super.dispose();
  }
}

class PinnedVideoPlayer extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final double height;

  PinnedVideoPlayer(this.widget, this.height);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Card(
        margin: const EdgeInsets.all(0),
        color: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
        elevation: 10.0,
        child: Center(
          child: widget,
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
