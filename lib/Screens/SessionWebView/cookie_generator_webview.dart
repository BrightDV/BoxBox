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

import 'package:boxbox/Screens/SessionWebView/webview_manager.dart';
import 'package:boxbox/api/formula1.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CookieGeneratorWebView extends StatefulWidget {
  final String sessionName;
  const CookieGeneratorWebView(this.sessionName, {super.key});

  @override
  State<CookieGeneratorWebView> createState() => _CookieGeneratorWebViewState();
}

class _CookieGeneratorWebViewState extends State<CookieGeneratorWebView> {
  CookieManager cookieManager = CookieManager.instance();

  Future<void> loadingAlert(BuildContext buildContext) async {
    return showDialog<void>(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.loading,
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LoadingIndicatorUtil(),
                Text(
                  AppLocalizations.of(context)!.pleaseWait,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => loadingAlert(context));
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          "https://account.formula1.com/",
        ),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
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
      onLoadStop: (controller, url) async {
        String cookieValue = '';

        List cookies = await cookieManager.getCookies(
          url: WebUri('.formula1.com'),
        );
        for (Cookie cookie in cookies) {
          if (cookie.name == 'reese84') {
            cookieValue = cookie.value;
            break;
          }
        }
        Hive.box('requests').put('webViewCookie', cookieValue);
        Hive.box('requests').put('webViewCookieLatestQuery', DateTime.now());
        await Formula1().saveLoginCookie(cookieValue);

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewTransitionScreen(widget.sessionName),
          ),
        );
      },
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
