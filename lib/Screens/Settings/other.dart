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

import 'dart:math' as math;

import 'package:boxbox/api/services/formulae.dart';
import 'package:boxbox/helpers/bottom_sheet.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OtherSettingsScreen extends StatefulWidget {
  final Function? update;
  const OtherSettingsScreen(this.update, {super.key});

  @override
  State<OtherSettingsScreen> createState() => _OtherSettingsScreenState();
}

class _OtherSettingsScreenState extends State<OtherSettingsScreen> {
  bool isRefreshing = false;
  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    bool useDataSaverMode = Hive.box('settings')
        .get('useDataSaverMode', defaultValue: false) as bool;
    bool useOfficialWebview = Hive.box('settings')
        .get('useOfficialWebview', defaultValue: false) as bool;
    bool shouldUse12HourClock = Hive.box('settings')
        .get('shouldUse12HourClock', defaultValue: false) as bool;
    bool enableExperimentalFeatures = Hive.box('settings')
        .get('enableExperimentalFeatures', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.other),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.championship),
            subtitle: Text(
              AppLocalizations.of(context)!.needsRestart,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onTap: () => context.pushNamed('championship-settings'),
            trailing: Icon(Icons.arrow_forward),
          ),
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
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.server,
            ),
            onTap: () => context.pushNamed(
              'server-settings',
              extra: {'update': widget.update},
            ),
            trailing: Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
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
          if (championship == 'Formula 1')
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.apiKey,
              ),
              onTap: () {
                final TextEditingController controller =
                    TextEditingController();
                showCustomBottomSheet(
                  context,
                  StatefulBuilder(
                    builder: (context, setState) => Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        15,
                        20,
                        15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.updateApiKey,
                            style: TextStyle(
                              fontSize: 20.0,
                            ), // here
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 10),
                            child: Text(
                              AppLocalizations.of(context)!.updateApiKeySub,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: AppLocalizations.of(context)!.apiKey,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 7),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.tonal(
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
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 7, bottom: 7),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Hive.box('settings').put(
                                    'officialApiKey',
                                    Constants().F1_API_KEY,
                                  );
                                  Navigator.of(context).pop();
                                  setState(() {});
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.reset,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 7, bottom: 20),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              trailing: Icon(
                Icons.key_outlined,
              ),
            ),
          if (championship == 'Formula 1')
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.formulaYouSettings,
              ),
              trailing: Icon(
                Icons.arrow_forward_rounded,
              ),
              onTap: () => context.pushNamed('formula-you-settings'),
            ),
          if (championship == 'Formula 1')
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.news,
              ),
              onTap: () => context.pushNamed('custom-home-feed-settings'),
              trailing: Icon(
                Icons.arrow_forward_rounded,
              ),
            ),
          if (championship == 'Formula 1')
            SwitchListTile(
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
            ),
          if (championship == 'Formula 1')
            SwitchListTile(
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
            ),
          if (championship == 'Formula E')
            ListTile(
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
