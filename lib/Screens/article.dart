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
import 'package:boxbox/api/article_widgets.dart';
import 'package:boxbox/classes/article.dart';
import 'package:boxbox/helpers/bottom_sheet.dart';
import 'package:boxbox/helpers/download.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/providers/article/format.dart';
import 'package:boxbox/providers/article/requests.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class ArticleScreen extends StatefulWidget {
  final String articleId;
  final String articleName;
  final bool isFromLink;
  final Function? update;
  final News? news;
  final String championshipOfArticle;

  const ArticleScreen(
    this.articleId,
    this.articleName,
    this.isFromLink, {
    this.update,
    this.news,
    this.championshipOfArticle = '',
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

  void updateArticleWithType(TaskStatusUpdate statusUpdate) {
    if (statusUpdate.status == TaskStatus.complete) {
      Map downloadsDescriptions = Hive.box('downloads').get(
        'downloadsDescriptions',
        defaultValue: {},
      );
      DownloadUtils().downloadedFilePathIfExists(statusUpdate.task.taskId).then(
        (path) async {
          String championship = Hive.box('settings')
              .get('championship', defaultValue: 'Formula 1') as String;
          File file = File(path!);
          Map savedArticle = json.decode(await file.readAsString());
          String heroImageUrl =
              ArticleFormatProvider().formatHeroUrl(savedArticle);

          String taskId = 'article_f1_${savedArticle['id']}';

          downloadsDescriptions[taskId] = {
            'id': savedArticle['id'].toString(),
            'type': 'article',
            'title': savedArticle['title'],
            'thumbnail': heroImageUrl,
            'championship': championship,
          };
          Hive.box('downloads')
              .put('downloadsDescriptions', downloadsDescriptions);
          List downloads = Hive.box('downloads').get(
            'downloadsList',
            defaultValue: [],
          );
          downloads.insert(0, taskId);
          Hive.box('downloads').put('downloadsList', downloads);
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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    String championshipOfArticle = widget.championshipOfArticle;
    if (championshipOfArticle == '') {
      championshipOfArticle = championship;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          ValueListenableBuilder(
            valueListenable: articleTitle,
            builder: (context, value, _) {
              return value.toString() == 'Loading...' ||
                      championshipOfArticle != 'Formula 1' ||
                      kIsWeb
                  ? Container()
                  : IconButton(
                      onPressed: () async {
                        String downloadingState =
                            await DownloadUtils().downloadArticle(
                          widget.articleId,
                          widget.articleName,
                          championshipOfArticle,
                          callback: updateArticleWithType,
                        );
                        if (downloadingState == "downloading") {
                          await Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.downloading,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else if (downloadingState == "already downloaded") {
                          showCustomBottomSheet(
                            context,
                            DownloadUtils().downloadedArticleBottomSheetContent(
                              'article_f1_${widget.articleId}',
                              widget.articleId,
                              widget.articleName,
                              update,
                              updateArticleWithType,
                              context,
                              championshipOfArticle,
                            ),
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
                      },
                      icon: Icon(
                        downloads.contains(
                          'article_f1_${widget.articleId}',
                        )
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
      body: ArticleProvider(
        widget.articleId,
        updateTitle,
        championshipOfArticle,
        news: widget.news,
      ),
    );
  }

  @override
  void dispose() {
    shouldRefresh = false;
    super.dispose();
  }
}

class ArticleProvider extends StatelessWidget {
  final String articleId;
  final Function updateArticleTitle;
  final String championshipOfArticle;
  final News? news;

  const ArticleProvider(
    this.articleId,
    this.updateArticleTitle,
    this.championshipOfArticle, {
    this.news,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Article>(
      future: ArticleRequestsProvider().getArticleData(
        articleId,
        updateArticleTitle,
        championshipOfArticle,
        news,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? snapshot.data!.articleContent.length == 0
                ? ArticleWebView(snapshot.data!)
                : ArticleParts(
                    snapshot.data!,
                    articleChampionship: championshipOfArticle,
                  )
            : const LoadingIndicatorUtil();
      },
    );
  }
}

class ArticleWebView extends StatefulWidget {
  final Article article;
  const ArticleWebView(this.article, {super.key});

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          'https://www.fiaformulae.com/en/news/${widget.article.articleId}?webview=true',
        ),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Sec-GPC': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'none',
          'Sec-Fetch-User': '?1',
        },
      ),
      initialSettings: InAppWebViewSettings(
        contentBlockers: [
          ContentBlocker(
            trigger: ContentBlockerTrigger(
              urlFilter: '.*',
            ),
            action: ContentBlockerAction(
              type: ContentBlockerActionType.CSS_DISPLAY_NONE,
              selector:
                  '.onetrust-pc-dark-filter, .otFlat, ._hj_feedback_container, .global-race-bar',
            ),
          ),
        ],
      ),
      gestureRecognizers: {
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
        Factory<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
        ),
        Factory<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(),
        ),
      },
    );
  }
}
