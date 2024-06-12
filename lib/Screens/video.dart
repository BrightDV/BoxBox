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

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/download.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoScreen extends StatefulWidget {
  final Video video;
  final Function? update;
  const VideoScreen(this.video, {this.update, Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool shouldRefresh = true;
  void update() {
    if (shouldRefresh) {
      setState(() {});
      if (widget.update != null) {
        widget.update!();
      }
    }
  }

  void updateVideoWithType(TaskStatusUpdate statusUpdate) {
    if (statusUpdate.status == TaskStatus.complete) {
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );

      Formula1().downloadedFilePathIfExists(statusUpdate.task.taskId).then(
        (path) {
          Map details = json.decode(statusUpdate.task.metaData);
          downloadsDescriptions[statusUpdate.task.taskId] = {
            'id': details['id'],
            'type': 'video',
            'title': details['title'],
            'thumbnail': details['thumbnail'],
            'url': details['url'],
            'description': details['description'],
            'videoDuration': details['videoDuration'],
            'datePosted': details['datePosted'],
          };
          Hive.box('downloads').put(
            'downloadsDescriptions',
            downloadsDescriptions,
          );
          List downloads = Hive.box('downloads').get(
            'downloadsList',
            defaultValue: [],
          );
          downloads.insert(0, 'video_${details['id']}');
          Hive.box('downloads').put('downloadsList', downloads);
          update();
        },
      );
    }
  }

  @override
  void dispose() {
    shouldRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fontUsedInArticles = Hive.box('settings')
        .get('fontUsedInArticles', defaultValue: 'Formula1') as String;
    List downloads = Hive.box('downloads').get(
      'downloadsList',
      defaultValue: [],
    );

    final Video video = widget.video;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: MediaQuery.of(context).size.width > 1000
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(video.caption),
                )
              : Marquee(
                  text: video.caption,
                  pauseAfterRound: const Duration(seconds: 1),
                  startAfter: const Duration(seconds: 1),
                  velocity: 85,
                  blankSpace: 100,
                ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (downloads.contains('video_${widget.video.videoId}')) {
                await Formula1().deleteFile('video_${widget.video.videoId}');
                update();
              } else {
                String? quality =
                    await DownloadUtils().videoDownloadQualitySelector(
                  context,
                );
                if (quality != null) {
                  String downloadingState = await Formula1().downloadVideo(
                    widget.video.videoId,
                    quality,
                    video: widget.video,
                    callback: updateVideoWithType,
                  );
                  if (downloadingState == "downloading") {
                    await Fluttertoast.showToast(
                      msg: 'Downloading',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    if (downloadingState == "downloading") {
                      Fluttertoast.showToast(
                        msg: 'Already downloading',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
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
              downloads.contains('video_${widget.video.videoId}')
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
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            color: Colors.transparent,
            child: VideoRenderer(
              video.videoId,
              autoplay: true,
              heroTag: video.videoId,
              update: update,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: Icon(
                    Icons.schedule,
                    size: 20.0,
                  ),
                ),
                Text(
                  timeago.format(
                    video.datePosted,
                    locale: Localizations.localeOf(context).toString(),
                  ),
                  style: TextStyle(
                    fontFamily: fontUsedInArticles,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(
              video.caption,
              style: TextStyle(
                fontFamily: fontUsedInArticles,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              video.description,
              style: TextStyle(
                fontFamily: fontUsedInArticles,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
