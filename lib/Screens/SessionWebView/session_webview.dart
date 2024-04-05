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
import 'package:hive_flutter/hive_flutter.dart';

class SessionWebView extends StatefulWidget {
  const SessionWebView({super.key});

  @override
  State<SessionWebView> createState() => _SessionWebViewState();
}

class _SessionWebViewState extends State<SessionWebView> {
  CookieManager cookieManager = CookieManager.instance();

  @override
  void initState() {
    String webViewCookie = Hive.box('requests').get(
      'webViewCookie',
      defaultValue: '',
    ) as String;
    String loginCookie = Hive.box('requests').get(
      'loginCookie',
      defaultValue: '',
    ) as String;
    print("HELLO world");

    cookieManager.setCookie(
      url: WebUri('https://www.formula1.com/en/live-experience-webview.html'),
      name: "reese84",
      value: webViewCookie,
      expiresDate: DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch,
      isSecure: false,
      path: '/',
      isHttpOnly: false,
      domain: '.formula1.com',
      sameSite: HTTPCookieSameSitePolicy.LAX,
    );
    cookieManager.setCookie(
      url: WebUri('https://www.formula1.com/en/live-experience-webview.html'),
      name: "login-session",
      value: loginCookie,
      expiresDate: DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch,
      isSecure: false,
      path: '/',
      isHttpOnly: false,
      domain: '.formula1.com',
      sameSite: HTTPCookieSameSitePolicy.LAX,
    );
    print("DNOe cookie");
    super.initState();
    print("init state");
  }

  @override
  Widget build(BuildContext context) {
    print("builiding...");
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          "https://www.formula1.com/en/live-experience-webview.html",
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
