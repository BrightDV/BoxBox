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

import 'dart:convert';

import 'package:boxbox/api/rss.dart';
import 'package:http/http.dart' as http;

class Wordpress {
  Future<List> getWordpressNews(String baseUrl, {int? max}) async {
    late Uri url;
    List formatedNews = [];
    baseUrl == 'https://beyondtheflag.com'
        ? url = Uri.parse('$baseUrl/wp-json/wp/v2/posts?categories=270521,0')
        : url = Uri.parse('$baseUrl/wp-json/wp/v2/posts');
    var response = await http.get(url);
    List responseAsJson = jsonDecode(
      response.body,
    );
    max != null
        ? formatedNews = responseAsJson.sublist(0, max)
        : formatedNews = responseAsJson;
    return formatedNews;
  }

  Future<List> getMoreWordpressNews(String baseUrl, int offset) async {
    late Uri url;

    baseUrl == 'https://beyondtheflag.com'
        ? url = Uri.parse(
            '$baseUrl/wp-json/wp/v2/posts?offset=$offset&categories=270521,0',
          )
        : url = Uri.parse('$baseUrl/wp-json/wp/v2/posts?offset=$offset');
    var response = await http.get(url);
    List responseAsJson = jsonDecode(
      response.body,
    );
    return responseAsJson;
  }

  Future<String> getImageUrl(String mediaUrl) async {
    var url = Uri.parse(mediaUrl);
    var response = await http.get(url);
    Map responseAsJson = jsonDecode(
      response.body,
    );
    return responseAsJson['source_url'];
  }
}

class MergedFeeds {
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

  Future<List<MergedNewsItemDefinition>> getWordpressArticles(
      String feedUrl) async {
    List<MergedNewsItemDefinition> formatedItems = [];
    List feedItems = await Wordpress().getWordpressNews(feedUrl);
    feedItems.forEach(
      (element) => formatedItems.add(
        MergedNewsItemDefinition(
          feedUrl,
          element['title']['rendered'],
          element['link'],
          element['date'],
          description: ' ',
          thumbnailIntermediateUrl: element['_links']['wp:featuredmedia'][0]
              ['href'],
        ),
      ),
    );
    return formatedItems;
  }

  Future<List<MergedNewsItemDefinition>> getRssArticles(String feedUrl) async {
    List<MergedNewsItemDefinition> formatedItems = [];
    Map feedItems = await RssFeeds().getFeedArticles(feedUrl);
    feedItems['feedArticles'].forEach(
      (element) => formatedItems.add(
        MergedNewsItemDefinition(
          feedUrl,
          element.title,
          element.link,
          element.pubDate.toString(),
          description: element.description,
          thumbnailUrl: element.enclosure != null
              ? element.enclosure.url
              : element.media.thumbnails.isNotEmpty
                  ? element.media.thumbnails[0].url
                  : element.media.contents.isNotEmpty
                      ? element.media.contents[0].url
                      : null,
        ),
      ),
    );
    return formatedItems;
  }

  Future<List<MergedNewsItemDefinition>> getFeedsArticles(
      List feedsNames) async {
    List<MergedNewsItemDefinition> feeds = [];
    for (String feedName in feedsNames) {
      feedName == 'WTF1.com' ||
              feedName == 'Racefans.net' ||
              feedName == 'Beyondtheflag.com'
          ? feeds = feeds +
              await getWordpressArticles(
                feedsUrl[feedName],
              )
          : feeds = feeds +
              await getRssArticles(
                feedsUrl[feedName],
              );
    }
    feeds.sort(
      (a, b) => DateTime.parse(b.date).compareTo(
        DateTime.parse(a.date),
      ),
    );
    return feeds;
  }
}

class MergedNewsItemDefinition {
  final String source;
  final String title;

  final String link;
  final String date;
  final String? description;
  final String? thumbnailUrl;
  final String? thumbnailIntermediateUrl;

  MergedNewsItemDefinition(
    this.source,
    this.title,
    this.link,
    this.date, {
    this.description,
    this.thumbnailUrl,
    this.thumbnailIntermediateUrl,
  });
}
