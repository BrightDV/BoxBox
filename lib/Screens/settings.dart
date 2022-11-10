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

class SettingsScreen extends StatefulWidget {
  final Function update;
  const SettingsScreen(this.update);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _settingsSetState() {
    setState(() {});
    widget.update();
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppearanceCard(_settingsSetState),
                PlayerCard(),
                OtherCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppearanceCard extends StatefulWidget {
  final Function update;
  const AppearanceCard(this.update);

  @override
  State<AppearanceCard> createState() => _AppearanceCardState();
}

class _AppearanceCardState extends State<AppearanceCard> {
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
    bool useDefaultFontForArticles = Hive.box('settings')
        .get('useDefaultFontForArticles', defaultValue: false) as bool;

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
      "default": AppLocalizations.of(context)?.defaultValue,
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

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Text(
            AppLocalizations.of(context)!.appearance,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.theme,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton(
            value: themeMode,
            dropdownColor:
                useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
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
            AppLocalizations.of(context)!.teamColors,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.needsRestart,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton(
            value: teamTheme,
            dropdownColor:
                useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
            onChanged: (String? newTeamTheme) {
              if (newTeamTheme != null) {
                setState(
                  () {
                    Map stringToValue = {
                      AppLocalizations.of(context)?.defaultValue: 'default',
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
              (String? value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value!,
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
            AppLocalizations.of(context)!.newsLayout,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton(
            value: newsLayoutFormated,
            dropdownColor:
                useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(
                  () {
                    Map stringToValue = {
                      AppLocalizations.of(context)?.articleFull: 'big',
                      AppLocalizations.of(context)?.articleTitleAndImage:
                          'medium',
                      AppLocalizations.of(context)?.articleTitleAndDescription:
                          'condensed',
                      AppLocalizations.of(context)?.articleTitle: 'small',
                    };
                    newsLayout = stringToValue[newValue];
                    Hive.box('settings').put('newsLayout', newsLayout);
                  },
                );
                widget.update();
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
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.font,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.fontDescription,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
          value: useDefaultFontForArticles,
          onChanged: (bool value) {
            setState(() {
              useDefaultFontForArticles = value;
              Hive.box('settings').put('useDefaultFontForArticles', value);
            });
          },
        ),
      ],
    );
  }
}

class PlayerCard extends StatefulWidget {
  const PlayerCard();
  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    int playerQuality =
        Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.player,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.playerQuality,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.playerQualitySub,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
          onTap: () {},
          trailing: DropdownButton(
            value: playerQuality,
            dropdownColor:
                useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(
                  () {
                    playerQuality = newValue;
                    Hive.box('settings').put('playerQuality', newValue);
                  },
                );
              }
            },
            items: <int>[
              180,
              360,
              720,
            ].map<DropdownMenuItem<int>>(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '${value}p',
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
    );
  }
}

class OtherCard extends StatefulWidget {
  const OtherCard();
  @override
  State<OtherCard> createState() => _OtherCardstate();
}

class _OtherCardstate extends State<OtherCard> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    bool enableExperimentalFeatures = Hive.box('settings')
        .get('enableExperimentalFeatures', defaultValue: false) as bool;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Text(
            AppLocalizations.of(context)!.other,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.dataSaverMode,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.dataSaverModeSub,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
          value: useDataSaverMode,
          onChanged: (bool value) {
            setState(() {
              useDataSaverMode = value;
              Hive.box('settings').put('useDataSaverMode', value);
              if (value) {
                Hive.box('settings').put('playerQuality', 180);
              } else {
                Hive.box('settings').put('playerQuality', 720);
              }
            });
          },
        ),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.experimentalFeatures,
            style: TextStyle(
              color: useDarkMode ? Colors.white : Colors.black,
            ),
          ),
          value: enableExperimentalFeatures,
          onChanged: (bool value) {
            setState(() {
              enableExperimentalFeatures = value;
              Hive.box('settings').put('enableExperimentalFeatures', value);
            });
          },
        ),
      ],
    );
  }
}
