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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode = Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'À propos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/icon.png',
            height: 200,
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              'Box, Box!',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Box, Box! est une application open-source disponible sur GitHub. Elle a pour but de permettre de suivre la Formule 1 plus simplement, sans pubs et sans traqueurs !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              height: 40,
              child: TextButton.icon(
                onPressed: () async => await launchUrl(
                  Uri.parse("https://github.com/BrightDV/BoxBox"),
                  mode: LaunchMode.externalApplication,
                ),
                icon: FaIcon(
                  FontAwesomeIcons.github,
                ),
                label: Text(
                  "GitHub - Box, Box!",
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.black,
                  onSurface: Colors.grey,
                  elevation: 5,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Application développée par @BrightDV',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
