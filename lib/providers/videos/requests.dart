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
 * Copyright (c) 2022-2025, BrightDV
 */

import 'package:boxbox/api/brightcove.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/classes/video.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VideosRequestProvider {
  Future<List<Video>> getLatestVideos(int offset, {String tag = ''}) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return F1VideosFetcher().getLatestVideos(
        24,
        offset,
      );
    } else if (championship == 'Formula E') {
      return FormulaE().getLatestVideos(
        24,
        offset,
      );
    } else {
      return [];
    }
  }

  Future<VideoDetails> getVideoLinks(
    String videoId, {
    String? player,
    String? articleChampionship,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1' ||
        championship == 'Formula E' ||
        championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return BrightCove().getVideoLinks(
        videoId,
        player: player,
        articleChampionship: articleChampionship,
      );
    } else {
      return VideoDetails('', [], [], '');
    }
  }

  String getBrightCovePlayerId(String championship) {
    if (championship == 'Formula 1') {
      return Constants().F1_BRIGHTCOVE_PLAYER_ID;
    } else if (championship == 'Formula E') {
      return Constants().FE_BRIGHTCOVE_PLAYER_ID;
    } else if (championship == 'Formula 2') {
      return Constants().F1_BRIGHTCOVE_PLAYER_ID;
    } else if (championship == 'Formula 3') {
      return Constants().F1_BRIGHTCOVE_PLAYER_ID;
    } else if (championship == 'F1 Academy') {
      return Constants().F1_BRIGHTCOVE_PLAYER_ID;
    } else {
      return '';
    }
  }

  String getBrightCovePlayerKey(String championship) {
    if (championship == 'Formula 1') {
      return Constants().F1_BRIGHTCOVE_PLAYER_KEY;
    } else if (championship == 'Formula E') {
      return Constants().FE_BRIGHTCOVE_PLAYER_KEY;
    } else if (championship == 'Formula 2') {
      return Constants().F1_BRIGHTCOVE_PLAYER_KEY;
    } else if (championship == 'Formula 3') {
      return Constants().F1_BRIGHTCOVE_PLAYER_KEY;
    } else if (championship == 'F1 Academy') {
      return Constants().F1_BRIGHTCOVE_PLAYER_KEY;
    } else {
      return '';
    }
  }
}
