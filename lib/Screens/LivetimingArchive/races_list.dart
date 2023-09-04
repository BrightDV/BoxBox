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

import 'package:boxbox/Screens/LivetimingArchive/live_timing.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArchiveRacesListScreen extends StatelessWidget {
  const ArchiveRacesListScreen({super.key});

  Future<List<Race>> getRacesList(bool toCome) async {
    return await ErgastApi().getLastSchedule(toCome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Timing Archive'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Race>>(
        future: getRacesList(false),
        builder: (context, snapshot) {
          return snapshot.hasError
              ? RequestErrorWidget(snapshot.error.toString())
              : snapshot.hasData
                  ? snapshot.data!.isEmpty
                      ? const EmptySchedule()
                      : ArchiveRacesList(
                          snapshot.data!,
                        )
                  : const LoadingIndicatorUtil();
        },
      ),
    );
  }
}

class ArchiveRacesList extends StatelessWidget {
  final List<Race> items;

  const ArchiveRacesList(
    this.items, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) => ArchiveRaceItem(
        items[items.length - index - 1],
        index,
      ),
      physics: const ClampingScrollPhysics(),
    );
  }
}

class ArchiveRaceItem extends StatelessWidget {
  final Race item;
  final int index;

  const ArchiveRaceItem(this.item, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int month = int.parse(item.date.split("-")[1]);
    String day = item.date.split("-")[2];
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    List months = [
      AppLocalizations.of(context)?.monthAbbreviationJanuary,
      AppLocalizations.of(context)?.monthAbbreviationFebruary,
      AppLocalizations.of(context)?.monthAbbreviationMarch,
      AppLocalizations.of(context)?.monthAbbreviationApril,
      AppLocalizations.of(context)?.monthAbbreviationMay,
      AppLocalizations.of(context)?.monthAbbreviationJune,
      AppLocalizations.of(context)?.monthAbbreviationJuly,
      AppLocalizations.of(context)?.monthAbbreviationAugust,
      AppLocalizations.of(context)?.monthAbbreviationSeptember,
      AppLocalizations.of(context)?.monthAbbreviationOctober,
      AppLocalizations.of(context)?.monthAbbreviationNovember,
      AppLocalizations.of(context)?.monthAbbreviationDecember,
    ];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveTimingScreen(
            '2023/${item.date}_${item.raceName.replaceAll(' ', '_')}/${item.date}_Race/',
            // ex: 2023/2023-03-05_Bahrain_Grand_Prix/2023-03-05_Race/
            item.circuitId,
            item.round,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        height: 80,
        color: index % 2 == 1
            ? useDarkMode
                ? const Color(0xff22222c)
                : const Color(0xffffffff)
            : useDarkMode
                ? const Color(0xff15151f)
                : const Color(0xfff4f4f4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: index == 0
                  ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
                  : const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: useDarkMode
                            ? index % 2 == 0
                                ? const Color.fromARGB(255, 36, 36, 48)
                                : const Color.fromARGB(255, 23, 23, 34)
                            : const Color.fromARGB(255, 136, 135, 135),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              months[month - 1].toLowerCase(),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.country,
                            style: TextStyle(
                              color: useDarkMode
                                  ? Colors.white
                                  : const Color(0xff171717),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              item.circuitName,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 136, 135, 135),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
