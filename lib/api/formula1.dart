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

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class Formula1 {
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
