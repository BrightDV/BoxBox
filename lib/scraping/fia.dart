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

import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class SessionDocument {
  final String name;
  final String postedDate;
  final String src;

  SessionDocument(this.name, this.postedDate, this.src);
}

class FIAScraper {
  Future<List<SessionDocument>> scrapeSessionDocuments() async {
    final String defaultEndpoint = Constants().F1_API_URL;
    late Uri latestDocumentsUrl;
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    if (endpoint != defaultEndpoint) {
      latestDocumentsUrl = Uri.parse(
        '$endpoint/documents',
      );
    } else {
      latestDocumentsUrl = Uri.parse(
        'https://www.fia.com/documents/championships/fia-formula-one-world-championship-14/season/season-2024-2043',
      );
    }
    http.Response response = await http.get(latestDocumentsUrl);
    dom.Document document = parser.parse(response.body);
    List<SessionDocument> documents = [];
    List<dom.Element> tempResult = document
        .getElementsByClassName('event-wrapper')[0]
        .getElementsByClassName('document-row');
    for (dom.Element document in tempResult) {
      documents.add(
        SessionDocument(
          document.getElementsByClassName('title').first.text.trim(),
          document.getElementsByClassName('published').first.text.trim(),
          'https://www.fia.com${document.getElementsByTagName('a').first.attributes['href']}',
        ),
      );
    }
    return documents;
  }
}
