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

import 'dart:ui';

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
