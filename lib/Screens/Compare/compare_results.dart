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

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/team_components.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CompareResultsScreen extends StatelessWidget {
  final String comparisonType;
  final String comparator;
  final String compared;
  final String comparatorId;
  final String comparedId;
  const CompareResultsScreen(
    this.comparisonType,
    this.comparator,
    this.compared,
    this.comparatorId,
    this.comparedId, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      comparator,
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'vs',
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      compared,
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: [
                  comparisonType == 'drivers'
                      ? DriverImageProvider(comparatorId)
                      : TeamCarImageProvider(comparatorId),
                  const Spacer(),
                  comparisonType == 'drivers'
                      ? DriverImageProvider(comparedId)
                      : TeamCarImageProvider(comparedId),
                ],
              ),
            ),
            FutureBuilder<List<List<int>>>(
              future: ErgastApi().getCompareDriverResults(comparator, compared),
              builder: (context, snapshot) => snapshot.hasError
                  ? RequestErrorWidget(
                      snapshot.error.toString(),
                    )
                  : snapshot.hasData
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Chart(
                                height: 300.0,
                                state: ChartState<void>(
                                  data: ChartData(
                                    [
                                      snapshot.data![0]
                                          .map(
                                            (e) => ChartItem<void>(e.toDouble(),
                                                min: 1),
                                          )
                                          .toList(),
                                      snapshot.data![1]
                                          .map(
                                            (e) => ChartItem<void>(e.toDouble(),
                                                min: 1),
                                          )
                                          .toList(),
                                    ],
                                  ),
                                  itemOptions: BubbleItemOptions(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    bubbleItemBuilder:
                                        (ItemBuilderData itemBuilderData) =>
                                            BubbleItem(
                                      color: itemBuilderData.itemIndex % 2 == 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    maxBarWidth: 3.0,
                                  ),
                                  backgroundDecorations: [
                                    GridDecoration(
                                      showVerticalGrid: false,
                                      showVerticalValues: true,
                                      showHorizontalValues: true,
                                      textStyle: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      horizontalAxisStep: 3,
                                      gridColor: useDarkMode
                                          ? Colors.white70
                                          : Colors.white30,
                                    ),
                                    SparkLineDecoration(
                                      lineWidth: 2.0,
                                      lineColor: Colors.red,
                                    ),
                                  ],
                                  foregroundDecorations: [
                                    SparkLineDecoration(
                                      id: 'second_line',
                                      lineWidth: 2.0,
                                      smoothPoints: false,
                                      lineColor: Colors.green,
                                      listIndex: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : const LoadingIndicatorUtil(),
            ),
          ],
        ),
      ),
    );
  }
}
