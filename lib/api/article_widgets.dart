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

import 'package:boxbox/api/atom_article_parts.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/custom_physics.dart';
import 'package:boxbox/helpers/news.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ArticleParts extends StatelessWidget {
  final Article article;
  final String? articleChampionship;

  const ArticleParts(
    this.article, {
    this.articleChampionship,
    Key? key,
  }) : super(key: key);

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
                        youtubeThumbnail: article.articleHero['fields']['image']
                                ?['url'] ??
                            '',
                        player: article.articleHero['fields']['player'],
                        articleChampionship: articleChampionship,
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
                      child: WidgetsList(
                        article,
                        articleScrollController,
                        articleChampionship: articleChampionship,
                      ),
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
                        child: WidgetsList(
                          article,
                          articleScrollController,
                          articleChampionship: articleChampionship,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Scrollbar(
                  interactive: true,
                  controller: articleScrollController,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: WidgetsList(
                      article,
                      articleScrollController,
                      articleChampionship: articleChampionship,
                    ),
                  ),
                ),
              );
  }
}

class WidgetsList extends StatelessWidget {
  final Article article;
  final ScrollController articleScrollController;
  final String? articleChampionship;
  const WidgetsList(
    this.article,
    this.articleScrollController, {
    this.articleChampionship,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // load static variables
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
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
          'articleChampionship': articleChampionship ?? championship,
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
            'articleChampionship': articleChampionship ?? championship,
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

    return ListView(
      shrinkWrap: true,
      controller: articleScrollController,
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
        if (article.articleTags.isNotEmpty) TagsList(article),

        // content
        for (var element in articleContent)
          element['contentType'] == 'atomRichText'
              ? TextParagraphRenderer(element['fields']['richTextBlock'])
              : element['contentType'] == 'atomVideo'
                  ? VideoRenderer(
                      element['fields']['videoId'],
                      caption: element['fields']?['caption'] ?? '',
                      player: element['fields']['player'],
                      articleChampionship: articleChampionship,
                    )
                  : element['contentType'] == 'atomVideoYouTube'
                      ? VideoRenderer(
                          '',
                          youtubeId: element['fields']['youTubeVideoId'],
                          youtubeThumbnail: article.articleHero['fields']
                                  ['image']['url'] ??
                              '',
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
                              ? AtomQuiz(element)
                              : element['contentType'] == 'atomImageGallery'
                                  ? ImageGallery(
                                      element['fields']['imageGallery'],
                                    )
                                  : element['contentType'] == 'atomSocialPost'
                                      ? AtomSocialButton(element)
                                      : element['contentType'] ==
                                              'atomLiveBlogScribbleLive'
                                          ? AtomScribbleLive(element)
                                          : element['contentType'] ==
                                                  'atomInteractiveExperience'
                                              ? AtomInteractiveExperience(
                                                  element)
                                              : element['contentType'] ==
                                                      'atomSessionResults'
                                                  ? AtomSessionResults(element)
                                                  : element['contentType'] ==
                                                          'atomTableContent'
                                                      ? AtomTableContent2(
                                                          element)
                                                      : element['contentType'] ==
                                                              'atomAudioBoom'
                                                          ? AtomAudioBoom(
                                                              element)
                                                          : element['contentType'] ==
                                                                  'atomLinkList'
                                                              ? AtomLinkList(
                                                                  element)
                                                              : element['contentType'] ==
                                                                      'atomPullQuote'
                                                                  ? AtomPullQuote(
                                                                      element)
                                                                  : element['contentType'] ==
                                                                          'atomPromotion'
                                                                      ? Container()
                                                                      : element['contentType'] ==
                                                                              'linkItem'
                                                                          ? Padding(
                                                                              padding: EdgeInsets.only(bottom: 15),
                                                                              child: TextParagraphRenderer("[__${element['fields']['title']}__](${element['fields']['webUrl']})"),
                                                                            )
                                                                          : UnsupportedWidget(
                                                                              element,
                                                                              article,
                                                                            ),

        // author
        if (article.authorDetails.isNotEmpty) AuthorDetails(article),

        // bottom action bar
        BottomActionBar(article),

        // related articles
        article.relatedArticles.isNotEmpty
            ? RelatedArticles(article, scrollController, articleChampionship)
            : SizedBox(height: 10),
      ],
    );
  }
}

class TagsList extends StatelessWidget {
  final Article article;
  const TagsList(this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: article.articleTags.length,
          itemBuilder: (context, index) => Padding(
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
                          article.articleTags[index]['fields']['tagName'],
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      body: NewsFeed(tagId: article.articleTags[index]['id']),
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
                    article.articleTags[index]['fields']['tagName'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthorDetails extends StatelessWidget {
  final Article article;
  const AuthorDetails(this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    width = width > 1400
        ? 800
        : width > 1000
            ? 500
            : width;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                  SizedBox(
                    width: width - 138,
                    child: Text(
                      article.authorDetails["shortDescription"] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final Article article;
  const BottomActionBar(this.article, {super.key});

  @override
  Widget build(BuildContext context) {
    bool shouldUse12HourClock = Hive.box('settings')
        .get('shouldUse12HourClock', defaultValue: false) as bool;
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;

    String languageCode = Localizations.localeOf(context).languageCode;
    return Card(
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
                      championship == 'Formula 1'
                          ? "https://www.formula1.com/en/latest/article/${article.articleSlug}.${article.articleId}"
                          : "https://www.fiaformulae.com/en/news/${article.articleId}",
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
                    shouldUse12HourClock
                        ? '${DateFormat.jm().format(article.publishedDate)}\n${DateFormat.yMMMMd(languageCode).format(article.publishedDate)}'
                        : '${DateFormat.Hm().format(article.publishedDate)}\n${DateFormat.yMMMMd(languageCode).format(article.publishedDate)}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RelatedArticles extends StatelessWidget {
  final Article article;
  final ScrollController scrollController;
  final String? articleChampionship;
  const RelatedArticles(
    this.article,
    this.scrollController,
    this.articleChampionship, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    return kIsWeb
        ? Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      : article['thumbnail']['image']['url'] +
                                          '.transform/2col-retina/image.jpg'
                                  : article['thumbnail']['image']['url']
                              : '',
                        ),
                        true,
                        articleChampionship: articleChampionship,
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
        : ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 275,
              maxHeight: 305,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              controller: scrollController,
              physics: const PagingScrollPhysics(
                itemDimension: 300,
              ),
              itemCount: article.relatedArticles.length,
              itemBuilder: (context, index) => Center(
                child: NewsItem(
                  News(
                    article.relatedArticles[index]['id'],
                    article.relatedArticles[index]['articleType'],
                    article.relatedArticles[index]['slug'],
                    article.relatedArticles[index]['title'],
                    article.relatedArticles[index]['metaDescription'] ?? ' ',
                    DateTime.parse(article.relatedArticles[index]['updatedAt']),
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
                  articleChampionship: articleChampionship,
                ),
              ),
            ),
          );
  }
}
