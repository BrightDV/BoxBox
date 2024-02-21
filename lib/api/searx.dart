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

import 'dart:convert';

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class SearXSearch {
  final List<String> instances = [
    'https://searx.be',
    'https://searx.tiekoetter.com',
    'https://searx.work',
    'https://darmarit.org/searx',
    'https://search.bus-hit.me',
    'https://search.demoniak.ch',
    'https://northboot.xyz',
    'https://search.in.projectsegfau.lt',
    'https://searxng.site/',
    'https://search.broker/',
    'https://search.inetol.net/',
    'https://opnxng.com/',
  ];

  final List<String> instancesWithJsonFormat = [
    'https://search.neet.works',
    'https://etsi.me',
    'https://search.projectsegfau.lt',
  ];

  Future<List> searchArticles(String query) async {
    List results = [];
    await searchArticlesWithoutScraping(query);
    if (results.isEmpty) {
      results = await searchArticlesWithScraping(query);
    }
    return results;
  }

  Future<List> searchArticlesWithoutScraping(String query) async {
    late http.Response response;
    List results = [];
    for (String instance in instancesWithJsonFormat) {
      response = await http.get(
        Uri.parse(
          '$instance/search?q="https://formula1.com/en/latest/article" $query&language=all&format=json',
        ),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        },
      );
      if (response.body.trim() != 'Too Many Requests' &&
          response.body.trim() != 'Rate limit exceeded' &&
          response.statusCode == 200) {
        break;
      }
    }

    if (response.body.trim() == 'Too Many Requests' ||
        response.body.trim() != 'Rate limit exceeded') {
      return [];
    } else {
      Map responseAsJson = jsonDecode(utf8.decode(response.bodyBytes));
      for (var result in responseAsJson['results']) {
        results.add(
          {
            'url': result['url'],
            'title': result['title'],
            'content': result['content'],
          },
        );
      }

      return results;
    }
  }

  Future<List> searchArticlesWithScraping(String query) async {
    late Uri url;
    late http.Response response;
    instances.shuffle();
    for (String instance in instances) {
      url = Uri.parse(
        '$instance/search?q="https://formula1.com/en/latest/article" $query&language=all&theme=simple',
      );
      response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        },
      );
      if (response.body.trim() != 'Too Many Requests' &&
          response.body.trim() != 'Rate limit exceeded' &&
          response.statusCode == 200) {
        break;
      }
    }
    dom.Document document = parser.parse(
      utf8.decode(response.bodyBytes),
    );
    List<Map> results = [];
    List<dom.Element> tempResults = document.getElementsByClassName('result');
    for (var element in tempResults) {
      if (element.firstChild!.attributes['href']!
          .contains('formula1.com/en/latest/article')) {
        results.add(
          {
            'url': element.firstChild!.attributes['href'],
            'title': element.children[1].firstChild!.text,
            'content': element.children[2].innerHtml
                .replaceAll('<span class="highlight">', '**')
                .replaceAll('</span>', '**')
                .substring(4),
          },
        );
      }
    }
    return results;
  }
}
