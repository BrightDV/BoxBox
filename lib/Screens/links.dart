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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatelessWidget {
  const LinksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.links,
        ),
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () async => await launchUrl(
                Uri.parse('https://www.formula1.com/'),
              ),
              child: ListTile(
                title: Text(
                  'Formula 1',
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'https://www.formula1.com/',
                  style: TextStyle(
                    color: useDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async => await launchUrl(
                Uri.parse('https://www.fia.com/regulation/category/110'),
              ),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.fiaRegulations,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'https://www.fia.com/regulation/category/110',
                  style: TextStyle(
                    color: useDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async => await launchUrl(
                Uri.parse('https://www.statsf1.com/'),
              ),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.statistics,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'https://www.statsf1.com/',
                  style: TextStyle(
                    color: useDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
