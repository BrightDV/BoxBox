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

class RaceTracksUrls {
  Map<String, String> gpConverters = {
    "bahrain": "Bahrain",
    "jeddah": "Saudi_Arabia",
    "albert_park": "Australia",
    "imola": "Emilia Romagna",
    "miami": "Miami",
    "catalunya": "Spain",
    "monaco": "Monaco",
    "baku": "Azerbaijan",
    "villeneuve": "Canada",
    "silverstone": "Great Britain",
    "red_bull_ring": "Austria",
    "ricard": "France",
    "hungaroring": "Hungary",
    "spa": "Belgium",
    "zandvoort": "Netherlands",
    "monza": "Italy",
    "marina_bay": "Singapore",
    "suzuka": "Japan",
    "americas": "USA",
    "rodriguez": "Mexico",
    "interlagos": "Brazil",
    "yas_marina": "Abu Dhabi",
  };
  Future<String> getRaceTrackUrl(String gpId) async {
    String gpName = gpConverters[gpId];
    return "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$gpName.jpg.transform/12col/image.jpg";
  }
}
