import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_peo.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ko'),
    Locale('ml'),
    Locale('nb'),
    Locale('nl'),
    Locale('pa'),
    Locale('peo'),
    Locale('pl'),
    Locale('pt'),
    Locale('sw'),
    Locale('ta'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Box, Box! is copylefted libre software, licensed under GPLv3+. Its aim is to allow users to follow Formula 1 and Formula E without ads or trackers.'**
  String get aboutDescription;

  /// No description provided for @aboutBottomLine.
  ///
  /// In en, this message translates to:
  /// **'With ❤ by BrightDV.'**
  String get aboutBottomLine;

  /// No description provided for @addCustomFeed.
  ///
  /// In en, this message translates to:
  /// **'Add a custom feed'**
  String get addCustomFeed;

  /// No description provided for @addCustomServer.
  ///
  /// In en, this message translates to:
  /// **'Add a custom server'**
  String get addCustomServer;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// No description provided for @alreadyDownloadedArticle.
  ///
  /// In en, this message translates to:
  /// **'This article has already been downloaded.'**
  String get alreadyDownloadedArticle;

  /// No description provided for @alreadyDownloading.
  ///
  /// In en, this message translates to:
  /// **'Already downloading'**
  String get alreadyDownloading;

  /// No description provided for @anyNetwork.
  ///
  /// In en, this message translates to:
  /// **'Any network'**
  String get anyNetwork;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @articleFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get articleFull;

  /// No description provided for @articleNotifications.
  ///
  /// In en, this message translates to:
  /// **'New articles notifications'**
  String get articleNotifications;

  /// No description provided for @articleTitleAndImage.
  ///
  /// In en, this message translates to:
  /// **'Title and Image'**
  String get articleTitleAndImage;

  /// No description provided for @articleTitleAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Title and Description'**
  String get articleTitleAndDescription;

  /// No description provided for @articleTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get articleTitle;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @championship.
  ///
  /// In en, this message translates to:
  /// **'Championship'**
  String get championship;

  /// No description provided for @chassis.
  ///
  /// In en, this message translates to:
  /// **'Chassis'**
  String get chassis;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for a new update'**
  String get checkUpdates;

  /// No description provided for @circuitLength.
  ///
  /// In en, this message translates to:
  /// **'Circuit Length'**
  String get circuitLength;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy title'**
  String get copyTitle;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @crashError.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get crashError;

  /// No description provided for @customErgastUrl.
  ///
  /// In en, this message translates to:
  /// **'Ergast Custom URL'**
  String get customErgastUrl;

  /// No description provided for @customFeed.
  ///
  /// In en, this message translates to:
  /// **'Custom feed'**
  String get customFeed;

  /// No description provided for @customHomeFeed.
  ///
  /// In en, this message translates to:
  /// **'Custom home feed'**
  String get customHomeFeed;

  /// No description provided for @customServer.
  ///
  /// In en, this message translates to:
  /// **'Custom server'**
  String get customServer;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @dataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Data unavailable at the moment.'**
  String get dataNotAvailable;

  /// No description provided for @dataSaverMode.
  ///
  /// In en, this message translates to:
  /// **'Data saver'**
  String get dataSaverMode;

  /// No description provided for @dataSaverModeSub.
  ///
  /// In en, this message translates to:
  /// **'Low-quality images and videos.'**
  String get dataSaverModeSub;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dayFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get dayFirstLetter;

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCustomFeed.
  ///
  /// In en, this message translates to:
  /// **'Delete feed'**
  String get deleteCustomFeed;

  /// No description provided for @deleteUrl.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to delete this URL?'**
  String get deleteUrl;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Download paused'**
  String get downloadPaused;

  /// No description provided for @downloadRunning.
  ///
  /// In en, this message translates to:
  /// **'Download running'**
  String get downloadRunning;

  /// No description provided for @driverAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'DRI'**
  String get driverAbbreviation;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'DRIVERS'**
  String get drivers;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Change order by long-pressing an item.'**
  String get editOrderDescription;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @errorOccurredDetails.
  ///
  /// In en, this message translates to:
  /// **'The app encountered an unknown error.\nPlease try again later.'**
  String get errorOccurredDetails;

  /// No description provided for @experimentalFeatures.
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get experimentalFeatures;

  /// No description provided for @fastestLaps.
  ///
  /// In en, this message translates to:
  /// **'Fastest Laps'**
  String get fastestLaps;

  /// No description provided for @fiaRegulations.
  ///
  /// In en, this message translates to:
  /// **'FIA Regulations'**
  String get fiaRegulations;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @firstGrandPrix.
  ///
  /// In en, this message translates to:
  /// **'First Grand Prix'**
  String get firstGrandPrix;

  /// No description provided for @firstTeamEntry.
  ///
  /// In en, this message translates to:
  /// **'First Team Entry'**
  String get firstTeamEntry;

  /// Keep 'Formula You' untranslated as it is the name of the service.
  ///
  /// In en, this message translates to:
  /// **'Formula You Settings'**
  String get formulaYouSettings;

  /// No description provided for @freePracticeFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'FP'**
  String get freePracticeFirstLetter;

  /// No description provided for @freePracticeOne.
  ///
  /// In en, this message translates to:
  /// **'Free Practice FP1'**
  String get freePracticeOne;

  /// No description provided for @freePracticeTwo.
  ///
  /// In en, this message translates to:
  /// **'Free Practice FP2'**
  String get freePracticeTwo;

  /// No description provided for @freePracticeThree.
  ///
  /// In en, this message translates to:
  /// **'Free Practice FP3'**
  String get freePracticeThree;

  /// No description provided for @freePracticeShort.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE'**
  String get freePracticeShort;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From '**
  String get from;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontDescription.
  ///
  /// In en, this message translates to:
  /// **'Font used in the articles.'**
  String get fontDescription;

  /// No description provided for @fullScreenGestures.
  ///
  /// In en, this message translates to:
  /// **'Enter/exit fullscreen gestures'**
  String get fullScreenGestures;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @gap.
  ///
  /// In en, this message translates to:
  /// **'GAP'**
  String get gap;

  /// No description provided for @grandsPrix.
  ///
  /// In en, this message translates to:
  /// **'Grands Prix entered'**
  String get grandsPrix;

  /// No description provided for @grandPrixMap.
  ///
  /// In en, this message translates to:
  /// **'Grand Prix Map'**
  String get grandPrixMap;

  /// No description provided for @grandPrixNotifications.
  ///
  /// In en, this message translates to:
  /// **'Grand-Prix sessions notifications'**
  String get grandPrixNotifications;

  /// No description provided for @grandPrixNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'You need to go to the schedule screen in order to initialize notifications of the next Grand-Prix.'**
  String get grandPrixNotificationsSub;

  /// No description provided for @hallOfFame.
  ///
  /// In en, this message translates to:
  /// **'Hall of Fame'**
  String get hallOfFame;

  /// No description provided for @highestRaceFinish.
  ///
  /// In en, this message translates to:
  /// **'Highest race finish'**
  String get highestRaceFinish;

  /// No description provided for @highestGridPosition.
  ///
  /// In en, this message translates to:
  /// **'Highest grid position'**
  String get highestGridPosition;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @hourFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get hourFirstLetter;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @lapRecord.
  ///
  /// In en, this message translates to:
  /// **'Lap Record'**
  String get lapRecord;

  /// No description provided for @laps.
  ///
  /// In en, this message translates to:
  /// **'LAPS'**
  String get laps;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @liveBlog.
  ///
  /// In en, this message translates to:
  /// **'Live Blog'**
  String get liveBlog;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @minuteAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minuteAbbreviation;

  /// No description provided for @modernNewsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Use modern appearance for the news.'**
  String get modernNewsAppearance;

  /// No description provided for @monthAbbreviationJanuary.
  ///
  /// In en, this message translates to:
  /// **'JAN'**
  String get monthAbbreviationJanuary;

  /// No description provided for @monthAbbreviationFebruary.
  ///
  /// In en, this message translates to:
  /// **'FEB'**
  String get monthAbbreviationFebruary;

  /// No description provided for @monthAbbreviationMarch.
  ///
  /// In en, this message translates to:
  /// **'MAR'**
  String get monthAbbreviationMarch;

  /// No description provided for @monthAbbreviationApril.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get monthAbbreviationApril;

  /// No description provided for @monthAbbreviationMay.
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get monthAbbreviationMay;

  /// No description provided for @monthAbbreviationJune.
  ///
  /// In en, this message translates to:
  /// **'JUN'**
  String get monthAbbreviationJune;

  /// No description provided for @monthAbbreviationJuly.
  ///
  /// In en, this message translates to:
  /// **'JUL'**
  String get monthAbbreviationJuly;

  /// No description provided for @monthAbbreviationAugust.
  ///
  /// In en, this message translates to:
  /// **'AUG'**
  String get monthAbbreviationAugust;

  /// No description provided for @monthAbbreviationSeptember.
  ///
  /// In en, this message translates to:
  /// **'SEP'**
  String get monthAbbreviationSeptember;

  /// No description provided for @monthAbbreviationOctober.
  ///
  /// In en, this message translates to:
  /// **'OCT'**
  String get monthAbbreviationOctober;

  /// No description provided for @monthAbbreviationNovember.
  ///
  /// In en, this message translates to:
  /// **'NOV'**
  String get monthAbbreviationNovember;

  /// No description provided for @monthAbbreviationDecember.
  ///
  /// In en, this message translates to:
  /// **'DEC'**
  String get monthAbbreviationDecember;

  /// No description provided for @motorsportLocalizeFeeds.
  ///
  /// In en, this message translates to:
  /// **'Motorsport.com\'s localized feeds'**
  String get motorsportLocalizeFeeds;

  /// No description provided for @needsRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to apply changes.'**
  String get needsRestart;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @newsLayout.
  ///
  /// In en, this message translates to:
  /// **'News Layout'**
  String get newsLayout;

  /// No description provided for @newsMix.
  ///
  /// In en, this message translates to:
  /// **'News Mix'**
  String get newsMix;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get newVersionAvailable;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show here. You may be rate limited.'**
  String get noResults;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show\nhere.'**
  String get nothingHere;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifications2hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get notifications2hours;

  /// No description provided for @notifications6hours.
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get notifications6hours;

  /// No description provided for @notifications12hours.
  ///
  /// In en, this message translates to:
  /// **'12 hours'**
  String get notifications12hours;

  /// No description provided for @notifications24hours.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get notifications24hours;

  /// No description provided for @numberOfLaps.
  ///
  /// In en, this message translates to:
  /// **'Number of Laps'**
  String get numberOfLaps;

  /// No description provided for @official.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get official;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline. The data may not be up to date.'**
  String get offline;

  /// No description provided for @offtrack.
  ///
  /// In en, this message translates to:
  /// **'You went off-track!'**
  String get offtrack;

  /// No description provided for @offtrackSub.
  ///
  /// In en, this message translates to:
  /// **'Back on track'**
  String get offtrackSub;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in web browser'**
  String get openInBrowser;

  /// No description provided for @openLiveBlog.
  ///
  /// In en, this message translates to:
  /// **'Open live blog'**
  String get openLiveBlog;

  /// No description provided for @openPoll.
  ///
  /// In en, this message translates to:
  /// **'Take the survey'**
  String get openPoll;

  /// No description provided for @openQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz'**
  String get openQuiz;

  /// No description provided for @openingWithInAppBrowser.
  ///
  /// In en, this message translates to:
  /// **'Opening with the in-app browser'**
  String get openingWithInAppBrowser;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get placeOfBirth;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @playerQuality.
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get playerQuality;

  /// No description provided for @playerQualitySub.
  ///
  /// In en, this message translates to:
  /// **'For videos in articles.'**
  String get playerQualitySub;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @podiums.
  ///
  /// In en, this message translates to:
  /// **'Podiums'**
  String get podiums;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get point;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @pointsAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get pointsAbbreviation;

  /// No description provided for @polePositions.
  ///
  /// In en, this message translates to:
  /// **'Pole Positions'**
  String get polePositions;

  /// No description provided for @positionAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get positionAbbreviation;

  /// No description provided for @powerUnit.
  ///
  /// In en, this message translates to:
  /// **'Power Unit'**
  String get powerUnit;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS'**
  String get previous;

  /// No description provided for @qualifyings.
  ///
  /// In en, this message translates to:
  /// **'Qualifyings'**
  String get qualifyings;

  /// No description provided for @qualifyingsFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'Q'**
  String get qualifyingsFirstLetter;

  /// No description provided for @qualifyingsShort.
  ///
  /// In en, this message translates to:
  /// **'QUALIFS'**
  String get qualifyingsShort;

  /// No description provided for @qualityToDownload.
  ///
  /// In en, this message translates to:
  /// **'Select which quality to download.'**
  String get qualityToDownload;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @race.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get race;

  /// No description provided for @raceDistance.
  ///
  /// In en, this message translates to:
  /// **'Race Distance'**
  String get raceDistance;

  /// No description provided for @raceFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get raceFirstLetter;

  /// No description provided for @raceStartsIn.
  ///
  /// In en, this message translates to:
  /// **'The race starts in:'**
  String get raceStartsIn;

  /// No description provided for @raceStartsOn.
  ///
  /// In en, this message translates to:
  /// **'The race starts on:'**
  String get raceStartsOn;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshChampionshipData.
  ///
  /// In en, this message translates to:
  /// **'Refresh championship data'**
  String get refreshChampionshipData;

  /// No description provided for @refreshChampionshipDataSub.
  ///
  /// In en, this message translates to:
  /// **'Refresh championship data before a new season.'**
  String get refreshChampionshipDataSub;

  /// No description provided for @refreshInterval.
  ///
  /// In en, this message translates to:
  /// **'Refresh interval'**
  String get refreshInterval;

  /// No description provided for @requestError.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch data.'**
  String get requestError;

  /// No description provided for @requiredNetworkConnection.
  ///
  /// In en, this message translates to:
  /// **'Required network connection'**
  String get requiredNetworkConnection;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @secondAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'SEC'**
  String get secondAbbreviation;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'The session is over.'**
  String get sessionCompleted;

  /// No description provided for @sessionCompletedShort.
  ///
  /// In en, this message translates to:
  /// **'Session completed'**
  String get sessionCompletedShort;

  /// No description provided for @sessionRunning.
  ///
  /// In en, this message translates to:
  /// **'Session running'**
  String get sessionRunning;

  /// No description provided for @sessionStartsIn.
  ///
  /// In en, this message translates to:
  /// **'The session starts in:'**
  String get sessionStartsIn;

  /// No description provided for @sessionStartsOn.
  ///
  /// In en, this message translates to:
  /// **'The session starts on:'**
  String get sessionStartsOn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get sprint;

  /// No description provided for @sprintFirstLetter.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sprintFirstLetter;

  /// No description provided for @sprintQualifyings.
  ///
  /// In en, this message translates to:
  /// **'Sprint Qualifyings'**
  String get sprintQualifyings;

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standings;

  /// No description provided for @startingGrid.
  ///
  /// In en, this message translates to:
  /// **'Starting Grid'**
  String get startingGrid;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statistics;

  /// No description provided for @tapToCheckForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Tap to check for new update.'**
  String get tapToCheckForUpdate;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @teamBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get teamBase;

  /// No description provided for @teamChief.
  ///
  /// In en, this message translates to:
  /// **'Team Chief'**
  String get teamChief;

  /// No description provided for @teamColors.
  ///
  /// In en, this message translates to:
  /// **'Team colors'**
  String get teamColors;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'TEAMS'**
  String get teams;

  /// No description provided for @technicalChief.
  ///
  /// In en, this message translates to:
  /// **'Technical Chief'**
  String get technicalChief;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get time;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @twelveHourClock.
  ///
  /// In en, this message translates to:
  /// **'Use a 12-hour clock'**
  String get twelveHourClock;

  /// No description provided for @unavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Unavailable offline'**
  String get unavailableOffline;

  /// No description provided for @updateApiKey.
  ///
  /// In en, this message translates to:
  /// **'Update API Key'**
  String get updateApiKey;

  /// No description provided for @updateApiKeySub.
  ///
  /// In en, this message translates to:
  /// **'Update the API key of the official website.\nUpdate this only if you now what you are doing.'**
  String get updateApiKeySub;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'New versions'**
  String get updates;

  /// No description provided for @useOfficialWebview.
  ///
  /// In en, this message translates to:
  /// **'Use official Webview for live sessions instead of f1-dash.com'**
  String get useOfficialWebview;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'Victory'**
  String get victory;

  /// No description provided for @victories.
  ///
  /// In en, this message translates to:
  /// **'Victories'**
  String get victories;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @viewHighlights.
  ///
  /// In en, this message translates to:
  /// **'View highlights'**
  String get viewHighlights;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'VIEW MORE'**
  String get viewMore;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View results'**
  String get viewResults;

  /// No description provided for @watchHighlightsOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'Watch highlights on YouTube'**
  String get watchHighlightsOnYoutube;

  /// No description provided for @watchOnYouTube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchOnYouTube;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @worldChampionships.
  ///
  /// In en, this message translates to:
  /// **'World Championships'**
  String get worldChampionships;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'de', 'el', 'en', 'es', 'fi', 'fr', 'hi', 'hu', 'id', 'it', 'ko', 'ml', 'nb', 'nl', 'pa', 'peo', 'pl', 'pt', 'sw', 'ta', 'tr', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'de': return AppLocalizationsDe();
    case 'el': return AppLocalizationsEl();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'hu': return AppLocalizationsHu();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ko': return AppLocalizationsKo();
    case 'ml': return AppLocalizationsMl();
    case 'nb': return AppLocalizationsNb();
    case 'nl': return AppLocalizationsNl();
    case 'pa': return AppLocalizationsPa();
    case 'peo': return AppLocalizationsPeo();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'sw': return AppLocalizationsSw();
    case 'ta': return AppLocalizationsTa();
    case 'tr': return AppLocalizationsTr();
    case 'uk': return AppLocalizationsUk();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
