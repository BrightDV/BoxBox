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

import 'package:boxbox/helpers/bottom_sheet.dart';
import 'package:boxbox/helpers/constants.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChampionshipScreen extends StatefulWidget {
  const ChampionshipScreen({super.key});

  @override
  State<ChampionshipScreen> createState() => _ChampionshipScreenState();
}

class _ChampionshipScreenState extends State<ChampionshipScreen> {
  void onChanged(String? value) {
    if (value != null) {
      Hive.box('settings').put('championship', value);
      setState(() {});
    }
  }

  void onF1SourceChanged(bool? value) {
    if (value != null) {
      Hive.box('settings').put('useOfficialDataSoure', value);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    bool useOfficialDataSoure = Hive.box('settings')
        .get('useOfficialDataSoure', defaultValue: true) as bool;
    String ergastUrl = Hive.box('settings').get(
      'ergastUrl',
      defaultValue: Constants().ERGAST_API_URL,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.championship),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: SizedBox(
              width: 32,
              child: CachedNetworkImage(
                imageUrl:
                    'https://www.formula1.com/assets/home/_next/static/media/f1-logo-180.1db9e85b.png',
                height: 32,
              ),
            ),
            trailing: Radio(
              value: 'Formula 1',
              groupValue: championship,
              onChanged: (value) => onChanged(value),
            ),
            title: Text('Formula 1'),
          ),
          championship == 'Formula 1'
              ? ListTile(
                  trailing: Radio(
                    value: true,
                    groupValue: useOfficialDataSoure,
                    onChanged: (value) => onF1SourceChanged(value),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: 80),
                    child: Text('Official'),
                  ),
                )
              : Container(),
          championship == 'Formula 1'
              ? ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final TextEditingController controller =
                              TextEditingController();
                          await showCustomBottomSheet(
                            context,
                            SizedBox(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  30,
                                  15,
                                  30,
                                  MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .customErgastUrl,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: ergastUrl,
                                        hintStyle: TextStyle(
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 7),
                                      child: Container(
                                        width: double.infinity,
                                        height: 50,
                                        child: FilledButton.tonal(
                                          onPressed: () {
                                            Hive.box('settings').put(
                                              'ergastUrl',
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
                                      padding:
                                          EdgeInsets.only(top: 7, bottom: 20),
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
                        icon: Icon(Icons.settings_outlined),
                      ),
                      Radio(
                        value: false,
                        groupValue: useOfficialDataSoure,
                        onChanged: (value) => onF1SourceChanged(value),
                      ),
                    ],
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: 80),
                    child: Text('Ergast'),
                  ),
                )
              : Container(),
          ListTile(
            leading: SizedBox(
              width: 32,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://external-content.duckduckgo.com/ip3/www.fiaformula2.com.ico',
                  height: 36,
                ),
              ),
            ),
            trailing: Radio(
              value: 'Formula 2',
              groupValue: championship,
              onChanged: (value) => onChanged(value),
            ),
            title: Text('Formula 2'),
          ),
          ListTile(
            leading: SizedBox(
              width: 32,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://external-content.duckduckgo.com/ip3/www.fiaformula3.com.ico',
                  height: 36,
                ),
              ),
            ),
            trailing: Radio(
              value: 'Formula 3',
              groupValue: championship,
              onChanged: (value) => onChanged(value),
            ),
            title: Text('Formula 3'),
          ),
          ListTile(
            leading: SizedBox(
              width: 32,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://external-content.duckduckgo.com/ip3/www.f1academy.com.ico',
                  height: 36,
                ),
              ),
            ),
            trailing: Radio(
              value: 'F1 Academy',
              groupValue: championship,
              onChanged: (value) => onChanged(value),
            ),
            title: Text('F1 Academy'),
          ),
          ListTile(
            leading: SizedBox(
              width: 32,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://www.fiaformulae.com/resources/v4.32.1/i/elements/favicon-160x160.png',
                  height: 36,
                ),
              ),
            ),
            trailing: Radio(
              value: 'Formula E',
              groupValue: championship,
              onChanged: (value) => onChanged(value),
            ),
            title: Text('Formula E'),
          ),
        ],
      ),
    );
  }
}
