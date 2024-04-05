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

import 'package:boxbox/Screens/SessionWebView/cookie_generator_webview.dart';
import 'package:boxbox/Screens/SessionWebView/session_webview.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WebViewManagerScreen extends StatefulWidget {
  final String sessionName;
  const WebViewManagerScreen(this.sessionName, {super.key});

  @override
  State<WebViewManagerScreen> createState() => _WebViewManagerScreenState();
}

class _WebViewManagerScreenState extends State<WebViewManagerScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) return;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: WebViewTransitionScreen(widget.sessionName),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WebViewTransitionScreen extends StatelessWidget {
  final String sessionName;
  const WebViewTransitionScreen(this.sessionName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionName),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: WebViewManagerUpdater(sessionName),
    );
  }
}

class WebViewManagerUpdater extends StatelessWidget {
  final String sessionName;
  const WebViewManagerUpdater(this.sessionName, {super.key});

  Widget saveCookie(String cookieValue, BuildContext context) {
    return FutureBuilder(
      future: Formula1().saveLoginCookie(cookieValue),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(snapshot.error.toString())
          : snapshot.hasData
              ? Container()
              : Text(
                  AppLocalizations.of(context)!.loading,
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime cookieLatestQuery = Hive.box('requests').get(
      'webViewCookieLatestQuery',
      defaultValue: now,
    ) as DateTime;
    String webViewCookie = Hive.box('requests').get(
      'webViewCookie',
      defaultValue: '',
    ) as String;
    String loginCookie = Hive.box('requests').get(
      'loginCookie',
      defaultValue: '',
    ) as String;
    DateTime loginCookieLatestQuery = Hive.box('requests').get(
      'loginCookieLatestQuery',
      defaultValue: now,
    ) as DateTime;
    if (cookieLatestQuery.compareTo(now.subtract(Duration(days: 15))) >= 0 ||
        webViewCookie != '' ||
        webViewCookie.isNotEmpty) {
      if ((loginCookieLatestQuery.compareTo(now.subtract(Duration(
                days: 3,
                hours: 12,
              ))) <
              0 ||
          loginCookie == '')) {
        saveCookie(webViewCookie, context);
      }
    }
    return (cookieLatestQuery.compareTo(now.subtract(Duration(days: 15))) < 0 ||
            webViewCookie == '' ||
            webViewCookie.isEmpty)
        ? CookieGeneratorWebView(sessionName)
        : SessionWebView();
  }
}
