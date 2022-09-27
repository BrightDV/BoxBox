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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppearanceScreen extends StatefulWidget {
  final Function update;
  const AppearanceScreen(this.update);

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    int themeMode =
        Hive.box('settings').get('themeMode', defaultValue: 0) as int;
    String teamTheme = Hive.box('settings')
        .get('teamTheme', defaultValue: 'default') as String;
    Map layoutValueToString = {
      'big': AppLocalizations.of(context).articleFull,
      'medium': AppLocalizations.of(context).articleTitleAndImage,
      'condensed': AppLocalizations.of(context).articleTitleAndDescription,
      'small': AppLocalizations.of(context).articleTitle,
    };
    List themeOptions = <String>[
      AppLocalizations.of(context).followSystem,
      AppLocalizations.of(context).lightMode,
      AppLocalizations.of(context).darkMode,
    ];
    String newsLayoutFormated = layoutValueToString[newsLayout];

    List<String> teamThemeOptions = [
      AppLocalizations.of(context).defaultValue,
      'Alfa Romeo',
      'Alpha Tauri',
      'Alpine',
      'Aston Martin',
      'Ferrari',
      'Haas',
      'McLaren',
      'Mercedes',
      'Red Bull',
      'Williams',
    ];

    Map teamNameToString = {
      "default": AppLocalizations.of(context).defaultValue,
      "alfa": 'Alfa Romeo',
      "alphatauri": 'Alpha Tauri',
      "alpine": 'Alpine',
      "aston_martin": 'Aston Martin',
      "ferrari": 'Ferrari',
      "haas": 'Haas',
      "mclaren": 'McLaren',
      "mercedes": 'Mercedes',
      "red_bull": 'Red Bull',
      "williams": 'Williams',
    };

    teamTheme = teamNameToString[teamTheme];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).appearance,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context).theme,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: themeMode,
              dropdownColor: useDarkMode
                  ? Theme.of(context).backgroundColor
                  : Colors.white,
              onChanged: (int newThemeMode) {
                if (newThemeMode != null) {
                  setState(
                    () {
                      bool newValue;
                      setState(() {
                        if (newThemeMode == 0) {
                          final Brightness brightnessValue =
                              MediaQuery.of(context).platformBrightness;
                          bool isDark = brightnessValue == Brightness.dark;
                          newValue = isDark;
                        } else if (newThemeMode == 1) {
                          newValue = false;
                        } else {
                          newValue = true;
                        }
                        Hive.box('settings').put('darkMode', newValue);
                        Hive.box('settings').put('themeMode', newThemeMode);
                        themeMode = newThemeMode;
                        useDarkMode = newValue;
                      });
                      widget.update();
                    },
                  );
                }
              },
              items: <int>[0, 1, 2].map<DropdownMenuItem<int>>(
                (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      themeOptions[value],
                      style: TextStyle(
                        fontSize: 12,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context).teamColors,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context).needsRestart,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: teamTheme,
              dropdownColor: useDarkMode
                  ? Theme.of(context).backgroundColor
                  : Colors.white,
              onChanged: (String newTeamTheme) {
                if (newTeamTheme != null) {
                  setState(
                    () {
                      Map stringToValue = {
                        AppLocalizations.of(context).defaultValue: 'default',
                        'Alfa Romeo': 'alfa',
                        'Alpha Tauri': 'alphatauri',
                        'Alpine': 'alpine',
                        'Aston Martin': 'aston_martin',
                        'Ferrari': 'ferrari',
                        'Haas': 'haas',
                        'McLaren': 'mclaren',
                        'Mercedes': 'mercedes',
                        'Red Bull': 'red_bull',
                        'Williams': 'williams',
                      };
                      Hive.box('settings')
                          .put('teamTheme', stringToValue[newTeamTheme]);
                      teamTheme = newTeamTheme;
                    },
                  );
                }
              },
              items: teamThemeOptions.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context).newsLayout,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: newsLayoutFormated,
              dropdownColor: useDarkMode
                  ? Theme.of(context).backgroundColor
                  : Colors.white,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      Map stringToValue = {
                        AppLocalizations.of(context).articleFull: 'big',
                        AppLocalizations.of(context).articleTitleAndImage:
                            'medium',
                        AppLocalizations.of(context).articleTitleAndDescription:
                            'condensed',
                        AppLocalizations.of(context).articleTitle: 'small',
                      };
                      newsLayout = stringToValue[newValue];
                      Hive.box('settings').put('newsLayout', newsLayout);
                    },
                  );
                  widget.update();
                }
              },
              items: <String>[
                AppLocalizations.of(context).articleFull,
                AppLocalizations.of(context).articleTitleAndImage,
                AppLocalizations.of(context).articleTitleAndDescription,
                AppLocalizations.of(context).articleTitle,
              ].map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: useDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
