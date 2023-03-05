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
    final Uri latestDocumentsUrl = Uri.parse(
      'https://www.fia.com/documents/championships/fia-formula-one-world-championship-14/season/season-2023-2042',
    );
    http.Response response = await http.get(latestDocumentsUrl);
    dom.Document document = parser.parse(response.body);
    List<SessionDocument> documents = [];
    List<dom.Element> tempResult = document
        .getElementsByClassName('event-wrapper')[0]
        .getElementsByClassName('document-row');
    for (var document in tempResult) {
      if (document.firstChild!.nodeType == 3) {
        documents.add(
          SessionDocument(
            'This document cannot be parsed.',
            'none',
            'https://www.fia.com/documents/championships/fia-formula-one-world-championship-14/season/season-2023-2042',
          ),
        );
      } else {
        documents.add(
          SessionDocument(
            document.firstChild!.children[1].text.substring(
                13, document.firstChild!.children[1].text.length - 3),
            document.firstChild!.children[2].children[0].text,
            'https://www.fia.com${document.firstChild?.attributes['href']}',
          ),
        );
      }
    }
    return documents;
  }
}
