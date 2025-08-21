import 'dart:convert';
import 'dart:io';

import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/api/services/formula_series.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/article.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/helpers/download.dart';
import 'package:boxbox/scraping/formulae.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArticleRequestsProvider {
  Future<Article> _getArticleFromFormula1(
    String articleId,
    Function updateArticleTitle,
  ) async {
    String? filePath = kIsWeb
        ? null
        : await DownloadUtils()
            .downloadedFilePathIfExists('article_f1_${articleId}');
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

  Future<Article> _getArticleFromFormulaE(
    String articleId,
    Function updateArticleTitle,
    News news,
  ) async {
    Article article = await FormulaEScraper().getArticleData(
      news,
      articleId,
    );
    updateArticleTitle(article.articleName);
    return article;
  }

  Future<Article> _getArticleFromFormulaSeries(
    String articleId,
    Function updateArticleTitle,
  ) async {
    Article article = await FormulaSeries().getArticleData(articleId);
    updateArticleTitle(article.articleName);
    return article;
  }

  Future<Article> getArticleData(
    String articleId,
    Function updateArticleTitle,
    String championshipOfArticle,
    News? news,
  ) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championshipOfArticle != '') {
      if (championshipOfArticle == 'Formula 1') {
        return await _getArticleFromFormula1(articleId, updateArticleTitle);
      } else if (championshipOfArticle == 'Formula E') {
        return await _getArticleFromFormulaE(
          articleId,
          updateArticleTitle,
          news!,
        );
      } else {
        return await _getArticleFromFormulaSeries(
          articleId,
          updateArticleTitle,
        );
      }
    } else if (championship == 'Formula 1') {
      return await _getArticleFromFormula1(articleId, updateArticleTitle);
    } else if (championship == 'Formula E') {
      return await _getArticleFromFormulaE(
        articleId,
        updateArticleTitle,
        news!,
      );
    } else {
      return await _getArticleFromFormulaSeries(
        articleId,
        updateArticleTitle,
      );
    }
  }

  Future<List<News>> getPageArticles(
    int offset, {
    String? tagId,
    String? articleType,
  }) async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return await Formula1().getMoreNews(
        offset,
        tagId: tagId,
        articleType: articleType,
      );
    } else if (championship == 'Formula E') {
      return await FormulaE().getMoreNews(
        offset,
        tagId: tagId,
        articleType: articleType,
      );
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return await FormulaSeries().getMoreNews(
        offset,
        tagId: tagId,
        articleType: articleType,
      );
    } else {
      return [];
    }
  }

  Map getSavedArticles() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Hive.box('requests').get('f1News', defaultValue: {}) as Map;
    } else if (championship == 'Formula E') {
      return Hive.box('requests').get('feNews', defaultValue: {}) as Map;
    } else if (championship == 'Formula 2' ||
        championship == 'Formula 3' ||
        championship == 'F1 Academy') {
      return Hive.box('requests').get(
          '${Constants().FORMULA_SERIES[championship]}News',
          defaultValue: {}) as Map;
    } else {
      return {};
    }
  }
}
