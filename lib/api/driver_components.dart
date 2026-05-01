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

import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        context.pushNamed(
          'drivers',
          pathParameters: {
            'driverId': item.detailsPath ?? item.driverId,
          },
          extra: {
            'givenName': item.givenName,
            'familyName': item.familyName,
            'detailsPath': item.detailsPath,
          },
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
                      height: 99,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
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
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: BoxBoxVerticalDivider(
                                width: 30,
                                thickness: 9,
                                color: finalTeamColor,
                                border: BorderRadius.circular(3.25),
                              ),
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
                                  Stack(
                                    children: [
                                      Text(
                                        item.givenName,
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontFamily: 'Northwell',
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 43),
                                        child: Text(
                                          item.familyName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19,
                                          ),
                                        ),
                                      ),
                                    ],
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
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeInDuration: const Duration(milliseconds: 300),
            ),
    );
  }
}
