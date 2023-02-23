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

class Convert {
  String teamsFromFormulaOneToErgast(String teamName) {
    Map formulaOneToErgast = {
      'Red Bull Racing RBPT': 'red_bull',
      'Ferrari': 'ferrari',
      'Mercedes': 'mercedes',
      'Alpine Renault': 'alpine',
      'McLaren Mercedes': 'mclaren',
      'AlphaTauri RBPT': 'alphatauri',
      'Aston Martin Aramco Mercedes': 'aston_martin',
      'Williams Mercedes': 'williams',
      'Alfa Romeo Ferrari': 'alfa',
      'Haas Ferrari': 'haas',
    };
    return formulaOneToErgast[teamName];
  }

  String circuitIdFromErgastToFormulaOne(String circuitId) {
    Map ergastToFormulaOne = {
      'bahrain': '1141',
      'jeddah': '1142',
      'albert_park': '1143',
      'baku': '1207',
      'miami': '1208',
      'imola': '1209',
      'monaco': '1210',
      'catalunya': '1211',
      'villeneuve': '1212',
      'red_bull_ring': '1213',
      'silverstone': '1214',
      'hungaroring': '1215',
      'spa': '1216',
      'zandvoort': '1217',
      'monza': '1218',
      'marina_bay': '1219',
      'suzuka': '1220',
      'losail': '1221',
      'americas': '1222',
      'rodriguez': '1223',
      'interlagos': '1224',
      'vegas': '1225',
      'yas_marina': '1226',
    };
    return ergastToFormulaOne[circuitId];
  }

  String circuitNameFromErgastToFormulaOneForRaceHub(String circuitId) {
    Map ergastToFormulaOne = {
      "bahrain": "Bahrain",
      "jeddah": "Saudi_Arabia",
      "albert_park": "Australia",
      "baku": "Azerbaijan",
      "miami": "Miami",
      "imola": "EmiliaRomagna",
      "monaco": "Monaco",
      "catalunya": "Spain",
      "villeneuve": "Canada",
      "red_bull_ring": "Austria",
      "silverstone": "Great_Britain",
      "hungaroring": "Hungary",
      "spa": "Belgium",
      "zandvoort": "Netherlands",
      "monza": "Italy",
      "marina_bay": "Singapore",
      "suzuka": "Japan",
      "losail": "Qatar",
      "americas": "United_States",
      "rodriguez": "Mexico",
      "interlagos": "Brazil",
      "vegas": "Las_Vegas",
      "yas_marina": "United_Arab_Emirates",
    };
    return ergastToFormulaOne[circuitId];
  }

  String circuitNameFromErgastToFormulaOne(String circuitId) {
    Map ergastToFormulaOne = {
      'bahrain': 'bahrain',
      'jeddah': 'saudi-arabia',
      'albert_park': 'australia',
      'baku': 'azerbaijan',
      'miami': 'miami',
      'imola': 'italy',
      'monaco': 'monaco',
      'catalunya': 'spain',
      'villeneuve': 'canada',
      'red_bull_ring': 'austria',
      'silverstone': 'great-britain',
      'hungaroring': 'hungary',
      'spa': 'belgium',
      'zandvoort': 'netherlands',
      'monza': 'italy',
      'marina_bay': 'singapore',
      'suzuka': 'japan',
      'losail': 'qatar',
      'americas': 'united-states',
      'rodriguez': 'mexico',
      'interlagos': 'brazil',
      'vegas': 'las-vegas',
      'yas_marina': 'abu-dhabi',
    };
    return ergastToFormulaOne[circuitId];
  }

  String driverIdFromErgast(String driverId) {
    Map ergastToFormulaOne = {
      "leclerc": "charles-leclerc",
      "sainz": "carlos-sainz",
      "max_verstappen": "max-verstappen",
      "perez": "sergio-perez",
      "russell": "george-russell",
      "hamilton": "lewis-hamilton",
      "ocon": "esteban-ocon",
      "gasly": "pierre-gasly",
      "zhou": "guanyu-zhou",
      "bottas": "valtteri-bottas",
      "norris": "lando-norris",
      "piastri": "oscar-piastri",
      "tsunoda": "yuki-tsunoda",
      "de_vries": "nyck-de-vries",
      "alonso": "fernando-alonso",
      "stroll": "lance-stroll",
      "hulkenberg": "nico-hulkenberg",
      "kevin_magnussen": "kevin-magnussen",
      "albon": "alexander-albon",
      "sargeant": "logan-sargeant",
      // not needed for 2023 but the standings will update on the 1st race
      // --> avoid crash of the standings
      "ricciardo": "daniel-ricciardo",
      "latifi": "nicholas-latifi",
      "vettel": "sebastian-vettel",
      "mick_schumacher": "mick-schumacher",
    };
    return ergastToFormulaOne[driverId];
  }

  String circuitNameFromFormulaOneToFormulaOneIdForRaceHub(String circuitId) {
    Map ergastToFormulaOne = {
      "Bahrain": '1141',
      "Saudi_Arabia": '1142',
      "Australia": '1143',
      "Azerbaijan": '1186',
      "Miami": '1187',
      "EmiliaRomagna": '1188',
      "Monaco": '1189',
      "Spain": '1190',
      "Canada": '1191',
      "Austria": '1192',
      "Great_Britain": '1193',
      "Hungary": '1194',
      "Belgium": '1195',
      "Netherlands": '1196',
      "Italy": '1197',
      "Singapore": '1198',
      "Japan": '1199',
      "Qatar": '1200',
      "United_States": '1201',
      "Mexico": '1202',
      "Brazil": '1203',
      "Las_Vegas": '1204',
      "United_Arab_Emirates": '1205',
    };
    return ergastToFormulaOne[circuitId];
  }

  String circuitNameFromFormulaOneToRoundNumber(String circuitId) {
    Map ergastToFormulaOne = {
      "Bahrain": '1',
      "Saudi_Arabia": '2',
      "Australia": '3',
      "Azerbaijan": '4',
      "Miami": '5',
      "EmiliaRomagna": '6',
      "Monaco": '7',
      "Spain": '8',
      "Canada": '9',
      "Austria": '10',
      "Great_Britain": '11',
      "Hungary": '12',
      "Belgium": '13',
      "Netherlands": '14',
      "Italy": '15',
      "Singapore": '16',
      "Japan": '17',
      "Qatar": '18',
      "United_States": '19',
      "Mexico": '20',
      "Brazil": '21',
      "Las_Vegas": '22',
      "United_Arab_Emirates": '23',
    };
    return ergastToFormulaOne[circuitId];
  }
}
