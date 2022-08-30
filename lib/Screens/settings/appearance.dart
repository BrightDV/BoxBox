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
      'big': 'Complet',
      'medium': 'Titre et Image',
      'condensed': 'Titre et Description',
      'small': 'Titre',
    };
    String newsLayoutFormated = valueToString[newsLayout];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apparence',
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
              'Thème sombre',
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
              'Disposition des actualités',
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
                        'Complet': 'big',
                        'Titre et Image': 'medium',
                        'Titre et Description': 'condensed',
                        'Titre': 'small',
                      };
                      newsLayout = stringToValue[newValue];
                      Hive.box('settings').put('newsLayout', newsLayout);
                    },
                  );
                  widget.update();
                }
              },
              items: <String>[
                'Complet',
                'Titre et Image',
                'Titre et Description',
                'Titre',
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
