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

import 'package:boxbox/Screens/FormulaYou/settings.dart';
import 'package:boxbox/Screens/FormulaYou/tags.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PersonalizedHomeScreen extends StatefulWidget {
  PersonalizedHomeScreen();
  @override
  _PersonalizedHomeScreenState createState() => _PersonalizedHomeScreenState();
}

class _PersonalizedHomeScreenState extends State<PersonalizedHomeScreen> {
  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List selectedTags =
        Hive.box('settings').get('selectedTags', defaultValue: []) as List;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    Map availableTags = FormulaYouTags().unifiedTags();
    List selectedTagsIds = [];
    for (String tagName in selectedTags)
      selectedTagsIds.add(
        availableTags[tagName],
      );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Formula You',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormulaYouSettingsScreen(
                  update: updateState,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: NewsFeedWidget(
        tagId: selectedTagsIds.join(','),
      ),
    );
  }
}
