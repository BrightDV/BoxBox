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

import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/article.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArticleFormatProvider {
  String formatHeroUrl(Map savedArticle) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (savedArticle['hero'].isNotEmpty) {
        if (savedArticle['hero']['contentType'] == 'atomVideo') {
          return savedArticle['hero']['fields']['thumbnail']['url'];
        } else if (savedArticle['hero']['contentType'] == 'atomVideoYouTube') {
          return savedArticle['hero']['fields']['image']['url'];
        } else if (savedArticle['hero']['contentType'] == 'atomImageGallery') {
          return savedArticle['hero']['fields']['imageGallery'][0]['url'];
        } else {
          return savedArticle['hero']['fields']['image']['url'];
        }
      }
    }
    return "";
  }

  String formatShareUrl(String articleId, String slug) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return 'https://www.formula1.com/en/latest/article/$slug.$articleId';
    } else if (championship == 'Formula E') {
      return 'https://www.fiaformulae.com/en/news/$articleId';
    } else {
      return '';
    }
  }

  List<News> formatNewsItems(Map latestNews) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return Formula1().formatResponse(latestNews);
    } else if (championship == 'Formula E') {
      return FormulaE().formatResponse(latestNews);
    } else {
      return [];
    }
  }
}
