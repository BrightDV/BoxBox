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
 * Copyright (c) 2022, BrightDV
 */

import 'dart:async';
import 'dart:convert';

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:url_launcher/url_launcher.dart';

class F1NewsFetcher {
  final String endpoint = "https://api.formula1.com";
  final String apikey = "qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP";

  List formatResponse(Map responseAsJson) {
    List finalJson = responseAsJson['items'];
    List newsList = [];
    finalJson.forEach((element) {
      element['title'] = element['title'].replaceAll("\n", "");
      if (element['metaDescription'] != null) {
        element['metaDescription'] = element['metaDescription'].replaceAll("\n", "");
      }
      newsList.add(
        News(
          element['id'],
          element['articleType'],
          element['slug'],
          element['title'],
          element['metaDescription'],
          element['updatedAt'],
          element['thumbnail']['image']['url'],
        ),
      );
    });
    return newsList;
  }

  Future<List> getLatestNews({String tagId}) async {
    Uri url;
    if (tagId != null) {
      url = Uri.parse('$endpoint/v1/editorial/articles?limit=40&tags=$tagId');
    } else {
      url = Uri.parse('$endpoint/v1/editorial/articles?limit=40');
    }
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });

    Map<String, dynamic> responseAsJson = json.decode(utf8.decode(response.bodyBytes));
    if (tagId == null) {
      Hive.box('requests').put('news', responseAsJson);
    }
    return formatResponse(responseAsJson);
  }

  Future<Article> getArticleData(String articleId) async {
    Uri url = Uri.parse('$endpoint/v1/editorial/articles/$articleId');
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "apikey": apikey,
      "locale": "en",
    });
    Map<String, dynamic> responseAsJson = json.decode(utf8.decode(response.bodyBytes));

    Article article = Article(
      responseAsJson['id'],
      responseAsJson['slug'],
      responseAsJson['title'],
      responseAsJson['createdAt'].substring(0, 10).split('-').reversed.join('-'),
      responseAsJson['articleTags'],
      responseAsJson['hero'],
      responseAsJson['body'],
      responseAsJson['relatedArticles'],
    );
    return article;
  }
}

class News {
  final String newsId;
  final String newsType;
  final String slug;
  final String title;
  final String subtitle;
  final String datePosted;
  final String imageUrl;

  News(
    this.newsId,
    this.newsType,
    this.slug,
    this.title,
    this.subtitle,
    this.datePosted,
    this.imageUrl,
  );
}

class Article {
  final String articleId;
  final String articleSlug;
  final String articleName;
  final String publishedDate;
  final List articleTags;
  final Map articleHero;
  final List articleContent;
  final List relatedArticles;

  Article(
    this.articleId,
    this.articleSlug,
    this.articleName,
    this.publishedDate,
    this.articleTags,
    this.articleHero,
    this.articleContent,
    this.relatedArticles,
  );
}

class NewsItem extends StatelessWidget {
  NewsItem(this.item, this.inRelated);

  final News item;
  final bool inRelated;
  final String endpoint = 'https://formula1.com';
  final String articleLink = '/en/latest/article.';

  Widget build(BuildContext context) {
    String imageUrl = item.imageUrl;
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    double width = MediaQuery.of(context).size.width;
    if (item.imageUrl.startsWith('https://www.formula1.com/')) {
      imageUrl = '${item.imageUrl}.transform/6col/image.jpg';
    }
    return SizedBox(
      width: inRelated ? width / 2.1 : width,
      child: Padding(
        padding: EdgeInsets.only(top: 5),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleScreen(item.newsId, item.title),
              ),
            );
          },
          child: Card(
            elevation: 5.0,
            color: useDarkMode ? Color(0xff343434) : Colors.white,
            child: Column(
              children: [
                Container(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => LoadingIndicatorUtil(),
                    errorWidget: (context, url, error) => Icon(Icons.error_outlined),
                    fadeOutDuration: Duration(seconds: 1),
                    fadeInDuration: Duration(seconds: 1),
                  ),
                ),
                ListTile(
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                      fontSize: inRelated ? 14 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    textAlign: TextAlign.justify,
                  ),
                  subtitle: inRelated
                      ? Text('')
                      : item.subtitle != null
                          ? Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.justify,
                            )
                          : Container(height: 0.0, width: 0.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final List items;

  NewsList({Key key, this.items});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return LazyLoadingList(
          initialSizeOfItems: 10,
          index: index,
          hasMore: true,
          loadMore: () {},
          child: NewsItem(
            items[index],
            false,
          ),
        );
      },
    );
  }
}

class ArticleRenderer extends StatelessWidget {
  final Article item;
  ArticleRenderer(this.item);

