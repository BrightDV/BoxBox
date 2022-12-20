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

import 'package:boxbox/Screens/MixedNews/rss_feed.dart';
import 'package:boxbox/Screens/MixedNews/rss_feed_article.dart';
import 'package:boxbox/Screens/MixedNews/wtf1.dart';
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
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    double width = MediaQuery.of(context).size.width;
    List<String> feeds = [
      'Motorsport.com',
      'Racer.com',
      'Crash.com',
    ];
    Map<String, dynamic> feedsUrl = {
      'Motorsport': 'https://www.motorsport.com/rss/f1/news/',
      'Racer': 'https://racer.com/f1/feed/',
      'Crash': 'https://www.crash.net/rss/f1',
    };
    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          'Mixed News',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'WTF1',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
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
                            builder: (context) => Wtf1Screen(),
                          ),
                        ),
                        child: Text(
                          'VIEW MORE',
                          style: TextStyle(
                            color: useDarkMode ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FutureBuilder<List>(
                    future: Wtf1().getWtf1News(max: 7),
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
                                        padding: EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RssFeedArticleScreen(
                                                article['title']['rendered']
                                                    .replaceAll('&#8217;', "'")
                                                    .replaceAll('&#8216;', "'"),
                                                article['guid']['rendered'],
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
                                                  future: Wtf1().getImageUrl(
                                                    article['_links']
                                                            ['wp:featuredmedia']
                                                        [0]['href'],
                                                  ),
                                                  builder: (context,
                                                          imageSnapshot) =>
                                                      imageSnapshot.hasError
                                                          ? RequestErrorWidget(
                                                              imageSnapshot
                                                                  .error
                                                                  .toString(),
                                                            )
                                                          : imageSnapshot
                                                                  .hasData
                                                              ? Image.network(
                                                                  imageSnapshot
                                                                      .data!,
                                                                )
                                                              : LoadingIndicatorUtil(),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    article['title']['rendered']
                                                        .replaceAll(
                                                            '&#8217;', "'")
                                                        .replaceAll(
                                                            '&#8216;', "'"),
                                                    style: TextStyle(
                                                      color: useDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign:
                                                        TextAlign.justify,
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
                            : LoadingIndicatorUtil(),
                  ),
                ),
                for (String feed in feeds)
                  Column(
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
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: RssFeeds()
                              .getFeedArticles(feedsUrl[feed], max: 7),
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
                                            height: feedItem.enclosure != null
                                                ? 232
                                                : 110,
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RssFeedArticleScreen(
                                                      feedItem.title!,
                                                      feedItem.link!.indexOf(
                                                                  '?utm') ==
                                                              -1
                                                          ? feedItem.link!
                                                          : feedItem.link!
                                                              .substring(
                                                              0,
                                                              feedItem.link!
                                                                  .indexOf(
                                                                      '?utm'),
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
                                                      feedItem.enclosure != null
                                                          ? Image.network(
                                                              feedItem
                                                                  .enclosure!
                                                                  .url!,
                                                            )
                                                          : Container(),
                                                      ListTile(
                                                        title: Text(
                                                          feedItem.title!,
                                                          style: TextStyle(
                                                            color: useDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.justify,
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
                                  : LoadingIndicatorUtil(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
