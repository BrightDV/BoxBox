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

class RaceTracksUrls {
  Map<String, String> trackUrlConverter = {
    "bahrain": "Bahrain",
    "jeddah": "Saudi_Arabia",
    "albert_park": "Australia",
    "baku": "Azerbaijan",
    "miami": "Miami",
    "imola": "Emilia Romagna",
    "monaco": "Monaco",
    "catalunya": "Spain",
    "villeneuve": "Canada",
    "red_bull_ring": "Austria",
    "silverstone": "Great Britain",
    "hungaroring": "Hungary",
    "spa": "Belgium",
    "zandvoort": "Netherlands",
    "monza": "Italy",
    "marina_bay": "Singapore",
    "suzuka": "Japan",
    "losail": "Qatar",
    "americas": "USA",
    "rodriguez": "Mexico",
    "interlagos": "Brazil",
    "vegas": "Las Vegas",
    "yas_marina": "Abu Dhabi",
  };

  Map<String, String> trackLayoutConverter = {
    "bahrain": "Bahrain",
    "jeddah": "Saudi_Arabia",
    "albert_park": "Australia",
    "baku": "Baku",
    "miami": "Miami",
    "imola": "Emilia Romagna",
    "monaco": "Monoco",
    "catalunya": "Spain",
    "villeneuve": "Canada",
    "red_bull_ring": "Austria",
    "silverstone": "Great Britain",
    "hungaroring": "Hungary",
    "spa": "Belgium",
    "zandvoort": "Netherlands",
    "monza": "Italy",
    "marina_bay": "Singapore",
    "suzuka": "Japan",
    "losail": "Qatar",
    "americas": "USA",
    "rodriguez": "Mexico",
    "interlagos": "Brazil",
    "vegas": "Las Vegas",
    "yas_marina": "Abu Dhabi",
  };
  Future<String> getRaceTrackUrl(String gpId) async {
    String gpName = trackUrlConverter[gpId]!;
    return "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Racehub%20header%20images%2016x9/$gpName.jpg.transform/12col/image.jpg";
  }

  Future<String> getTrackLayoutImageUrl(String gpId) async {
    String gpName = trackLayoutConverter[gpId]!.replaceAll(' ', '_');
    print(gpName);
    return "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Circuit%20maps%2016x9/${gpName}_Circuit.png";
  }
}
