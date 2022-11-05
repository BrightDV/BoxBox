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

import 'package:http/http.dart';

class Twitter {
  Future<String> getGuestToken() async {
    Uri uri = Uri.parse(
      'https://api.twitter.com/1.1/guest/activate.json',
    );
    Response res = await post(
      uri,
      headers: {
        'Authorization': 'Bearer ' +
            'AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA',
      },
    );
    Map responseAsJson = jsonDecode(res.body);
    return responseAsJson['guest_token'];
  }

  Future<Map<String, dynamic>> getTweetContent(String tweetId) async {
    String guestToken = await getGuestToken();
    Uri uri = Uri.parse(
      'https://twitter.com/i/api/2/timeline/conversation/$tweetId.json',
    );
    Response res = await get(
      uri,
      headers: {
        'Authorization': 'Bearer ' +
            'AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA',
        'X-Guest-Token': guestToken,
      },
    );
    Map responseAsJson = jsonDecode(res.body);
    Map<String, dynamic> tweet =
        responseAsJson['globalObjects']['tweets'][tweetId];
    return tweet;
  }
}
