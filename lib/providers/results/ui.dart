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

import 'package:boxbox/Screens/free_practice.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/api/services/formula1.dart';
import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/race.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultsUIProvider {
  Widget getRaceResultsWidget(
    AsyncSnapshot snapshot,
    BuildContext context,
    bool isFromRaceHub,
    String raceResultsLastSavedFormat,
    Map savedData,
    bool hasError,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      if (raceResultsLastSavedFormat == 'ergast') {
        if (savedData['MRData'] != null) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.youtube,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.unavailableOffline,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {},
                ),
                RaceDriversResultsList(
                  ErgastApi().formatRaceStandings(savedData),
                ),
              ],
            ),
          );
        }
      } else {
        if (savedData['raceResultsRace']) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.youtube,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.unavailableOffline,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {},
                ),
                RaceDriversResultsList(
                  Formula1().formatRaceStandings(savedData),
                ),
              ],
            ),
          );
        }
      }
    } else if (championship == 'Formula E') {
      if (savedData['results']) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.youtube,
                ),
                title: Text(
                  AppLocalizations.of(context)!.unavailableOffline,
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
              ),
              RaceDriversResultsList(
                FormulaE().formatRaceStandings(savedData),
              ),
            ],
          ),
        );
      }
    } else {
      return Container();
    }
    if (hasError) {
      return RequestErrorWidget(snapshot.error.toString());
    } else {
      return LoadingIndicatorUtil();
    }
  }

  Widget getQualificationResultsWidget(
    AsyncSnapshot snapshot,
    Race? race,
    String? raceUrl,
    bool? isSprintQualifying,
  ) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return QualificationDriversResultsList(
        snapshot.data!,
        race,
        raceUrl,
        isSprintQualifying,
      );
    } else if (championship == 'Formula E') {
      return FreePracticeResultsList(
        snapshot.data!,
        DateTime.parse(race!.date).year,
        race.raceName,
        10,
      );
    } else {
      return Container();
    }
  }
}
