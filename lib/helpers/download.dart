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

import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/api/brightcove.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadUtils {
  final String f1Endpoint = Constants().F1_API_URL;
  final String f1ApiKey = Constants().getOfficialApiKey();
  Future<String?> videoDownloadQualitySelector(
    BuildContext context,
  ) async {
    int playerQuality =
        Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    String? quality = await showDialog(
      context: context,
      builder: (context) {
        String selectedQuality = playerQuality.toString();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.qualityToDownload,
              style: TextStyle(
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Radio(
                    value: "180",
                    groupValue: selectedQuality,
                    onChanged: (String? value) => setState(() {
                      selectedQuality = value!;
                    }),
                  ),
                  Text(
                    '180p',
                  ),
                  Radio(
                    value: "360",
                    groupValue: selectedQuality,
                    onChanged: (String? value) => setState(() {
                      selectedQuality = value!;
                    }),
                  ),
                  Text(
                    '360p',
                  ),
                  Radio(
                    value: "720",
                    groupValue: selectedQuality,
                    onChanged: (String? value) => setState(() {
                      selectedQuality = value!;
                    }),
                  ),
                  Text(
                    '720p',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                ),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.download,
                ),
                onPressed: () async {
                  Navigator.of(context).pop(selectedQuality);
                },
              ),
            ],
          ),
        );
      },
    );
    return quality;
  }

  AlertDialog downloadedArticleActionPopup(
    String taskId,
    String articleId,
    String articleName,
    Function update,
    Function(TaskStatusUpdate) updateArticleWithType,
    BuildContext context,
    String articleChampionship,
  ) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            20.0,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.all(
        50.0,
      ),
      title: Text(
        AppLocalizations.of(context)!.alreadyDownloadedArticle,
        style: TextStyle(
          fontSize: 24.0,
        ),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.cancel,
          ),
        ),
        IconButton(
          onPressed: () async {
            await DownloadUtils().deleteFile(taskId);
            Navigator.of(context).pop();
            update();
          },
          icon: Icon(Icons.delete_outline),
          tooltip: AppLocalizations.of(context)!.delete,
        ),
        IconButton(
          onPressed: () async {
            await DownloadUtils().downloadArticle(
              articleId,
              articleName,
              articleChampionship,
              callback: updateArticleWithType,
            );
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.refresh),
          tooltip: AppLocalizations.of(context)!.refresh,
        ),
      ],
    );
  }

  Future<String> downloadArticle(
      String articleId, String articleTitle, String championship,
      {Function(TaskStatusUpdate)? callback}) async {
    String endpoint =
        Hive.box('settings').get('server', defaultValue: f1Endpoint) as String;

    String taskId = 'article_f1_$articleId';

    bool isDownloaded = await downloadedFileCheck(taskId);

    if (!isDownloaded) {
      FileDownloader().unregisterCallbacks(callback: callback);
      if (callback != null) {
        FileDownloader().registerCallbacks(taskStatusCallback: callback);
      }

      final task = DownloadTask(
        taskId: taskId,
        url: endpoint != f1Endpoint
            ? '$endpoint/f1/v1/editorial/articles/$articleId'
            : '$endpoint/v1/editorial/articles/$articleId',
        filename: '$taskId.json',
        displayName: articleTitle,
        headers: endpoint != f1Endpoint
            ? {
                "Accept": "application/json",
              }
            : {
                "Accept": "application/json",
                "apikey": f1ApiKey,
                "locale": "en",
              },
        //directory: 'Box, Box! Downloads',
        updates: Updates.statusAndProgress,
        //requiresWiFi: true,
        retries: 5,
      );

      final successfullyEnqueued = await FileDownloader().enqueue(task);

      if (successfullyEnqueued) {
        return "downloading";
      } else {
        return "not downloaded";
      }
    } else {
      return "already downloaded";
    }
  }

  Future<String> downloadVideo(
    String videoId,
    String quality, {
    Video? video,
    Function(TaskStatusUpdate)? callback,
  }) async {
    bool isDownloaded = await downloadedFileCheck('video_f1_$videoId');

    if (!isDownloaded) {
      FileDownloader().unregisterCallbacks(callback: callback);
      if (callback != null) {
        FileDownloader().registerCallbacks(taskStatusCallback: callback);
      }
      if (video == null) {
        video = await F1VideosFetcher().getVideoDetails(videoId);
      }

      Map links = await BrightCove().getVideoLinks(videoId);
      String link =
          links['videos'][links['qualities'].indexOf('${quality}p') + 1];
      // index 0 is preferred quality

      Map videoDetails = {
        'id': video.videoId,
        'title': video.caption,
        'thumbnail': video.thumbnailUrl,
        'url': video.videoUrl,
        'description': video.description,
        'videoDuration': video.videoDuration,
        'datePosted': video.datePosted.toIso8601String(),
      };

      String taskId = 'video_f1_$videoId';
      String filename = 'video_f1_$videoId.mp4';

      DownloadTask task = DownloadTask(
        taskId: taskId,
        url: link,
        filename: filename,
      );

      int fileSize = await task.expectedFileSize();
      videoDetails['fileSize'] = fileSize;

      task = DownloadTask(
        taskId: taskId,
        url: link,
        filename: filename,
        displayName: video.caption,
        //directory: 'Box, Box! Downloads',
        updates: Updates.statusAndProgress,
        //requiresWiFi: true,
        retries: 3,
        allowPause: true,
        metaData: json.encode(videoDetails),
      );

      final successfullyEnqueued = await FileDownloader().enqueue(task);

      if (successfullyEnqueued) {
        return "downloading";
      } else {
        return "not downloaded";
      }
    } else {
      return "already downloaded";
    }
  }

  Future<bool> downloadedFileCheck(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> downloadedFilePathIfExists(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      return await record.task.filePath();
    } else {
      return null;
    }
  }

  Future<void> deleteFile(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      // delete download taskId
      List downloads = await Hive.box('downloads').get(
        'downloadsList',
        defaultValue: [],
      );
      downloads.remove(taskId);
      await Hive.box('downloads').put('downloadsList', downloads);
      // delete download record
      await FileDownloader().database.deleteRecordWithId(taskId);
      // delete download description
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );
      downloadsDescriptions.remove(taskId);
      await Hive.box('downloads')
          .put('downloadsDescriptions', downloadsDescriptions);
      String filePath = await record.task.filePath();
      // delete file from device
      await File(filePath).delete();
    }
  }

  Future<Map?> downloadedFilePathAndNameIfExists(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );
      final String filePath = await record.task.filePath();
      final String name = downloadsDescriptions[taskId]['title'];
      return {'file': filePath, 'name': name};
    } else {
      return null;
    }
  }
}
