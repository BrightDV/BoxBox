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

import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  final Function? update;
  const SettingsScreen({Key? key, this.update}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _settingsSetState() {
    setState(() {});
    if (widget.update != null) {
      widget.update!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.settings,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.appearance),
              leading: Icon(Icons.format_paint_outlined),
              onTap: () => context.pushNamed('appearance-settings'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.player),
              leading: Icon(Icons.play_arrow_outlined),
              onTap: () => context.pushNamed('player-settings'),
            ),
            ListTile(
              title: Text('Notifications'),
              leading: Icon(Icons.notifications_outlined),
              onTap: () => context.pushNamed('notifications-settings'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.other),
              leading: Icon(Icons.miscellaneous_services_outlined),
              onTap: () => context.pushNamed(
                'other-settings',
                extra: {'update': _settingsSetState},
              ),
            ),
          ],
        ));
  }
}
