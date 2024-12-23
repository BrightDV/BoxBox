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

import 'dart:math' as math;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:boxbox/Screens/FormulaYou/settings.dart';
import 'package:boxbox/Screens/custom_home_feed_settings.dart';
import 'package:boxbox/Screens/server_settings.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final Function update;
  const SettingsScreen(this.update, {Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppearanceCard(),
                PlayerCard(useDarkMode),
                OtherCard(_settingsSetState),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppearanceCard extends StatefulWidget {
  const AppearanceCard({Key? key}) : super(key: key);

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

    return Card(
      elevation: 5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text(
              AppLocalizations.of(context)!.appearance,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
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

class PlayerCard extends StatefulWidget {
  final bool useDarkMode;
  const PlayerCard(this.useDarkMode, {Key? key}) : super(key: key);

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  @override
  Widget build(BuildContext context) {
    int playerQuality =
        Hive.box('settings').get('playerQuality', defaultValue: 360) as int;
    String pipedApiUrl = Hive.box('settings')
        .get('pipedApiUrl', defaultValue: 'pipedapi.kavin.rocks') as String;
    return Card(
      elevation: 5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text(
              AppLocalizations.of(context)!.player,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.playerQuality,
              style: TextStyle(),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.playerQualitySub,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: playerQuality,
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
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          ListTile(
            title: Text(
              'Piped Proxy URL',
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.pipedApiUrlSub,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: pipedApiUrl,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      pipedApiUrl = newValue;
                      Hive.box('settings').put('pipedApiUrl', newValue);
                    },
                  );
                }
              },
              items: <String>[
                'pipedapi.kavin.rocks',
                'pipedapi.syncpundit.io',
                'pipedapi.adminforge.de',
                'watchapi.whatever.social',
                'api.piped.privacydev.net',
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

class OtherCard extends StatefulWidget {
  final Function update;
  const OtherCard(this.update, {Key? key}) : super(key: key);
  @override
  State<OtherCard> createState() => _OtherCardstate();
}

class _OtherCardstate extends State<OtherCard> {
  bool isRefreshing = false;
  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    bool useOfficialWebview = Hive.box('settings')
        .get('useOfficialWebview', defaultValue: true) as bool;
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: true) as bool;
    bool shouldUse12HourClock = Hive.box('settings')
        .get('shouldUse12HourClock', defaultValue: false) as bool;
    bool enableExperimentalFeatures = Hive.box('settings')
        .get('enableExperimentalFeatures', defaultValue: false) as bool;

    return Card(
      elevation: 5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text(
              AppLocalizations.of(context)!.other,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.championship),
            subtitle: Text(
              AppLocalizations.of(context)!.needsRestart,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: championship,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      championship = newValue;
                      Hive.box('settings').put('championship', newValue);
                    },
                  );
                }
              },
              items: <String>[
                'Formula 1',
                'Formula E',
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
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.apiKey,
            ),
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller =
                    TextEditingController();
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          20.0,
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(
                      25.0,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.updateApiKey,
                      style: TextStyle(
                        fontSize: 24.0,
                      ), // here
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.updateApiKeySub,
                          textAlign: TextAlign.justify,
                        ),
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.apiKey,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Hive.box('settings').put(
                                  'officialApiKey',
                                  controller.text,
                                );
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: Text(
                                AppLocalizations.of(context)!.save,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Hive.box('settings').put(
                                  'officialApiKey',
                                  Constants().F1_API_KEY,
                                );
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: Text(
                                AppLocalizations.of(context)!.defaultValue,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.close,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            trailing: Icon(
              Icons.key_outlined,
            ),
          ),
          championship == 'Formula 1'
              ? ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.formulaYouSettings,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormulaYouSettingsScreen(),
                    ),
                  ),
                )
              : Container(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.news,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomeHomeFeedSettingsScreen(
                  widget.update,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.server,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServerSettingsScreen(
                  widget.update,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
          championship == 'Formula 1'
              ? SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.dataSaverMode,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.dataSaverModeSub,
                    style: TextStyle(
                      fontSize: 12,
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
                )
              : Container(),
          championship == 'Formula 1'
              ? SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.useOfficialWebview,
                  ),
                  value: useOfficialWebview,
                  onChanged: (bool value) {
                    setState(
                      () {
                        useOfficialWebview = value;
                        Hive.box('settings').put('useOfficialWebview', value);
                      },
                    );
                  },
                )
              : Container(),
          SwitchListTile(
            title: Text(
              AppLocalizations.of(context)!.twelveHourClock,
            ),
            value: shouldUse12HourClock,
            onChanged: (bool value) {
              setState(
                () {
                  shouldUse12HourClock = value;
                  Hive.box('settings').put('shouldUse12HourClock', value);
                },
              );
            },
          ),
          championship == 'Formula E'
              ? ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.refreshChampionshipData,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.refreshChampionshipDataSub,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    setState(
                      () {
                        isRefreshing = true;
                      },
                    );
                    await FormulaE().updateChampionshipId();
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.done,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.grey.shade500,
                      fontSize: 16.0,
                    );

                    setState(
                      () {
                        isRefreshing = false;
                      },
                    );
                  },
                  trailing: isRefreshing
                      ? LoadingIcon()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(Icons.sync_outlined),
                        ),
                )
              : Container(),
          championship == 'Formula 1'
              ? GestureDetector(
                  onLongPress: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/BrightDV/BoxBox/wiki/Ergast-API-vs-Official-API',
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.useOfficialDataSource,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.useOfficialDataSourceSub,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    value: useOfficialDataSoure,
                    onChanged: (bool value) {
                      setState(
                        () {
                          useOfficialDataSoure = value;
                          Hive.box('settings')
                              .put('useOfficialDataSoure', value);
                        },
                      );
                    },
                  ),
                )
              : Container(),
          SwitchListTile(
            title: Text(
              AppLocalizations.of(context)!.experimentalFeatures,
            ),
            value: enableExperimentalFeatures,
            onChanged: (bool value) {
              setState(
                () {
                  enableExperimentalFeatures = value;
                  Hive.box('settings').put('enableExperimentalFeatures', value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoadingIcon extends StatefulWidget {
  const LoadingIcon({super.key});

  @override
  State<LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon>
    with TickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final Animation<double> animation = CurvedAnimation(
    parent: controller,
    curve: Curves.linear,
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.repeat();
    return RotationTransition(
      turns: animation,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: Icon(Icons.sync_outlined),
      ),
    );
  }
}
