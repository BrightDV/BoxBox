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

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class RssFeeds {
  Future<Map<String, dynamic>> getFeedArticles(String feedUrl,
      {int? max}) async {
    var url = Uri.parse(feedUrl);
    var response = await http.get(url);
    RssFeed rssFeed = RssFeed.parse(response.body);
    List<RssItem> rssItems = rssFeed.items!;
    if (max != null) {
      rssItems = rssItems.sublist(0, max);
    }
    Map<String, dynamic> resultsFormated = {
      'feedTitle': rssFeed.title,
      'feedArticles': rssItems,
    };

    return resultsFormated;
  }
}
