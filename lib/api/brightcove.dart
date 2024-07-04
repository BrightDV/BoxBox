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

import 'package:boxbox/helpers/download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';

class BrightCove {
  static const key = 'brightCoveVideoCache';
  static CacheManager videoCache = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 10,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  Future<Map> fetchStreamData(
      String videoId, String? player, String? articleChampionship) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    late Map responseAsJson;
    if (kIsWeb) {
      late Uri uri;
      if (articleChampionship != null) {
        uri = Uri.parse(
          articleChampionship == 'Formula 1'
              ? 'https://edge.api.brightcove.com/playback/v1/accounts/6057949432001/videos/$videoId'
              : 'https://edge.api.brightcove.com/playback/v1/accounts/6275361344001/videos/$videoId',
        );
      } else if (player != null) {
        uri = Uri.parse(
          'https://edge.api.brightcove.com/playback/v1/accounts/$player/videos/$videoId',
        );
      } else {
        uri = Uri.parse(
          championship == 'Formula 1'
              ? 'https://edge.api.brightcove.com/playback/v1/accounts/6057949432001/videos/$videoId'
              : 'https://edge.api.brightcove.com/playback/v1/accounts/6275361344001/videos/$videoId',
        );
      }
      Response res = await get(
        uri,
        headers: {
          'Accept': articleChampionship != null
              ? articleChampionship == 'Formula 1'
                  ? ' application/json;pk=BCpkADawqM1hQVBuXkSlsl6hUsBZQMmrLbIfOjJQ3_n8zmPOhlNSwZhQBF6d5xggxm0t052lQjYyhqZR3FW2eP03YGOER9ihJkUnIhRZGBxuLhnL-QiFpvcDWIh_LvwN5j8zkjTtGKarhsdV'
                  : ' application/json;pk=BCpkADawqM0CZElkVwfs62q-JTOc4CeZSNJRfxT923qzbMSqp6qn5VEgWV1iao1cEf2sXX9ce8achTuOfYKUvfchSis_rB5Sxz_ih70GYLYdf8bZgHi3Yq1VK_6v3mj29rxxcJjF3OX6Ri32'
              : championship == 'Formula 1'
                  ? ' application/json;pk=BCpkADawqM1hQVBuXkSlsl6hUsBZQMmrLbIfOjJQ3_n8zmPOhlNSwZhQBF6d5xggxm0t052lQjYyhqZR3FW2eP03YGOER9ihJkUnIhRZGBxuLhnL-QiFpvcDWIh_LvwN5j8zkjTtGKarhsdV'
                  : ' application/json;pk=BCpkADawqM0CZElkVwfs62q-JTOc4CeZSNJRfxT923qzbMSqp6qn5VEgWV1iao1cEf2sXX9ce8achTuOfYKUvfchSis_rB5Sxz_ih70GYLYdf8bZgHi3Yq1VK_6v3mj29rxxcJjF3OX6Ri32',
        },
      );
      responseAsJson = jsonDecode(res.body);
    } else {
      late String url;

      if (articleChampionship != null) {
        url = articleChampionship == 'Formula 1'
            ? 'https://edge.api.brightcove.com/playback/v1/accounts/6057949432001/videos/$videoId'
            : 'https://edge.api.brightcove.com/playback/v1/accounts/6275361344001/videos/$videoId';
      } else if (player != null) {
        url =
            'https://edge.api.brightcove.com/playback/v1/accounts/$player/videos/$videoId';
      } else {
        url = championship == 'Formula 1'
            ? 'https://edge.api.brightcove.com/playback/v1/accounts/6057949432001/videos/$videoId'
            : 'https://edge.api.brightcove.com/playback/v1/accounts/6275361344001/videos/$videoId';
      }
      final Future<File> fileStream = videoCache.getSingleFile(
        url,
        headers: {
          'Accept': articleChampionship != null
              ? articleChampionship == 'Formula 1'
                  ? ' application/json;pk=BCpkADawqM1hQVBuXkSlsl6hUsBZQMmrLbIfOjJQ3_n8zmPOhlNSwZhQBF6d5xggxm0t052lQjYyhqZR3FW2eP03YGOER9ihJkUnIhRZGBxuLhnL-QiFpvcDWIh_LvwN5j8zkjTtGKarhsdV'
                  : ' application/json;pk=BCpkADawqM0CZElkVwfs62q-JTOc4CeZSNJRfxT923qzbMSqp6qn5VEgWV1iao1cEf2sXX9ce8achTuOfYKUvfchSis_rB5Sxz_ih70GYLYdf8bZgHi3Yq1VK_6v3mj29rxxcJjF3OX6Ri32'
              : championship == 'Formula 1'
                  ? ' application/json;pk=BCpkADawqM1hQVBuXkSlsl6hUsBZQMmrLbIfOjJQ3_n8zmPOhlNSwZhQBF6d5xggxm0t052lQjYyhqZR3FW2eP03YGOER9ihJkUnIhRZGBxuLhnL-QiFpvcDWIh_LvwN5j8zkjTtGKarhsdV'
                  : ' application/json;pk=BCpkADawqM0CZElkVwfs62q-JTOc4CeZSNJRfxT923qzbMSqp6qn5VEgWV1iao1cEf2sXX9ce8achTuOfYKUvfchSis_rB5Sxz_ih70GYLYdf8bZgHi3Yq1VK_6v3mj29rxxcJjF3OX6Ri32',
        },
      );
      final response = await fileStream;

      responseAsJson = jsonDecode(
        utf8.decode(
          await response.readAsBytes(),
        ),
      );
    }
    return responseAsJson;
  }

  Future<Map<String, dynamic>> getVideoLinks(String videoId,
      {String? player, String? articleChampionship}) async {
    String? filePath =
        await DownloadUtils().downloadedFilePathIfExists('video_f1_${videoId}');

    if (filePath != null) {
      return {'file': filePath};
    } else {
      int playerQuality =
          Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
      Map streamsData =
          await fetchStreamData(videoId, player, articleChampionship);
      Map<String, dynamic> streamUrls = {};
      streamUrls['poster'] = streamsData['poster'];
      streamUrls['videos'] = [];
      streamUrls['qualities'] = [];
      bool foundPreferedQuality = false;
      List<int> resSelected = [];
      for (var element in streamsData['sources']) {
        if (element['height'] == playerQuality && !foundPreferedQuality) {
          streamUrls['videos'].insert(0, element['src']);
          foundPreferedQuality = true;
        } else if (element['codec'] == 'H264' &&
            !resSelected.contains(element['height'])) {
          resSelected.add(element['height']);
          streamUrls['videos'].add(element['src']);
          streamUrls['qualities'].add('${element['height']}p');
        }
      }
      int c = 0;
      for (String streamUrl in streamUrls['videos']) {
        if (streamUrl.startsWith('http://')) {
          streamUrls['videos'][c] =
              streamUrl.replaceFirst('http://', 'https://');
        }
        c++;
      }
      if (streamUrls['videos'].isEmpty) {
        streamUrls['videos'].add(streamsData['sources'][0]['src']);
      }
      streamUrls['name'] = streamsData['name'];
      return streamUrls;
    }
  }
}
