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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final List<ContentBlocker> contentBlockers = [];

  @override
  void initState() {
    super.initState();
    contentBlockers.add(
      ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
          unlessDomain: ["live.planetf1.com"],
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
      ".bs-sticky",
      ".bs-block",
      ".unic",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
            "https://live.planetf1.com/",
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
        onPermissionRequest: (controller, permissionRequest) async {
          PermissionResponse(
            action: PermissionResponseAction.DENY,
          );
        },
      ),
    );
  }
}
