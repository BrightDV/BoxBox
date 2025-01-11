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

class EditOrderScreen extends StatefulWidget {
  final Function updateParent;
  const EditOrderScreen(this.updateParent, {Key? key}) : super(key: key);

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List feedsNames = Hive.box('feeds').get(
      'feedsNames',
      defaultValue: [
        'WTF1.com',
        'Racefans.net',
        // 'Beyondtheflag.com',
        'Motorsport.com',
        'Autosport.com',
        'GPFans.com',
        'Racer.com',
        'Thecheckeredflag.co.uk',
        'Motorsportweek.com',
        'Crash.net',
        //'Pitpass.com', // TODO: fix Pitpass
      ],
    ) as List;
    Map<String, dynamic> feedsDetails = Hive.box('feeds').get(
      'feedsDetails',
      defaultValue: {
        'WTF1.com': {'url': 'https://wtf1.com', 'type': 'wp'},
        'Racefans.net': {'url': 'https://racefans.net', 'type': 'wp'},
        /* 'Beyondtheflag.com': {
          'url': 'https://beyondtheflag.com',
          'type': 'wp'
        }, */
        'Motorsport.com': {
          'url': 'https://www.motorsport.com/rss/f1/news/',
          'type': 'rss'
        },
        'Autosport.com': {
          'url': 'https://www.autosport.com/rss/f1/news/',
          'type': 'rss'
        },
        'GPFans.com': {
          'url': 'https://www.gpfans.com/en/rss.xml',
          'type': 'rss'
        },
        'Racer.com': {'url': 'https://racer.com/f1/feed/', 'type': 'rss'},
        'Thecheckeredflag.co.uk': {
          'url':
              'https://www.thecheckeredflag.co.uk/open-wheel/formula-1/feed/',
          'type': 'rss'
        },
        'Motorsportweek.com': {
          'url': 'https://www.motorsportweek.com/feed/',
          'type': 'rss'
        },
        'Crash.net': {'url': 'https://www.crash.net/rss/f1', 'type': 'rss'},
        /* 'Pitpass.com': {
          'url':
              'https://www.pitpass.com/fes_php/fes_usr_sit_newsfeed.php?fes_prepend_aty_sht_name=1',
          'type': 'rss'
        }, */
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.edit,
        ),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                final TextEditingController nameController =
                    TextEditingController();
                final TextEditingController urlController =
                    TextEditingController();
                String type = "rss";
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
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
                      ),
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Example',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            hintText: 'https://example.com',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w100,
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
                                onChanged: (String? value) => setState(
                                  () {
                                    type = value!;
                                  },
                                ),
                              ),
                              Text(
                                'WordPress',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          feedsNames.add(nameController.text);
                          Hive.box('feeds').put('feedsNames', feedsNames);
                          feedsDetails[nameController.text] = {
                            'url': urlController.text,
                            'type': type
                          };
                          Hive.box('feeds').put('feedsDetails', feedsDetails);
                          Navigator.of(context).pop();
                          update();
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
            icon: Icon(
              Icons.add_outlined,
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: ReorderableListView.builder(
          header: Padding(
            padding: const EdgeInsets.all(5),
            child: RichText(
              text: TextSpan(
                text: AppLocalizations.of(context)!.editOrderDescription,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          itemBuilder: (_, index) => ListTile(
            key: Key('$index'),
            title: Text(
              feedsNames[index],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
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
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          feedsDetails.remove(feedsNames[index]);
                          Hive.box('feeds').put('feedsDetails', feedsDetails);
                          feedsNames.remove(feedsNames[index]);
                          Hive.box('feeds').put('feedsNames', feedsNames);
                          Navigator.of(context).pop();
                          setState(() {});
                          widget.updateParent();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.yes,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          itemCount: feedsNames.length,
          onReorder: (int oldIndex, int newIndex) {
            setState(
              () {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final String item = feedsNames.removeAt(oldIndex);
                feedsNames.insert(newIndex, item);
                Hive.box('feeds').put('feedsNames', feedsNames);
                widget.updateParent();
              },
            );
          },
        ),
      ),
    );
  }
}
