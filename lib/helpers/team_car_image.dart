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

class TeamCarImage {
  Map<String, String> teamCarDecoder = {
    "ferrari":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/ferrari.png",
    "mercedes":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/mercedes.png",
    "red_bull":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/red-bull-racing.png",
    "alpine":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/alpine.png",
    "haas":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/haas-f1-team.png",
    "alfa":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/alfa-romeo.png",
    "alphatauri":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/alphatauri.png",
    "mclaren":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/mclaren.png",
    "aston_martin":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/aston-martin.png",
    "williams":
        "https://www.formula1.com/content/dam/fom-website/teams/2022/williams.png",
  };
  Future<String> getTeamCarImageURL(String teamId) async {
    String teamCarImageUrl = teamCarDecoder[teamId];
    return teamCarImageUrl;
  }
}
