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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen();

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    List articlesHistory =
        Hive.box('history').get('articlesHistory', defaultValue: []) as List;
    articlesHistory.reversed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.history,
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              Hive.box('history').put('articlesHistory', []);
            }),
            icon: Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: articlesHistory.length == 0
          ? Center(
              child: Text(
                '¯\\_(ツ)_/¯',
                style: TextStyle(
                  color: useDarkMode ? Colors.white : Colors.black,
                  fontSize: 40,
                ),
              ),
            )
          : ListView.builder(
              itemCount: articlesHistory.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => Card(
                elevation: 5.0,
                color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CachedNetworkImage(
                        imageUrl: articlesHistory[index]['imageUrl'],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        child: Column(
                          children: [
                            Text(
                              articlesHistory[index]['articleTitle'],
                              style: TextStyle(
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.justify,
                            ),
                            Text(
                              articlesHistory[index]['timeVisited'].substring(
                                0,
                                articlesHistory[index]['timeVisited']
                                        .indexOf('.') -
                                    3,
                              ),
                              style: TextStyle(
                                color: useDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
