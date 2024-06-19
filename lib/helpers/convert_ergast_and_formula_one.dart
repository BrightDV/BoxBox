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
      'Haas F1 Team': 'haas',
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

  String circuitNameFromFormulaOneToErgastForCircuitPoints(String circuitId) {
    Map formulaOneToErgast = {
      "Bahrain": "bahrain",
      "Saudi Arabia": "jeddah",
      "Australia": "albert_park",
      "Azerbaijan": "baku",
      "Miami": "miami",
      "Emilia-Romagna": "imola",
      "Monaco": "monaco",
      "Spain": "catalunya",
      "Canada": "villeneuve",
      "Austria": "red_bull_ring",
      "Great Britain": "silverstone",
      "Hungary": "hungaroring",
      "Belgium": "spa",
      "Netherlands": "zandvoort",
      "Italy": "monza",
      "Singapore": "marina_bay",
      "Japan": "suzuka",
      "Qatar": "losail",
      "United States": "americas",
      "Mexico": "rodriguez",
      "Brazil": "interlagos",
      "Las Vegas": "vegas",
      "Abu Dhabi": "yas_marina",
      "China": "shanghai"
    };
    return formulaOneToErgast[circuitId] ?? '';
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
      "bahrain": '1229',
      "saudi_arabia": '1230',
      "australia": '1231',
      "japan": '1232',
      "china": '1233',
      "miami": '1234',
      "emiliaromagna": '1235',
      "monaco": '1236',
      "monte%20carlo": '1236',
      "canada": '1237',
      "spain": '1238',
      "austria": '1239',
      "great_britain": '1240',
      "hungary": '1241',
      "belgium": '1242',
      "netherlands": '1243',
      "italy": '1244',
      "azerbaijan": '1245',
      "singapore": '1246',
      "USA": '1247',
      "mexico": '1248',
      "brazil": '1249',
      "las_vegas": '1250',
      "qatar": '1251',
      "united_arab_emirates": '1252',
    };
    return ergastToFormulaOne[circuitId];
  }

  String circuitNameFromFormulaOneToRoundNumber(String circuitId) {
    Map ergastToFormulaOne = {
      "bahrain": '1',
      "saudi_arabia": '2',
      "australia": '3',
      "japan": '4',
      "china": '5',
      "miami": '6',
      "emiliaromagna": '7',
      "monaco": '8',
      "monte%20carlo": '8',
      "canada": '9',
      "spain": '10',
      "austria": '11',
      "great_britain": '12',
      "hungary": '13',
      "belgium": '14',
      "netherlands": '15',
      "italy": '16',
      "azerbaijan": '17',
      "singapore": '18',
      "USA": '19',
      "mexico": '20',
      "brazil": '21',
      "las_vegas": '22',
      "qatar": '23',
      "united_arab_emirates": '24',
    };
    return ergastToFormulaOne[circuitId.toLowerCase()];
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
