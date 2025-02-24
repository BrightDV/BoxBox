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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RssFeedArticleScreen extends StatefulWidget {
  final String articleTitle;
  final String articleUrl;
  const RssFeedArticleScreen(this.articleTitle, this.articleUrl, {Key? key})
      : super(key: key);

  @override
  State<RssFeedArticleScreen> createState() => _RssFeedArticleScreenState();
}

class _RssFeedArticleScreenState extends State<RssFeedArticleScreen> {
  final List<ContentBlocker> contentBlockers = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      contentBlockers.add(
        ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: ".*",
            unlessDomain: [
              widget.articleUrl.split('/')[2],
            ],
            resourceType: [
              ContentBlockerTriggerResourceType.SCRIPT,
              ContentBlockerTriggerResourceType.RAW,
            ],
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          ),
        ),
      );
      List<String> selectors = [
        ".banner",
        ".banners",
        ".ads",
        ".ad",
        ".advert",
        ".w7e-platform-101",
        ".adgrid-ad-container",
        ".ms-apb-inarticle-after-preview-without-sidebar",
        ".ms-apb-super",
        ".ms-content_sidebar",
        ".ms-apb",
        ".ms-footer_piano-footer",
        ".advert-banner-container",
        ".ad-top-margin",
        ".mv-ad-box",
        ".onetrust-pc-dark-filter",
        ".ms-ap",
        ".ms-hapb",
        ".ci-ad",
        ".ot-sdk-container",
        ".GoogleActiveViewElement",
        ".widget_text",
        ".topbanmobile",
        ".primisslate",
        ".snackStickyParent",
        ".region-banner",
        ".inarticle-wrapper",
      ];
      contentBlockers.add(
        ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: ".*",
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: selectors.join(', '),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () => launchUrl(
              Uri.parse(
                widget.articleUrl,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(
              Icons.language,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 3,
              right: 6,
            ),
            child: IconButton(
              onPressed: () => Share.share(
                widget.articleUrl,
              ),
              icon: const Icon(
                Icons.share,
              ),
            ),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
            widget.articleUrl,
          ),
        ),
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()),
          Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer()),
          Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        },
        initialSettings: InAppWebViewSettings(
          contentBlockers: contentBlockers,
        ),
      ),
    );
  }
}
