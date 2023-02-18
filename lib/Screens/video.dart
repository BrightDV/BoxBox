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

import 'package:boxbox/api/news.dart';
import 'package:boxbox/api/videos.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoScreen extends StatefulWidget {
  final Video video;
  const VideoScreen(this.video, {Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    final Video video = widget.video;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: Marquee(
            text: video.caption,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            pauseAfterRound: const Duration(seconds: 1),
            startAfter: const Duration(seconds: 1),
            velocity: 85,
            blankSpace: 100,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
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
                    color:
                        useDarkMode ? Colors.grey.shade300 : Colors.grey[800],
                    size: 20.0,
                  ),
                ),
                Text(
                  timeago.format(
                    video.datePosted,
                    locale: Localizations.localeOf(context).toString(),
                  ),
                  style: TextStyle(
                    color:
                        useDarkMode ? Colors.grey.shade300 : Colors.grey[700],
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
                color: useDarkMode ? Colors.white : Colors.black,
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
                color:
                    useDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
