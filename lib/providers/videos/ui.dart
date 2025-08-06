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

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/classes/video.dart';
import 'package:boxbox/helpers/download.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:river_player/river_player.dart';
import 'package:share_plus/share_plus.dart';

class VideosUIProvider {
  List<Widget> getVideoActions(
    List downloads,
    Video video,
    Function update,
    Function? widgetUpdate,
    BuildContext context,
    Function(TaskStatusUpdate)? updateVideoWithType,
    bool shouldRefresh,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (!kIsWeb) {
        return [
          IconButton(
            onPressed: () async {
              if (downloads.contains('video_f1_${video.videoId}')) {
                await DownloadUtils().deleteFile('video_f1_${video.videoId}');
                if (widgetUpdate != null) {
                  Future.delayed(
                    Duration(milliseconds: 100),
                  ).then(
                    (_) => update(),
                  );
                } else {
                  update();
                }
              } else {
                String? quality =
                    await DownloadUtils().videoDownloadQualitySelector(
                  context,
                );
                if (quality != null) {
                  String downloadingState = await DownloadUtils().downloadVideo(
                    video.videoId,
                    quality,
                    video: video,
                    callback: updateVideoWithType,
                  );
                  if (downloadingState == "downloading") {
                    if (widgetUpdate != null) {
                      widgetUpdate();
                    }
                    await Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.downloading,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    if (downloadingState == "downloading") {
                      await Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.alreadyDownloading,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      await Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.errorOccurred,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  }
                }
              }
            },
            icon: Icon(
              downloads.contains('video_f1_${video.videoId}')
                  ? Icons.delete_outline
                  : Icons.save_alt_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 3,
              right: 6,
            ),
            child: IconButton(
              onPressed: () => Share.share(
                video.videoUrl,
              ),
              icon: const Icon(
                Icons.share,
              ),
            ),
          ),
        ];
      } else {
        return [];
      }
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(
            left: 3,
            right: 6,
          ),
          child: IconButton(
            onPressed: () => Share.share(
              video.videoUrl,
            ),
            icon: const Icon(
              Icons.share,
            ),
          ),
        ),
      ];
    }
  }

  List<BetterPlayerOverflowMenuItem> getPlayerTopBarActions(
    Function downloadVideo,
    String videoId,
    String name,
    String poster,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return [
        BetterPlayerOverflowMenuItem(
          Icons.save_alt_outlined,
          'Download',
          () async => await downloadVideo(
            videoId,
            name,
            poster,
          ),
        ),
      ];
    } else {
      return [];
    }
  }
}
