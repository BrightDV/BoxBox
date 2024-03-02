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

import 'package:flutter/material.dart';

class TeamBackgroundColor {
  final Map<String, Color> teamColorsList = {
    "default": const Color(0xFFE10600),
    "navyBlue": const Color(0x00000001),
    "blueGrey": const Color(0xFF000408),
    "mercedes": const Color(0xFF27F4D2),
    "red_bull": const Color(0xFF3671C6),
    "ferrari": const Color(0xFFE8002D),
    "mclaren": const Color(0xFFFF8000),
    "alpine": const Color(0xFFFF87BC),
    "rb": const Color(0xFF6692FF),
    "aston_martin": const Color(0xFF229971),
    "williams": const Color(0xFF64C4FF),
    "sauber": const Color(0xFF52E252),
    "haas": const Color(0xffB6BABD),
    // 2023
    "alphatauri": const Color(0xFF4E7C9B),
    "alfa": const Color(0xFFB12039),
  };

  Color getTeamColor(String teamName) {
    Color teamColors = teamColorsList[teamName] ?? Colors.transparent;
    return teamColors;
  }
}
