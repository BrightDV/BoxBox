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

import 'package:boxbox/Screens/article.dart';
import 'package:flutter/material.dart';

class HandleRoute {
  static Route? handleRoute(String? url) {
    if (url == null) return null;
    final String articleId = url.split('.')[-2];

    return PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => ArticleUrlHandler(articleId),
    );
  }
}

class ArticleUrlHandler extends StatelessWidget {
  final String articleId;
  const ArticleUrlHandler(this.articleId, {Key? key});

  void showErrorDialog(BuildContext context, String url) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(url),
            content: Text(url.split('.')[-2]),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //Navigator.pushReplacement(
    //  context,
    //  PageRouteBuilder(
    //    opaque: false,
    //    pageBuilder: (_, __, ___) => ArticleScreen(
    //      articleId,
    //      '',
    //      true,
    //    ),
    //  ),
    //);
    return Scaffold(
      appBar: AppBar(
        title: Text('Intent'),
      ),
      body: Text('Artile: $articleId'),
    );
  }
}
