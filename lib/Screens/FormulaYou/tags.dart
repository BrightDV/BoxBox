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

// TODO: update tags

class FormulaYouTags {
  Map drivers = {
    'Sargeant': '5WihF0lzmVmSFzbLTN0gbV',
    'De Vries': '68dmFpPx0katXobJThKkvz',
    'Piastri': '41uIxNZh02INCdkNl0EoUR',
    'Zhou': 'POO9gtXwXZc3pcxaxqZ8l',
    'Magnussen': '2VPHxEVItqamysmo4gYuom',
    'Russell': 'IsIJcxqC0CkGkUOecEs6Y',
    'Tsunoda': '5U2ewFvY7cTnHc93V2cihA',
    'Alonso': '7ybrIvmq9GWyeqwcUaIKKY',
    'Perez': '2XIxifOI3S0eMaiSqWQ8yS',
    'Sainz': '699bpqs9Fe0uEOea2y0w8i',
    'Gasly': '3xf5DpCbfO4okMMUUkmUyC',
    'Stroll': '4Sag45cec0o4SAG8YoG0M8',
    'Ocon': '67LM58GFgsqEuQ2YWKg24m',
    'Norris': '6y9lwYH3K86YsgoMGg4iEI',
    'Leclerc': '6YzJwtlvqwsyESUsqeCoAa',
    'Hamilton': '4JkPrl5z1S8aKUYKcsmmSw',
    'Bottas': '7pmFWUdaogM26A20qoKySo',
    'Albon': '1VZSmmLnnyO0QISYesMeYq',
    'Verstappen': '35LWmREgr620I24EIcMeG2',
    'Hulkenberg': '57LMEfzsjmSo2iAgQ6YIeq',
  };

  Map teams = {
    'Mercedes': '5m8RZ1RZSMOKAO8qIuSY2Y',
    'Ferrari': '3dIkMVlv3iyaaScYu2OiYI',
    'Red Bull Racing': '3cMoP6kpSMgCeoAIaGsU0a',
    'Alpine': '4n4PqH0eoNW9geoT75sHTP',
    'AlphaTauri': '7qTv9kSVeRQUPU2KBeQOvn',
    'Aston Martin': 'fKMtIEyrTrpfwCKViP6Y4',
    'Alfa Romeo': '2pEKAZR4sCpBZus0cCfzc7',
    'Williams': 'SPHhgHqWWG8mYq8eewsQU',
    'Haas': '5V60e311lYSIsWMe4OWA6M',
    'McLaren': '5MLqooeGDmOqQqQsmuYyGQ',
  };

  Map articleTypes = {
    'Fun/Humour': 'YcEEy4RzKS2AyYCsM8gKy',
    'Quiz': '32T199Y0d3wc8OEeINjqH9',
    'Beyond The Grid': '63HGi6Q0grEg1ToZBtPNQ9',
    'Jolyon Palmer\'s Analysis': '6FcjGxXKQqz1cEwqtjV1Ge',
    'Play': '1WxomVA1KQoY2ggooQCg2o',
    'Fantasy': '6GSX6tD4iIiuOSAq0W2S6g',
    'Feature': '72fUC5A1fGWye8aAWUq8WQ',
    'Opinion': '23XFDLy5XC4Woa6IUqSmqY',
    'Technical': '4lP4Pth1kICO2iCQqGAIIU',
    'Tech Tuesday': '3AKvs2xfm9FnpDgVzB4PXs',
    'Archive': 'fKTHmS6vS04g8gYIyISco',
    'Esports': 'N0CpHwC3MAUK4iwAEYi6e',
    'Analysis': '3HkjTN75peeCOsSegCyOWi',
  };

  Map misc = {
    'Pirelli': '4bJexMQn9S0mOkQMQaGqO8',
    'Car Launches': '1PqvC3R6bS0ews6Oueu8Y0',
    'F1 TV': '3xTe2Rr3ZOVUxzatez8AFD',
    'Road to F1': 'B9uCZGHxBucq8OIcyAGoy',
    'Sunstainability': '2Xv0Ky85GUqpD8aP9sgUwq',
    'Jolyon Palmer': '47A6JMeLFKk4igeWIkAMkO',
  };

  List<Map> tags() => [
        drivers,
        teams,
        articleTypes,
        misc,
      ];

  Map unifiedTags() => Map.from(drivers)
    ..addAll(teams)
    ..addAll(articleTypes)
    ..addAll(misc);
}
