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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class UnofficialWebviewScreen extends StatefulWidget {
  const UnofficialWebviewScreen({Key? key}) : super(key: key);
  @override
  State<UnofficialWebviewScreen> createState() =>
      _UnofficialWebviewScreenState();
}

class _UnofficialWebviewScreenState extends State<UnofficialWebviewScreen> {
  final List<ContentBlocker> contentBlockers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          "https://f1-dash.com/dashboard",
        ),
      ),
      initialSettings: InAppWebViewSettings(
        contentBlockers: contentBlockers,
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
