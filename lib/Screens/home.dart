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

import 'package:boxbox/helpers/live_session_status_indicator.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController _scrollController;
  const HomeScreen(this._scrollController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          const LiveSessionStatusIndicator(),
          SizedBox(
            height: MediaQuery.of(context).size.height - 60,
            child: NewsFeed(scrollController: _scrollController),
          ),
        ],
      ),
    );
  }
}
