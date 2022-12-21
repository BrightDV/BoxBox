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

class Wtf1 {
  Future<List> getWtf1News({int? max}) async {
    List formatedNews = [];
    var url = Uri.parse('https://wtf1.com/wp-json/wp/v2/posts');
    var response = await http.get(url);
    List responseAsJson = jsonDecode(
      response.body,
    );
    max != null
        ? formatedNews = responseAsJson.sublist(0, max)
        : formatedNews = responseAsJson;
    return formatedNews;
  }

  Future<List> getMoreWtf1News(int offset) async {
    var url = Uri.parse('https://wtf1.com/wp-json/wp/v2/posts?offset=$offset');
    var response = await http.get(url);
    List responseAsJson = jsonDecode(
      response.body,
    );
    return responseAsJson;
  }

  Future<String> getImageUrl(String mediaUrl) async {
    var url = Uri.parse(mediaUrl);
    var response = await http.get(url);
    Map responseAsJson = jsonDecode(
      response.body,
    );
    return responseAsJson['source_url'];
  }
}
