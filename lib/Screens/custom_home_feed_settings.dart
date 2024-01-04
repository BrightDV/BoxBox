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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomeHomeFeedSettingsScreen extends StatefulWidget {
  final Function updateParent;
  const CustomeHomeFeedSettingsScreen(this.updateParent, {super.key});

  @override
  State<CustomeHomeFeedSettingsScreen> createState() =>
      _CustomeHomeFeedSettingsScreenState();
}

class _CustomeHomeFeedSettingsScreenState
    extends State<CustomeHomeFeedSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    const String officialFeed = "https://api.formula1.com";
    List savedFeedUrl = Hive.box('settings')
        .get('homeFeed', defaultValue: [officialFeed, "api"]) as List;
    List customFeeds =
        Hive.box('settings').get('customFeeds', defaultValue: []) as List;
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;

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
      ),
      backgroundColor: useDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      body: SingleChildScrollView(
        child: Theme(
          data: ThemeData(
            unselectedWidgetColor: useDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Formula1',
          ),
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
                    color: useDarkMode ? Colors.white : Colors.black,
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
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                groupValue: savedFeedUrl[0],
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) => setState(
                  () {
                    savedFeedUrl = [value, "api"];
                    Hive.box('settings').put('homeFeed', savedFeedUrl);
                    widget.updateParent();
                  },
                ),
              ),
              ExpansionTile(
                title: Text(
                  AppLocalizations.of(context)!.motorsportLocalizeFeeds,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                iconColor: useDarkMode ? Colors.white : Colors.black,
                children: [
                  for (var feed in customFeedUrls.entries)
                    RadioListTile(
                      value: feed.value,
                      title: Text(
                        feed.key,
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      groupValue: savedFeedUrl[0],
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => setState(
                        () {
                          savedFeedUrl = [feed.value, "rss"];
                          Hive.box('settings').put('homeFeed', savedFeedUrl);
                          widget.updateParent();
                        },
                      ),
                    ),
                ],
              ),
              for (var feed in customFeeds)
                GestureDetector(
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: useDarkMode
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                20.0,
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(
                            50.0,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.deleteCustomFeed,
                            style: TextStyle(
                              fontSize: 24.0,
                              color: useDarkMode ? Colors.white : Colors.black,
                            ), // here
                            textAlign: TextAlign.center,
                          ),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)!.deleteUrl,
                                style: TextStyle(
                                  color:
                                      useDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                              ),
                            ),
                            ElevatedButton(
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
                                widget.updateParent();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.yes,
                              ),
                            ),
                          ],
                        );
                      }),
                  child: InkWell(
                    child: RadioListTile(
                      value: feed[0],
                      title: Text(
                        feed[0],
                        style: TextStyle(
                          color: useDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      groupValue: savedFeedUrl[0],
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => setState(
                        () {
                          Hive.box('settings').put('homeFeed', feed);
                          widget.updateParent();
                        },
                      ),
                    ),
                  ),
                ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.addCustomFeed,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.add_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController controller =
                        TextEditingController();
                    String type = "rss";
                    return StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        backgroundColor: useDarkMode
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20.0,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(
                          30.0,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.customFeed,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: useDarkMode ? Colors.white : Colors.black,
                          ), // here
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'https://example.com',
                                hintStyle: TextStyle(
                                  color: useDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              cursorColor:
                                  useDarkMode ? Colors.white : Colors.black,
                              style: TextStyle(
                                color:
                                    useDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor:
                                    useDarkMode ? Colors.white : Colors.black,
                                fontFamily: 'Formula1',
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio(
                                      value: "rss",
                                      groupValue: type,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      onChanged: (String? value) =>
                                          setState(() {
                                        type = value!;
                                      }),
                                    ),
                                    Text(
                                      'RSS',
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Radio(
                                      value: "wp",
                                      groupValue: type,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      onChanged: (String? value) =>
                                          setState(() {
                                        type = value!;
                                      }),
                                    ),
                                    Text(
                                      'WordPress',
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
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
                              widget.updateParent();
                            },
                            child: Text(
                              AppLocalizations.of(context)!.save,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              AppLocalizations.of(context)!.close,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
