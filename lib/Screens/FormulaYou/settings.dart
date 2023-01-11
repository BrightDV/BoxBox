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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'package:boxbox/Screens/FormulaYou/tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FormulaYouSettingsScreen extends StatefulWidget {
  final Function? update;
  const FormulaYouSettingsScreen({this.update});

  @override
  State<FormulaYouSettingsScreen> createState() =>
      _FormulaYouSettingsScreenState();
}

class _FormulaYouSettingsScreenState extends State<FormulaYouSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    List selectedTags =
        Hive.box('settings').get('selectedTags', defaultValue: []) as List;
    List availableTags = FormulaYouTags().tags();
    int i = 0;

    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.formulaYouSettings,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          for (i; i < availableTags.length; i++)
            ExpansionTile(
              title: Text(
                i == 0
                    ? AppLocalizations.of(context)!.drivers.capitalize()
                    : i == 1
                        ? AppLocalizations.of(context)!.teams.capitalize()
                        : i == 2
                            ? AppLocalizations.of(context)!.topics.capitalize()
                            : AppLocalizations.of(context)!.other.capitalize(),
              ),
              children: [
                for (String key in availableTags[i].keys.toList()..sort())
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor:
                          useDarkMode ? Colors.white : Colors.black,
                    ),
                    child: CheckboxListTile(
                      value: selectedTags.contains(key) ? true : false,
                      onChanged: (value) {
                        selectedTags.contains(key)
                            ? selectedTags.remove(key)
                            : selectedTags.add(key);
                        Hive.box('settings').put('selectedTags', selectedTags);
                        if (widget.update != null) {
                          widget.update!();
                        }
                        setState(() {});
                      },
                      title: Text(
                        key,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
              collapsedIconColor: useDarkMode ? Colors.white : Colors.black,
              collapsedTextColor: useDarkMode ? Colors.white : Colors.black,
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
