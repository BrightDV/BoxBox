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
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServerSettingsScreen extends StatefulWidget {
  final Function? updateParent;
  const ServerSettingsScreen(this.updateParent, {super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final String officialServer = Constants().F1_API_URL;
    List customServers =
        Hive.box('settings').get('customServers', defaultValue: []) as List;
    String savedServer = Hive.box('settings')
        .get('server', defaultValue: officialServer) as String;

    void _setState() {
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.server,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RadioListTile(
              value: officialServer,
              title: Text(
                AppLocalizations.of(context)!.official,
              ),
              groupValue: savedServer,
              onChanged: (value) => setState(
                () {
                  savedServer = value!;
                  Hive.box('settings').put('server', savedServer);
                  if (widget.updateParent != null) {
                    widget.updateParent!();
                  }
                },
              ),
            ),
            for (var server in customServers)
              GestureDetector(
                onLongPress: () => showCustomBottomSheet(
                  context,
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      15,
                      20,
                      MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.deleteCustomFeed,
                          style: TextStyle(
                            fontSize: 20.0,
                          ), // here
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            AppLocalizations.of(context)!.deleteUrl,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 7),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.tonal(
                              onPressed: () {
                                customServers.remove(server);
                                Hive.box('settings').put(
                                  'customServers',
                                  customServers,
                                );
                                if (server == savedServer) {
                                  Hive.box('settings').put(
                                    'server',
                                    officialServer,
                                  );
                                }
                                Navigator.of(context).pop();
                                _setState();
                                if (widget.updateParent != null) {
                                  widget.updateParent!();
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.yes,
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
                child: InkWell(
                  child: RadioListTile(
                    value: server,
                    title: Text(
                      server,
                    ),
                    groupValue: savedServer,
                    onChanged: (value) => setState(
                      () {
                        Hive.box('settings').put('server', server);
                        if (widget.updateParent != null) {
                          widget.updateParent!();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.addCustomServer,
              ),
              trailing: Icon(
                Icons.add_outlined,
              ),
              onTap: () {
                final TextEditingController controller =
                    TextEditingController();
                showCustomBottomSheet(
                  context,
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      15,
                      20,
                      MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.customServer,
                            style: TextStyle(
                              fontSize: 20.0,
                            ), // here
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                ),
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
                                    'server',
                                    controller.text,
                                  );
                                  customServers.add(controller.text);
                                  Hive.box('settings').put(
                                    'customServers',
                                    customServers,
                                  );
                                  Navigator.of(context).pop();
                                  _setState();
                                  if (widget.updateParent != null) {
                                    widget.updateParent!();
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.save,
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
            ),
          ],
        ),
      ),
    );
  }
}
