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

import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FreePracticeScreen extends StatelessWidget {
  final String sessionTitle;
  final int sessionIndex;
  final Race race;
  const FreePracticeScreen(
    this.sessionTitle,
    this.sessionIndex,
    this.race,
  );

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionTitle),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: FutureBuilder(
        future: FormulaOneScraper().scrape(
          race.circuitId,
          sessionIndex,
          'practice-$sessionIndex',
          true,
        ),
        builder: (context, snapshot) => snapshot.hasError
            ? snapshot.error.toString() == 'RangeError: Value not in range: 0'
                ? Center(
                    child: Text(
                      'Les données ne sont pas disponibles actuellement.',
                      style: TextStyle(
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  )
                : RequestErrorWidget(
                    snapshot.error.toString(),
                  )
            : snapshot.hasData
                ? FreePracticeResultsList(
                    snapshot.data,
                    race,
                    sessionIndex,
                  )
                : LoadingIndicatorUtil(),
      ),
    );
  }
}

class FreePracticeResultsList extends StatelessWidget {
  final List<ScraperRaceResult> results;
  final Race race;
  final int sessionIndex;

  const FreePracticeResultsList(
    this.results,
    this.race,
    this.sessionIndex,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length + 2,
      itemBuilder: (context, index) => index == 0
          ? ListTile(
              leading: FaIcon(
                FontAwesomeIcons.youtube,
                color: Colors.white,
              ),
              title: Text(
                'Voir le résumé sur YouTube',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () async {
                var yt = YoutubeExplode();
                final raceYear = race.date.split('-')[0];
                final List<Video> searchResults = await yt.search.search(
                  "Formula 1 Free Practice $sessionIndex ${race.raceName} $raceYear",
                );
                final Video bestVideoMatch = searchResults[0];
                await launchUrl(
                  Uri.parse(
                      "https://youtube.com/watch?v=${bestVideoMatch.id.value}"),
                  mode: LaunchMode.externalApplication,
                );
                // video.id.value,
              },
              tileColor: Color(0xff383840),
            )
          : index == 1
              ? Container(
                  color: Color(0xff383840),
                  height: 45,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'POS',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(flex: 2, child: Text('')),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'PIL',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'TEMPS',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'ÉCART',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'TOURS',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : FreePracticeResultItem(
                  results[index - 2],
                  index - 2,
                ),
    );
  }
}

class FreePracticeResultItem extends StatelessWidget {
  final ScraperRaceResult result;
  final int index;

  const FreePracticeResultItem(
    this.result,
    this.index,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index % 2 == 1 ? Color(0xff22222c) : Color(0xff15151f),
      height: 45,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                result.time == '' ? 'DNF' : result.position,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: VerticalDivider(
                color: TeamBackgroundColor().getTeamColors(
                  Converter().teamsFromFormulaOneToErgast(this.result.car),
                ),
                thickness: 8,
                width: 25,
                indent: 7,
                endIndent: 7,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                result.driver[2],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: index == 0 ? Color(0xffff00ff) : Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.time == '' ? '--' : result.time,
                      style: TextStyle(
                        color: index == 0 || result.time == ''
                            ? Colors.white
                            : Color(0xff00ff00),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.gap == '' ? '--' : result.gap,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff383840),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      result.laps,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
