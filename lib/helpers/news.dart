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

import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart' as bgdl;
import 'package:boxbox/api/brightcove.dart';
import 'package:boxbox/classes/article.dart';
import 'package:boxbox/helpers/custom_player_controls.dart';
import 'package:boxbox/helpers/download.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/providers/article/format.dart';
import 'package:boxbox/providers/article/requests.dart';
import 'package:boxbox/providers/videos/ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:river_player/river_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class NewsItem extends StatelessWidget {
  final News item;
  final bool inRelated;
  final bool? showSmallDescription;
  final double? width;
  final int itemPerRow;
  final String? articleChampionship;

  const NewsItem(
    this.item,
    this.inRelated, {
    Key? key,
    this.showSmallDescription,
    this.width,
    this.itemPerRow = 1,
    this.articleChampionship,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.imageUrl;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.openInBrowser,
                  style: TextStyle(
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
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.share,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(
                  Icons.copy_outlined,
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.copyTitle,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        position: RelativeRect.fromRect(
          tapPosition & const Size(40, 40),
          Offset.zero & overlay.semanticBounds.size,
        ),
      ).then<void>(
        (int? delta) {
          if (delta == null) return;
          if (delta == 0)
            launchUrl(
              Uri.parse(
                ArticleFormatProvider().formatShareUrl(
                  item.newsId,
                  item.slug,
                ),
              ),
              mode: LaunchMode.externalApplication,
            );
          else if (delta == 1)
            Share.share(
              ArticleFormatProvider().formatShareUrl(
                item.newsId,
                item.slug,
              ),
            );
          else {
            Clipboard.setData(ClipboardData(text: item.title));
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.copied,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
          ;
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => context.pushNamed(
                      'article',
                      pathParameters: {'id': item.newsId},
                      extra: {
                        'articleName': item.title,
                        'championshipOfArticle': articleChampionship ?? '',
                        'isFromLink': false,
                        'news': item,
                      },
                    ),
                    hoverColor: HSLColor.fromColor(
                      Theme.of(context).colorScheme.surface,
                    ).withLightness(0.4).toColor(),
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
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      placeholder: (context, url) =>
                                          const SizedBox(
                                        width: 300,
                                        child: LoadingIndicatorUtil(
                                          replaceImage: true,
                                          fullBorderRadius: false,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          ImageRequestErrorUtil(
                                        width: 300,
                                      ),
                                      fadeOutDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      fadeInDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      cacheManager: CacheManager(
                                        Config(
                                          "newsImages",
                                          stalePeriod: const Duration(days: 7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
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
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 300,
                                    child: LoadingIndicatorUtil(
                                      replaceImage: true,
                                      fullBorderRadius: false,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      ImageRequestErrorUtil(
                                    width: 300,
                                  ),
                                  fadeOutDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  fadeInDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  cacheManager: CacheManager(
                                    Config(
                                      "newsImages",
                                      stalePeriod: const Duration(days: 7),
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  item.title,
                                  style: TextStyle(
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
                color: Theme.of(context).colorScheme.surface,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => context.pushNamed(
                      'article',
                      pathParameters: {'id': item.newsId},
                      extra: {
                        'articleName': item.title,
                        'championshipOfArticle': articleChampionship ?? '',
                        'isFromLink': false,
                        'news': item,
                      },
                    ),
                    hoverColor: HSLColor.fromColor(
                      Theme.of(context).colorScheme.surface,
                    ).withLightness(0.4).toColor(),
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
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                placeholder: (context, url) =>
                                                    SizedBox(
                                                  height: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width >
                                                          500)
                                                      ? null
                                                      : (showSmallDescription ??
                                                              false)
                                                          ? height / (16 / 9) -
                                                              58
                                                          : width / (16 / 9) -
                                                              10,
                                                  child:
                                                      const LoadingIndicatorUtil(
                                                    replaceImage: true,
                                                    fullBorderRadius: false,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        ImageRequestErrorUtil(
                                                  height: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width >
                                                          500)
                                                      ? (MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  itemPerRow -
                                                              8 * itemPerRow) /
                                                          (16 / 9)
                                                      : (showSmallDescription ??
                                                              false)
                                                          ? height / (16 / 9) -
                                                              58
                                                          : width / (16 / 9) -
                                                              10,
                                                ),
                                                fadeOutDuration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                fadeInDuration: const Duration(
                                                  milliseconds: 300,
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
                                            item.newsType != ''
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8,
                                                    ),
                                                    child: Container(
                                                      width: item.isBreaking !=
                                                                  null &&
                                                              item.isBreaking ==
                                                                  true
                                                          ? 215
                                                          : item
                                                                          .newsType ==
                                                                      'Podcast' ||
                                                                  item.newsType ==
                                                                      'Feature' ||
                                                                  item.newsType ==
                                                                      'Opinion' ||
                                                                  item.newsType ==
                                                                      'Report' ||
                                                                  item.newsType ==
                                                                      'Preview'
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
                                                                      ? 155
                                                                      : 90,
                                                      height: 27,
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  3),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  3),
                                                        ),
                                                        color: item.isBreaking !=
                                                                    null &&
                                                                item.isBreaking ==
                                                                    true
                                                            ? useDarkMode
                                                                ? Color(
                                                                    0xFF998400,
                                                                  )
                                                                : Color(
                                                                    0xFFffdd01,
                                                                  )
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 6,
                                                            ),
                                                            child: item.isBreaking !=
                                                                        null &&
                                                                    item.isBreaking ==
                                                                        true
                                                                ? SizedBox(
                                                                    width: 24.0,
                                                                    height:
                                                                        24.0,
                                                                    child:
                                                                        LoadingIndicator(
                                                                      indicatorType:
                                                                          Indicator
                                                                              .ballScaleMultiple,
                                                                      colors: [
                                                                        useDarkMode
                                                                            ? Colors.white
                                                                            : Colors.grey.shade700
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Icon(
                                                                    item.newsType ==
                                                                            'Video'
                                                                        ? Icons
                                                                            .play_arrow_outlined
                                                                        : item.newsType ==
                                                                                'Image Gallery'
                                                                            ? Icons.image_outlined
                                                                            : item.newsType == 'Podcast'
                                                                                ? Icons.podcasts_outlined
                                                                                : item.newsType == 'Poll'
                                                                                    ? Icons.bar_chart
                                                                                    : item.newsType == 'News'
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
                                                                                                                : item.newsType == 'Preview'
                                                                                                                    ? Icons.remove_red_eye_outlined
                                                                                                                    : Icons.info_outlined,
                                                                    size: 24,
                                                                  ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 5,
                                                            ),
                                                            child: Text(
                                                              item.isBreaking !=
                                                                          null &&
                                                                      item.isBreaking ==
                                                                          true
                                                                  ? 'BREAKING NEWS'
                                                                  : item
                                                                      .newsType,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 6,
                                                            ),
                                                            child: item.isBreaking !=
                                                                        null &&
                                                                    item.isBreaking ==
                                                                        true
                                                                ? SizedBox(
                                                                    width: 24.0,
                                                                    height:
                                                                        24.0,
                                                                    child:
                                                                        LoadingIndicator(
                                                                      indicatorType:
                                                                          Indicator
                                                                              .ballScaleMultiple,
                                                                      colors: [
                                                                        useDarkMode
                                                                            ? Colors.white
                                                                            : Colors.grey.shade700
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    height: 0.0,
                                                    width: 0.0,
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: (showSmallDescription ?? false)
                                          ? 3
                                          : 5,
                                      textAlign: TextAlign.justify,
                                    ),
                                    subtitle: (newsLayout != 'big' &&
                                                newsLayout != 'condensed') ||
                                            ((showSmallDescription ?? false) &&
                                                width < 1361)
                                        ? null
                                        : Text(
                                            item.subtitle,
                                            textAlign: TextAlign.justify,
                                            maxLines: width > 1360 ? 3 : 5,
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
                                                              itemPerRow -
                                                          8 * itemPerRow) /
                                                      (16 / 9)
                                                  : (showSmallDescription ??
                                                          false)
                                                      ? height / (16 / 9) - 58
                                                      : width / (16 / 9) - 5,
                                              child: const LoadingIndicatorUtil(
                                                replaceImage: true,
                                                fullBorderRadius: false,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    ImageRequestErrorUtil(
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      500)
                                                  ? (MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              itemPerRow -
                                                          8 * itemPerRow) /
                                                      (16 / 9)
                                                  : (showSmallDescription ??
                                                          false)
                                                      ? height / (16 / 9) - 58
                                                      : width / (16 / 9) - 5,
                                            ),
                                            fadeOutDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            fadeInDuration: const Duration(
                                              milliseconds: 300,
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
                                        item.newsType != ''
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Container(
                                                  width: item.isBreaking != null &&
                                                          item.isBreaking ==
                                                              true
                                                      ? 215
                                                      : item.newsType ==
                                                                  'Podcast' ||
                                                              item.newsType ==
                                                                  'Feature' ||
                                                              item.newsType ==
                                                                  'Opinion' ||
                                                              item.newsType ==
                                                                  'Report' ||
                                                              item.newsType ==
                                                                  'Preview'
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
                                                                  ? 155
                                                                  : 90,
                                                  height: 27,
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(3),
                                                      topRight:
                                                          Radius.circular(8),
                                                      bottomRight:
                                                          Radius.circular(3),
                                                    ),
                                                    color: item.isBreaking !=
                                                                null &&
                                                            item.isBreaking ==
                                                                true
                                                        ? useDarkMode
                                                            ? Color(
                                                                0xFF998400,
                                                              )
                                                            : Color(
                                                                0xFFffdd01,
                                                              )
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 6,
                                                        ),
                                                        child: item.isBreaking !=
                                                                    null &&
                                                                item.isBreaking ==
                                                                    true
                                                            ? SizedBox(
                                                                width: 24.0,
                                                                height: 24.0,
                                                                child:
                                                                    LoadingIndicator(
                                                                  indicatorType:
                                                                      Indicator
                                                                          .ballScaleMultiple,
                                                                  colors: [
                                                                    useDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey
                                                                            .shade700
                                                                  ],
                                                                ),
                                                              )
                                                            : Icon(
                                                                item.newsType ==
                                                                        'Video'
                                                                    ? Icons
                                                                        .play_arrow_outlined
                                                                    : item.newsType ==
                                                                            'Image Gallery'
                                                                        ? Icons
                                                                            .image_outlined
                                                                        : item.newsType ==
                                                                                'Podcast'
                                                                            ? Icons.podcasts_outlined
                                                                            : item.newsType == 'Poll'
                                                                                ? Icons.bar_chart
                                                                                : item.newsType == 'News'
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
                                                                                                            : item.newsType == 'Preview'
                                                                                                                ? Icons.remove_red_eye_outlined
                                                                                                                : Icons.info_outlined,
                                                                size: 24,
                                                              ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 5,
                                                        ),
                                                        child: Text(
                                                          item.isBreaking !=
                                                                      null &&
                                                                  item.isBreaking ==
                                                                      true
                                                              ? 'BREAKING NEWS'
                                                              : item.newsType,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 6,
                                                        ),
                                                        child: item.isBreaking !=
                                                                    null &&
                                                                item.isBreaking ==
                                                                    true
                                                            ? SizedBox(
                                                                width: 24.0,
                                                                height: 24.0,
                                                                child:
                                                                    LoadingIndicator(
                                                                  indicatorType:
                                                                      Indicator
                                                                          .ballScaleMultiple,
                                                                  colors: [
                                                                    useDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey
                                                                            .shade700
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 0.0,
                                                width: 0.0,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      (showSmallDescription ?? false) ? 3 : 5,
                                  textAlign: TextAlign.justify,
                                ),
                                subtitle: (newsLayout != 'big' &&
                                            newsLayout != 'condensed') ||
                                        ((showSmallDescription ?? false) &&
                                            width < 1361)
                                    ? null
                                    : Text(
                                        item.subtitle,
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
      List<News> newItems = await ArticleRequestsProvider().getPageArticles(
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
    Map latestNews = ArticleRequestsProvider().getSavedArticles();

    return (_pagingController.error.toString() == 'XMLHttpRequest error.' ||
                _pagingController.error
                    .toString()
                    .toLowerCase()
                    .contains('failed host lookup')) &&
            (latestNews.isNotEmpty) &&
            widget.tagId == null &&
            widget.articleType == null
        ? OfflineNewsList(
            items: ArticleFormatProvider().formatNewsItems(latestNews),
            scrollController: widget.scrollController,
          )
        : width < 576
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
                      pagingController: _pagingController,
                    ),
                    newPageProgressIndicatorBuilder: (_) =>
                        const LoadingIndicatorUtil(),
                  ),
                ),
              )
            : PagedGridView<int, News>(
                padding: EdgeInsets.only(
                  left: width > 1360
                      ? (width - 1320) / 2.5
                      : width > 1024
                          ? (width - 986) / 2.5
                          : width > 768
                              ? (width - 750) / 2.5
                              : width > 576
                                  ? (width - 576) / 2.5
                                  : width,
                  right: width > 1360
                      ? (width - 1320) / 2.5
                      : width > 1024
                          ? (width - 986) / 2.5
                          : width > 768
                              ? (width - 750) / 2.5
                              : width > 576
                                  ? (width - 576) / 2.5
                                  : width,
                  top: 15,
                ),
                pagingController: _pagingController,
                scrollController: widget.scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width < 850 ? 2 : 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                builderDelegate: PagedChildBuilderDelegate<News>(
                  itemBuilder: (context, item, index) {
                    return NewsItem(
                      item,
                      false,
                      showSmallDescription: true,
                      itemPerRow: width < 850 ? 2 : 3,
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) =>
                      const LoadingIndicatorUtil(),
                  firstPageErrorIndicatorBuilder: (_) {
                    return FirstPageExceptionIndicator(
                      title: AppLocalizations.of(context)!
                          .errorOccurred, //AppLocalizations.of(context)!.errorOccurred,
                      message:
                          AppLocalizations.of(context)!.errorOccurredDetails,
                      onTryAgain: () => _pagingController.refresh(),
                    );
                  },
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

class OfflineNewsList extends StatelessWidget {
  final List<News> items;
  final ScrollController? scrollController;

  const OfflineNewsList({
    required this.items,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return width < 576
        ? ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) => index == items.length - 1
                ? const Padding(
                    padding: EdgeInsets.all(15),
                  )
                : NewsItem(
                    items[index],
                    false,
                  ),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width < 750 ? 2 : 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            controller: scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) => index == items.length - 1
                ? const Padding(
                    padding: EdgeInsets.all(15),
                  )
                : NewsItem(
                    items[index],
                    false,
                    showSmallDescription: true,
                    itemPerRow: width < 750 ? 2 : 3,
                  ),
          );
  }
}

class TextParagraphRenderer extends StatelessWidget {
  final String text;

  const TextParagraphRenderer(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        fitContent: false,
        onTapLink: (text, url, title) {
          if (url!.startsWith('https://www.formula1.com/en/latest/article.')) {
            String articleId = url.substring(43, url.length - 5).split('.')[1];
            context.pushNamed(
              'article',
              pathParameters: {'id': articleId},
              extra: {
                'articleName': text,
                'championshipOfArticle': 'Formula 1',
                'isFromLink': true,
              },
            );
          } else if (url
              .startsWith('https://www.formula1.com/en/latest/article/')) {
            String articleId = url.split('.').last;
            context.pushNamed(
              'article',
              pathParameters: {'id': articleId},
              extra: {
                'articleName': text,
                'championshipOfArticle': 'Formula 1',
                'isFromLink': true,
              },
            );
          } else if (url.startsWith('https://www.formula1.com/en/drivers/')) {
            String driverId = url.split('/')[5];
            context.pushNamed(
              'drivers',
              pathParameters: {'driverId': driverId},
            );
          } else if (url.startsWith('https://www.formula1.com/en/teams/')) {
            String teamId = url.split('/')[5];
            context.pushNamed(
              'teams',
              pathParameters: {'teamId': teamId},
            );
          } else if (url.startsWith('https://www.formula1.com/en/results')) {
            String standingsType =
                url.substring(0, url.length - 5).split('/')[6];
            if (standingsType == "driver-standings" ||
                standingsType == "drivers") {
              context.pushNamed("standings");
            } else if (standingsType == "constructor-standings" ||
                standingsType == "team") {
              context.pushNamed(
                "standings",
                extra: {"switchToTeamStandings": true},
              );
            } else {
              launchUrl(Uri.parse(url));
            }
          } else if (url ==
              "https://www.formula1.com/en/racing/${DateTime.now().year}.html") {
            context.pushNamed("schedule");
          } else if ((url
                      .startsWith("https://www.formula1.com/en/racing/202") ||
                  url.startsWith(
                      "https://www.formula1.com/content/fom-website/en/racing/202")) &&
              url.split('/').length > 5) {
            context.pushNamed(
              'racing',
              pathParameters: {'meetingId': url.split('/').last.split('.')[0]},
            );
          } else if (url == 'https://linktr.ee/F1raceprogramme') {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.openingWithInAppBrowser,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            launchUrl(
              Uri.parse("https://web.formula1rp.com/"),
            );
          } else if (url.startsWith('https://www.fiaformulae.com/en/news/')) {
            String articleId = url.split('/').last;
            context.pushNamed(
              'article',
              pathParameters: {'id': articleId},
              extra: {
                'articleName': text,
                'championshipOfArticle': 'Formula E',
                'isFromLink': true,
              },
            );
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        styleSheet: MarkdownStyleSheet(
          strong: TextStyle(
            fontSize: fontUsedInArticles == 'Formula1' ? 16 : 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
          p: TextStyle(
            fontSize: fontUsedInArticles == 'Formula1' ? 14 : 18,
            fontFamily: fontUsedInArticles,
          ),
          pPadding: EdgeInsets.only(
            top: fontUsedInArticles == 'Formula1' ? 10 : 7,
            bottom: fontUsedInArticles == 'Formula1' ? 10 : 7,
          ),
          a: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.normal,
            fontFamily: fontUsedInArticles,
          ),
          h1: TextStyle(
            fontFamily: fontUsedInArticles,
          ),
          h2: TextStyle(
            fontFamily: fontUsedInArticles,
          ),
          h3: TextStyle(
            fontFamily: fontUsedInArticles,
          ),
          h4: TextStyle(
            fontFamily: fontUsedInArticles,
          ),
          listBullet: TextStyle(
            fontFamily: fontUsedInArticles,
          ),
          textAlign: WrapAlignment.spaceBetween,
        ),
      ),
    );
  }
}

class ImageRenderer extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final bool? inSchedule;
  final bool? isHero;
  final bool? isPodcastPreview;

  const ImageRenderer(
    this.imageUrl, {
    Key? key,
    this.caption,
    this.inSchedule,
    this.isHero,
    this.isPodcastPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 450
        : width > 1000
            ? 500
            : width;
    return Padding(
      padding: EdgeInsets.only(
        bottom: inSchedule != null || isPodcastPreview != null ? 0 : 10,
      ),
      child: inSchedule != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => SizedBox(
                height: MediaQuery.of(context).size.width > 1000
                    ? 800
                    : MediaQuery.of(context).size.width / (16 / 9),
                child: const LoadingIndicatorUtil(
                  replaceImage: true,
                  fullBorderRadius: false,
                  borderRadius: false,
                ),
              ),
              errorWidget: (context, url, error) => ImageRequestErrorUtil(
                height: MediaQuery.of(context).size.width > 1000
                    ? 800
                    : MediaQuery.of(context).size.width / (16 / 9),
              ),
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeInDuration: const Duration(milliseconds: 300),
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
                                        child: isHero != null && isHero!
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                placeholder: (context, url) =>
                                                    SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      (16 / 9),
                                                  child:
                                                      const LoadingIndicatorUtil(
                                                    replaceImage: true,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        ImageRequestErrorUtil(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      (16 / 9),
                                                ),
                                                fadeOutDuration:
                                                    const Duration(seconds: 1),
                                                fadeInDuration: isHero ?? false
                                                    ? const Duration(
                                                        milliseconds: 300,
                                                      )
                                                    : const Duration(
                                                        seconds: 1,
                                                      ),
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
                                                  imageUrl,
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
                                                                const LoadingIndicatorUtil(
                                                              replaceImage:
                                                                  true,
                                                            ),
                                                          ),
                                                errorBuilder:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error_outlined,
                                                  size: 30,
                                                ),
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(
                                            Icons.close_rounded,
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
                      isHero != null && isHero!
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => SizedBox(
                                height: width,
                                child: const LoadingIndicatorUtil(
                                  replaceImage: true,
                                  borderRadius: false,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  ImageRequestErrorUtil(),
                              fadeOutDuration: const Duration(
                                milliseconds: 300,
                              ),
                              fadeInDuration: const Duration(milliseconds: 300),
                              cacheManager: CacheManager(
                                Config(
                                  "newsImages",
                                  stalePeriod: const Duration(days: 7),
                                ),
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      loadingProgress == null
                                          ? child
                                          : SizedBox(
                                              height: width / (16 / 9),
                                              child: const LoadingIndicatorUtil(
                                                replaceImage: true,
                                                borderRadius: false,
                                              ),
                                            ),
                              errorBuilder: (context, url, error) => Icon(
                                Icons.error_outlined,
                                size: 30,
                              ),
                            ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: caption != null && caption != ''
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(4),
                                color: Colors.black.withOpacity(0.7),
                                child: Text(
                                  caption!,
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
              : SizedBox(
                  height: (isPodcastPreview ?? false)
                      ? null
                      : MediaQuery.of(context).size.width / (16 / 9),
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
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              placeholder: (context, url) =>
                                                  SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    (16 / 9),
                                                child:
                                                    const LoadingIndicatorUtil(
                                                  replaceImage: true,
                                                  borderRadius: false,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      ImageRequestErrorUtil(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    (16 / 9),
                                              ),
                                              fadeOutDuration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              fadeInDuration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              cacheManager: CacheManager(
                                                Config(
                                                  "newsImages",
                                                  stalePeriod: Duration(
                                                    days:
                                                        isHero ?? false ? 7 : 1,
                                                  ),
                                                ),
                                              ),
                                            )),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(
                                              Icons.close_rounded,
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
                    child: caption != null && caption != ''
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) => SizedBox(
                                  height: MediaQuery.of(context).size.width /
                                      (16 / 9),
                                  child: const LoadingIndicatorUtil(
                                    replaceImage: true,
                                    borderRadius: false,
                                    fullBorderRadius: false,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    ImageRequestErrorUtil(
                                  height: MediaQuery.of(context).size.width /
                                      (16 / 9),
                                ),
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                cacheManager: CacheManager(
                                  Config(
                                    "newsImages",
                                    stalePeriod: const Duration(days: 1),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.black.withOpacity(0.7),
                                  child: Text(
                                    caption!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) => SizedBox(
                              child: const LoadingIndicatorUtil(
                                replaceImage: true,
                                borderRadius: false,
                                fullBorderRadius: false,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                ImageRequestErrorUtil(),
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeInDuration: const Duration(milliseconds: 300),
                            cacheManager: CacheManager(
                              Config(
                                "newsImages",
                                stalePeriod: const Duration(days: 1),
                              ),
                            ),
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
  final String? youtubeThumbnail;
  final String? heroTag;
  final String? caption;
  final Function? update;
  final String? player;
  final String? articleChampionship;

  const VideoRenderer(
    this.videoId, {
    Key? key,
    this.autoplay,
    this.youtubeId,
    this.youtubeThumbnail,
    this.heroTag,
    this.caption,
    this.update,
    this.player,
    this.articleChampionship,
  }) : super(key: key);

  /*  Future<Map<String, dynamic>> getYouTubeVideoLinks(String videoId) async {
    String playerQuality =
        "${Hive.box('settings').get('playerQuality', defaultValue: 360) as int}p";
    String pipedApiUrl = Hive.box('settings')
        .get('pipedApiUrl', defaultValue: 'pipedapi.kavin.rocks') as String;
    // 144p is not available as a muxed stream
    if (playerQuality == '180p') {
      playerQuality = '360p';
    }
    String defaultUrl = '';
    Map<String, dynamic> urls = {};
    urls['videos'] = [];
    urls['qualities'] = [];
    Response response = await get(
      Uri.parse("https://$pipedApiUrl/streams/$videoId"),
    );
    Map videoDetails = json.decode(utf8.decode(response.bodyBytes));

    urls['poster'] = videoDetails['thumbnailUrl'];
    urls['name'] = videoDetails['title'];
    urls['author'] = videoDetails['uploader'];
    // audio stream -> 1 = 126 kbps (m4a)
    urls['audioTrack'] = videoDetails['audioStreams'][1];
    for (var stream in videoDetails['videoStreams']) {
      if ((stream['format'] == "MPEG_4") &&
          (!urls['qualities'].contains(stream['quality'])) &&
          (stream['videoOnly'] == false)) {
        urls['videos'].add(stream['url']);
        urls['qualities'].add(stream['quality']);
        if (stream['quality'] == playerQuality) {
          defaultUrl = stream['url'];
        }
      }
    }

    urls['videos'] = urls['videos'].reversed.toList();
    urls['qualities'] = urls['qualities'].reversed.toList();

    urls['videos'].insert(0, defaultUrl);
    return urls;
  }
 */

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 800
        : width > 1000
            ? 500
            : 400;
    return (youtubeId ?? '') != ''
        ? Stack(
            children: [
              CachedNetworkImage(
                imageUrl: youtubeThumbnail!,
                placeholder: (context, url) => SizedBox(
                  height: MediaQuery.of(context).size.width / (16 / 9),
                  child: const LoadingIndicatorUtil(
                    replaceImage: true,
                    fullBorderRadius: false,
                    borderRadius: false,
                  ),
                ),
                errorWidget: (context, url, error) => ImageRequestErrorUtil(
                  height: MediaQuery.of(context).size.width / (16 / 9),
                ),
                fadeOutDuration: const Duration(milliseconds: 100),
                fadeInDuration: const Duration(milliseconds: 100),
                colorBlendMode: BlendMode.darken,
                color: Colors.black.withOpacity(0.5),
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async => await launchUrl(
                    Uri.parse('https://youtube.com/watch?v=$youtubeId!'),
                    mode: LaunchMode.externalApplication,
                  ),
                  label: Padding(
                    padding: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                    child: Text(AppLocalizations.of(context)!.watchOnYouTube),
                  ),
                  icon: Padding(
                    padding: EdgeInsets.only(top: 15, left: 10, bottom: 15),
                    child: Icon(
                      Icons.play_arrow_outlined,
                      size: 28,
                    ),
                  ),
                ),
              )
            ],
          )
        : FutureBuilder<Map<String, dynamic>>(
            future: BrightCove().getVideoLinks(
              videoId,
              player: player,
              articleChampionship: articleChampionship,
            ),
            builder: (context, snapshot) => snapshot.hasError
                ? SizedBox(
                    height: kIsWeb
                        ? width / (16 / 9)
                        : MediaQuery.of(context).size.width / (16 / 9),
                    child: Center(
                      child: RequestErrorWidget(
                        snapshot.error.toString(),
                      ),
                    ),
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
                                  videoId,
                                  autoplay == null ? false : autoplay!,
                                  heroTag ?? '',
                                  Theme.of(context).colorScheme.surface,
                                  (youtubeId ?? '') != '',
                                  update: update,
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .color,
                                ),
                              ),
                            ),
                        ],
                      )
                    : SizedBox(
                        height: kIsWeb
                            ? width / (16 / 9)
                            : MediaQuery.of(context).size.width / (16 / 9),
                        child: const Center(
                          child: LoadingIndicatorUtil(
                            replaceImage: true,
                            fullBorderRadius: false,
                            borderRadius: false,
                          ),
                        ),
                      ),
          );
  }
}

class BetterPlayerVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> videoUrls;
  final String videoId;
  final bool autoplay;
  final String heroTag;
  final Color primaryColor;
  final bool isFromYouTube;
  final Function? update;

  const BetterPlayerVideoPlayer(
    this.videoUrls,
    this.videoId,
    this.autoplay,
    this.heroTag,
    this.primaryColor,
    this.isFromYouTube, {
    Key? key,
    this.update,
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

  void updateWithType(bgdl.TaskStatusUpdate statusUpdate) {
    if (statusUpdate.status == bgdl.TaskStatus.complete) {
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );

      DownloadUtils().downloadedFilePathIfExists(statusUpdate.task.taskId).then(
        (path) {
          Map details = json.decode(statusUpdate.task.metaData);
          downloadsDescriptions[statusUpdate.task.taskId] = {
            'id': details['id'],
            'type': 'video',
            'title': details['title'],
            'thumbnail': details['thumbnail'],
            'url': details['url'],
            'description': details['description'],
            'videoDuration': details['videoDuration'],
            'datePosted': details['datePosted'],
            'fileSize': details['fileSize'],
          };
          Hive.box('downloads').put(
            'downloadsDescriptions',
            downloadsDescriptions,
          );
          List downloads = Hive.box('downloads').get(
            'downloadsList',
            defaultValue: [],
          );
          downloads.insert(0, 'video_f1_${details['id']}');
          Hive.box('downloads').put('downloadsList', downloads);
          if (widget.update != null) {
            widget.update!();
          }
        },
      );
    } else if ((statusUpdate.status == bgdl.TaskStatus.canceled) ||
        (statusUpdate.status == bgdl.TaskStatus.failed)) {
      bgdl.FileDownloader()
          .database
          .deleteRecordWithId(statusUpdate.task.taskId);
    }
  }

  Future<void> downloadVideo(
      String videoId, String caption, String thumbnail) async {
    String? quality = await DownloadUtils().videoDownloadQualitySelector(
      context,
    );
    if (quality != null) {
      String downloadingState = await DownloadUtils().downloadVideo(
        widget.videoId,
        quality,
        callback: updateWithType,
      );
      if (downloadingState == "downloading") {
        if (widget.update != null) {
          widget.update!();
        }
        await Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.downloading,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        if (downloadingState == "downloading") {
          await Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.alreadyDownloading,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          await Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.errorOccurred,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoUrls['file'] != null) {
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        widget.videoUrls['file'],
      );

      BetterPlayerControlsConfiguration controlsConfiguration =
          BetterPlayerControlsConfiguration(
        enableAudioTracks: false,
        enableSubtitles: false,
        overflowModalColor: widget.primaryColor,
        overflowMenuIconsColor: useDarkMode ? Colors.white : Colors.black,
        overflowModalTextColor: useDarkMode ? Colors.white : Colors.black,
        showControlsOnInitialize: false,
        enableQualities: false,
      );

      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
        autoPlay: widget.autoplay,
        allowedScreenSleep: false,
        autoDetectFullscreenDeviceOrientation: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          customControlsBuilder: (controller, onPlayerVisibilityChanged) =>
              CustomControls(
            onControlsVisibilityChanged: onPlayerVisibilityChanged,
            controlsConfiguration: controlsConfiguration,
            isOffline: true,
            title: widget.videoUrls['name'],
          ),
          playerTheme: BetterPlayerTheme.custom,
        ),
        placeholder: _buildVideoPlaceholder(),
        showPlaceholderUntilPlay: true,
      );

      // setup the controller
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource,
      );

      // add event listener for the placeholder
      _betterPlayerController.addEventsListener(
        (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            _setPlaceholderVisibleState(false);
          }
        },
      );
    } else {
      Map<String, String>? qualities = {};
      int c = 0;
      for (c; c < widget.videoUrls['qualities'].length; c++) {
        String quality = widget.videoUrls['qualities'][c];
        qualities[quality] = widget.videoUrls['videos'][c + 1];
      }
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrls['videos'][0],
        resolutions: qualities,
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          maxBufferMs: 1000 * 30,
          bufferForPlaybackMs: 3000,
        ),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: false,
          preCacheSize: 0,
        ),
        headers: {
          'user-agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
        },
      );
      BetterPlayerControlsConfiguration controlsConfiguration =
          BetterPlayerControlsConfiguration(
        enableAudioTracks: false,
        enableSubtitles: false,
        overflowModalColor: widget.primaryColor,
        overflowMenuIconsColor: useDarkMode ? Colors.white : Colors.black,
        overflowModalTextColor: useDarkMode ? Colors.white : Colors.black,
        showControlsOnInitialize: false,
        overflowMenuCustomItems: VideosUIProvider().getPlayerTopBarActions(
          downloadVideo,
          widget.videoId,
          widget.videoUrls['name'],
          widget.videoUrls['poster'],
        ),
      );

      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
        autoPlay: widget.autoplay,
        allowedScreenSleep: false,
        autoDetectFullscreenDeviceOrientation: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          customControlsBuilder: (controller, onPlayerVisibilityChanged) =>
              CustomControls(
            onControlsVisibilityChanged: onPlayerVisibilityChanged,
            controlsConfiguration: controlsConfiguration,
            isOffline: false,
            title: widget.videoUrls['name'],
          ),
          playerTheme: BetterPlayerTheme.custom,
        ),
        placeholder: _buildVideoPlaceholder(),
        showPlaceholderUntilPlay: true,
      );

      // setup the controller
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource,
      );

      // add event listener for the placeholder
      _betterPlayerController.addEventsListener(
        (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            _setPlaceholderVisibleState(false);
          }
        },
      );
    }
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
                  Align(
                    alignment: Alignment.center,
                    child: widget.videoUrls['poster'] != null
                        ? CachedNetworkImage(
                            imageUrl: widget.videoUrls['poster'],
                            placeholder: (context, url) => SizedBox(
                              height:
                                  MediaQuery.of(context).size.width / (16 / 9),
                              child: const LoadingIndicatorUtil(
                                replaceImage: true,
                                fullBorderRadius: false,
                                borderRadius: false,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                ImageRequestErrorUtil(
                              height:
                                  MediaQuery.of(context).size.width / (16 / 9),
                            ),
                            fadeOutDuration: const Duration(milliseconds: 100),
                            fadeInDuration: const Duration(milliseconds: 100),
                          )
                        : SizedBox(
                            height:
                                MediaQuery.of(context).size.width / (16 / 9),
                            child: const LoadingIndicatorUtil(
                              replaceImage: true,
                              fullBorderRadius: false,
                              borderRadius: false,
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
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
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
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;

    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          items: [
            for (var image in widget.images)
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width / (16 / 9),
                ),
                child: ImageRenderer(
                  useDataSaverMode
                      ? image['renditions'] != null
                          ? image['renditions']['2col-retina']
                          : image['url'] + '.transform/2col-retina/image.jpg'
                      : image['url'],
                  caption: image['caption'] ?? '',
                ),
              ),
          ],
          options: CarouselOptions(
              viewportFraction: 1,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(
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
