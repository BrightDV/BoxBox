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

import 'dart:async';

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScheduleScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const ScheduleScreen({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: TabBarView(
          children: [
            ScheduleWidget(
              false,
              scrollController: scrollController,
            ),
            ScheduleWidget(
              true,
              scrollController: scrollController,
            ),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: const Size(200, 100),
          child: SizedBox(
            height: 50,
            child: Card(
              elevation: 3,
              child: TabBar(
                dividerColor: Colors.transparent,
                tabs: [
                  Text(
                    AppLocalizations.of(context)!.previous,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.next,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleWidget extends StatelessWidget {
  final bool toCome;
  final ScrollController? scrollController;
  const ScheduleWidget(
    this.toCome, {
    Key? key,
    this.scrollController,
  }) : super(key: key);

  Future<List<Race>> getRacesList(bool toCome) async {
    return await ErgastApi().getLastSchedule(toCome);
  }

  @override
  Widget build(BuildContext context) {
    Map schedule =
        Hive.box('requests').get('schedule', defaultValue: {}) as Map;
    return FutureBuilder<List<Race>>(
      future: getRacesList(toCome),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          schedule['MRData'] != null
              ? RacesList(
                  ErgastApi().formatLastSchedule(
                    schedule,
                    toCome,
                  ),
                  toCome,
                  scrollController: scrollController,
                )
              : RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? snapshot.data!.isEmpty
                ? const EmptySchedule()
                : RacesList(
                    snapshot.data!,
                    toCome,
                    scrollController: scrollController,
                  )
            : schedule['MRData'] != null
                ? ErgastApi()
                        .formatLastSchedule(
                          schedule,
                          toCome,
                        )
                        .isEmpty
                    ? const EmptySchedule()
                    : RacesList(
                        ErgastApi().formatLastSchedule(
                          schedule,
                          toCome,
                        ),
                        toCome,
                        scrollController: scrollController,
                      )
                : const LoadingIndicatorUtil();
      },
    );
  }
}

class EmptySchedule extends StatelessWidget {
  const EmptySchedule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.nothingHere,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 30,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
