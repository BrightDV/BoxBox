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
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
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

  Future updateDownloadsState(String newStatus) async {
    if (newStatus == 'pause') {
      List<TaskRecord> records = await FileDownloader()
          .database
          .allRecordsWithStatus(TaskStatus.running);
      for (var record in records) {
        final task = record.task;
        if (task is DownloadTask) {
          await FileDownloader().pause(task);
        }
      }
    } else {
      List<TaskRecord> records = await FileDownloader()
          .database
          .allRecordsWithStatus(TaskStatus.paused);
      for (var record in records) {
        final task = record.task;
        if (task is DownloadTask) {
          await FileDownloader().resume(task);
        }
      }
    }
    await Future.delayed(Duration(milliseconds: 300), update);
  }

  bool hasRunningDownloads(List<TaskRecord> records) {
    for (var record in records) {
      if (record.status == TaskStatus.running) {
        return true;
      }
    }
    return false;
  }

  Future deleteDownloads(List<TaskRecord> records) async {
    for (var record in records) {
      await Formula1().deleteFile(record.taskId);
    }
    update();
  }

  @override
  Widget build(BuildContext context) {
    List downloads = Hive.box('downloads').get(
      'downloadsList',
      defaultValue: [],
    );
    return FutureBuilder(
      future: FileDownloader().database.allRecords(),
      builder: (context, snapshot) => snapshot.hasError
          ? Scaffold(
              appBar: AppBar(
                title: Text(
                  'Downloads',
                ),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: Center(
                child: RequestErrorWidget(snapshot.error.toString()),
              ),
            )
          : snapshot.hasData
              ? snapshot.data!.isEmpty
                  ? Scaffold(
                      appBar: AppBar(
                        title: Text(
                          'Downloads',
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      body: Center(
                        child: Text(
                          '¯\\_(ツ)_/¯',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    )
                  : Scaffold(
                      appBar: AppBar(
                        title: Text(
                          'Downloads',
                        ),
                        actions: [
                          snapshot.data!.length != downloads.length
                              ? hasRunningDownloads(snapshot.data!)
                                  ? IconButton(
                                      onPressed: () async =>
                                          await updateDownloadsState('pause'),
                                      icon: Icon(
                                        Icons.pause_outlined,
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () async =>
                                          await updateDownloadsState('resume'),
                                      icon: Icon(
                                        Icons.play_arrow_outlined,
                                      ),
                                    )
                              : Container(),
                          IconButton(
                            onPressed: () async =>
                                await deleteDownloads(snapshot.data!),
                            icon: Icon(
                              Icons.delete_outline,
                            ),
                          )
                        ],
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      body: DownloadsList(snapshot.data!, update),
                    )
              : Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Downloads',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  body: LoadingIndicatorUtil(),
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
                      'Running',
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
                      return RunningDownloadItem(
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

class RunningDownloadItem extends StatefulWidget {
  final TaskRecord taskRecord;
  final Function updateWhenDownloadComplete;
  const RunningDownloadItem(
    this.taskRecord,
    this.updateWhenDownloadComplete, {
    super.key,
  });

  @override
  State<RunningDownloadItem> createState() => _RunningDownloadItemState();
}

class _RunningDownloadItemState extends State<RunningDownloadItem> {
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
                height: 90,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskDetails['title'],
                        maxLines: 3,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                      ),
                      taskDetails['fileSize'] != null &&
                              taskDetails['fileSize'] != -1
                          ? Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                filesize(taskDetails['fileSize']),
                              ),
                            )
                          : Container(),
                    ],
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
