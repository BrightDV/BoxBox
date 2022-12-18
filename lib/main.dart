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

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/bottom_navigation_bar.dart';
import 'package:boxbox/helpers/handle_native.dart';
import 'package:boxbox/helpers/route_handler.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/theme/teams_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // ignore: unused_local_variable
  final settingsBox = await Hive.openBox('settings');
  // ignore: unused_local_variable
  final requestsBox = await Hive.openBox('requests');
  // ignore: unused_local_variable
  final historyBox = await Hive.openBox('history');
  AwesomeNotifications().initialize(
    'resource://drawable/notification_icon',
    [
      NotificationChannel(
        channelKey: 'eventTracker',
        channelName: 'New Grand Prix notifications',
        channelDescription: 'Show a notification before each GP.',
        defaultColor: Colors.red,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'newArticle',
        channelName: 'New article',
        channelDescription:
            'Show a notification when a new article is published.',
        defaultColor: Colors.red,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );

  Workmanager().initialize(
    callbackDispatcher,
  );
  Workmanager().registerPeriodicTask(
    'newsLoader',
    "Load news in background",
    existingWorkPolicy: ExistingWorkPolicy.replace,
    frequency: Duration(hours: 4),
  );

  runApp(MyApp());
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Hive.initFlutter();
    Box hiveBox = await Hive.openBox("requests");
    Map cachedNews = hiveBox.get('news', defaultValue: {}) as Map;
    bool useDataSaverMode =
        hiveBox.get('useDataSaverMode', defaultValue: false) as bool;
    try {
      Map<String, dynamic> fetchedData = await F1NewsFetcher().getRawNews();
      if (cachedNews['items'].isNotEmpty &&
          fetchedData['items'][0]['id'] != cachedNews['items'][0]['id']) {
        String imageUrl = fetchedData['items'][0]['thumbnail']['image']['url'];
        if (useDataSaverMode) {
          if (fetchedData['items'][0]['thumbnail']['image']['renditions'] !=
              null) {
            imageUrl = fetchedData['items'][0]['thumbnail']['image']
                ['renditions']['2col-retina'];
          } else {
            imageUrl += '.transform/2col-retina/image.jpg';
          }
        }
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: createUniqueId(),
            channelKey: 'newArticle',
            title: fetchedData['items'][0]['title'],
            body: fetchedData['items'][0]['metaDescription'],
            largeIcon: imageUrl,
            bigPicture: imageUrl,
            hideLargeIconOnExpand: true,
            notificationLayout: NotificationLayout.BigPicture,
            payload: {
              'id': fetchedData['items'][0]['id'],
              'title': fetchedData['items'][0]['title'],
            },
          ),
        );
        hiveBox.put('news', fetchedData);
      } else {
        return Future.value(true);
      }
    } catch (error) {}
    return true;
  });
}

