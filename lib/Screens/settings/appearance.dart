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
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    Map valueToString = {
      'big': AppLocalizations.of(context).articleFull,
      'medium': AppLocalizations.of(context).articleTitleAndImage,
      'condensed': AppLocalizations.of(context).articleTitleAndDescription,
      'small': AppLocalizations.of(context).articleTitle,
    };
    String newsLayoutFormated = valueToString[newsLayout];
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
          SwitchListTile(
            title: Text(
              AppLocalizations.of(context).darkMode,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            value: useDarkMode,
            onChanged: (bool value) {
              Hive.box('settings').put('darkMode', value);
              useDarkMode = value;
              setState(() {});
              widget.update();
            },
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
