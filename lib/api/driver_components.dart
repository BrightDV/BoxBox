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

import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/Screens/driver_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Driver {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String points;
  final String? driverImage;
  final String? detailsPath;
  final Color? teamColor;

  Driver(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.points, {
    this.driverImage,
    this.detailsPath,
    this.teamColor,
  });
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
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    Color tC;
    if (championship == 'Formula 1') {
      tC = TeamBackgroundColor().getTeamColor(teamId);
    } else {
      tC = FormulaE().getTeamColor(teamId);
    }
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColor =
        item.teamColor != null ? item.teamColor! : getTeamColors(item.team);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(
              item.driverId,
              item.givenName,
              item.familyName,
              detailsPath: item.detailsPath,
            ),
          ),
        );
      },
      child: Container(
        height: 120,
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.surface,
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
                            child: BoxBoxVerticalDivider(
                              width: 30,
                              thickness: 9,
                              color: finalTeamColor,
                              border: BorderRadius.circular(3.25),
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
              driverImage: item.driverImage,
            ),
          ],
        ),
      ),
    );
  }
}

class DriverImageProvider extends StatelessWidget {
  String getDriverImageUrl(String driverId) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return DriverResultsImage().getDriverImageURL(driverId);
    } else {
      return FormulaE().getDriverImageURL(driverId);
    }
  }

  final String driverId;
  final String? driverImage;
  const DriverImageProvider(
    this.driverId, {
    Key? key,
    this.driverImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        driverImage != null ? driverImage! : getDriverImageUrl(driverId);
    return SizedBox(
      width: 120,
      child: imageUrl == 'none'
          ? Center(
              child: Icon(
                Icons.no_photography_outlined,
                size: 32,
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 120,
                child: LoadingIndicatorUtil(),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outlined),
              fadeOutDuration: const Duration(milliseconds: 500),
              fadeInDuration: const Duration(milliseconds: 500),
            ),
    );
  }
}