void setTimeagoLocaleMessages() {
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
  timeago.setLocaleMessages('az', timeago.AzMessages());
  timeago.setLocaleMessages('az_short', timeago.AzShortMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('ca_short', timeago.CaShortMessages());
  timeago.setLocaleMessages('cs', timeago.CsMessages());
  timeago.setLocaleMessages('cs_short', timeago.CsShortMessages());
  timeago.setLocaleMessages('da', timeago.DaMessages());
  timeago.setLocaleMessages('da_short', timeago.DaShortMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('de_short', timeago.DeShortMessages());
  timeago.setLocaleMessages('dv', timeago.DvMessages());
  timeago.setLocaleMessages('dv_short', timeago.DvShortMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('es_short', timeago.EsShortMessages());
  timeago.setLocaleMessages('et', timeago.EtMessages());
  timeago.setLocaleMessages('et_short', timeago.EtShortMessages());
  timeago.setLocaleMessages('fa', timeago.FaMessages());
  timeago.setLocaleMessages('fi', timeago.FiMessages());
  timeago.setLocaleMessages('fi_short', timeago.FiShortMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
  timeago.setLocaleMessages('gr', timeago.GrMessages());
  timeago.setLocaleMessages('gr_short', timeago.GrShortMessages());
  timeago.setLocaleMessages('he', timeago.HeMessages());
  timeago.setLocaleMessages('he', timeago.HeMessages());
  timeago.setLocaleMessages('he_short', timeago.HeShortMessages());
  timeago.setLocaleMessages('hi', timeago.HiMessages());
  timeago.setLocaleMessages('hi_short', timeago.HiShortMessages());
  timeago.setLocaleMessages('hu', timeago.HuMessages());
  timeago.setLocaleMessages('hu_short', timeago.HuShortMessages());
  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  timeago.setLocaleMessages('km', timeago.KmMessages());
  timeago.setLocaleMessages('km_short', timeago.KmShortMessages());
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  timeago.setLocaleMessages('ku', timeago.KuMessages());
  timeago.setLocaleMessages('ku_short', timeago.KuShortMessages());
  timeago.setLocaleMessages('mn', timeago.MnMessages());
  timeago.setLocaleMessages('mn_short', timeago.MnShortMessages());
  timeago.setLocaleMessages('ms_MY', timeago.MsMyMessages());
  timeago.setLocaleMessages('ms_MY_short', timeago.MsMyShortMessages());
  timeago.setLocaleMessages('nb_NO', timeago.NbNoMessages());
  timeago.setLocaleMessages('nb_NO_short', timeago.NbNoShortMessages());
  timeago.setLocaleMessages('nl', timeago.NlMessages());
  timeago.setLocaleMessages('nl_short', timeago.NlShortMessages());
  timeago.setLocaleMessages('nn_NO', timeago.NnNoMessages());
  timeago.setLocaleMessages('nn_NO_short', timeago.NnNoShortMessages());
  timeago.setLocaleMessages('pl', timeago.PlMessages());
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
  timeago.setLocaleMessages('ro', timeago.RoMessages());
  timeago.setLocaleMessages('ro_short', timeago.RoShortMessages());
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());
  timeago.setLocaleMessages('rw', timeago.RwMessages());
  timeago.setLocaleMessages('rw_short', timeago.RwShortMessages());
  timeago.setLocaleMessages('sv', timeago.SvMessages());
  timeago.setLocaleMessages('sv_short', timeago.SvShortMessages());
  timeago.setLocaleMessages('ta', timeago.TaMessages());
  timeago.setLocaleMessages('th', timeago.ThMessages());
  timeago.setLocaleMessages('th_short', timeago.ThShortMessages());
  timeago.setLocaleMessages('tk', timeago.TkMessages());
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setLocaleMessages('uk', timeago.UkMessages());
  timeago.setLocaleMessages('uk_short', timeago.UkShortMessages());
  timeago.setLocaleMessages('ur', timeago.UrMessages());
  timeago.setLocaleMessages('vi', timeago.ViMessages());
  timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
  timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
}

class NotificationController {
  static Future<void> startListeningNotificationEvents(
      BuildContext context) async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async =>
          receivedAction.payload?['id'] == null
              ? null
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleScreen(
                      receivedAction.payload!['id']!,
                      receivedAction.payload!['title']!,
                      false,
                    ),
                  ),
                ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents(context);
    super.initState();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen(
      (String value) {
        handleSharedText(value, navigatorKey);
      },
      onError: (err) {
        // print("ERROR in getTextStream: $err");
      },
    );

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(
      (String? value) {
        if (value != null) handleSharedText(value, navigatorKey);
      },
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String teamTheme = Hive.box('settings')
        .get('teamTheme', defaultValue: 'default') as String;
    Map<int, Color> color = TeamsThemes().getTeamTheme(teamTheme);

    MaterialColor colorCustom =
        MaterialColor(TeamsThemes().getTeamColor(teamTheme), color);
    setTimeagoLocaleMessages();

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
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return HandleRoute.handleRoute(settings.name);
      },
    );
  }
}
