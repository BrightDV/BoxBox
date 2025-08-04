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

import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/providers/schedule/requests.dart';
import 'package:boxbox/providers/schedule/ui.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    Map result = ScheduleRequestsProvider().getSavedSchedule();
    Map schedule = result['schedule'];
    String scheduleLastSavedFormat = result['schedule'] ?? '';

    return FutureBuilder<List<Race>>(
      future: ScheduleRequestsProvider().getRacesList(toCome),
      builder: (context, snapshot) => snapshot.hasError
          ? ScheduleUIProvider().getScheduleWidget(
              snapshot,
              scheduleLastSavedFormat,
              schedule,
              toCome,
              scrollController,
              true,
            )
          : snapshot.hasData
              ? snapshot.data!.isEmpty
                  ? const EmptySchedule()
                  : RacesList(
                      snapshot.data!,
                      toCome,
                      scrollController: scrollController,
                    )
              : ScheduleUIProvider().getScheduleWidget(
                  snapshot,
                  scheduleLastSavedFormat,
                  schedule,
                  toCome,
                  scrollController,
                  false,
                ),
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
