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

import 'package:boxbox/Screens/MixedNews/edit_order.dart';
import 'package:boxbox/Screens/MixedNews/rss_feed.dart';
import 'package:boxbox/Screens/MixedNews/rss_feed_article.dart';
import 'package:boxbox/Screens/MixedNews/wordpress.dart';
import 'package:boxbox/api/mixed_news.dart';
import 'package:boxbox/api/rss.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    double width = MediaQuery.of(context).size.width;
    List feeds = Hive.box('feeds').get(
      'feedsNames',
      defaultValue: [
        'WTF1.com',
        'Racefans.net',
        'Beyondtheflag.com',
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
      'Beyondtheflag.com': 'https://beyondtheflag.com',
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
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          'Mixed News',
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditOrderScreen(
                  updateParent,
                ),
              ),
            ),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                feed,
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Spacer(),
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
                                  'VIEW MORE',
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
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
                            builder: (context, snapshot) => snapshot.hasError
                                ? RequestErrorWidget(
                                    snapshot.error.toString(),
                                  )
                                : snapshot.hasData && snapshot.data != null
                                    ? Row(
                                        children: [
                                          for (Map article in snapshot.data!)
                                            Container(
                                              width: width / 2.1,
                                              height: 232,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                                child: GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          RssFeedArticleScreen(
                                                        article['title']
                                                                ['rendered']
                                                            .replaceAll(
                                                                '&#8211;', "'")
                                                            .replaceAll(
                                                                '&#8216;', "'")
                                                            .replaceAll(
                                                                '&#8217;', "'")
                                                            .replaceAll(
                                                                '&#8220;', '"')
                                                            .replaceAll(
                                                                '&#8221;', '"'),
                                                        article['guid']
                                                            ['rendered'],
                                                      ),
                                                    ),
                                                  ),
                                                  child: Card(
                                                    elevation: 5.0,
                                                    color: useDarkMode
                                                        ? Color(0xff1d1d28)
                                                        : Colors.white,
                                                    child: Column(
                                                      children: [
                                                        FutureBuilder<String>(
                                                          future: Wordpress()
                                                              .getImageUrl(
                                                            article['_links'][
                                                                    'wp:featuredmedia']
                                                                [0]['href'],
                                                          ),
                                                          builder: (context,
                                                                  imageSnapshot) =>
                                                              imageSnapshot
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
                                                                          imageSnapshot
                                                                              .data!,
                                                                        )
                                                                      : LoadingIndicatorUtil(),
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                            article['title']
                                                                    ['rendered']
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
                                                            style: TextStyle(
                                                              color: useDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            maxLines: 5,
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
                                    : Container(
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
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                feed,
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Spacer(),
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
                                  'VIEW MORE',
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
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
                            builder: (context, snapshot) => snapshot.hasError
                                ? RequestErrorWidget(
                                    snapshot.error.toString(),
                                  )
                                : snapshot.hasData && snapshot.data != null
                                    ? Row(
                                        children: [
                                          for (var feedItem
                                              in snapshot.data!['feedArticles'])
                                            Container(
                                              width: width / 2.1,
                                              height:
                                                  feedItem.enclosure != null ||
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
                                                    EdgeInsets.only(top: 5),
                                                child: GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          RssFeedArticleScreen(
                                                        feedItem.title!,
                                                        feedItem.link!.indexOf(
                                                                  '?utm',
                                                                ) ==
                                                                -1
                                                            ? feedItem.link!
                                                            : feedItem.link!
                                                                .substring(
                                                                0,
                                                                feedItem.link!
                                                                    .indexOf(
                                                                  '?utm',
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Card(
                                                    elevation: 5.0,
                                                    color: useDarkMode
                                                        ? Color(0xff1d1d28)
                                                        : Colors.white,
                                                    child: Column(
                                                      children: [
                                                        feedItem.enclosure !=
                                                                null
                                                            ? Image.network(
                                                                feedItem
                                                                    .enclosure!
                                                                    .url!,
                                                              )
                                                            : feedItem
                                                                    .media
                                                                    .thumbnails
                                                                    .isNotEmpty
                                                                ? Image.network(
                                                                    feedItem
                                                                        .media
                                                                        .thumbnails[
                                                                            0]
                                                                        .url,
                                                                  )
                                                                : feedItem
                                                                        .media
                                                                        .contents
                                                                        .isNotEmpty
                                                                    ? Image
                                                                        .network(
                                                                        feedItem
                                                                            .media
                                                                            .contents[0]
                                                                            .url,
                                                                      )
                                                                    : Container(),
                                                        ListTile(
                                                          title: Text(
                                                            feedItem.title!,
                                                            style: TextStyle(
                                                              color: useDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            maxLines: 5,
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
                                    : Container(
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
