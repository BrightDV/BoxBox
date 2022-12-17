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

class SearXSearch {
  final List<String> instances = [
    'https://search.unlocked.link/',
    'https://search.sapti.me/',
    'https://searx.xyz/',
    'https://search.neet.works/',
    'https://dynabyte.ca/',
  ];
  Future<List> searchArticles(String query) async {
    late Uri url;
    late http.Response response;
    for (String instance in instances) {
      url = Uri.parse(
        '$instance/search?q="formula1.com/en/latest/article" $query&format=json',
      );
      response = await http.get(url);
      if (response.body != 'Too Many Requests') {
        break;
      }
    }
    Map<String, dynamic> responseAsJson = jsonDecode(response.body);

    return responseAsJson['results'];
  }
}
