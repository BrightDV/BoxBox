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

class Convert {
  String teamsFromFormulaOneToErgast(String teamName) {
    Map formulaOneToErgast = {
      'Red Bull Racing Honda RBPT': 'red_bull',
      'Ferrari': 'ferrari',
      'Mercedes': 'mercedes',
      'Alpine Renault': 'alpine',
      'McLaren Mercedes': 'mclaren',
      'RB Honda RBPT': 'rb',
      'Aston Martin Aramco Mercedes': 'aston_martin',
      'Williams Mercedes': 'williams',
      'Kick Sauber Ferrari': 'sauber',
      'Haas Ferrari': 'haas',
      // 2023
      'Alfa Romeo Ferrari': 'alfa',
      'AlphaTauri Honda RBPT': 'alphatauri',
      // 2022
      'AlphaTauri RBPT': 'alphatauri',
      'Red Bull Racing RBPT': 'red_bull',
      // 2021
      'Red Bull Racing Honda': 'red_bull',
      'AlphaTauri Honda': 'alphatauri',
      'Aston Martin Mercedes': 'aston_martin',
      'Alfa Romeo Racing Ferrari': 'alfa',
    };
    return formulaOneToErgast[teamName] ?? 'none';
  }

  String teamsFromFormulaOneApiToErgast(String teamName) {
    // TODO: merge both functions into one by checking if name in string instead of exact match
    Map formulaOneToErgast = {
      'Red Bull Racing': 'red_bull',
      'Ferrari': 'ferrari',
      'Mercedes': 'mercedes',
      'Alpine': 'alpine',
      'McLaren': 'mclaren',
      'RB': 'rb',
      'Aston Martin': 'aston_martin',
      'Williams': 'williams',
      'Kick Sauber': 'sauber',
      'Haas': 'haas',
    };
    return formulaOneToErgast[teamName] ?? 'none';
  }

  String teamsFromErgastToFormulaOne(String teamName) {
    Map formulaOneToErgast = {
      'red_bull': 'Red-Bull-Racing',
      'ferrari': 'Ferrari',
      'mercedes': 'Mercedes',
      'alpine': 'Alpine',
      'mclaren': 'McLaren',
      'rb': 'RB',
      'aston_martin': 'Aston-Martin',
      'williams': 'Williams',
      'sauber': 'Kick-Sauber',
      'haas': 'Haas-F1-Team',
    };
    return formulaOneToErgast[teamName] ?? 'none';
  }

  String circuitIdFromErgastToFormulaOne(String circuitId) {
    Map ergastToFormulaOne = {
      'bahrain': '1229',
      'jeddah': '1230',
      'albert_park': '1231',
      'suzuka': '1232',
      'shanghai': '1233',
      'miami': '1234',
      'imola': '1235',
      'monaco': '1236',
      'villeneuve': '1237',
      'catalunya': '1238',
      'red_bull_ring': '1239',
      'silverstone': '1240',
      'hungaroring': '1241',
      'spa': '1242',
      'zandvoort': '1243',
      'monza': '1244',
      'baku': '1245',
      'marina_bay': '1246',
      'americas': '1247',
      'rodriguez': '1248',
      'interlagos': '1249',
      'vegas': '1250',
      'losail': '1251',
      'yas_marina': '1252',
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
      "shanghai": "China",
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
      'shanghai': 'china',
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

  String driverIdFromFormula1(String driverId) {
    Map formulaOneToErgast = {
      "charles-leclerc": "leclerc",
      "carlos-sainz": "sainz",
      "max-verstappen": "max_verstappen",
      "sergio-perez": "perez",
      "george-russell": "russell",
      "lewis-hamilton": "hamilton",
      "esteban-ocon": "ocon",
      "pierre-gasly": "gasly",
      "guanyu-zhou": "zhou",
      "valtteri-bottas": "bottas",
      "lando-norris": "norris",
      "oscar-piastri": "piastri",
      "yuki-tsunoda": "tsunoda",
      "nyck-de-vries": "de_vries",
      "fernando-alonso": "alonso",
      "lance-stroll": "stroll",
      "nico-hulkenberg": "hulkenberg",
      "kevin-magnussen": "kevin_magnussen",
      "alexander-albon": "albon",
      "logan-sargeant": "sargeant",
      "daniel-ricciardo": "ricciardo",
      "nicholas-latifi": "latifi",
      "sebastian-vettel": "vettel",
      "mick-schumacher": "mick_schumacher"
    };
    return formulaOneToErgast[driverId] ?? 'none';
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
      "ricciardo": "ricciardo",
    };
    return ergastToFormulaOne[driverId];
  }

  String circuitNameFromFormulaOneToFormulaOneIdForRaceHub(String circuitId) {
    Map ergastToFormulaOne = {
      "Bahrain": '1229',
      "Saudi_Arabia": '1230',
      "Australia": '1231',
      "Japan": '1232',
      "China": '1233',
      "Miami": '1234',
      "EmiliaRomagna": '1235',
      "Monaco": '1236',
      "Monte%20Carlo": '1236',
      "Canada": '1237',
      "Spain": '1238',
      "Austria": '1239',
      "Great_Britain": '1240',
      "Hungary": '1241',
      "Belgium": '1242',
      "Netherlands": '1243',
      "Italy": '1244',
      "Azerbaijan": '1245',
      "Singapore": '1246',
      "USA": '1247',
      "Mexico": '1248',
      "Brazil": '1249',
      "Las_Vegas": '1250',
      "Qatar": '1251',
      "United_Arab_Emirates": '1252',
    };
    return ergastToFormulaOne[circuitId];
  }

  String circuitNameFromFormulaOneToRoundNumber(String circuitId) {
    Map ergastToFormulaOne = {
      "Bahrain": '1',
      "Saudi_Arabia": '2',
      "Australia": '3',
      "Japan": '4',
      "China": '5',
      "Miami": '6',
      "EmiliaRomagna": '7',
      "Monaco": '8',
      "Monte%20Carlo": '8',
      "Canada": '9',
      "Spain": '10',
      "Austria": '11',
      "Great_Britain": '12',
      "Hungary": '13',
      "Belgium": '14',
      "Netherlands": '15',
      "Italy": '16',
      "Azerbaijan": '17',
      "Singapore": '18',
      "USA": '19',
      "Mexico": '20',
      "Brazil": '21',
      "Las_Vegas": '22',
      "Qatar": '23',
      "United_Arab_Emirates": '24',
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
