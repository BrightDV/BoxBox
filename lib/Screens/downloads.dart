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

    List<List<TaskRecord>> separatedRecords = [[], []];

    for (var record in records) {
      if (record.status != TaskStatus.complete) {
        separatedRecords[0].add(record);
      } else {
        separatedRecords[1].add(record);
      }
    }
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            separatedRecords[0].length != 0
                ? Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                    child: Text(
                      'Pending',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : Container(),
            separatedRecords[0].length != 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: separatedRecords[0].length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return PendingDownloadItem(
                        separatedRecords[0][index],
                        update,
                      );
                    },
                  )
                : Container(),
            separatedRecords[1].length != 0
                ? Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : Container(),
            separatedRecords[1].length != 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: separatedRecords[1].length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => downloadsDescriptions[
                                            separatedRecords[1][index].taskId]
                                        ['type'] ==
                                    'article'
                                ? ArticleScreen(
                                    downloadsDescriptions[
                                            separatedRecords[1][index].taskId]
                                        ['id'],
                                    downloadsDescriptions[
                                            separatedRecords[1][index].taskId]
                                        ['title'],
                                    false,
                                    update: update,
                                  )
                                : VideoScreen(
                                    Video(
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['id'],
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['url'],
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['title'],
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['description'],
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['videoDuration'],
                                      downloadsDescriptions[
                                              separatedRecords[1][index].taskId]
                                          ['thumbnail'],
                                      DateTime.parse(
                                        downloadsDescriptions[
                                            separatedRecords[1][index]
                                                .taskId]['datePosted'],
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: downloadsDescriptions[
                                          separatedRecords[1][index].taskId]
                                      ['thumbnail'],
                                ),
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
                                  downloadsDescriptions[
                                          separatedRecords[1][index].taskId]
                                      ['title'],
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
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class PendingDownloadItem extends StatefulWidget {
  final TaskRecord taskRecord;
  final Function updateWhenDownloadComplete;
  const PendingDownloadItem(
    this.taskRecord,
    this.updateWhenDownloadComplete, {
    super.key,
  });

  @override
  State<PendingDownloadItem> createState() => _PendingDownloadItemState();
}

class _PendingDownloadItemState extends State<PendingDownloadItem> {
  late Timer timer;
  bool isDownloadFinished = false;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (isDownloadFinished) {
        widget.updateWhenDownloadComplete();
      } else {
        setState(
          () {},
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map taskDetails = json.decode(
      widget.taskRecord.task.metaData,
    );
    final List<Color> gradient = [
      Theme.of(context).colorScheme.onPrimary.withAlpha(150),
      Theme.of(context).colorScheme.onPrimary.withAlpha(200),
      Colors.transparent,
      Colors.transparent,
    ];

    return Card(
      elevation: 5.0,
      child: FutureBuilder(
        future: FileDownloader().database.recordForId(widget.taskRecord.taskId),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.status == TaskStatus.complete) {
            isDownloadFinished = true;
            return Container();
          } else {
            return Container(
              decoration: snapshot.hasData
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: gradient,
                        stops: [
                          0.0,
                          snapshot.data!.progress,
                          snapshot.data!.progress,
                          1.0,
                        ],
                      ),
                    )
                  : null,
              child: SizedBox(
                height: 80,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      taskDetails['title'],
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}