  Future<Article> getArticleData(String articleId) async {
    return await F1NewsFetcher().getArticleData(articleId);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getArticleData(item.articleId),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Text(
            snapshot.error.toString(),
          );
        return snapshot.hasData
            ? JoinArticlesParts(
                snapshot.data,
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}

class JoinArticlesParts extends StatelessWidget {
  final Article article;

  JoinArticlesParts(this.article);

  Widget build(BuildContext context) {
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    List articleContent = article.articleContent;
    List<Widget> widgetsList = [];
    if (article.articleHero['contentType'] == 'atomVideo') {
      widgetsList.add(
        ImageRenderer(
          article.articleHero['fields']['thumbnail']['url'],
        ),
      );
    } else {
      widgetsList.add(
        ImageRenderer(
          article.articleHero['fields']['image']['url'],
        ),
      );
    }
    List<Widget> tagsList = [];
    article.articleTags.forEach(
      (tag) => tagsList.add(
        Padding(
          padding: EdgeInsets.only(
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    backgroundColor: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
                    body: NewsFeedWidget(tagId: tag['id']),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromRGBO(255, 6, 0, .8),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  tag['fields']['tagName'],
                  style: TextStyle(
                    color: Color.fromRGBO(255, 6, 0, .8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    widgetsList.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Row(
            children: tagsList,
          ),
        ),
      ),
    );

    articleContent.forEach((element) {
      if (element['contentType'] == 'atomRichText') {
        widgetsList.add(
          TextParagraphRenderer(element['fields']['richTextBlock']),
        );
      } else if (element['contentType'] == 'atomVideo') {
        widgetsList.add(
          ImageRenderer(element['fields']['thumbnail']['url']),
        );
      } else if (element['contentType'] == 'atomImage') {
        widgetsList.add(
          ImageRenderer(
            element['fields']['image']['url'],
            caption: element['fields']['caption'],
          ),
        );
      }
    });
    List<Widget> relatedArticles = [];
    article.relatedArticles.forEach(
      (article) => relatedArticles.add(
        NewsItem(
          News(
            article['id'],
            article['articleType'],
            article['slug'],
            article['title'],
            article['metaDescription'],
            article['updatedAt'],
            article['thumbnail']['image']['url'],
          ),
          true,
        ),
      ),
    );
    widgetsList.add(
      Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.language,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () async => await launchUrl(
                          Uri.parse("https://www.formula1.com/en/latest/article.${article.articleSlug}.${article.articleId}.html"),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      Text(
                        'Ouvrir',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.schedule,
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        article.publishedDate,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    widgetsList.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: relatedArticles,
        ),
      ),
    );
    return SingleChildScrollView(
      child: Column(
        children: widgetsList,
      ),
    );
  }
}

class TextParagraphRenderer extends StatelessWidget {
  final String text;
  TextParagraphRenderer(this.text);

  Widget build(BuildContext context) {
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: MarkdownBody(
        data: text,
        selectable: true,
        onTapLink: (text, url, title) {
          if (url.startsWith('https://www.formula1.com/en/latest/article.')) {
            String articleId = url.substring(43, url.length - 5).split('.')[1];
            if (text.startsWith('READ MORE:')) {
              text = text.substring(10);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleScreen(articleId, text),
              ),
            );
          } else if (url.startsWith('https://www.formula1.com/en/results')) {
            String standingsType = url.substring(0, url.length - 5).split('/')[5];
            if (standingsType == "driver-standings") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        'Classements',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: StandingsScreen(),
                  ),
                ),
              );
            } else if (standingsType == "constructor-standings") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        'Classements',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: StandingsScreen(
                      switchToTeamStandings: true,
                    ),
                  ),
                ),
              );
            } else if (url.startsWith("https://www.formula1.com/en/racing/${RegExp(r'\d{4}')}/")) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        'Circuit...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    body: Text('Circuit!'),
                  ),
                ),
              );
            } else {
              launchUrl(Uri.parse(url));
            }
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        styleSheet: MarkdownStyleSheet(
          strong: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          p: TextStyle(
            fontSize: 14,
            color: useDarkMode ? Colors.white : Colors.black,
          ),
          pPadding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          a: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
          h1: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          h2: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          h3: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          h4: TextStyle(
            color: useDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class ImageRenderer extends StatelessWidget {
  final String imageUrl;
  final String caption;
  ImageRenderer(this.imageUrl, {this.caption});

  Widget build(BuildContext context) {
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(
                  top: 52,
                  bottom: 50,
                ),
                insetPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.transparent,
                content: Builder(
                  builder: (context) {
                    return Container(
                      width: double.infinity - 10,
                      child: InteractiveViewer(
                        minScale: 0.1,
                        maxScale: 6,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                            ),
                            Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) => LoadingIndicatorUtil(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error_outlined,
                                ),
                                fadeOutDuration: Duration(seconds: 1),
                                fadeInDuration: Duration(seconds: 1),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: useDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                imageUrl,
              ),
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: caption != null
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    caption,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}
