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

class TeamCarImage {
  Map<String, String> teamCarDecoder = {
    "ferrari":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/ferrari-left.png",
    "mercedes":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/mercedes-left.png",
    "red_bull":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/red-bull-left.png",
    "alpine":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/alpine-left.png",
    "haas":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/haas-f1-team-left.png",
    "alfa":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/alfa-romeo-racing-left.png",
    "alphatauri":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/alphatauri-left.png",
    "mclaren":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/mclaren-left.png",
    "aston_martin":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/aston-martin-left.png",
    "williams":
        "https://media.formula1.com/content/dam/fom-website/teams/2023/williams-left.png",
  };
  Future<String> getTeamCarImageURL(String teamId) async {
    String teamCarImageUrl = teamCarDecoder[teamId]!;
    return teamCarImageUrl;
  }
}
