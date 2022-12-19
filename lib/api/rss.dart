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

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class RssFeeds {
  Future<List<RssItem>> getMotorsportArticles({int? max}) async {
    var url = Uri.parse('https://www.motorsport.com/rss/f1/news/');
    var response = await http.get(url);
    RssFeed rssFeed = RssFeed.parse(
      utf8.decode(
        response.bodyBytes,
      ),
    );
    List<RssItem> rssItems = rssFeed.items!;
    if (max != null) {
      rssItems = rssItems.sublist(0, max);
    }

    return rssItems;
  }

  Future<RssFeed> getWtf1Articles() async {
    var url = Uri.parse('https://wtf1.com/feed/');
    var response = await http.get(url);
    RssFeed rssFeed = RssFeed.parse(
      utf8.decode(
        response.bodyBytes,
      ),
    );
    return rssFeed;
  }
}
