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

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxbox/helpers/live_session_status_indicator.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController _scrollController;
  HomeScreen(this._scrollController);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async =>
          receivedAction.payload?['id'] == null
              ? null
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleScreen(
                      receivedAction.payload!['id']!,
                      receivedAction.payload!['title']!,
                      false,
                    ),
                  ),
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          LiveSessionStatusIndicator(),
          Container(
            height: MediaQuery.of(context).size.height - 60,
            child: NewsFeedWidget(scrollController: widget._scrollController),
          ),
        ],
      ),
    );
  }
}
