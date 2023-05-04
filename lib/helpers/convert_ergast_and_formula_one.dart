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
      'Red Bull Racing Honda RBPT': 'red_bull',
      'Ferrari': 'ferrari',
      'Mercedes': 'mercedes',
      'Alpine Renault': 'alpine',
      'McLaren Mercedes': 'mclaren',
      'AlphaTauri Honda RBPT': 'alphatauri',
      'Aston Martin Aramco Mercedes': 'aston_martin',
      'Williams Mercedes': 'williams',
      'Alfa Romeo Ferrari': 'alfa',
      'Haas Ferrari': 'haas',
    };
    return formulaOneToErgast[teamName];
  }

  String teamsFromErgastToFormulaOne(String teamName) {
    Map formulaOneToErgast = {
      'red_bull': 'Red-Bull-Racing',
      'ferrari': 'Ferrari',
      'mercedes': 'Mercedes',
      'alpine': 'Alpine',
      'mclaren': 'McLaren',
      'alphatauri': 'AlphaTauri',
      'aston_martin': 'Aston-Martin',
      'williams': 'Williams',
      'alfa': 'Alfa-Romeo',
      'haas': 'Haas-F1-Team',
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

  String driverIdFromErgastForImages(String driverId) {
    Map ergastToFormulaOne = {
      "leclerc": "leclerc",
      "sainz": "sainz",
      "max_verstappen": "verstappen",
      "perez": "perez",
      "russell": "russell",
      "hamilton": "hamilton",
      "ocon": "ocon",
      "gasly": "gasly",
      "zhou": "zhou",
      "bottas": "bottas",
      "norris": "norris",
      "piastri": "piastri",
      "tsunoda": "tsunoda",
      "de_vries": "de-vries",
      "alonso": "alonso",
      "stroll": "stroll",
      "hulkenberg": "hulkenberg",
      "kevin_magnussen": "magnussen",
      "albon": "albon",
      "sargeant": "sargeant",
    };
    return ergastToFormulaOne[driverId];
  }

  String circuitNameFromFormulaOneToFormulaOneIdForRaceHub(String circuitId) {
    Map ergastToFormulaOne = {
      "Bahrain": '1141',
      "Saudi_Arabia": '1142',
      "Australia": '1143',
      "Azerbaijan": '1207',
      "Miami": '1208',
      "EmiliaRomagna": '1209',
      "Monaco": '1210',
      "Spain": '1211',
      "Canada": '1212',
      "Austria": '1213',
      "Great_Britain": '1214',
      "Hungary": '1215',
      "Belgium": '1216',
      "Netherlands": '1217',
      "Italy": '1218',
      "Singapore": '1219',
      "Japan": '1220',
      "Qatar": '1221',
      "United_States": '1222',
      "Mexico": '1223',
      "Brazil": '1224',
      "Las_Vegas": '1225',
      "United_Arab_Emirates": '1226',
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

  String driverCodeToTeam(String driverCode) {
    Map dict = {
      "1": "red_bull",
      "2": "williams",
      "4": "mclaren",
      "10": "alpine",
      "11": "red_bull",
      "14": "aston_martin",
      "16": "ferrari",
      "18": "aston_martin",
      "20": "haas",
      "21": "alphatauri",
      "22": "alphatauri",
      "23": "williams",
      "24": "alfa",
      "27": "haas",
      "31": "alpine",
      "44": "mercedes",
      "55": "ferrari",
      "63": "mercedes",
      "77": "alfa",
      "81": "mclaren",
    };
    return dict[driverCode];
  }
}
