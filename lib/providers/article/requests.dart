import 'dart:convert';
import 'dart:io';

import 'package:boxbox/api/formula1.dart';
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
      } else {
        return await _getArticleFromFormulaE(
          articleId,
          updateArticleTitle,
          news!,
        );
      }
    } else if (championship == 'Formula 1') {
      return await _getArticleFromFormula1(articleId, updateArticleTitle);
    } else {
      return await _getArticleFromFormulaE(
        articleId,
        updateArticleTitle,
        news!,
      );
    }
  }
}
