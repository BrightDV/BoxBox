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

import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/free_practice_screen.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/custom_physics.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleParts extends StatelessWidget {
  final Article article;

  const ArticleParts(this.article, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController articleScrollController = ScrollController();
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 800
        : width > 1000
            ? 500
            : width;
    return (article.articleHero['contentType'] == 'atomVideo') ||
            (article.articleHero['contentType'] == 'atomVideoYouTube')
        ? NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedVideoPlayer(
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 300,
                        maxWidth: 800,
                      ),
                      child: VideoRenderer(
                        article.articleHero['fields']['videoId'] ?? '',
                        autoplay: true,
                        youtubeId: article.articleHero['fields']
                                ['youTubeVideoId'] ??
                            '',
                      ),
                    ),
                  ),
                  width / (16 / 9),
                ),
              ),
            ],
            body: SafeArea(
              child: Scrollbar(
                interactive: true,
                controller: articleScrollController,
                child: SingleChildScrollView(
                  controller: articleScrollController,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 300,
                        maxWidth: 800,
                      ),
                      child: WidgetsList(article, articleScrollController),
                    ),
                  ),
                ),
              ),
            ),
          )
        : MediaQuery.of(context).size.width > 1000
            ? SafeArea(
                child: Scrollbar(
                  interactive: true,
                  controller: articleScrollController,
                  child: SingleChildScrollView(
                    controller: articleScrollController,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 800,
                        ),
                        child: WidgetsList(article, articleScrollController),
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Scrollbar(
                  interactive: true,
                  controller: articleScrollController,
                  child: SingleChildScrollView(
                    controller: articleScrollController,
                    child: WidgetsList(article, articleScrollController),
                  ),
                ),
              );
  }
}

class WidgetsList extends StatelessWidget {
  final Article article;
  final ScrollController articleScrollController;
  const WidgetsList(this.article, this.articleScrollController, {super.key});

