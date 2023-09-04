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
 * Copyright (c) 2022-2023, BrightDV
 */

class LiveTimingTracksCoefficients {
  List<Map> coefficients = [
    {
      "drivers": {
        "x": (int x) => x / 55 + 245,
        "y": (int y) => -y / 54 + 480,
      },
      "map": {
        "x": (double x) =>
            double.parse((x * 1000000)
                    .round()
                    .toString()
                    .substring(3, (x * 1000000).round().toString().length)) /
                30 -
            250,
        "y": (double y) =>
            -double.parse((y * 1000000)
                    .round()
                    .toString()
                    .substring(3, (y * 1000000).round().toString().length)) /
                30 +
            1400,
      },
    },
    {
      "drivers": {
        "x": (int x) => x / 55 + 245,
        "y": (int y) => -y / 54 + 480,
      },
      "map": {
        "x": (double x) =>
            double.parse((x * 1000000)
                    .round()
                    .toString()
                    .substring(3, (x * 1000000).round().toString().length)) /
                51 +
            120,
        "y": (double y) =>
            -double.parse((y * 1000000)
                    .round()
                    .toString()
                    .substring(3, (y * 1000000).round().toString().length)) /
                49 +
            1100,
      },
    },
  ];
  Map getCoefficients(String round) {
    return coefficients[int.parse(round) - 1];
  }
}
