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

import 'dart:async';

import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/event_tracker.dart';
import 'package:boxbox/api/livetiming.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SessionScreen extends StatefulWidget {
  final String sessionFullName;
  final Session session;

  const SessionScreen(
    this.sessionFullName,
    this.session,
  );
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    int timeBetween(DateTime from, DateTime to) {
      return to.difference(from).inSeconds;
    }

    int timeToRace = timeBetween(
      DateTime.now(),
      widget.session.startTime,
    );
    int days = (timeToRace / 60 / 60 / 24).round();
    int hours = (timeToRace / 60 / 60 - days * 24 - 1).round();
    int minutes = (timeToRace / 60 - days * 24 * 60 - hours * 60 + 60).round();
    int seconds =
        (timeToRace - days * 24 * 60 * 60 - hours * 60 * 60 - minutes * 60);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sessionFullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: widget.session.state == 'upcoming'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.sessionStartsIn,
                      style: TextStyle(
                        fontSize: 20,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                TimerCountdown(
                  format: CountDownTimerFormat.daysHoursMinutesSeconds,
                  endTime: DateTime.now().add(
                    Duration(
                      days: days,
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                    ),
                  ),
                  timeTextStyle: TextStyle(
                    fontSize: 25,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  colonsTextStyle: TextStyle(
                    fontSize: 23,
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                  descriptionTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                  ),
                  spacerWidth: 15,
                  daysDescription: AppLocalizations.of(context)!.dayFirstLetter,
                  hoursDescription:
                      AppLocalizations.of(context)!.hourFirstLetter,
                  minutesDescription:
                      AppLocalizations.of(context)!.minuteAbbreviation,
                  secondsDescription:
                      AppLocalizations.of(context)!.secondAbbreviation,
                  onEnd: () {
                    setState(() {});
                  },
                ),
              ],
            )
          : widget.session.state == 'completed'
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.sessionCompleted,
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl:
                      'https://www.formula1.com/en/live-experience-webview.html',
                ),
    );
  }
}

class SessionFeed extends StatefulWidget {
  const SessionFeed({Key? key}) : super(key: key);
  _SessionFeedState createState() => _SessionFeedState();
}

class _SessionFeedState extends State<SessionFeed> {
  Future<Map> getSessionInfo() async {
    return await LiveTiming().sessionInfo();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: getSessionInfo(),
      builder: (context, snapshot) {
        return snapshot.hasError
            ? Text(snapshot.error.toString())
            : snapshot.hasData
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        TrackStatus(snapshot.data!),
                        Leaderboard(snapshot.data!),
                      ],
                    ),
                  )
                : LoadingIndicatorUtil();
      },
    );
  }
}

class TrackStatus extends StatefulWidget {
  final Map sessionInfo;
  const TrackStatus(this.sessionInfo);

  @override
  State<TrackStatus> createState() => _TrackStatusState();
}

class _TrackStatusState extends State<TrackStatus> {
  Map trackStates = {
    '1': 'Drapeau Vert',
    '2': 'Drapeau Jaune',
    '3': 'Unknown',
    '4': 'Voiture de Sécurité',
    '5': 'Drapeau Rouge',
    '6': 'Voiture de Sécurité Virtuelle',
    '7': 'Fin de la Voiture de Sécurité Virtuelle',
  };

