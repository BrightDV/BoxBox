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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class RssFeedArticleScreen extends StatefulWidget {
  final String articleTitle;
  final String articleUrl;
  const RssFeedArticleScreen(this.articleTitle, this.articleUrl, {Key? key})
      : super(key: key);

  @override
  State<RssFeedArticleScreen> createState() => _RssFeedArticleScreenState();
}

class _RssFeedArticleScreenState extends State<RssFeedArticleScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    print(widget.articleTitle);
    print(widget.articleUrl);
    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Marquee(
          text: widget.articleTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          pauseAfterRound: Duration(seconds: 1),
          startAfter: Duration(seconds: 1),
          velocity: 85,
          blankSpace: 100,
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
            widget.articleUrl,
          ),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            preferredContentMode: UserPreferredContentMode.DESKTOP,
          ),
        ),
        gestureRecognizers: [
          Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()),
          Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer()),
          Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        ].toSet(),
      ),
    );
  }
}
