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

import 'package:flutter/material.dart';

class TeamBackgroundColor {
  final Map<String, List<Color>> teamsGradientColors = {
    "mercedes": [
      Color(0xff000000),
      Color(0xff059d93),
      Color(0xffffffff),
    ],
    "red_bull": [
      Color(0xff001a31),
      Color(0xffec1848),
      Color(0xffffffff),
    ],
    "ferrari": [
      Colors.black,
      Colors.red,
      Color(0xffffffff),
    ],
    "mclaren": [
      Colors.black,
      Colors.orange,
      Color(0xffffffff),
    ],
    "alpine": [
      Color(0xff0856ab),
      Color(0xffeb0901),
      Color(0xffffffff),
    ],
    "alphatauri": [
      Color(0xff002a40),
      Colors.white,
      Colors.black,
    ],
    "aston_martin": [
      Color(0xff00584f),
      Color(0xff5d9a44),
      Color(0xffffffff),
    ],
    "williams": [
      Color(0xff121b65),
      Color(0xff1fc7f4),
      Color(0xffffffff),
    ],
    "alfa": [
      Color(0xff15543e),
      Color(0xff9e2237),
      Color(0xffffffff),
    ],
    "haas": [
      Color(0xffeb1b3b),
      Colors.white,
      Colors.black,
    ],
  };

  final Map<String, Color> teamColorsList = {
    "mercedes": Color(0xff6CD3BF),
    "red_bull": Color(0xff1E5BC6),
    "ferrari": Color(0xffED1C24),
    "mclaren": Color(0xffF58020),
    "alpine": Color(0xff2293D1),
    "alphatauri": Color(0xff4E7C9B),
    "aston_martin": Color(0xff2D826D),
    "williams": Color(0xff37BEDD),
    "alfa": Color(0xffB12039),
    "haas": Color(0xffB6BABD),
  };

  List<Color> getTeamGradient(String teamName) {
    List teamGradientColors = teamsGradientColors[teamName];
    return teamGradientColors;
  }

  Color getTeamColors(String teamName) {
    Color teamColors = teamColorsList[teamName];
    return teamColors;
  }
}
