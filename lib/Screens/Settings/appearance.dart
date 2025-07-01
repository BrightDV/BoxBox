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
 * Copyright (c) 2022-2025, BrightDV
 */

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
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
    String fontUsedInArticles = Hive.box('settings')
        .get('fontUsedInArticles', defaultValue: 'Formula1') as String;

    Map layoutValueToString = {
      'big': AppLocalizations.of(context)?.articleFull,
      'medium': AppLocalizations.of(context)?.articleTitleAndImage,
      'condensed': AppLocalizations.of(context)?.articleTitleAndDescription,
      'small': AppLocalizations.of(context)?.articleTitle,
    };
    List themeOptions = <String?>[
      AppLocalizations.of(context)?.followSystem,
      AppLocalizations.of(context)?.lightMode,
      AppLocalizations.of(context)?.darkMode,
    ];
    String newsLayoutFormated = layoutValueToString[newsLayout];
    List<String?> teamThemeOptions = [
      AppLocalizations.of(context)?.defaultValue,
      // TODO: localize
      'Navy Blue',
      'Blue Grey',
      'Alpine',
      'Aston Martin',
      'Ferrari',
      'Haas',
      'Kick Sauber',
      'McLaren',
      'Mercedes',
      'RB',
      'Red Bull',
      'Williams',
    ];

    Map teamNameToString = {
      "default": AppLocalizations.of(context)?.defaultValue,
      // TODO: localize
      "navyBlue": 'Navy Blue',
      "blueGrey": 'Blue Grey',
      "sauber": 'Kick Sauber',
      "rb": 'RB',
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

    Map fontNameToLabel = {
      'Formula1': 'Formula 1',
      'Titilium': 'Titilium',
      'Roboto': AppLocalizations.of(context)!.defaultValue,
    };
    fontUsedInArticles = fontNameToLabel[fontUsedInArticles];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appearance,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.theme,
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: themeMode,
              onChanged: (int? newThemeMode) {
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
                          if (newValue) {
                            AdaptiveTheme.of(context).setDark();
                          } else {
                            AdaptiveTheme.of(context).setLight();
                          }
                        } else if (newThemeMode == 1) {
                          newValue = false;
                          AdaptiveTheme.of(context).setLight();
                        } else {
                          newValue = true;
                          AdaptiveTheme.of(context).setDark();
                        }
                        Hive.box('settings').put('darkMode', newValue);
                        Hive.box('settings').put('themeMode', newThemeMode);

                        themeMode = newThemeMode;
                        useDarkMode = newValue;
                      });
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
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.teamColors,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.needsRestart,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: teamTheme,
              onChanged: (String? newTeamTheme) {
                if (newTeamTheme != null) {
                  setState(
                    () {
                      Map stringToValue = {
                        // TODO: localize
                        AppLocalizations.of(context)?.defaultValue: 'default',
                        'Navy Blue': 'navyBlue',
                        'Blue Grey': 'blueGrey',
                        'Kick Sauber': 'sauber',
                        'RB': 'rb',
                        'Alpine': 'alpine',
                        'Aston Martin': 'aston_martin',
                        'Ferrari': 'ferrari',
                        'Haas': 'haas',
                        'McLaren': 'mclaren',
                        'Mercedes': 'mercedes',
                        'Red Bull': 'red_bull',
                        'Williams': 'williams',
                      };
                      Hive.box('settings').put(
                        'teamTheme',
                        stringToValue[newTeamTheme],
                      );
                      Color color = TeamBackgroundColor()
                          .getTeamColor(stringToValue[newTeamTheme]);

                      AdaptiveTheme.of(context).setTheme(
                        light: ThemeData(
                          useMaterial3: true,
                          brightness: Brightness.light,
                          colorScheme: color == Color(0xFF000408) ||
                                  color == Color(0x00000001)
                              ? ColorScheme.fromSeed(
                                  seedColor: color,
                                  brightness: Brightness.light,
                                )
                              : ColorScheme.fromSeed(
                                  seedColor: color,
                                  onPrimary: color,
                                  brightness: Brightness.light,
                                ),
                          fontFamily: 'Formula1',
                        ),
                        dark: ThemeData(
                          useMaterial3: true,
                          brightness: Brightness.dark,
                          colorScheme: (color == Color(0xFF000408) ||
                                  color == Color(0x00000001))
                              ? ColorScheme.fromSeed(
                                  seedColor: color,
                                  brightness: Brightness.dark,
                                )
                              : ColorScheme.fromSeed(
                                  seedColor: color,
                                  onPrimary: HSLColor.fromColor(color)
                                      .withLightness(0.4)
                                      .toColor(),
                                  brightness: Brightness.dark,
                                ),
                          fontFamily: 'Formula1',
                        ),
                      );
                      teamTheme = newTeamTheme;
                    },
                  );
                }
              },
              items: teamThemeOptions.map<DropdownMenuItem<String>>(
                (String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value!,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.newsLayout,
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: newsLayoutFormated,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      Map stringToValue = {
                        AppLocalizations.of(context)?.articleFull: 'big',
                        AppLocalizations.of(context)?.articleTitleAndImage:
                            'medium',
                        AppLocalizations.of(context)
                            ?.articleTitleAndDescription: 'condensed',
                        AppLocalizations.of(context)?.articleTitle: 'small',
                      };
                      newsLayout = stringToValue[newValue];
                      Hive.box('settings').put('newsLayout', newsLayout);
                    },
                  );
                }
              },
              items: <String>[
                AppLocalizations.of(context)!.articleFull,
                AppLocalizations.of(context)!.articleTitleAndImage,
                AppLocalizations.of(context)!.articleTitleAndDescription,
                AppLocalizations.of(context)!.articleTitle,
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
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.font,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.fontDescription,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            trailing: DropdownButton(
              value: fontUsedInArticles,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      Map stringToValue = {
                        'Formula 1': 'Formula1',
                        'Titilium': 'Titilium',
                        AppLocalizations.of(context)!.defaultValue: 'Roboto',
                      };
                      fontUsedInArticles = stringToValue[newValue];
                      Hive.box('settings')
                          .put('fontUsedInArticles', fontUsedInArticles);
                    },
                  );
                }
              },
              items: <String>[
                'Formula 1',
                'Titilium',
                AppLocalizations.of(context)!.defaultValue,
              ].map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
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
