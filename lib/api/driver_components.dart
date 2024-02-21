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

import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/Screens/driver_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Driver {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String points;

  Driver(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.points,
  );
}

class DriverResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String time;
  final bool isFastest;
  final String fastestLapTime;
  final String fastestLap;
  final String? lapsDone;
  final String? points;
  final String? raceId;
  final String? raceName;
  final String? status;

  DriverResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.time,
    this.isFastest,
    this.fastestLapTime,
    this.fastestLap, {
    this.lapsDone,
    this.points,
    this.raceId,
    this.raceName,
    this.status,
  });
}

class DriverQualificationResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String timeq1;
  final String timeq2;
  final String timeq3;

  DriverQualificationResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.timeq1,
    this.timeq2,
    this.timeq3,
  );
}

class StartingGridPosition {
  final String position;
  final String number;
  final String driver;
  final String team;
  final String teamFullName;
  final String time;

  StartingGridPosition(
    this.position,
    this.number,
    this.driver,
    this.team,
    this.teamFullName,
    this.time,
  );
}

class DriversList extends StatelessWidget {
  final List<Driver> items;
  final ScrollController? scrollController;

  const DriversList({
    Key? key,
    required this.items,
    this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      controller: scrollController,
      itemBuilder: (context, index) {
        return DriverItem(
          items[index],
          index,
        );
      },
    );
  }
}

class DriverItem extends StatelessWidget {
  final Driver item;
  final int index;

  const DriverItem(
    this.item,
    this.index, {
    Key? key,
  }) : super(key: key);

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColors(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColor = getTeamColors(item.team);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(
              item.driverId,
              item.givenName,
              item.familyName,
            ),
          ),
        );
      },
      child: Container(
        height: 120,
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.background,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 92,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              item.position,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: VerticalDivider(
                              color: finalTeamColor,
                              thickness: 9,
                              width: 30,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.givenName,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    item.familyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 19,
                                    ),
                                  ),
                                  int.parse(item.points) == 1
                                      ? Text(
                                          "${item.points} ${AppLocalizations.of(context)?.point}",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(
                                          "${item.points} ${AppLocalizations.of(context)?.points}",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ],
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
            DriverImageProvider(
              item.driverId,
            ),
          ],
        ),
      ),
    );
  }
}

class DriverImageProvider extends StatelessWidget {
  Future<String> getDriverImageUrl(String driverId) async {
    return await DriverResultsImage().getDriverImageURL(driverId);
  }

  final String driverId;
  const DriverImageProvider(this.driverId, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDriverImageUrl(driverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? CachedNetworkImage(
                imageUrl: snapshot.data.toString(),
                placeholder: (context, url) => const SizedBox(
                  width: 100,
                  child: LoadingIndicatorUtil(),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outlined),
                fadeOutDuration: const Duration(milliseconds: 500),
                fadeInDuration: const Duration(milliseconds: 500),
              )
            : const LoadingIndicatorUtil();
      },
    );
  }
}
