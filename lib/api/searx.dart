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

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class SearXSearch {
  final List<String> instances = [
    'https://search.unlocked.link/',
    'https://search.sapti.me/',
    'https://searx.xyz/',
    'https://search.neet.works/',
    'https://dynabyte.ca/',
  ];
  final List<String> scrapingInstances = [
    'https://search.unlocked.link/',
    'https://search.sapti.me/',
    'https://searx.xyz/',
    'https://search.neet.works/',
    'https://dynabyte.ca/',
    'https://searx.fmac.xyz/',
    'https://priv.au/',
    'https://searx.be',
    'https://searx.tiekoetter.com/',
    'https://searx.work/',
  ];
  Future<List> searchArticles(String query) async {
    late Uri url;
    late http.Response response;
    for (String instance in instances) {
      url = Uri.parse(
        '$instance/search?q="formula1.com/en/latest/article" $query&format=json',
      );
      response = await http.get(
        url,
        headers: {
          'user-agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
        },
      );
      if (response.body != 'Too Many Requests') {
        break;
      }
    }
    late Map<String, dynamic> responseAsJson;
    try {
      responseAsJson = jsonDecode(response.body);
    } catch (e) {
      responseAsJson = await scrapeArticles(query);
    }
    return responseAsJson['results'];
  }

  Future<Map<String, dynamic>> scrapeArticles(String query) async {
    late Uri url;
    late http.Response response;
    for (String instance in scrapingInstances) {
      url = Uri.parse(
        '$instance/search?q="formula1.com/en/latest/article" $query',
      );
      response = await http.get(
        url,
        headers: {
          'user-agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
        },
      );
      if (response.body != 'Too Many Requests') {
        break;
      }
    }
    dom.Document document = parser.parse(
      utf8.decode(response.bodyBytes),
    );
    List<Map> results = [];
    List<dom.Element> _tempResults = document.getElementsByTagName('article');
    _tempResults.forEach(
      (element) {
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
      },
    );

    Map<String, dynamic> responseAsJson = {};
    responseAsJson['results'] = results;

    return responseAsJson;
  }
}