  @override
  Widget build(BuildContext context) {
    // load static variables
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    List articleContent = article.articleContent;

    // set the heroImageUrl for the history
    String heroImageUrl = "";
    if (article.articleHero.isNotEmpty) {
      if (article.articleHero['contentType'] == 'atomVideo') {
        heroImageUrl = article.articleHero['fields']['thumbnail']['url'];
      } else if (article.articleHero['contentType'] == 'atomVideoYouTube') {
        heroImageUrl = article.articleHero['fields']['image']['url'];
      } else if (article.articleHero['contentType'] == 'atomImageGallery') {
        heroImageUrl = article.articleHero['fields']['imageGallery'][0]['url'];
      } else {
        heroImageUrl = article.articleHero['fields']['image']['url'];
      }
    }

    // update the history
    List articlesHistory =
        Hive.box('history').get('articlesHistory', defaultValue: []) as List;
    if (articlesHistory.isEmpty) {
      articlesHistory.add(
        {
          'imageUrl': heroImageUrl,
          'articleId': article.articleId,
          'articleTitle': article.articleName,
          'timeVisited': DateTime.now().toString(),
        },
      );
    } else {
      if (articlesHistory[articlesHistory.length - 1]['articleId'] !=
          article.articleId) {
        articlesHistory.add(
          {
            'imageUrl': heroImageUrl,
            'articleId': article.articleId,
            'articleTitle': article.articleName,
            'timeVisited': DateTime.now().toString(),
          },
        );
      }
    }
    Hive.box('history').put('articlesHistory', articlesHistory);
    articlesHistory =
        Hive.box('history').get('articlesHistory', defaultValue: []) as List;

    // values for the related articles in web

    ScrollController scrollController = ScrollController();
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 450
        : width > 1000
            ? 500
            : 400;

    // return the different parts

    return Column(
      children: [
        // hero
        article.articleHero['contentType'] == 'atomImageGallery'
            ? ImageGallery(article.articleHero['fields']['imageGallery'])
            : (article.articleHero['contentType'] != 'atomVideo') &&
                    (article.articleHero['contentType'] != 'atomVideoYouTube')
                ? ImageRenderer(
                    useDataSaverMode
                        ? article.articleHero['fields']['image']
                                    ['renditions'] !=
                                null
                            ? article.articleHero['fields']['image']
                                ['renditions']['2col-retina']
                            : article.articleHero['fields']['image']['url'] +
                                '.transform/2col-retina/image.jpg'
                        : article.articleHero['fields']['image']['url'],
                    isHero: true,
                  )
                : Container(),

        // tags
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: [
                for (var tag in article.articleTags)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 5,
                      right: 5,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  tag['fields']['tagName'],
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              body: NewsFeed(tagId: tag['id']),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Text(
                            tag['fields']['tagName'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // content

        for (var element in articleContent)
          element['contentType'] == 'atomRichText'
              ? TextParagraphRenderer(element['fields']['richTextBlock'])
              : element['contentType'] == 'atomVideo'
                  ? VideoRenderer(
                      element['fields']['videoId'],
                      caption: element['fields']?['caption'] ?? '',
                    )
                  : element['contentType'] == 'atomVideoYouTube'
                      ? VideoRenderer(
                          '',
                          youtubeId: element['fields']['youTubeVideoId'],
                        )
                      : element['contentType'] == 'atomImage'
                          ? ImageRenderer(
                              useDataSaverMode
                                  ? element['fields']['image']['renditions'] !=
                                          null
                                      ? element['fields']['image']['renditions']
                                          ['2col-retina']
                                      : element['fields']['image']['url'] +
                                          '.transform/2col-retina/image.jpg'
                                  : element['fields']['image']['url'],
                              caption: element['fields']['caption'] ?? '',
                            )
                          : element['contentType'] == 'atomQuiz'
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                    vertical: 20.0,
                                  ),
                                  child: GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          20,
                                          10,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .openQuiz,
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.bar_chart,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .quiz,
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          body: InAppWebView(
                                            initialUrlRequest: URLRequest(
                                              url: WebUri(
                                                "https://www.riddle.com/view/${element['fields']['riddleId']}",
                                              ),
                                            ),
                                            initialSettings:
                                                InAppWebViewSettings(
                                              preferredContentMode:
                                                  UserPreferredContentMode
                                                      .DESKTOP,
                                            ),
                                            gestureRecognizers: {
                                              Factory<VerticalDragGestureRecognizer>(
                                                  () =>
                                                      VerticalDragGestureRecognizer()),
                                              Factory<HorizontalDragGestureRecognizer>(
                                                  () =>
                                                      HorizontalDragGestureRecognizer()),
                                              Factory<ScaleGestureRecognizer>(
                                                  () =>
                                                      ScaleGestureRecognizer()),
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : element['contentType'] == 'atomImageGallery'
                                  ? ImageGallery(
                                      element['fields']['imageGallery'],
                                    )
                                  : element['contentType'] == 'atomSocialPost'
                                      ? element['fields']['postType'] ==
                                              'Twitter'
                                          ? SizedBox(
                                              height: 450,
                                              child: InAppWebView(
                                                initialUrlRequest: URLRequest(
                                                  url: WebUri(
                                                    "https://farside.link/nitter/x/status/${element['fields']['postId']}/embed",
                                                  ),
                                                ),
                                                gestureRecognizers: {
                                                  Factory<VerticalDragGestureRecognizer>(
                                                      () =>
                                                          VerticalDragGestureRecognizer()),
                                                  Factory<HorizontalDragGestureRecognizer>(
                                                      () =>
                                                          HorizontalDragGestureRecognizer()),
                                                  Factory<ScaleGestureRecognizer>(
                                                      () =>
                                                          ScaleGestureRecognizer()),
                                                },
                                                initialSettings:
                                                    InAppWebViewSettings(
                                                  transparentBackground: true,
                                                ),
                                              ),
                                            )
                                          : element['fields']['postType'] ==
                                                  'Instagram'
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: TextButton.icon(
                                                      onPressed: () async =>
                                                          await launchUrl(
                                                        Uri.parse(
                                                            element['fields']
                                                                ['postUrl']),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      ),
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .instagram,
                                                      ),
                                                      label: const Text(
                                                        "Instagram Post",
                                                      ),
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Colors.white,
                                                        ),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          const Color.fromARGB(
                                                            255,
                                                            241,
                                                            77,
                                                            90,
                                                          ),
                                                        ),
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all<double>(5),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                      : element['contentType'] ==
                                              'atomLiveBlogScribbleLive'
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 5.0,
                                                vertical: 30.0,
                                              ),
                                              child: GestureDetector(
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      5,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                      20,
                                                      10,
                                                      20,
                                                      10,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .openLiveBlog,
                                                        ),
                                                        const Spacer(),
                                                        SizedBox(
                                                          width: 30.0,
                                                          height: 30.0,
                                                          child:
                                                              LoadingIndicator(
                                                            indicatorType: Indicator
                                                                .ballScaleMultiple,
                                                            colors: [
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Scaffold(
                                                      appBar: AppBar(
                                                        title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .liveBlog,
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary,
                                                      ),
                                                      body: InAppWebView(
                                                        initialUrlRequest:
                                                            URLRequest(
                                                          url: WebUri(
                                                            "https://embed.scribblelive.com/Embed/v7.aspx?Id=${element['fields']['scribbleEventId'].split('/')[2]}&ThemeId=37480",
                                                          ),
                                                        ),
                                                        gestureRecognizers: {
                                                          Factory<VerticalDragGestureRecognizer>(
                                                              () =>
                                                                  VerticalDragGestureRecognizer()),
                                                          Factory<HorizontalDragGestureRecognizer>(
                                                              () =>
                                                                  HorizontalDragGestureRecognizer()),
                                                          Factory<ScaleGestureRecognizer>(
                                                              () =>
                                                                  ScaleGestureRecognizer()),
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : element['contentType'] ==
                                                  'atomInteractiveExperience'
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 5.0,
                                                    vertical: 30.0,
                                                  ),
                                                  child: GestureDetector(
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSecondary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                          20,
                                                          10,
                                                          20,
                                                          10,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .openLiveBlog,
                                                            ),
                                                            const Spacer(),
                                                            SizedBox(
                                                              width: 30.0,
                                                              height: 30.0,
                                                              child:
                                                                  LoadingIndicator(
                                                                indicatorType:
                                                                    Indicator
                                                                        .ballScaleMultiple,
                                                                colors: [
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(
                                                            title: Text(
                                                              element['fields']
                                                                  ['title'],
                                                            ),
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary,
                                                          ),
                                                          body: InAppWebView(
                                                            initialUrlRequest:
                                                                URLRequest(
                                                              url: WebUri(
                                                                element['fields']
                                                                    [
                                                                    'eventUrl'],
                                                              ),
                                                            ),
                                                            gestureRecognizers: {
                                                              Factory<VerticalDragGestureRecognizer>(
                                                                  () =>
                                                                      VerticalDragGestureRecognizer()),
                                                              Factory<HorizontalDragGestureRecognizer>(
                                                                  () =>
                                                                      HorizontalDragGestureRecognizer()),
                                                              Factory<ScaleGestureRecognizer>(
                                                                  () =>
                                                                      ScaleGestureRecognizer()),
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : element['contentType'] ==
                                                      'atomSessionResults'
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        10,
                                                      ),
                                                      child: Container(
                                                        height: element['fields']
                                                                    [
                                                                    'sessionType']
                                                                .startsWith(
                                                                    'Starting Grid')
                                                            ? 378
                                                            : 290,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSecondary,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            15.0,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 15,
                                                              ),
                                                              child: Text(
                                                                element['fields']
                                                                    [
                                                                    'meetingCountryName'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              element['fields'][
                                                                          'sessionType'] ==
                                                                      'Race'
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .race
                                                                  : element['fields']
                                                                              [
                                                                              'sessionType'] ==
                                                                          'Qualifying'
                                                                      ? AppLocalizations.of(
                                                                              context)!
                                                                          .qualifyings
                                                                      : element['fields']['sessionType'] ==
                                                                              'Sprint'
                                                                          ? AppLocalizations.of(context)!
                                                                              .sprint
                                                                          : element['fields']['sessionType'] == 'Sprint Shootout'
                                                                              ? 'Sprint Shootout'
                                                                              : element['fields']['sessionType'].startsWith('Starting Grid')
                                                                                  ? element['fields']['sessionType']
                                                                                  : element['fields']['sessionType'].endsWith('1')
                                                                                      ? AppLocalizations.of(context)!.freePracticeOne
                                                                                      : element['fields']['sessionType'].endsWith('2')
                                                                                          ? AppLocalizations.of(context)!.freePracticeTwo
                                                                                          : AppLocalizations.of(context)!.freePracticeThree,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 15,
                                                                left: 15,
                                                              ),
                                                              child: Row(
                                                                children: element['fields']
                                                                            [
                                                                            'sessionType']
                                                                        .startsWith(
                                                                            'Starting Grid')
                                                                    ? [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.positionAbbreviation,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Container(),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.driverAbbreviation,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              6,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.team.toUpperCase(),
                                                                          ),
                                                                        ),
                                                                      ]
                                                                    : [
                                                                        Expanded(
                                                                          flex: element['fields']['sessionType'] == 'Race' || element['fields']['sessionType'] == 'Sprint'
                                                                              ? 5
                                                                              : 4,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.positionAbbreviation,
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        Expanded(
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Text(
                                                                            AppLocalizations.of(context)!.time,
                                                                          ),
                                                                        ),
                                                                        element['fields']['sessionType'] == 'Race' ||
                                                                                element['fields']['sessionType'] == 'Sprint'
                                                                            ? Expanded(
                                                                                flex: 3,
                                                                                child: Text(
                                                                                  AppLocalizations.of(context)!.pointsAbbreviation,
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                      ],
                                                              ),
                                                            ),
                                                            for (Map driverResults in element[
                                                                            'fields']
                                                                        [
                                                                        'sessionType']
                                                                    .startsWith(
                                                                        'Starting Grid')
                                                                ? element['fields']
                                                                        ['startingGrid']
                                                                    ['results']
                                                                : element['fields']
                                                                        ['raceResults${element['fields']['sessionType'] == 'Sprint' ? 'SprintQualifying' : element['fields']['sessionType'] == 'Sprint Shootout' ? 'SprintShootout' : element['fields']['sessionType']}']
                                                                    ['results'])
                                                              element['fields']['sessionType'] ==
                                                                          'Race' ||
                                                                      element['fields']['sessionType'] ==
                                                                          'Sprint'
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        top: 7,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Text(
                                                                              driverResults['positionNumber'] == '66666' ? 'DQ' : driverResults['positionNumber'],
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 15,
                                                                              child: VerticalDivider(
                                                                                color: Color(
                                                                                  int.parse(
                                                                                    driverResults['teamColourCode'] == null ? '00FFFFFF' : 'FF${driverResults['teamColourCode']}',
                                                                                    radix: 16,
                                                                                  ),
                                                                                ),
                                                                                thickness: 5,
                                                                                width: 5,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                3,
                                                                            child:
                                                                                Text(
                                                                              driverResults['driverTLA'].toString(),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Expanded(
                                                                            flex:
                                                                                6,
                                                                            child:
                                                                                Text(
                                                                              driverResults['gapToLeader'] != "0.0"
                                                                                  ? '+${driverResults['gapToLeader']}'
                                                                                  : element['fields']['sessionType'] == 'Race'
                                                                                      ? driverResults['raceTime']
                                                                                      : driverResults['sprintQualifyingTime'],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                3,
                                                                            child:
                                                                                Text(
                                                                              element['fields']['sessionType'] == 'Race' ? (driverResults['racePoints'] ?? '0').toString() : (driverResults['sprintQualifyingPoints'] ?? '0').toString(),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : element['fields']
                                                                              ['sessionType']
                                                                          .startsWith('Starting Grid')
                                                                      ? Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            top:
                                                                                7,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  driverResults['positionNumber'] == '66666' ? 'DQ' : driverResults['positionNumber'],
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: SizedBox(
                                                                                  height: 15,
                                                                                  child: VerticalDivider(
                                                                                    color: Color(
                                                                                      int.parse(
                                                                                        driverResults['teamColourCode'] == null ? '00FFFFFF' : 'FF${driverResults['teamColourCode']}',
                                                                                        radix: 16,
                                                                                      ),
                                                                                    ),
                                                                                    thickness: 5,
                                                                                    width: 5,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 4,
                                                                                child: Text(
                                                                                  driverResults['driverLastName'],
                                                                                ),
                                                                              ),
                                                                              const Spacer(),
                                                                              Expanded(
                                                                                flex: 6,
                                                                                child: Text(
                                                                                  driverResults['teamName'],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            top:
                                                                                7,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  driverResults['positionNumber'] == '66666' ? 'DQ' : driverResults['positionNumber'],
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: SizedBox(
                                                                                  height: 15,
                                                                                  child: VerticalDivider(
                                                                                    color: Color(
                                                                                      int.parse(
                                                                                        driverResults['teamColourCode'] == null ? '00FFFFFF' : 'FF${driverResults['teamColourCode']}',
                                                                                        radix: 16,
                                                                                      ),
                                                                                    ),
                                                                                    thickness: 5,
                                                                                    width: 5,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 3,
                                                                                child: Text(
                                                                                  driverResults['driverTLA'].toString(),
                                                                                ),
                                                                              ),
                                                                              const Spacer(),
                                                                              Expanded(
                                                                                flex: 6,
                                                                                child: Text(
                                                                                  element['fields']['sessionType'].startsWith('Practice') ? driverResults['classifiedTime'] ?? '--' : driverResults['q3']?['classifiedTime'] ?? '--',
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 15,
                                                                ),
                                                                child: SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft:
                                                                          Radius
                                                                              .zero,
                                                                      topRight:
                                                                          Radius
                                                                              .zero,
                                                                      bottomLeft:
                                                                          Radius
                                                                              .circular(
                                                                        15,
                                                                      ),
                                                                      bottomRight:
                                                                          Radius
                                                                              .circular(
                                                                        15,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => element['fields']['sessionType'].startsWith('Practice')
                                                                              ? FreePracticeScreen(
                                                                                  element['fields']['raceResults${element['fields']['sessionType']}']['description'].endsWith('1')
                                                                                      ? AppLocalizations.of(context)!.freePracticeOne
                                                                                      : element['fields']['raceResults${element['fields']['sessionType']}']['description'].endsWith('2')
                                                                                          ? AppLocalizations.of(context)!.freePracticeTwo
                                                                                          : AppLocalizations.of(context)!.freePracticeThree,
                                                                                  int.parse(
                                                                                    element['fields']['raceResults${element['fields']['sessionType']}']['session'].substring(1),
                                                                                  ),
                                                                                  '',
                                                                                  int.parse(
                                                                                    element['fields']['season'],
                                                                                  ),
                                                                                  element['fields']['meetingOfficialName'],
                                                                                  raceUrl: element['fields']['cta'],
                                                                                )
                                                                              : Scaffold(
                                                                                  appBar: AppBar(
                                                                                    title: Text(
                                                                                      element['fields']['sessionType'] == 'Race'
                                                                                          ? AppLocalizations.of(context)!.race
                                                                                          : element['fields']['sessionType'] == 'Sprint'
                                                                                              ? AppLocalizations.of(context)!.sprint
                                                                                              : element['fields']['sessionType'] == 'Sprint Shootout'
                                                                                                  ? 'Sprint Shootout'
                                                                                                  : element['fields']['cta'].endsWith('starting-grid.html')
                                                                                                      ? AppLocalizations.of(context)!.startingGrid
                                                                                                      : AppLocalizations.of(context)!.qualifyings,
                                                                                    ),
                                                                                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                                                                  ),
                                                                                  backgroundColor: Theme.of(context).colorScheme.background,
                                                                                  body: element['fields']['sessionType'] == 'Race' || element['fields']['sessionType'] == 'Sprint'
                                                                                      ? RaceResultsProvider(
                                                                                          raceUrl: element['fields']['cta'],
                                                                                        )
                                                                                      : SingleChildScrollView(
                                                                                          child: element['fields']['cta'].endsWith('starting-grid.html')
                                                                                              ? StartingGridProvider(element['fields']['cta'])
                                                                                              : QualificationResultsProvider(
                                                                                                  raceUrl: element['fields']['cta'],
                                                                                                  isSprintShootout: element['fields']['sessionType'] == 'Sprint Shootout' ? true : false,
                                                                                                ),
                                                                                        ),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            const ContinuousRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.zero,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.of(context)!
                                                                            .viewResults,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : element['contentType'] ==
                                                          'atomTableContent'
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSecondary,
                                                              ),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                  15,
                                                                ),
                                                                topRight: Radius
                                                                    .circular(
                                                                  15,
                                                                ),
                                                              ),
                                                            ),
                                                            height:
                                                                (element['fields']['tableData']['tableContent'].length +
                                                                            1) *
                                                                        50.0 +
                                                                    2,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 50,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      child:
                                                                          Text(
                                                                        element['fields']
                                                                            [
                                                                            'title'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  for (List driverItem
                                                                      in element['fields']
                                                                              [
                                                                              'tableData']
                                                                          [
                                                                          'tableContent'])
                                                                    Row(
                                                                      children: <Widget>[
                                                                        for (Map driverDetails
                                                                            in driverItem)
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(
                                                                                color: Theme.of(context).colorScheme.onSecondary,
                                                                              ),
                                                                            ),
                                                                            width:
                                                                                150,
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Center(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(4),
                                                                                child: Text(
                                                                                  driverDetails['value'].toString(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : element['contentType'] ==
                                                              'atomAudioBoom'
                                                          ? SizedBox(
                                                              height: 400,
                                                              child:
                                                                  InAppWebView(
                                                                initialUrlRequest:
                                                                    URLRequest(
                                                                  url: WebUri(
                                                                    'https:${element['fields']['audioPodcast']['iFrameSrc']}',
                                                                  ),
                                                                ),
                                                                gestureRecognizers: {
                                                                  Factory<VerticalDragGestureRecognizer>(
                                                                      () =>
                                                                          VerticalDragGestureRecognizer()),
                                                                  Factory<HorizontalDragGestureRecognizer>(
                                                                      () =>
                                                                          HorizontalDragGestureRecognizer()),
                                                                  Factory<ScaleGestureRecognizer>(
                                                                      () =>
                                                                          ScaleGestureRecognizer()),
                                                                },
                                                                initialSettings:
                                                                    InAppWebViewSettings(
                                                                        transparentBackground:
                                                                            true),
                                                              ),
                                                            )
                                                          : element['contentType'] ==
                                                                  'atomLinkList'
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  child: ListView
                                                                      .builder(
                                                                    itemCount:
                                                                        element['fields']['items'].length +
                                                                            1,
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    itemBuilder: (context,
                                                                            index) =>
                                                                        index ==
                                                                                0
                                                                            ? Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  bottom: 10,
                                                                                ),
                                                                                child: Text(
                                                                                  element['fields']['title'],
                                                                                  style: TextStyle(
                                                                                    fontSize: 19,
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : GestureDetector(
                                                                                onTap: () {
                                                                                  String articleUrl = element['fields']['items'][index - 1]['webUrl'];
                                                                                  String articleId = articleUrl.substring(43, articleUrl.length - 5).split('.')[1];
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => ArticleScreen(
                                                                                        articleId,
                                                                                        element['fields']['items'][index - 1]['title'],
                                                                                        true,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(2),
                                                                                  child: Text(
                                                                                    '• ${element['fields']['items'][index - 1]['title']}',
                                                                                    style: TextStyle(
                                                                                      color: Theme.of(context).primaryColor,
                                                                                      decoration: TextDecoration.underline,
                                                                                      fontSize: 16,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                  ),
                                                                )
                                                              : element['contentType'] ==
                                                                      'atomPullQuote'
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5),
                                                                                child: Text(
                                                                                  '“',
                                                                                  style: TextStyle(
                                                                                    fontSize: 50,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 20,
                                                                              child: Align(
                                                                                alignment: Alignment.center,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                                                  child: Text(
                                                                                    element['fields']['quoteText'],
                                                                                    style: TextStyle(
                                                                                      color: Theme.of(context).colorScheme.primary,
                                                                                      fontSize: 22,
                                                                                      fontStyle: FontStyle.italic,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 5),
                                                                                child: Text(
                                                                                  '”',
                                                                                  style: TextStyle(
                                                                                    fontSize: 50,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            element['fields']['quoteCitation'],
                                                                            style:
                                                                                TextStyle(
                                                                              color: useDarkMode ? Colors.grey[400] : Colors.grey[800],
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(
                                                                      height:
                                                                          100,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            SelectableText(
                                                                          'Unsupported widget ¯\\_(ツ)_/¯\nType: ${element['contentType']}\nArticle id: ${article.articleId}',
                                                                        ),
                                                                      ),
                                                                    ),

        // author

        if (article.authorDetails.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  article.authorDetails['image'] != null
                      ? Image.network(
                          article.authorDetails['image']['url'],
                          height: 80,
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.authorDetails["fullName"],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          article.authorDetails["shortDescription"] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // bottom action bar

        Card(
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                        ),
                        onPressed: () => Share.share(
                          "https://www.formula1.com/en/latest/article.${article.articleSlug}.${article.articleId}.html",
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.share,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.schedule,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        DateFormat('kk:mm\nyyyy-MM-dd')
                            .format(article.publishedDate),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // related articles

        kIsWeb
            ? Stack(
                alignment: Alignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var article in article.relatedArticles)
                          NewsItem(
                            News(
                              article['id'],
                              article['articleType'],
                              article['slug'],
                              article['title'],
                              article['metaDescription'] ?? ' ',
                              DateTime.parse(article['updatedAt']),
                              article['thumbnail'] != null
                                  ? useDataSaverMode
                                      ? article['thumbnail']['image']
                                                  ['renditions'] !=
                                              null
                                          ? article['thumbnail']['image']
                                              ['renditions']['2col']
                                          : article['thumbnail']['image']
                                                  ['url'] +
                                              '.transform/2col-retina/image.jpg'
                                      : article['thumbnail']['image']['url']
                                  : '',
                            ),
                            true,
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: GestureDetector(
                        onTap: () => scrollController.animateTo(
                          scrollController.offset - width + 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () => scrollController.animateTo(
                          scrollController.offset + width - 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 275,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  physics: const PagingScrollPhysics(
                    itemDimension: 300,
                  ),
                  itemCount: article.relatedArticles.length,
                  itemBuilder: (context, index) => NewsItem(
                    News(
                      article.relatedArticles[index]['id'],
                      article.relatedArticles[index]['articleType'],
                      article.relatedArticles[index]['slug'],
                      article.relatedArticles[index]['title'],
                      article.relatedArticles[index]['metaDescription'] ?? ' ',
                      DateTime.parse(
                          article.relatedArticles[index]['updatedAt']),
                      article.relatedArticles[index]['thumbnail'] != null
                          ? useDataSaverMode
                              ? article.relatedArticles[index]['thumbnail']
                                          ['image']['renditions'] !=
                                      null
                                  ? article.relatedArticles[index]['thumbnail']
                                      ['image']['renditions']['2col']
                                  : article.relatedArticles[index]['thumbnail']
                                          ['image']['url'] +
                                      '.transform/2col-retina/image.jpg'
                              : article.relatedArticles[index]['thumbnail']
                                  ['image']['url']
                          : '',
                    ),
                    true,
                    width: 300,
                  ),
                ),
              ),
      ],
    );
  }
}
