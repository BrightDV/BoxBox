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

class CustomeHomeFeedSettingsScreen extends StatefulWidget {
  final Function? updateParent;
  const CustomeHomeFeedSettingsScreen(this.updateParent, {super.key});

  @override
  State<CustomeHomeFeedSettingsScreen> createState() =>
      _CustomeHomeFeedSettingsScreenState();
}

class _CustomeHomeFeedSettingsScreenState
    extends State<CustomeHomeFeedSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final String officialFeed = Constants().F1_API_URL;
    List savedFeedUrl = Hive.box('settings')
        .get('homeFeed', defaultValue: [officialFeed, "api"]) as List;
    List customFeeds =
        Hive.box('settings').get('customFeeds', defaultValue: []) as List;

    Map<String, String> customFeedUrls = {
      'France': 'https://fr.motorsport.com',
      'España': 'https://es.motorsport.com',
      'Brasil': 'https://motorsport.uol.com.br',
      'Deutschland': 'https://de.motorsport.com',
      'Italia': 'https://it.motorsport.com',
      'Россия': 'https://ru.motorsport.com',
      '中文': 'https://cn.motorsport.com',
      'Magyarország': 'https://hu.motorsport.com',
      'Indonesia': 'https://id.motorsport.com',
      '日本': 'https://jp.motorsport.com',
      'Nederland': 'https://nl.motorsport.com',
      'Türkİye': 'https://tr.motorsport.com',
      'USA': 'https://us.motorsport.com',
      'Latinoamérica': 'https://lat.motorsport.com',
      'Switzerland': 'https://ch.motorsport.com',
      'Australia': 'https://au.motorsport.com',
      'Polska': 'https://pl.motorsport.com',
    };

    void _setState() {
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.news,
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              child: Text(
                AppLocalizations.of(context)!.customHomeFeed,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            RadioListTile(
              value: officialFeed,
              title: Text(
                AppLocalizations.of(context)!.official,
              ),
              groupValue: savedFeedUrl[0],
              onChanged: (value) => setState(
                () {
                  savedFeedUrl = [value, "api"];
                  Hive.box('settings').put('homeFeed', savedFeedUrl);
                  if (widget.updateParent != null) {
                    widget.updateParent!();
                  }
                },
              ),
            ),
            ExpansionTile(
              title: Text(
                AppLocalizations.of(context)!.motorsportLocalizeFeeds,
              ),
              children: [
                for (var feed in customFeedUrls.entries)
                  RadioListTile(
                    value: feed.value,
                    title: Text(
                      feed.key,
                    ),
                    groupValue: savedFeedUrl[0],
                    onChanged: (value) => setState(
                      () {
                        savedFeedUrl = [feed.value, "rss"];
                        Hive.box('settings').put('homeFeed', savedFeedUrl);
                        if (widget.updateParent != null) {
                          widget.updateParent!();
                        }
                      },
                    ),
                  ),
              ],
            ),
            for (var feed in customFeeds)
              GestureDetector(
                onLongPress: () {
                  showCustomBottomSheet(
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
                          Text(
                            AppLocalizations.of(context)!.deleteUrl,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 7),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.tonal(
                                onPressed: () {
                                  customFeeds.remove(feed);
                                  Hive.box('settings').put(
                                    'customFeeds',
                                    customFeeds,
                                  );
                                  if (savedFeedUrl[0] == feed[0]) {
                                    savedFeedUrl = [officialFeed, "api"];
                                    Hive.box('settings').put(
                                      'homeFeed',
                                      savedFeedUrl,
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
                  );
                },
                child: InkWell(
                  child: RadioListTile(
                    value: feed[0],
                    title: Text(
                      feed[0],
                    ),
                    groupValue: savedFeedUrl[0],
                    onChanged: (value) => setState(
                      () {
                        Hive.box('settings').put('homeFeed', feed);
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
                AppLocalizations.of(context)!.addCustomFeed,
              ),
              trailing: Icon(
                Icons.add_outlined,
              ),
              onTap: () {
                final TextEditingController controller =
                    TextEditingController();
                String type = "rss";
                showCustomBottomSheet(
                  context,
                  StatefulBuilder(
                    builder: (context, setState) => Padding(
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
                            AppLocalizations.of(context)!.customFeed,
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  value: "rss",
                                  groupValue: type,
                                  onChanged: (String? value) => setState(() {
                                    type = value!;
                                  }),
                                ),
                                Text(
                                  'RSS',
                                ),
                                Radio(
                                  value: "wp",
                                  groupValue: type,
                                  onChanged: (String? value) => setState(() {
                                    type = value!;
                                  }),
                                ),
                                Text(
                                  'WordPress',
                                ),
                              ],
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
                                    'homeFeed',
                                    [controller.text, type],
                                  );
                                  customFeeds.add([controller.text, type]);
                                  Hive.box('settings').put(
                                    'customFeeds',
                                    customFeeds,
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
