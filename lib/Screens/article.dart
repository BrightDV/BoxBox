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
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/api/article_parts.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class ArticleScreen extends StatefulWidget {
  final String articleId;
  final String articleName;
  final bool isFromLink;
  final Function? update;

  const ArticleScreen(
    this.articleId,
    this.articleName,
    this.isFromLink, {
    this.update,
    Key? key,
  }) : super(key: key);

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  ValueNotifier<String> articleTitle = ValueNotifier('Loading...');
  bool shouldRefresh = true;

  void updateTitle(String title) {
    articleTitle.value = title;
  }

  void update() {
    if (shouldRefresh) {
      setState(() {});
      if (widget.update != null) {
        widget.update!();
      }
    }
  }

  void updateWithType(TaskStatusUpdate statusUpdate) {
    if (statusUpdate.status == TaskStatus.complete) {
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );

      Formula1().downloadedFilePathIfExists(statusUpdate.task.taskId).then(
        (path) async {
          File file = File(path!);
          Map savedArticle = json.decode(await file.readAsString());

          String heroImageUrl = "";
          if (savedArticle['hero'].isNotEmpty) {
            if (savedArticle['hero']['contentType'] == 'atomVideo') {
              heroImageUrl = savedArticle['hero']['fields']['thumbnail']['url'];
            } else if (savedArticle['hero']['contentType'] ==
                'atomVideoYouTube') {
              heroImageUrl = savedArticle['hero']['fields']['image']['url'];
            } else if (savedArticle['hero']['contentType'] ==
                'atomImageGallery') {
              heroImageUrl =
                  savedArticle['hero']['fields']['imageGallery'][0]['url'];
            } else {
              heroImageUrl = savedArticle['hero']['fields']['image']['url'];
            }
          }

          downloadsDescriptions['article_${savedArticle['id']}'] = {
            'id': savedArticle['id'],
            'type': 'article',
            'title': savedArticle['title'],
            'thumbnail': heroImageUrl,
          };
          Hive.box('downloads')
              .put('downloadsDescriptions', downloadsDescriptions);
          update();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List downloads = Hive.box('downloads').get(
      'downloadsList',
      defaultValue: [],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          ValueListenableBuilder(
            valueListenable: articleTitle,
            builder: (context, value, _) {
              return value.toString() == 'Loading...'
                  ? Container()
                  : IconButton(
                      onPressed: () async {
                        String downloadingState =
                            await Formula1().downloadArticle(
                          widget.articleId,
                          callback: updateWithType,
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
                        } else if (downloadingState == "already downloaded") {
                          showDialog(
                            context: context,
                            builder: (context) => downloadedArticleActionPopup(
                              'article_${widget.articleId}',
                              widget.articleId,
                              update,
                              updateWithType,
                              context,
                            ),
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
                      },
                      icon: Icon(
                        downloads.contains('article_${widget.articleId}')
                            ? Icons.download_done_rounded
                            : Icons.save_alt_rounded,
                      ),
                    );
            },
          ),
        ],
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: widget.isFromLink
              ? ValueListenableBuilder(
                  valueListenable: articleTitle,
                  builder: (context, value, widget) {
                    return value.toString() == 'Loading...'
                        ? const Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Text('Loading...'),
                          )
                        : width > 1000
                            ? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(value.toString()),
                              )
                            : Marquee(
                                text: value.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                pauseAfterRound: const Duration(seconds: 1),
                                startAfter: const Duration(seconds: 1),
                                velocity: 85,
                                blankSpace: 100,
                              );
                  },
                )
              : width > 1000
                  ? Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(widget.articleName),
                    )
                  : Marquee(
                      text: widget.articleName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      pauseAfterRound: const Duration(seconds: 1),
                      startAfter: const Duration(seconds: 1),
                      velocity: 85,
                      blankSpace: 100,
                    ),
        ),
      ),
      body: ArticleProvider(widget.articleId, updateTitle),
    );
  }

  @override
  void dispose() {
    shouldRefresh = false;
    super.dispose();
  }
}

class ArticleProvider extends StatelessWidget {
  Future<Article> getArticleData(
      String articleId, Function updateArticleTitle) async {
    String? filePath =
        await Formula1().downloadedFilePathIfExists('article_${articleId}');
    if (filePath != null) {
      File file = File(filePath);
      Map savedArticle = await json.decode(await file.readAsString());
      Article article = Article(
        savedArticle['id'],
        savedArticle['slug'],
        savedArticle['title'],
        DateTime.parse(savedArticle['createdAt']),
        savedArticle['articleTags'],
        savedArticle['hero'] ?? {},
        savedArticle['body'],
        savedArticle['relatedArticles'],
        savedArticle['author'] ?? {},
      );
      updateArticleTitle(article.articleName);
      return article;
    } else {
      Article article = await Formula1().getArticleData(articleId);
      updateArticleTitle(article.articleName);
      return article;
    }
  }

  final String articleId;
  final Function updateArticleTitle;
  const ArticleProvider(
    this.articleId,
    this.updateArticleTitle, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Article>(
      future: getArticleData(articleId, updateArticleTitle),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? ArticleParts(snapshot.data!)
            : const LoadingIndicatorUtil();
      },
    );
  }
}

AlertDialog downloadedArticleActionPopup(
  String taskId,
  String articleId,
  Function update,
  Function(TaskStatusUpdate) updateWithType,
  BuildContext context,
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
      'This article has already been downloaded.',
      style: TextStyle(
        fontSize: 24.0,
      ), // here
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
          await Formula1().deleteFile(taskId);
          Navigator.of(context).pop();
          update();
        },
        icon: Icon(Icons.delete_outline),
        tooltip: 'Delete',
      ),
      IconButton(
        onPressed: () async {
          await Formula1().downloadArticle(
            articleId,
            callback: updateWithType,
          );
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    ],
  );
}