  Map backgroundColors = {
    "1": Colors.green,
    "2": Colors.yellow,
    "3": Colors.black,
    "4": Colors.yellow,
    "5": Colors.red,
    "6": Colors.yellow,
    "7": Colors.yellow,
  };

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(
      Duration(seconds: 5),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: FutureBuilder<Map>(
        future: LiveTiming().trackStatus(widget.sessionInfo),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? Container(
                    height: 50,
                    color: backgroundColors[snapshot.data?['Status']],
                    child: Center(
                      child: Text(
                        trackStates[snapshot.data?['Status']],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : LoadingIndicatorUtil(),
      ),
    );
  }
}

class Leaderboard extends StatefulWidget {
  final Map sessionInfo;
  const Leaderboard(this.sessionInfo);

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  Map numberToPilot = {
    "1": ["max_verstappen", "Max", "Verstappen", "VER", "red_bull"],
    "16": ["leclerc", "Charles", "Leclerc", "LEC", "ferrari"],
    "11": ["perez", "Sergio", "Pérez", "PER", "red_bull"],
    "55": ["sainz", "Carlos", "Sainz", "SAI", "ferrari"],
    "63": ["russell", "Georges", "Russell", "RUS", "mercedes"],
    "44": ["hamilton", "Lewis", "Hamilton", "HAM", "mercedes"],
    "4": ["norris", "Lando", "Norris", "NOR", "mclaren"],
    "31": ["ocon", "Esteban", "Ocon", "OCO", "alpine"],
    "77": ["bottas", "Valtteri", "Bottas", "BOT", "alfa"],
    "14": ["alonso", "Alonso", "Fernando", "ALO", "alpine"],
    "20": ["kevin_magnussen", "Kevin", "Magnussen", "MAG", "haas"],
    "3": ["ricciardo", "Daniel", "Ricciardo", "RIC", "mclaren"],
    "10": ["gasly", "Pierre", "Gasly", "GAS", "alphatauri"],
    "5": ["vettel", "Sebastian", "Vettel", "VET", "aston_martin"],
    "47": ["mick_schumacher", "Mick", "Schumacher", "MSC", "haas"],
    "22": ["tsunoda", "Yuki", "Tsunoda", "TSU", "alphatauri"],
    "24": ["zhou", "Guanyu", "Zhou", "ZHO", "alfa"],
    "23": ["albon", "Alexander", "Albon", "ALB", "williams"],
    "18": ["stroll", "Lance", "Stroll", "STR", "aston_martin"],
    "6": ["latifi", "Nicholas", "Latifi", "LAT", "williams"],
    "27": ["hulkenberg", "Nico", "Hülkenberg", "HUL", "aston_martin"],
    "17": ["de_vries", "Nyck", "De Vries", "VRI", "mercedes"],
  };

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(
      Duration(seconds: 2),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: LiveTiming().timingData(widget.sessionInfo),
      builder: (context, snapshot) {
        if (snapshot.hasError == true) {
          return RequestErrorWidget(
            snapshot.error.toString(),
          );
        } else {
          if (snapshot.hasData == true) {
            List drivers = snapshot.data!.keys.toList();
            List driversResults = [];
            if (widget.sessionInfo['Path'].endsWith('Race/')) {
              drivers.forEach(
                (element) {
                  snapshot.data![element.toString()]['Line'] == 1
                      ? driversResults.add(
                          DriverResult(
                            numberToPilot[element.toString()][0],
                            snapshot.data![element]['Line'].toString(),
                            element.toString(),
                            numberToPilot[element.toString()][1],
                            numberToPilot[element.toString()][2],
                            numberToPilot[element.toString()][3],
                            numberToPilot[element.toString()][4],
                            snapshot.data![element]['Retired']
                                ? 'DNF'
                                : snapshot.data![element]['InPit']
                                    ? 'PIT'
                                    : snapshot.data![element]['PitOut']
                                        ? 'PIT OUT'
                                        : snapshot.data![element]['GapToLeader']
                                            .toString(),
                            false,
                            snapshot.data![element]['BestLapTime']['Value'],
                            snapshot.data![element]['BestLapTime']['Lap'],
                            lapsDone: snapshot.data![element]['NumberOfLaps'],
                          ),
                        )
                      : driversResults.add(
                          DriverResult(
                            numberToPilot[element.toString()][0],
                            snapshot.data![element]['Line'].toString(),
                            element.toString(),
                            numberToPilot[element.toString()][1],
                            numberToPilot[element.toString()][2],
                            numberToPilot[element.toString()][3],
                            numberToPilot[element.toString()][4],
                            snapshot.data![element]['TimeDiffToPositionAhead']
                                .toString(),
                            snapshot.data![element]['PersonalBestLapTime']
                                        ['Position'] ==
                                    1
                                ? true
                                : false,
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Value'],
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Lap'],
                          ),
                        );
                },
              );
            } else {
              drivers.forEach(
                (element) {
                  snapshot.data![element.toString()]['Line'] == 1
                      ? driversResults.add(
                          DriverResult(
                            numberToPilot[element.toString()][0],
                            snapshot.data![element]['Line'].toString(),
                            element.toString(),
                            numberToPilot[element.toString()][1],
                            numberToPilot[element.toString()][2],
                            numberToPilot[element.toString()][3],
                            numberToPilot[element.toString()][4],
                            snapshot.data![element]['BestLapTime']['Value']
                                .toString(),
                            snapshot.data![element]['PersonalBestLapTime']
                                        ['Position'] ==
                                    1
                                ? true
                                : false,
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Value'],
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Lap'],
                          ),
                        )
                      : driversResults.add(
                          DriverResult(
                            numberToPilot[element.toString()][0],
                            snapshot.data![element]['Line'].toString(),
                            element.toString(),
                            numberToPilot[element.toString()][1],
                            numberToPilot[element.toString()][2],
                            numberToPilot[element.toString()][3],
                            numberToPilot[element.toString()][4],
                            snapshot.data![element]['TimeDiffToFastest']
                                .toString(),
                            snapshot.data![element]['PersonalBestLapTime']
                                        ['Position'] ==
                                    1
                                ? true
                                : false,
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Value'],
                            snapshot.data![element]['PersonalBestLapTime']
                                ['Lap'],
                          ),
                        );
                },
              );
            }

            driversResults.sort((a, b) {
              return int.parse(a.position).compareTo(int.parse(b.position));
            });

            return ListView.builder(
              shrinkWrap: true,
              itemCount: drivers.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return DriverResultItem(
                  driversResults[index],
                  index,
                );
              },
            );
          } else {
            return LoadingIndicatorUtil();
          }
        }
      },
    );
  }
}

class WeatherPopup extends StatelessWidget {
  const WeatherPopup({Key? key}) : super(key: key);

  Future<Map> getWeather() async {
    Map sessionInfo = await LiveTiming().sessionInfo();
    return await LiveTiming().weather(sessionInfo);
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Center(
        child: Text('MÉTÉO'),
      ),
      content: FutureBuilder<Map>(
        future: getWeather(),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(snapshot.error.toString())
            : snapshot.hasData
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Température de l\'air: ${snapshot.data!["AirTemp"]}°C'),
                      Text(
                          'Température du circuit: ${snapshot.data!["TrackTemp"]}°C'),
                      Text('Humidité: ${snapshot.data!["Humidity"]}%'),
                      Text('Pression: ${snapshot.data!["Pressure"]}hPa'),
                      Text('Pluie: ${snapshot.data!["Rainfall"]}mm'),
                      Text('Vent: ${snapshot.data!["WindSpeed"]}km/h'),
                      Text(
                          'Direction du vent: ${snapshot.data!["WindDirection"]}°'),
                    ],
                  )
                : LoadingIndicatorUtil(),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class EventsFeed extends StatefulWidget {
  const EventsFeed({Key? key}) : super(key: key);

  @override
  State<EventsFeed> createState() => _EventsFeedState();
}

class _EventsFeedState extends State<EventsFeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Radios'),
    );
  }
}
