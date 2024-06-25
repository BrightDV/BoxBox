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

import 'dart:async';
import 'dart:convert';

import 'package:boxbox/api/formula1.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class FormulaE {
  final String defaultEndpoint = "https://api.formula-e.pulselive.com";

  List<News> formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['content'];
    List<News> newsList = [];

    for (var element in finalJson) {
      element['title'] = element['title'].trim();
      if (element['description'] != null) {
        element['description'] = element['description'].trim();
      }
      String newsType = '';
      for (var tag in element['tags']) {
        if (tag['label'].contains('label')) {
          newsType = tag['label'].split(':')[1].toString().capitalize();
        }
      }

      newsList.add(
        News(
          element['id'].toString(),
          newsType,
          '',
          element['title'],
          element['description'] ?? '',
          DateTime.fromMillisecondsSinceEpoch(element['publishFrom']),
          element['imageUrl'],
          author: element['author'],
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
    int page = offset ~/ 12;

    url = Uri.parse(
      '$defaultEndpoint/content/formula-e/text/EN/?page=$page&pageSize=16&tagNames=content-type%3Anews&tagExpression=&playlistTypeRestriction=&playlistId=&detail=&size=16&championshipId=&sort=',
    );

    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );

    Map<String, dynamic> responseAsJson =
        json.decode(utf8.decode(response.bodyBytes));
    if (offset == 0 && tagId == null && articleType == null) {
      Hive.box('requests').put('news', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
