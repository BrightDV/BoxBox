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

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';

class BrightCove {
  Future<Map> fetchStreamData(String videoId) async {
    Uri uri = Uri.parse(
      'https://edge.api.brightcove.com/playback/v1/accounts/6057949432001/videos/$videoId',
    );
    Response res = await get(
      uri,
      headers: {
        'Accept': ' application/json;pk=BCpkADawqM1hQVBuXkSlsl6hUsBZQMmrLbIfOjJQ3_n8zmPOhlNSwZhQBF6d5xggxm0t052lQjYyhqZR3FW2eP03YGOER9ihJkUnIhRZGBxuLhnL-QiFpvcDWIh_LvwN5j8zkjTtGKarhsdV',
      },
    );
    Map responseAsJson = jsonDecode(res.body);
    return responseAsJson;
  }

  Future<String> getVideoLink(String videoId) async {
    int playerQuality = Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    Map streamsData = await fetchStreamData(videoId);
    String streamUrl = '';
    for (var element in streamsData['sources']) {
      if (element['height'] == playerQuality) {
        streamUrl = element['src'];
        break;
      }
    }
    if (streamUrl.startsWith('http://')) {
      streamUrl = streamUrl.replaceFirst('http://', 'https://');
    }
    return streamUrl;
  }
}
