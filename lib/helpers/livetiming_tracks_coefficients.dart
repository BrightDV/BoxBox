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
  Map<String, Map> coefficients = {
    "bahrain": {
      "drivers": {
        "x": (int x) => x / 30.5 + 112,
        "y": (int y) => -y / 33.5 + 422,
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
    "jeddah": {
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
    "albert_park": {
      "drivers": {
        "x": (int x) => x / 50.5 + 210,
        "y": (int y) => -y / 61.3 + 385,
      },
      "map": {
        "x": (double x) =>
            double.parse((x * 1000000)
                    .round()
                    .toString()
                    .substring(4, (x * 1000000).round().toString().length)) /
                55 -
            1066,
        "y": (double y) =>
            double.parse((y * 1000000)
                    .round()
                    .toString()
                    .substring(4, (y * 1000000).round().toString().length)) /
                55 -
            500,
      },
    },
  };
  Map getCoefficients(String raceName) {
    return coefficients[raceName] ?? {};
  }
}
