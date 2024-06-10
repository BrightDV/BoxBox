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

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/video.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads',
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder(
        future: FileDownloader().database.allRecords(),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? snapshot.data!.isEmpty
                    ? Center(
                        child: Text(
                          '¯\\_(ツ)_/¯',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      )
                    : DownloadsList(snapshot.data!, update)
                : LoadingIndicatorUtil(),
      ),
    );
  }
}

class DownloadsList extends StatelessWidget {
  final List<TaskRecord> records;
  final Function update;
  const DownloadsList(this.records, this.update, {super.key});

  @override
  Widget build(BuildContext context) {
    Map downloadsDescriptions = Hive.box('downloads').get(
      'downloadsDescriptions',
      defaultValue: {},
    );

    return ListView.builder(
      shrinkWrap: true,
      itemCount: records.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => downloadsDescriptions[records[index].taskId]
                          ['type'] ==
                      'article'
                  ? ArticleScreen(
                      downloadsDescriptions[records[index].taskId]['id'],
                      downloadsDescriptions[records[index].taskId]['title'],
                      false,
                      update: update,
                    )
                  : VideoScreen(
                      Video(
                        downloadsDescriptions[records[index].taskId]['id'],
                        downloadsDescriptions[records[index].taskId]['url'],
                        downloadsDescriptions[records[index].taskId]['title'],
                        downloadsDescriptions[records[index].taskId]
                            ['description'],
                        downloadsDescriptions[records[index].taskId]
                            ['videoDuration'],
                        downloadsDescriptions[records[index].taskId]
                            ['thumbnail'],
                        DateTime.parse(
                          downloadsDescriptions[records[index].taskId]
                              ['datePosted'],
                        ),
                      ),
                      update: update,
                    ),
            ),
          );
        },
        child: Card(
          elevation: 5.0,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: CachedNetworkImage(
                  imageUrl: downloadsDescriptions[records[index].taskId]
                      ['thumbnail'],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Text(
                    downloadsDescriptions[records[index].taskId]['title'],
                    maxLines: 3,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
