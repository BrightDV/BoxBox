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

import 'package:boxbox/Screens/team_details.dart';
import 'package:boxbox/helpers/divider.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/helpers/team_car_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Team {
  final String constructorId;
  final String position;
  final String name;
  final String points;
  final String wins;
  final String? teamCarImage;
  final String? teamCarImageCropped;
  final String? detailsPath;
  final Color? teamColor;

  Team(
    this.constructorId,
    this.position,
    this.name,
    this.points,
    this.wins, {
    this.teamCarImage,
    this.teamCarImageCropped,
    this.detailsPath,
    this.teamColor,
  });
  factory Team.fromMap(Map<String, dynamic> json) {
    return Team(json['constructorId'], json['position'], json['name'],
        json['points'], json['wins']);
  }
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(json['constructorId'], json['position'], json['name'],
        json['points'], json['wins']);
  }
}

class TeamItem extends StatelessWidget {
  final Team item;
  final int index;

  const TeamItem(this.item, this.index, {Key? key}) : super(key: key);

  Color getTeamColors(String teamId) {
    Color tC = TeamBackgroundColor().getTeamColor(teamId);
    return tC;
  }

  @override
  Widget build(BuildContext context) {
    Color finalTeamColors = item.teamColor != null
        ? item.teamColor!
        : getTeamColors(item.constructorId);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamDetailsScreen(
            item.constructorId,
            item.name,
            detailsPath: item.detailsPath,
          ),
        ),
      ),
      child: Container(
        height: item.teamCarImageCropped != null ? 113 : 120,
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  item.position,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: BoxBoxVerticalDivider(
                color: finalTeamColors,
                thickness: 9,
                width: 40,
                indent: 30,
                endIndent: 30,
                border: BorderRadius.circular(3.25),
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  int.parse(item.points) == 1
                      ? Text(
                          "${item.points} ${AppLocalizations.of(context)?.point}",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      : Text(
                          "${item.points} ${AppLocalizations.of(context)?.points}",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                  item.wins != "NA"
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: int.parse(item.wins) == 1
                              ? Text(
                                  "${item.wins} ${AppLocalizations.of(context)?.victory}",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                )
                              : Text(
                                  "${item.wins} ${AppLocalizations.of(context)?.victories}",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                        )
                      : Container(),
                ],
              ),
            ),
            item.teamCarImageCropped != null
                ? Expanded(
                    flex: 6,
                    child: TeamCarImageProvider(
                      item.constructorId,
                      teamCarImageCropped: item.teamCarImageCropped,
                    ),
                  )
                : Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TeamCarImageProvider(
                        item.constructorId,
                        teamCarImageCropped: item.teamCarImageCropped,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TeamCarImageProvider extends StatelessWidget {
  String getTeamCarImageURL(String teamId) {
    return TeamCarImage().getTeamCarImageURL(teamId);
  }

  final String teamId;
  final String? teamCarImageCropped;
  const TeamCarImageProvider(
    this.teamId, {
    Key? key,
    this.teamCarImageCropped,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String teamCarImageUrl = teamCarImageCropped != null
        ? teamCarImageCropped!
        : getTeamCarImageURL(teamId);
    return teamCarImageUrl == 'none'
        ? SizedBox(
            width: 120,
            child: Center(
              child: Icon(
                Icons.no_photography_outlined,
                size: 32,
              ),
            ),
          )
        : CachedNetworkImage(
            imageBuilder: (context, imageProvider) => Transform.scale(
              alignment: teamCarImageCropped != null
                  ? Alignment.centerRight
                  : Alignment.center,
              scale: 1.5,
              child: Container(
                alignment:
                    teamCarImageCropped != null ? Alignment.centerRight : null,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: teamCarImageCropped != null ? null : BoxFit.fitHeight,
                    alignment: teamCarImageCropped != null
                        ? FractionalOffset.centerRight
                        : FractionalOffset.centerLeft,
                  ),
                ),
              ),
            ),
            imageUrl: teamCarImageUrl,
            placeholder: (context, url) => const SizedBox(
              width: 100,
              child: LoadingIndicatorUtil(),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error_outlined),
            fadeOutDuration: const Duration(milliseconds: 500),
            fadeInDuration: const Duration(milliseconds: 500),
            cacheManager: CacheManager(
              Config(
                "teamCarImages",
                stalePeriod: const Duration(days: 7),
              ),
            ),
          );
  }
}

class TeamsList extends StatelessWidget {
  final List<Team> items;
  final ScrollController? scrollController;

  const TeamsList({
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
        return TeamItem(
          items[index],
          index,
        );
      },
    );
  }
}
