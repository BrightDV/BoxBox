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

import 'package:boxbox/Screens/MixedNews/rss_feed_article.dart';
import 'package:boxbox/api/rss.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class RssFeedScreen extends StatefulWidget {
  final String feedTitle;
  final String feedUrl;
  const RssFeedScreen(this.feedTitle, this.feedUrl, {Key? key})
      : super(key: key);

  @override
  State<RssFeedScreen> createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return Scaffold(
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.feedTitle,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: RssFeeds().getFeedArticles(
          widget.feedUrl,
        ),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(
                snapshot.error.toString(),
              )
            : snapshot.hasData
                ? RssFeedItemsList(snapshot)
                : const LoadingIndicatorUtil(),
      ),
    );
  }
}

class RssFeedItemsList extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final bool homeFeed;
  const RssFeedItemsList(this.snapshot, {this.homeFeed = false, super.key});

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
                  Uri.parse(""),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  "",
                );
        },
      );
    }

    return ListView.builder(
      itemCount: snapshot.data!['feedArticles'].length,
      shrinkWrap: true,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: useDarkMode ? const Color(0xff1d1d28) : Colors.white,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RssFeedArticleScreen(
                  snapshot.data!['feedArticles'][index].title!,
                  snapshot.data!['feedArticles'][index].link!.indexOf('?utm') ==
                          -1
                      ? snapshot.data!['feedArticles'][index].link!
                      : snapshot.data!['feedArticles'][index].link!.substring(
                          0,
                          snapshot.data!['feedArticles'][index].link!
                              .indexOf('?utm'),
                        ),
                ),
              ),
            ),
            onTapDown: (position) => storePosition(position),
            onLongPress: () {
              Feedback.forLongPress(context);
              showDetailsMenu();
            },
            child: Column(
              children: [
                newsLayout != 'condensed' &&
                        newsLayout != 'small' &&
                        (snapshot.data!['feedArticles'][index].enclosure !=
                                null ||
                            snapshot.data!['feedArticles'][index].media
                                .thumbnails.isNotEmpty ||
                            snapshot.data!['feedArticles'][index].media.contents
                                .isNotEmpty)
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: homeFeed
                            ? CachedNetworkImage(
                                imageUrl: snapshot.data!['feedArticles'][index]
                                            .enclosure !=
                                        null
                                    ? snapshot.data!['feedArticles'][index]
                                        .enclosure!.url!
                                    : snapshot.data!['feedArticles'][index]
                                            .media.thumbnails.isNotEmpty
                                        ? snapshot.data!['feedArticles'][index]
                                            .media.thumbnails[0].url
                                        : snapshot.data!['feedArticles'][index]
                                            .media.contents[0].url,
                                placeholder: (context, url) => const SizedBox(
                                  height: 90,
                                  child: LoadingIndicatorUtil(
                                    replaceImage: true,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error_outlined,
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
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
                                snapshot.data!['feedArticles'][index]
                                            .enclosure !=
                                        null
                                    ? snapshot.data!['feedArticles'][index]
                                        .enclosure!.url!
                                    : snapshot.data!['feedArticles'][index]
                                            .media.thumbnails.isNotEmpty
                                        ? snapshot.data!['feedArticles'][index]
                                            .media.thumbnails[0].url
                                        : snapshot.data!['feedArticles'][index]
                                            .media.contents[0].url,
                              ),
                      )
                    : const SizedBox(
                        height: 0.0,
                        width: 0.0,
                      ),
                ListTile(
                  title: Text(
                    snapshot.data!['feedArticles'][index].title!,
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
                      : homeFeed
                          ? Text(
                              snapshot.data!['feedArticles'][index].description!
                                          .indexOf("<a ") ==
                                      -1
                                  ? snapshot
                                      .data!['feedArticles'][index].description!
                                  : snapshot
                                      .data!['feedArticles'][index].description!
                                      .substring(
                                        0,
                                        snapshot.data!['feedArticles'][index]
                                            .description!
                                            .indexOf("<a "),
                                      )
                                      .replaceAll('<br>', ''),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[800],
                              ),
                            )
                          : MarkdownBody(
                              data: snapshot.data!['feedArticles'][index]
                                          .description!
                                          .indexOf("<a ") ==
                                      -1
                                  ? snapshot
                                      .data!['feedArticles'][index].description!
                                  : snapshot
                                      .data!['feedArticles'][index].description!
                                      .substring(
                                        0,
                                        snapshot.data!['feedArticles'][index]
                                            .description!
                                            .indexOf("<a "),
                                      )
                                      .replaceAll('<br>', ''),
                              styleSheet: MarkdownStyleSheet(
                                textAlign: WrapAlignment.spaceBetween,
                                p: TextStyle(
                                  color: useDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[800],
                                ),
                              ),
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
                          snapshot.data!['feedArticles'][index].pubDate!,
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
      ),
    );
  }
}
