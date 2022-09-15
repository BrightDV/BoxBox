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

//import 'package:flutlab_logcat/flutlab_logcat.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/bottom_navigation_bar.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await FlutLabLogcat.init();
  await Hive.initFlutter();
  // ignore: unused_local_variable
  final settingsBox = await Hive.openBox('settings');
  // ignore: unused_local_variable
  final requestsBox = await Hive.openBox('requests');
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(255, 6, 0, .1),
      100: Color.fromRGBO(255, 6, 0, .2),
      200: Color.fromRGBO(255, 6, 0, .3),
      300: Color.fromRGBO(255, 6, 0, .4),
      400: Color.fromRGBO(255, 6, 0, .5),
      500: Color.fromRGBO(255, 6, 0, .6),
      600: Color.fromRGBO(255, 6, 0, .7),
      700: Color.fromRGBO(255, 6, 0, .8),
      800: Color.fromRGBO(255, 6, 0, .9),
      900: Color.fromRGBO(255, 6, 0, 1),
    };
    MaterialColor colorCustom = MaterialColor(0xffe10600, color);
    return MaterialApp(
      title: 'Box, Box!',
      theme: ThemeData(
        fontFamily: 'Formula1',
        primarySwatch: colorCustom,
        backgroundColor: Color(0xff12121a),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainBottomNavigationBar(),
    );
  }
}
