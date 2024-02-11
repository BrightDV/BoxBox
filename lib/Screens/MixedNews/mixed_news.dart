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

import 'package:boxbox/Screens/MixedNews/edit_order.dart';
import 'package:boxbox/Screens/MixedNews/rss_feed.dart';
import 'package:boxbox/Screens/MixedNews/rss_feed_article.dart';
import 'package:boxbox/Screens/MixedNews/wordpress.dart';
import 'package:boxbox/api/mixed_news.dart';
import 'package:boxbox/api/rss.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class MixedNewsScreen extends StatefulWidget {
  const MixedNewsScreen({Key? key}) : super(key: key);

  @override
  State<MixedNewsScreen> createState() => _MixedNewsScreenState();
}

class _MixedNewsScreenState extends State<MixedNewsScreen> {
  void updateParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useMergedFeeds =
        Hive.box('feeds').get('mergedFeeds', defaultValue: false) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    double width = MediaQuery.of(context).size.width;
    List feeds = Hive.box('feeds').get(
      'feedsNames',
      defaultValue: [
        'WTF1.com',
        'Racefans.net',
        //'Beyondtheflag.com', // disabled for the moment
        'Motorsport.com',
        'Autosport.com',
        'GPFans.com',
        'Racer.com',
        'Thecheckeredflag.co.uk',
        'Motorsportweek.com',
        'Crash.net',
        'Pitpass.com',
      ],
    ) as List;
    Map<String, dynamic> feedsUrl = {
      'WTF1.com': 'https://wtf1.com',
      'Racefans.net': 'https://racefans.net',
      //'Beyondtheflag.com': 'https://beyondtheflag.com',
      'Motorsport.com': 'https://www.motorsport.com/rss/f1/news/',
      'Autosport.com': 'https://www.autosport.com/rss/f1/news/',
      'GPFans.com': 'https://www.gpfans.com/en/rss.xml',
      'Racer.com': 'https://racer.com/f1/feed/',
      'Thecheckeredflag.co.uk':
          'https://www.thecheckeredflag.co.uk/open-wheel/formula-1/feed/',
      'Motorsportweek.com': 'https://www.motorsportweek.com/feed/',
      'Crash.net': 'https://www.crash.net/rss/f1',
      'Pitpass.com':
          'https://www.pitpass.com/fes_php/fes_usr_sit_newsfeed.php?fes_prepend_aty_sht_name=1',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.newsMix,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              setState(
                () {
                  useMergedFeeds = !useMergedFeeds;
                  Hive.box('feeds').put('mergedFeeds', useMergedFeeds);
                },
              );
            },
            icon: Icon(
              useMergedFeeds ? Icons.splitscreen : Icons.merge,
            ),
          ),
          useMergedFeeds
              ? Container()
              : IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditOrderScreen(
                        updateParent,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit,
                  ),
                ),
        ],
      ),
      body: useMergedFeeds
          ? FutureBuilder<List<MergedNewsItemDefinition>>(
              future: MergedFeeds().getFeedsArticles(feeds),
              builder: (context, snapshot) => snapshot.hasError
                  ? RequestErrorWidget(
                      snapshot.error.toString(),
                    )
                  : snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Card(
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RssFeedArticleScreen(
                                      snapshot.data![index].title,
                                      !snapshot.data![index].link
                                              .contains('?utm')
                                          ? snapshot.data![index].link
                                          : snapshot.data![index].link
                                              .substring(
                                              0,
                                              snapshot.data![index].link
                                                  .indexOf('?utm'),
                                            ),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    newsLayout != 'condensed' &&
                                            newsLayout != 'small' &&
                                            (snapshot.data![index]
                                                        .thumbnailUrl !=
                                                    null ||
                                                snapshot.data![index]
                                                        .thumbnailIntermediateUrl !=
                                                    null)
                                        ? Container(
                                            constraints: BoxConstraints(
                                              minHeight: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      (16 / 9) -
                                                  5,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              child: snapshot.data![index]
                                                          .thumbnailUrl !=
                                                      null
                                                  ? Image.network(
                                                      snapshot.data![index]
                                                          .thumbnailUrl!,
                                                    )
                                                  : FutureBuilder<String>(
                                                      future: Wordpress()
                                                          .getImageUrl(
                                                        snapshot.data![index]
                                                            .thumbnailIntermediateUrl!,
                                                      ),
                                                      builder: (context,
                                                              snapshot) =>
                                                          snapshot.hasError
                                                              ? RequestErrorWidget(
                                                                  snapshot.error
                                                                      .toString(),
                                                                )
                                                              : snapshot.hasData
                                                                  ? Image
                                                                      .network(
                                                                      snapshot
                                                                          .data!,
                                                                    )
                                                                  : const LoadingIndicatorUtil(),
                                                    ),
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 0.0,
                                            width: 0.0,
                                          ),
                                    ListTile(
                                      title: Text(
                                        snapshot.data![index].title
                                            .replaceAll('&#8211;', "'")
                                            .replaceAll('&#8216;', "'")
                                            .replaceAll('&#8217;', "'")
                                            .replaceAll('&#8220;', '"')
                                            .replaceAll('&#8221;', '"'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                        textAlign: TextAlign.justify,
                                      ),
                                      subtitle: newsLayout != 'big' &&
                                              newsLayout != 'condensed' &&
                                              snapshot.data![index].description!
                                                  .isEmpty
                                          ? null
                                          : MarkdownBody(
                                              data: !snapshot
                                                      .data![index].description!
                                                      .contains("<a ")
                                                  ? snapshot
                                                      .data![index].description!
                                                  : snapshot
                                                      .data![index].description!
                                                      .substring(
                                                        0,
                                                        snapshot.data![index]
                                                            .description!
                                                            .indexOf("<a "),
                                                      )
                                                      .replaceAll('<br>', '')
                                                      .replaceAll(
                                                          '&#8211;', "'")
                                                      .replaceAll(
                                                          '&#8216;', "'")
                                                      .replaceAll(
                                                          '&#8217;', "'")
                                                      .replaceAll(
                                                          '&#8220;', '"')
                                                      .replaceAll(
                                                          '&#8221;', '"')
                                                      .replaceAll('â-', '"')
                                                      .replaceAll(
                                                          '&nbsp;', ' '),
                                              styleSheet: MarkdownStyleSheet(
                                                textAlign:
                                                    WrapAlignment.spaceBetween,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16,
                                        left: 16,
                                        bottom: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.from,
                                            style: TextStyle(
                                              color: useDarkMode
                                                  ? Colors.grey.shade300
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            feedsUrl.keys
                                                .firstWhere(
                                                  (k) =>
                                                      feedsUrl[k] ==
                                                      snapshot
                                                          .data![index].source,
                                                  orElse: () => '',
                                                )
                                                .split('.')[0],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Spacer(),
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
                                              DateTime.parse(
                                                snapshot.data![index].date,
                                              ),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: LoadingIndicatorUtil(),
                        ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (String feed in feeds)
                    feed == 'WTF1.com' ||
                            feed == 'Racefans.net' ||
                            feed == 'Beyondtheflag.com'
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      feed,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WordpressScreen(
                                            feed,
                                            feedsUrl[feed],
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.viewMore,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder<List>(
                                  future: Wordpress().getWordpressNews(
                                    feedsUrl[feed],
                                    max: 5,
                                  ),
                                  builder: (context, snapshot) => snapshot
                                          .hasError
                                      ? RequestErrorWidget(
                                          snapshot.error.toString(),
                                        )
                                      : snapshot.hasData &&
                                              snapshot.data != null
                                          ? Row(
                                              children: [
                                                for (Map article
                                                    in snapshot.data!)
                                                  SizedBox(
                                                    width: width / 2.1,
                                                    height: 232,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RssFeedArticleScreen(
                                                              article['title'][
                                                                      'rendered']
                                                                  .replaceAll(
                                                                      '&#8211;',
                                                                      "'")
                                                                  .replaceAll(
                                                                      '&#8216;',
                                                                      "'")
                                                                  .replaceAll(
                                                                      '&#8217;',
                                                                      "'")
                                                                  .replaceAll(
                                                                      '&#8220;',
                                                                      '"')
                                                                  .replaceAll(
                                                                      '&#8221;',
                                                                      '"'),
                                                              article['link'],
                                                            ),
                                                          ),
                                                        ),
                                                        child: Card(
                                                          elevation: 5.0,
                                                          child: Column(
                                                            children: [
                                                              FutureBuilder<
                                                                  String>(
                                                                future: Wordpress()
                                                                    .getImageUrl(
                                                                  article['_links']
                                                                          [
                                                                          'wp:featuredmedia']
                                                                      [
                                                                      0]['href'],
                                                                ),
                                                                builder: (context, imageSnapshot) => imageSnapshot
                                                                        .hasError
                                                                    ? RequestErrorWidget(
                                                                        imageSnapshot
                                                                            .error
                                                                            .toString(),
                                                                      )
                                                                    : imageSnapshot
                                                                            .hasData
                                                                        ? Image
                                                                            .network(
                                                                            imageSnapshot.data!,
                                                                          )
                                                                        : const LoadingIndicatorUtil(),
                                                              ),
                                                              ListTile(
                                                                title: Text(
                                                                  article['title']
                                                                          [
                                                                          'rendered']
                                                                      .replaceAll(
                                                                          '&#8211;',
                                                                          "'")
                                                                      .replaceAll(
                                                                          '&#8216;',
                                                                          "'")
                                                                      .replaceAll(
                                                                          '&#8217;',
                                                                          "'")
                                                                      .replaceAll(
                                                                          '&#8220;',
                                                                          '"')
                                                                      .replaceAll(
                                                                          '&#8221;',
                                                                          '"'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLines: 4,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : const SizedBox(
                                              height: 232,
                                              child: LoadingIndicatorUtil(),
                                            ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      feed,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RssFeedScreen(
                                            feed,
                                            feedsUrl[feed],
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.viewMore,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: RssFeeds().getFeedArticles(
                                    feedsUrl[feed],
                                    max: 5,
                                  ),
                                  builder: (context, snapshot) => snapshot
                                          .hasError
                                      ? RequestErrorWidget(
                                          snapshot.error.toString(),
                                        )
                                      : snapshot.hasData &&
                                              snapshot.data != null
                                          ? Row(
                                              children: [
                                                for (var feedItem in snapshot
                                                    .data!['feedArticles'])
                                                  SizedBox(
                                                    width: width / 2.1,
                                                    height: feedItem.enclosure !=
                                                                null ||
                                                            feedItem
                                                                .media
                                                                .thumbnails
                                                                .isNotEmpty ||
                                                            feedItem
                                                                .media
                                                                .contents
                                                                .isNotEmpty
                                                        ? 232
                                                        : 110,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RssFeedArticleScreen(
                                                              feedItem.title!,
                                                              feedItem.link!
                                                                          .indexOf(
                                                                        '?utm',
                                                                      ) ==
                                                                      -1
                                                                  ? feedItem
                                                                      .link!
                                                                  : feedItem
                                                                      .link!
                                                                      .substring(
                                                                      0,
                                                                      feedItem
                                                                          .link!
                                                                          .indexOf(
                                                                        '?utm',
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                        child: Card(
                                                          elevation: 5.0,
                                                          child: Column(
                                                            children: [
                                                              feedItem.enclosure !=
                                                                      null
                                                                  ? Image
                                                                      .network(
                                                                      feedItem
                                                                          .enclosure!
                                                                          .url!,
                                                                    )
                                                                  : feedItem
                                                                          .media
                                                                          .thumbnails
                                                                          .isNotEmpty
                                                                      ? Image
                                                                          .network(
                                                                          feedItem
                                                                              .media
                                                                              .thumbnails[0]
                                                                              .url,
                                                                        )
                                                                      : feedItem
                                                                              .media
                                                                              .contents
                                                                              .isNotEmpty
                                                                          ? Image
                                                                              .network(
                                                                              feedItem.media.contents[0].url,
                                                                            )
                                                                          : Container(),
                                                              ListTile(
                                                                title: Text(
                                                                  feedItem
                                                                      .title!,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLines: 4,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : const SizedBox(
                                              height: 232,
                                              child: LoadingIndicatorUtil(),
                                            ),
                                ),
                              ),
                            ],
                          ),
                ],
              ),
            ),
    );
  }
}
