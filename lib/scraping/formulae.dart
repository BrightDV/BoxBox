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

import 'dart:convert';

import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;

class FormulaEScraper {
  final String defaultEndpoint = "https://www.fiaformulae.com";
  final String defaultF1Endpoint = Constants().F1_API_URL;

  List<html2md.Rule> rules = [
    html2md.Rule(
      'share-top',
      filterFn: (node) {
        if (node.nodeName == 'div' &&
            (node.className.contains('w-article__share') ||
                node.className.contains('w-article__discover'))) {
          return true;
        }
        return false;
      },
      replacement: (content, node) {
        return '';
      },
    ),
  ];

  Future<Article> getArticleData(News? item, String articleId) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultF1Endpoint) as String;
    Uri url = Uri.parse(endpoint != defaultF1Endpoint
        ? '$endpoint/fe/en/news/$articleId'
        : '$defaultEndpoint/en/news/$articleId');
    http.Response response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
      },
    );

    dom.Document document = parser.parse(utf8.decode(response.bodyBytes));
    List<dom.Element> content =
        document.getElementsByClassName('w-article__content')[0].children;
    List<Map> body = [];
    for (dom.Element element in content) {
      if (element.className.contains('articleWidget') &&
          element.getElementsByClassName('video-player__instance').isNotEmpty) {
        dom.Element player =
            element.getElementsByClassName('video-player__instance')[0];
        body.add(
          {
            'contentType': 'atomVideo',
            'fields': {
              'videoId': player.attributes['data-video-id'],
              'player': player.attributes['data-player']
            },
          },
        );
      } else if (element.getElementsByTagName('img').isNotEmpty) {
        body.add(
          {
            'contentType': 'atomImage',
            'fields': {
              'image': {
                'url': element.getElementsByTagName('img')[0].attributes['src'],
              }
            },
          },
        );
      } else {
        String parsedElement = html2md.convert(element, rules: rules);
        if (parsedElement != '') {
          body.add(
            {
              'contentType': 'atomRichText',
              'fields': {
                'richTextBlock': parsedElement,
              },
            },
          );
        }
      }
    }
    Article article;
    if (item != null) {
      article = Article(
        item.newsId,
        item.slug,
        item.title,
        item.datePosted,
        item.tags ?? [],
        {
          'contentType': 'atomImage',
          'fields': {
            'image': {'url': item.imageUrl}
          }
        },
        body,
        [],
        item.author ?? {},
      );
    } else {
      News newsItem = await FormulaE().getArticle(articleId);
      article = Article(
        newsItem.newsId,
        newsItem.slug,
        newsItem.title,
        newsItem.datePosted,
        newsItem.tags ?? [],
        {
          'contentType': 'atomImage',
          'fields': {
            'image': {'url': newsItem.imageUrl}
          }
        },
        body,
        [],
        newsItem.author ?? {},
      );
    }
    return article;
  }
}
