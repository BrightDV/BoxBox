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

import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class F1VideosFetcher {
  final String defaultEndpoint = Constants().F1_API_URL;
  final String apikey = Constants().F1_API_KEY;

  List<Video> formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['videos'];
    List<Video> newsList = [];
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;

    for (var element in finalJson) {
      String imageUrl = element['thumbnail']['url'];
      if (useDataSaverMode) {
        if (element['thumbnail']['renditions'] != null) {
          imageUrl = element['thumbnail']['renditions']['2col-retina'];
        } else {
          imageUrl += '.transform/2col-retina/image.jpg';
        }
      }
      newsList.add(
        Video(
          element['videoId'],
          'https://formula1.com${element['url']}',
          element['caption'],
          element?['description'] ?? '',
          element['videoDuration'],
          imageUrl,
          DateTime.parse(element['publishedAt']),
        ),
      );
    }
    return newsList;
  }

  Future<List<Video>> getLatestVideos(
    int limit,
    int offset, {
    String tag = '',
  }) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    Uri url;
    if (tag != '') {
      url = Uri.parse(
        endpoint != defaultEndpoint
            ? '$endpoint/f1/v1/video-assets/videos?limit=$limit&tag=$tag&offset=$offset'
            : '$endpoint/v1/video-assets/videos?limit=$limit&tag=$tag&offset=$offset',
      );
    } else {
      url = Uri.parse(
        endpoint != defaultEndpoint
            ? '$endpoint/f1/v1/video-assets/videos?limit=$limit&offset=$offset'
            : '$endpoint/v1/video-assets/videos?limit=$limit&offset=$offset',
      );
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

    Map<String, dynamic> responseAsJson = json.decode(
      utf8.decode(response.bodyBytes),
    );
    return formatResponse(responseAsJson);
  }

  Future<Video> getVideoDetails(String videoId) async {
    String endpoint = Hive.box('settings')
        .get('server', defaultValue: defaultEndpoint) as String;
    Uri url = Uri.parse(
      endpoint != defaultEndpoint
          ? "$endpoint/f1/v1/video-assets/videos/$videoId"
          : "$endpoint/v1/video-assets/videos/$videoId",
    );
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
    String imageUrl = responseAsJson['thumbnail']['url'];
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    if (useDataSaverMode) {
      if (responseAsJson['thumbnail']['renditions'] != null) {
        imageUrl = responseAsJson['thumbnail']['renditions']['2col-retina'];
      } else {
        imageUrl += '.transform/2col-retina/image.jpg';
      }
    }
    return Video(
      responseAsJson['videoId'],
      'https://formula1.com${responseAsJson['url']}',
      responseAsJson['caption'],
      responseAsJson['description'],
      responseAsJson['videoDuration'],
      imageUrl,
      DateTime.parse(responseAsJson['publishedAt']),
    );
  }
}

class Video {
  final String videoId;
  final String videoUrl;
  final String caption;
  final String description;
  final String videoDuration;
  final String thumbnailUrl;
  final DateTime datePosted;

  Video(
    this.videoId,
    this.videoUrl,
    this.caption,
    this.description,
    this.videoDuration,
    this.thumbnailUrl,
    this.datePosted,
  );
}
