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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen();

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).updates,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context).checkUpdates,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tapToCheckForUpdate,
              style: TextStyle(
                color: useDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () async {
              var url = Uri.parse(
                  'https://api.github.com/repos/BrightDV/BoxBox/releases/latest');
              var response = await http.get(url);
              Map<String, dynamic> responseAsJson = jsonDecode(response.body);
              String remoteVersion = responseAsJson['tag_name'].substring(1);
              PackageInfo versionOfAppInstalled =
                  await PackageInfo.fromPlatform();
              print(responseAsJson['assets'][0]['browser_download_url']);
              if (versionOfAppInstalled.version != remoteVersion) {
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext ctx) => Dialog(
                    backgroundColor: useDarkMode
                        ? Theme.of(context).backgroundColor
                        : Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 15,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(10.0, 24.0, 10.0, 24.0),
                              child: Text(
                                AppLocalizations.of(context)
                                    .newVersionAvailable,
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            MarkdownBody(
                              data: responseAsJson['body'],
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                h1: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                h2: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                h3: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                p: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                                listBullet: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async => await launchUrl(
                                      Uri.parse(
                                        responseAsJson['assets'][0]
                                            ['browser_download_url'],
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context).download,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      AppLocalizations.of(context).close,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {}
            },
          ),
        ],
      ),
    );
  }
}
