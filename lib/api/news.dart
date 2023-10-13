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
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/api/brightcove.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class F1NewsFetcher {
  final String defaultEndpoint = "https://api.formula1.com";
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
      String imageUrl = "";
      if (element['thumbnail'] != null) {
        imageUrl = element['thumbnail']['image']['url'];
        if (useDataSaverMode) {
          if (element['thumbnail']['image']['renditions'] != null) {
            imageUrl =
                element['thumbnail']['image']['renditions']['2col-retina'];
          } else {
            imageUrl += '.transform/2col-retina/image.jpg';
          }
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

  FutureOr<List<News>> getMoreNews(
    int offset, {
    String? tagId,
    String? articleType,
  }) async {
    Uri url;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
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
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    if (offset == 0 && tagId == null && articleType == null) {
      Hive.box('requests').put('news', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }

  Future<Map<String, dynamic>> getRawPersonalizedFeed(
    List tags, {
    String? articleType,
  }) async {
    Uri url;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (articleType != null) {
      url = Uri.parse(
        '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}&articleTypes=$articleType',
      );
    } else {
      url = Uri.parse(
          '$endpoint/v1/editorial/articles?limit=16&tags=${tags.join(',')}');
    }
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    return responseAsJson;
  }

  Future<Article> getArticleData(String articleId) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    Uri url = Uri.parse('$endpoint/v1/editorial/articles/$articleId');
    var response = await http.get(
      url,
      headers: endpoint != defaultEndpoint
          ? {
              "Accept": "application/json",
            }
          : {
              "Accept": "application/json",
              "apikey": apikey,
              "locale": "en",
            },
    );
    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );

    Article article = Article(
      responseAsJson['id'],
      responseAsJson['slug'],
      responseAsJson['title'],
      DateTime.parse(responseAsJson['createdAt']),
      responseAsJson['articleTags'],
      responseAsJson['hero'] ?? {},
      responseAsJson['body'],
      responseAsJson['relatedArticles'],
      responseAsJson['author'] ?? {},
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
  final Map authorDetails;

  Article(
    this.articleId,
    this.articleSlug,
    this.articleName,
    this.publishedDate,
    this.articleTags,
    this.articleHero,
    this.articleContent,
    this.relatedArticles,
    this.authorDetails,
  );
}

class NewsItem extends StatefulWidget {
  final News item;
  final bool inRelated;
  final bool? showSmallDescription;
  final double? width;
  final int itemPerRow;

  const NewsItem(
    this.item,
    this.inRelated, {
    Key? key,
    this.showSmallDescription,
    this.width,
    this.itemPerRow = 1,
  }) : super(key: key);
  @override
  State<NewsItem> createState() => _NewsItemState();
}

class _NewsItemState extends State<NewsItem> with TickerProviderStateMixin {
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
                      "https://www.formula1.com/en/latest/article.${item.slug}.${item.newsId}.html"),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  "https://www.formula1.com/en/latest/article.${item.slug}.${item.newsId}.html",
                );
        },
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width / 2.1 > 300 ? 230 : width / 2.1,
        maxWidth: width > 1400
            ? 600
            : width > 1000
                ? 400
                : 300,
        minHeight: 232,
      ),
      child: inRelated
          ? Padding(
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
                    hoverColor: useDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    onTapDown: (position) => storePosition(position),
                    onLongPress: () {
                      Feedback.forLongPress(context);
                      showDetailsMenu();
                    },
                    child: kIsWeb
                        ? Hover(
                            builder: (isHovered) => PhysicalModel(
                              color: Colors.transparent,
                              elevation: isHovered ? 16 : 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                        placeholder: (context, url) =>
                                            const SizedBox(
                                          width: 300,
                                          child: LoadingIndicatorUtil(
                                            replaceImage: true,
                                          ),
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
                                            stalePeriod:
                                                const Duration(days: 7),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      textAlign: TextAlign.justify,
                                    ),
                                    mouseCursor: SystemMouseCursors.click,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
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
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                      width: 300,
                                      child: LoadingIndicatorUtil(
                                        replaceImage: true,
                                      ),
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
                                    fadeOutDuration: const Duration(seconds: 1),
                                    fadeInDuration: const Duration(seconds: 1),
                                    cacheManager: CacheManager(
                                      Config(
                                        "newsImages",
                                        stalePeriod: const Duration(days: 7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  textAlign: TextAlign.justify,
                                ),
                                mouseCursor: SystemMouseCursors.click,
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
                    hoverColor: useDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    onTapDown: (position) => storePosition(position),
                    onLongPress: () {
                      Feedback.forLongPress(context);
                      showDetailsMenu();
                    },
                    child: kIsWeb
                        ? Hover(
                            builder: (isHovered) => PhysicalModel(
                              color: Colors.transparent,
                              elevation: isHovered ? 16 : 0,
                              child: Column(
                                children: [
                                  newsLayout != 'condensed' &&
                                          newsLayout != 'small'
                                      ? Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              child: Hero(
                                                tag: widget.item.newsId,
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  placeholder: (context, url) =>
                                                      SizedBox(
                                                    height: (MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width >
                                                            500)
                                                        ? (MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    widget
                                                                        .itemPerRow -
                                                                8 *
                                                                    widget
                                                                        .itemPerRow) /
                                                            (16 / 9)
                                                        : (widget.showSmallDescription ??
                                                                false)
                                                            ? height /
                                                                    (16 / 9) -
                                                                58
                                                            : width / (16 / 9) -
                                                                10,
                                                    child:
                                                        const LoadingIndicatorUtil(
                                                      replaceImage: true,
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          SizedBox(
                                                    height: 50,
                                                    child: Icon(
                                                      Icons.error_outlined,
                                                      color: useDarkMode
                                                          ? const Color(
                                                              0xff1d1d28)
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  fadeOutDuration:
                                                      const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  fadeInDuration:
                                                      const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  cacheManager: CacheManager(
                                                    Config(
                                                      "newsImages",
                                                      stalePeriod:
                                                          const Duration(
                                                              days: 5),
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
                                                width: item.newsType ==
                                                            'Podcast' ||
                                                        item.newsType ==
                                                            'Feature' ||
                                                        item.newsType ==
                                                            'Opinion' ||
                                                        item.newsType ==
                                                            'Report'
                                                    ? 110
                                                    : item.newsType ==
                                                                'Technical' ||
                                                            item.newsType ==
                                                                'Live Blog' ||
                                                            item.newsType ==
                                                                'Interview'
                                                        ? 120
                                                        : item.newsType ==
                                                                'Image Gallery'
                                                            ? 150
                                                            : 90,
                                                height: 27,
                                                alignment: Alignment.bottomLeft,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(3),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(3),
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 2,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ],
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 6,
                                                      ),
                                                      child: Icon(
                                                        item.newsType == 'Video'
                                                            ? Icons
                                                                .play_arrow_outlined
                                                            : item.newsType ==
                                                                    'Image Gallery'
                                                                ? Icons
                                                                    .image_outlined
                                                                : item.newsType ==
                                                                        'Podcast'
                                                                    ? Icons
                                                                        .podcasts_outlined
                                                                    : item.newsType ==
                                                                            'Poll'
                                                                        ? Icons
                                                                            .bar_chart
                                                                        : item.newsType ==
                                                                                'News'
                                                                            ? Icons.feed_outlined
                                                                            : item.newsType == 'Report'
                                                                                ? Icons.report_outlined
                                                                                : item.newsType == 'Interview'
                                                                                    ? Icons.mic_outlined
                                                                                    : item.newsType == 'Feature'
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
                                                      padding:
                                                          const EdgeInsets.only(
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
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines:
                                          (widget.showSmallDescription ?? false)
                                              ? 3
                                              : 5,
                                      textAlign: TextAlign.justify,
                                    ),
                                    subtitle: (newsLayout != 'big' &&
                                                newsLayout != 'condensed') ||
                                            ((widget.showSmallDescription ??
                                                    false) &&
                                                width < 1361)
                                        ? null
                                        : Text(
                                            item.subtitle,
                                            style: TextStyle(
                                              color: useDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                            textAlign: TextAlign.justify,
                                            maxLines: width > 1360 ? 4 : 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                    mouseCursor: SystemMouseCursors.click,
                                  ),
                                  width > 1360
                                      ? Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16,
                                                bottom: 10,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                      locale: Localizations
                                                              .localeOf(context)
                                                          .toString(),
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
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                              bottom: 5,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                        Localizations.localeOf(
                                                                context)
                                                            .toString(),
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
                                        ),
                                ],
                              ),
                            ),
                          )
                        : Column(
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
                                              placeholder: (context, url) =>
                                                  SizedBox(
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        500)
                                                    ? (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                widget
                                                                    .itemPerRow -
                                                            8 *
                                                                widget
                                                                    .itemPerRow) /
                                                        (16 / 9)
                                                    : (widget.showSmallDescription ??
                                                            false)
                                                        ? height / (16 / 9) - 58
                                                        : width / (16 / 9) - 10,
                                                child:
                                                    const LoadingIndicatorUtil(
                                                  replaceImage: true,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      SizedBox(
                                                height: 50,
                                                child: Icon(
                                                  Icons.error_outlined,
                                                  color: useDarkMode
                                                      ? const Color(0xff1d1d28)
                                                      : Colors.white,
                                                ),
                                              ),
                                              fadeOutDuration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              fadeInDuration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              cacheManager: CacheManager(
                                                Config(
                                                  "newsImages",
                                                  stalePeriod:
                                                      const Duration(days: 5),
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
                                                    item.newsType ==
                                                        'Feature' ||
                                                    item.newsType ==
                                                        'Opinion' ||
                                                    item.newsType == 'Report'
                                                ? 110
                                                : item.newsType ==
                                                            'Technical' ||
                                                        item.newsType ==
                                                            'Live Blog' ||
                                                        item.newsType ==
                                                            'Interview'
                                                    ? 120
                                                    : item.newsType ==
                                                            'Image Gallery'
                                                        ? 150
                                                        : 90,
                                            height: 27,
                                            alignment: Alignment.bottomLeft,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 6,
                                                  ),
                                                  child: Icon(
                                                    item.newsType == 'Video'
                                                        ? Icons
                                                            .play_arrow_outlined
                                                        : item.newsType ==
                                                                'Image Gallery'
                                                            ? Icons
                                                                .image_outlined
                                                            : item.newsType ==
                                                                    'Podcast'
                                                                ? Icons
                                                                    .podcasts_outlined
                                                                : item.newsType ==
                                                                        'Poll'
                                                                    ? Icons
                                                                        .bar_chart
                                                                    : item.newsType ==
                                                                            'News'
                                                                        ? Icons
                                                                            .feed_outlined
                                                                        : item.newsType ==
                                                                                'Report'
                                                                            ? Icons.report_outlined
                                                                            : item.newsType == 'Interview'
                                                                                ? Icons.mic_outlined
                                                                                : item.newsType == 'Feature'
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      (widget.showSmallDescription ?? false)
                                          ? 3
                                          : 5,
                                  textAlign: TextAlign.justify,
                                ),
                                subtitle: (newsLayout != 'big' &&
                                            newsLayout != 'condensed') ||
                                        ((widget.showSmallDescription ??
                                                false) &&
                                            width < 1361)
                                    ? null
                                    : Text(
                                        item.subtitle,
                                        style: TextStyle(
                                          color: useDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[800],
                                        ),
                                        textAlign: TextAlign.justify,
                                        maxLines: width > 1360 ? 4 : 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                mouseCursor: SystemMouseCursors.click,
                              ),
                              width > 1360
                                  ? Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
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
                                                      Localizations.localeOf(
                                                              context)
                                                          .toString(),
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
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                          bottom: 5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                                locale: Localizations.localeOf(
                                                        context)
                                                    .toString(),
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
                                    ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
    );
  }
}

class NewsList extends StatefulWidget {
  final ScrollController? scrollController;
  final String? tagId;
  final String? articleType;

  const NewsList({
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    const String officialFeed = "https://api.formula1.com";
    Map latestNews = Hive.box('requests').get('news', defaultValue: {}) as Map;
    String savedServer = Hive.box('settings')
        .get('server', defaultValue: officialFeed) as String;
    return (_pagingController.error.toString() == 'XMLHttpRequest error.' ||
                _pagingController.error.toString() ==
                    "Failed host lookup: ${savedServer.replaceAll(
                          'http://',
                          '',
                        ).replaceAll(
                          'https://',
                          '',
                        )}" ||
                _pagingController.error.toString() ==
                    "Failed host lookup: '${savedServer.replaceAll(
                          'http://',
                          '',
                        ).replaceAll(
                          'https://',
                          '',
                        )}'") &&
            latestNews['items'] != null &&
            widget.tagId == null &&
            widget.articleType == null
        ? OfflineNewsList(
            items: F1NewsFetcher().formatResponse(latestNews),
            scrollController: widget.scrollController,
          )
        : width < 500
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
                    itemBuilder: (context, item, index) =>
                        NewsItem(item, false),
                    firstPageProgressIndicatorBuilder: (_) =>
                        const LoadingIndicatorUtil(),
                    firstPageErrorIndicatorBuilder: (_) =>
                        FirstPageExceptionIndicator(
                      title: AppLocalizations.of(context)!.errorOccurred,
                      message:
                          AppLocalizations.of(context)!.errorOccurredDetails,
                      onTryAgain: () => _pagingController.refresh(),
                    ),
                    newPageProgressIndicatorBuilder: (_) =>
                        const LoadingIndicatorUtil(),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 15),
                child: PagedGridView<int, News>(
                  pagingController: _pagingController,
                  scrollController: widget.scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width < 750 ? 2 : 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<News>(
                    itemBuilder: (context, item, index) {
                      return NewsItem(
                        item,
                        false,
                        showSmallDescription: true,
                        itemPerRow: width < 750 ? 2 : 3,
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        const LoadingIndicatorUtil(),
                    firstPageErrorIndicatorBuilder: (_) {
                      return FirstPageExceptionIndicator(
                        title: AppLocalizations.of(context)!.errorOccurred,
                        message:
                            AppLocalizations.of(context)!.errorOccurredDetails,
                        onTryAgain: () => _pagingController.refresh(),
                      );
                    },
                    newPageProgressIndicatorBuilder: (_) =>
                        const LoadingIndicatorUtil(),
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
    double width = MediaQuery.of(context).size.width;
    List<News> formatedNews = F1NewsFetcher().formatResponse(cachedNews);

    return width < 500
        ? ListView.builder(
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
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width < 750 ? 2 : 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
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
                    showSmallDescription: true,
                    itemPerRow: width < 750 ? 2 : 3,
                  ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class TextParagraphRenderer extends StatelessWidget {
  final String text;
  const TextParagraphRenderer(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String fontUsedInArticles = Hive.box('settings')
        .get('fontUsedInArticles', defaultValue: 'Formula1') as String;
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
          } else if (url ==
              "https://www.formula1.com/en/racing/${DateTime.now().year}.html") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      AppLocalizations.of(context)!.schedule,
                    ),
                  ),
                  body: const ScheduleScreen(),
                ),
              ),
            );
          } else if ((url
                      .startsWith("https://www.formula1.com/en/racing/202") ||
                  url.startsWith(
                      "https://www.formula1.com/content/fom-website/en/racing/202")) &&
              url.split('/').length > 5) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CircuitScreen(
                  Race(
                    '0',
                    '',
                    '',
                    '',
                    url.split('/').last.split('.')[0],
                    '',
                    '',
                    '',
                    [],
                  ),
                  isFetched: false,
                ),
              ),
            );
          } else if (url == 'https://e-m.media/f1/') {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.openingWithInAppBrowser,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            launchUrl(
              Uri.parse("https://raceprogramme.formula1.com/#/catalogue"),
            );
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        styleSheet: MarkdownStyleSheet(
          strong: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: fontUsedInArticles == 'Formula1' ? 16 : 20,
            fontWeight: FontWeight.w500,
          ),
          p: TextStyle(
            fontSize: fontUsedInArticles == 'Formula1' ? 14 : 18,
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
          ),
          pPadding: EdgeInsets.only(
            top: fontUsedInArticles == 'Formula1' ? 10 : 7,
            bottom: fontUsedInArticles == 'Formula1' ? 10 : 7,
          ),
          a: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.normal,
            fontFamily: fontUsedInArticles,
          ),
          h1: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
          ),
          h2: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
          ),
          h3: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
          ),
          h4: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
          ),
          listBullet: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontFamily: fontUsedInArticles,
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
                height: MediaQuery.of(context).size.width > 1000
                    ? 800
                    : MediaQuery.of(context).size.width / (16 / 9),
                child: const LoadingIndicatorUtil(
                  replaceImage: true,
                  borderRadius: false,
                ),
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
          : kIsWeb
              ? GestureDetector(
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
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: widget.isHero != null &&
                                                  widget.isHero!
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.imageUrl,
                                                  placeholder: (context, url) =>
                                                      SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            (16 / 9),
                                                    child:
                                                        const LoadingIndicatorUtil(
                                                      replaceImage: true,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(
                                                          Icons.error_outlined),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          seconds: 1),
                                                  fadeInDuration:
                                                      widget.isHero ?? false
                                                          ? const Duration(
                                                              milliseconds: 300)
                                                          : const Duration(
                                                              seconds: 1),
                                                  cacheManager: CacheManager(
                                                    Config(
                                                      "newsImages",
                                                      stalePeriod:
                                                          const Duration(
                                                              days: 7),
                                                    ),
                                                  ),
                                                )
                                              : Image(
                                                  image: NetworkImage(
                                                    widget.imageUrl,
                                                  ),
                                                  loadingBuilder: (context,
                                                          child,
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
                                                                  const LoadingIndicatorUtil(
                                                                replaceImage:
                                                                    true,
                                                              ),
                                                            ),
                                                  errorBuilder:
                                                      (context, url, error) =>
                                                          Icon(
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
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                                height: MediaQuery.of(context).size.width /
                                    (16 / 9),
                                child: const LoadingIndicatorUtil(
                                  replaceImage: true,
                                  borderRadius: false,
                                ),
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
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      loadingProgress == null
                                          ? child
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  (16 / 9),
                                              child: const LoadingIndicatorUtil(
                                                replaceImage: true,
                                                borderRadius: false,
                                              ),
                                            ),
                              errorBuilder: (context, url, error) => Icon(
                                Icons.error_outlined,
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
                                size: 30,
                              ),
                            ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: widget.caption != null && widget.caption != ''
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(4),
                                color: Colors.black.withOpacity(0.7),
                                child: Text(
                                  widget.caption!,
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
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.width / (16 / 9),
                  ),
                  child: GestureDetector(
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: widget.isHero != null &&
                                                    widget.isHero!
                                                ? CachedNetworkImage(
                                                    imageUrl: widget.imageUrl,
                                                    placeholder:
                                                        (context, url) =>
                                                            SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              (16 / 9),
                                                      child:
                                                          const LoadingIndicatorUtil(
                                                        replaceImage: true,
                                                        borderRadius: false,
                                                      ),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons
                                                            .error_outlined),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            seconds: 1),
                                                    fadeInDuration:
                                                        widget.isHero ?? false
                                                            ? const Duration(
                                                                milliseconds:
                                                                    300)
                                                            : const Duration(
                                                                seconds: 1),
                                                    cacheManager: CacheManager(
                                                      Config(
                                                        "newsImages",
                                                        stalePeriod:
                                                            const Duration(
                                                                days: 7),
                                                      ),
                                                    ),
                                                  )
                                                : Image(
                                                    image: NetworkImage(
                                                      widget.imageUrl,
                                                    ),
                                                    loadingBuilder: (context,
                                                            child,
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
                                                                    const LoadingIndicatorUtil(
                                                                  replaceImage:
                                                                      true,
                                                                  borderRadius:
                                                                      false,
                                                                ),
                                                              ),
                                                    errorBuilder:
                                                        (context, url, error) =>
                                                            Icon(
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                                  height: MediaQuery.of(context).size.width /
                                      (16 / 9),
                                  child: const LoadingIndicatorUtil(
                                    replaceImage: true,
                                    borderRadius: false,
                                  ),
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
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    loadingProgress == null
                                        ? child
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                (16 / 9),
                                            child: const LoadingIndicatorUtil(
                                              replaceImage: true,
                                              borderRadius: false,
                                            ),
                                          ),
                                errorBuilder: (context, url, error) => Icon(
                                  Icons.error_outlined,
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  size: 30,
                                ),
                              ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: widget.caption != null && widget.caption != ''
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.black.withOpacity(0.7),
                                  child: Text(
                                    widget.caption!,
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
                ),
    );
  }
}

class VideoRenderer extends StatelessWidget {
  final String videoId;
  final bool? autoplay;
  final String? youtubeId;
  final String? heroTag;
  final String? caption;

  const VideoRenderer(
    this.videoId, {
    Key? key,
    this.autoplay,
    this.youtubeId,
    this.heroTag,
    this.caption,
  }) : super(key: key);

  Future<Map<String, dynamic>> getYouTubeVideoLinks(String videoId) async {
    Map<String, dynamic> urls = {};
    urls['videos'] = [];
    YoutubeExplode yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var video = await yt.videos.get(videoId);

    urls['poster'] = 'https://img.youtube.com/vi/$videoId/0.jpg';
    urls['name'] = video.title;
    urls['author'] = video.author;

    for (var stream in manifest.muxed) {
      urls['videos'].add(stream.url.toString());
    }
    urls['videos'].add(manifest.muxed[1].url.toString());
    urls['videos'] = urls['videos'].reversed.toList();
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 800
        : width > 1000
            ? 500
            : 400;
    return FutureBuilder<Map<String, dynamic>>(
      future: (youtubeId ?? '') != ''
          ? getYouTubeVideoLinks(youtubeId!)
          : BrightCove().getVideoLinks(videoId),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
              snapshot.error.toString(),
            )
          : snapshot.hasData
              ? Column(
                  children: [
                    kIsWeb
                        ? SizedBox(
                            height: width / (16 / 9),
                            child: InAppWebView(
                              initialUrlRequest: URLRequest(
                                url: WebUri(
                                  snapshot.data!['videos'][0],
                                ),
                              ),
                              initialSettings: InAppWebViewSettings(
                                preferredContentMode:
                                    UserPreferredContentMode.DESKTOP,
                                transparentBackground: true,
                                iframeAllowFullscreen: true,
                                mediaPlaybackRequiresUserGesture:
                                    !(autoplay ?? false),
                              ),
                            ),
                          )
                        : BetterPlayerVideoPlayer(
                            snapshot.data!,
                            autoplay == null ? false : autoplay!,
                            heroTag ?? '',
                          ),
                    if (caption != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                          left: 10,
                          right: 10,
                        ),
                        child: Text(
                          caption!,
                          style: TextStyle(
                            color: useDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.width / (16 / 9),
                  child: const LoadingIndicatorUtil(
                    replaceImage: true,
                    borderRadius: false,
                  ),
                ),
    );
  }
}

class BetterPlayerVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> videoUrls;
  final bool autoplay;
  final String heroTag;

  const BetterPlayerVideoPlayer(
    this.videoUrls,
    this.autoplay,
    this.heroTag, {
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
      resolutions: widget.videoUrls['videos'].length == 4
          ? {
              '720p': widget.videoUrls['videos'][1],
              '360p': widget.videoUrls['videos'][2],
              '180p': widget.videoUrls['videos'][3],
            }
          : {
              '720p': widget.videoUrls['videos'][1],
              '360p': widget.videoUrls['videos'][2],
            },
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: widget.videoUrls['name'] ?? 'Video',
        author: widget.videoUrls['author'] ?? "Formula 1",
        imageUrl: widget.videoUrls['poster'],
        activityName: "MainActivity",
      ),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        maxBufferMs: 1000 * 30,
        bufferForPlaybackMs: 3000,
      ),
      headers: {
        'user-agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      },
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
    _betterPlayerController.addEventsListener(
      (event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          _setPlaceholderVisibleState(false);
        }
      },
    );
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
                  widget.heroTag != ''
                      ? Hero(
                          tag: widget.heroTag,
                          child: CachedNetworkImage(
                            imageUrl: widget.videoUrls['poster'],
                            placeholder: (context, url) => SizedBox(
                              height:
                                  MediaQuery.of(context).size.width / (16 / 9),
                              child: const LoadingIndicatorUtil(
                                replaceImage: true,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error_outlined,
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                            fadeOutDuration: const Duration(milliseconds: 100),
                            fadeInDuration: const Duration(seconds: 1),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.dstATop,
                              ),
                              image: NetworkImage(
                                widget.videoUrls['poster'],
                              ),
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
        color: useDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white,
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

class ImageGallery extends StatefulWidget {
  final List images;
  const ImageGallery(
    this.images, {
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          items: [
            for (var image in widget.images)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    ImageRenderer(
                      useDataSaverMode
                          ? image['renditions'] != null
                              ? image['renditions']['2col-retina']
                              : image['url'] +
                                  '.transform/2col-retina/image.jpg'
                          : image['url'],
                      caption: image['caption'] ?? '',
                    ),
                  ],
                ),
              ),
          ],
          options: CarouselOptions(
              viewportFraction: 1,
              aspectRatio: 16 / 9,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 7),
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var image in widget.images)
              Container(
                width: 6.0,
                height: 6.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (useDarkMode ? Colors.white : Colors.black).withOpacity(
                    _current == widget.images.indexOf(image) ? 0.9 : 0.4,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
