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

import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/race_components.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/racetracks_url.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/Screens/circuit_map_screen.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CircuitScreen extends StatefulWidget {
  final Race race;

  const CircuitScreen(this.race);

  @override
  _CircuitScreenState createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  @override
  Widget build(BuildContext context) {
    final Race race = widget.race;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.map_outlined,
                  ),
                  tooltip: AppLocalizations.of(context)!.grandPrixMap,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CircuitMapScreen(
                        race.circuitId,
                      ),
                    );
                  },
                ),
              ],
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: RaceImageProvider(race),
                title: Text(
                  race.raceName + ' Grand Prix',
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: ListTile(
                  title: Text(
                    'View results',
                    style: TextStyle(
                      color: useDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RaceDetailsScreen(
                        race,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TrackLayoutImage(race),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FutureBuilder<Map>(
                  future: FormulaOneScraper().scrapeCircuitFacts(
                    Converter().circuitNameFromErgastToFormulaOneForRaceHub(
                      race.circuitId,
                    ),
                  ),
                  builder: (context, snapshot) => snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Text(
                                snapshot.data!.keys.elementAt(index),
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                snapshot.data![
                                    snapshot.data!.keys.elementAt(index)],
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          shrinkWrap: true,
                        )
                      : Container(
                          height: 400,
                          child: LoadingIndicatorUtil(),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FutureBuilder<String>(
                  future: FormulaOneScraper().scrapeCircuitHistory(
                    Converter().circuitNameFromErgastToFormulaOneForRaceHub(
                      race.circuitId,
                    ),
                  ),
                  builder: (context, snapshot) => snapshot.hasData
                      ? MarkdownBody(
                          data: snapshot.data!,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            strong: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            p: TextStyle(
                              fontSize: 14,
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                            pPadding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            h1: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                            h2: TextStyle(
                              color: useDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : Container(
                          height: 400,
                          child: LoadingIndicatorUtil(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaceImageProvider extends StatelessWidget {
  Future<String> getCircuitImageUrl(Race race) async {
    return await RaceTracksUrls().getRaceTrackUrl(race.circuitId);
  }

  final Race race;
  RaceImageProvider(this.race);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCircuitImageUrl(this.race),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? CachedNetworkImage(
                errorWidget: (context, url, error) =>
                    Icon(Icons.error_outlined),
                fadeOutDuration: Duration(seconds: 1),
                fadeInDuration: Duration(seconds: 1),
                fit: BoxFit.cover,
                imageUrl: snapshot.data!,
                placeholder: (context, url) => LoadingIndicatorUtil(),
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}

class TrackLayoutImage extends StatelessWidget {
  Future<String> getTrackLayoutImageUrl(Race race) async {
    return await RaceTracksUrls().getTrackLayoutImageUrl(race.circuitId);
  }

  final Race race;
  TrackLayoutImage(this.race);
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<String>(
      future: getTrackLayoutImageUrl(this.race),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.only(
                          top: 52,
                          bottom: 50,
                        ),
                        insetPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.transparent,
                        content: Builder(
                          builder: (context) {
                            return Container(
                              width: double.infinity - 10,
                              child: InteractiveViewer(
                                minScale: 0.1,
                                maxScale: 8,
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                    ),
                                    Card(
                                        color:
                                            Colors.transparent.withOpacity(0.5),
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image(
                                          image: NetworkImage(
                                            snapshot.data!,
                                          ),
                                          loadingBuilder: (context, child,
                                                  loadingProgress) =>
                                              loadingProgress == null
                                                  ? child
                                                  : Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              (16 / 9),
                                                      child:
                                                          LoadingIndicatorUtil(),
                                                    ),
                                          errorBuilder: (context, url, error) =>
                                              Icon(
                                            Icons.error_outlined,
                                            color: useDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            size: 30,
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.close_rounded,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.network(
                      snapshot.data!,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : Container(
                                  height: MediaQuery.of(context).size.width /
                                      (16 / 9),
                                  child: LoadingIndicatorUtil(),
                                ),
                      errorBuilder: (context, url, error) => Icon(
                        Icons.error_outlined,
                        color: useDarkMode ? Colors.white : Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}
