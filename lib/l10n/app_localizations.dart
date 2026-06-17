import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SitaRam'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Read • Listen • Reflect'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get navRead;

  /// No description provided for @navListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get navListen;

  /// No description provided for @navReflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get navReflect;

  /// No description provided for @navAiGuide.
  ///
  /// In en, this message translates to:
  /// **'AI Guide'**
  String get navAiGuide;

  /// No description provided for @navResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get navResearch;

  /// No description provided for @navDonate.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get navDonate;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'SitaRam'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Valmiki Ramayana'**
  String get homeSubtitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Read  •  Listen  •  Reflect'**
  String get homeTagline;

  /// No description provided for @homeKandaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Kanda Library'**
  String get homeKandaLibrary;

  /// No description provided for @homeDailyWisdom.
  ///
  /// In en, this message translates to:
  /// **'Daily Wisdom'**
  String get homeDailyWisdom;

  /// No description provided for @homeContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get homeContinueReading;

  /// No description provided for @homeContinueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue Listening'**
  String get homeContinueListening;

  /// No description provided for @homeOpenChapterLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open Chapter Library'**
  String get homeOpenChapterLibrary;

  /// No description provided for @homeReadMainBook.
  ///
  /// In en, this message translates to:
  /// **'Read the Main Book'**
  String get homeReadMainBook;

  /// No description provided for @homeOpenPdfBook.
  ///
  /// In en, this message translates to:
  /// **'Open PDF Book'**
  String get homeOpenPdfBook;

  /// No description provided for @homeSourcePdf.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get homeSourcePdf;

  /// No description provided for @homeChaptersLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} Chapter(s) loaded'**
  String homeChaptersLoaded(int count);

  /// No description provided for @homeNotYetCompiled.
  ///
  /// In en, this message translates to:
  /// **'This Kanda is not yet compiled.'**
  String get homeNotYetCompiled;

  /// No description provided for @homeNoChaptersImported.
  ///
  /// In en, this message translates to:
  /// **'No Chapters Imported Yet'**
  String get homeNoChaptersImported;

  /// No description provided for @kandaNameBala.
  ///
  /// In en, this message translates to:
  /// **'Bala Kanda'**
  String get kandaNameBala;

  /// No description provided for @kandaNameAyodhya.
  ///
  /// In en, this message translates to:
  /// **'Ayodhya Kanda'**
  String get kandaNameAyodhya;

  /// No description provided for @kandaNameAranya.
  ///
  /// In en, this message translates to:
  /// **'Aranya Kanda'**
  String get kandaNameAranya;

  /// No description provided for @kandaNameKishkindha.
  ///
  /// In en, this message translates to:
  /// **'Kishkindha Kanda'**
  String get kandaNameKishkindha;

  /// No description provided for @kandaNameSundara.
  ///
  /// In en, this message translates to:
  /// **'Sundara Kanda'**
  String get kandaNameSundara;

  /// No description provided for @kandaNameYuddha.
  ///
  /// In en, this message translates to:
  /// **'Yuddha Kanda'**
  String get kandaNameYuddha;

  /// No description provided for @kandaNameUttara.
  ///
  /// In en, this message translates to:
  /// **'Uttara Kanda'**
  String get kandaNameUttara;

  /// No description provided for @kandaDescBala.
  ///
  /// In en, this message translates to:
  /// **'Book of Youth — The birth, youth, and education of Sri Rama, and his holy marriage to Sita.'**
  String get kandaDescBala;

  /// No description provided for @kandaDescAyodhya.
  ///
  /// In en, this message translates to:
  /// **'Book of Ayodhya — The preparation for Rama\'s coronation, the boons of Kaikeyi, and the sorrowful exile.'**
  String get kandaDescAyodhya;

  /// No description provided for @kandaDescAranya.
  ///
  /// In en, this message translates to:
  /// **'Book of Forest — The forest life, encounters with sages and demons, and abduction of Sita by Ravana.'**
  String get kandaDescAranya;

  /// No description provided for @kandaDescKishkindha.
  ///
  /// In en, this message translates to:
  /// **'Book of Kishkindha — The alliance of Rama with Sugriva, the monkey kingdom, and launching the search.'**
  String get kandaDescKishkindha;

  /// No description provided for @kandaDescSundara.
  ///
  /// In en, this message translates to:
  /// **'Book of Beauty — Hanuman\'s miraculous flight to Lanka, locating Sita, and the burning of Lanka.'**
  String get kandaDescSundara;

  /// No description provided for @kandaDescYuddha.
  ///
  /// In en, this message translates to:
  /// **'Book of War — The construction of the bridge, the great battle with Ravana, and rescue of Sita.'**
  String get kandaDescYuddha;

  /// No description provided for @kandaDescUttara.
  ///
  /// In en, this message translates to:
  /// **'Last Book — The return to Ayodhya, coronation of Sri Rama, and final pastimes.'**
  String get kandaDescUttara;

  /// No description provided for @readerTabEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get readerTabEnglish;

  /// No description provided for @readerTabBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get readerTabBangla;

  /// No description provided for @readerTabSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get readerTabSpanish;

  /// No description provided for @readerTabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get readerTabInsights;

  /// No description provided for @readerTabAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get readerTabAudio;

  /// No description provided for @readerSourceInfo.
  ///
  /// In en, this message translates to:
  /// **'Source Info'**
  String get readerSourceInfo;

  /// No description provided for @readerBanglaNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Bangla translation not available.'**
  String get readerBanglaNotLoaded;

  /// No description provided for @readerSpanishNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Spanish placeholder — reviewed text will be added after public-domain review.'**
  String get readerSpanishNotLoaded;

  /// No description provided for @readerSetAiContext.
  ///
  /// In en, this message translates to:
  /// **'Set as AI Context'**
  String get readerSetAiContext;

  /// No description provided for @readerAiSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Switched context. Tap the AI Guide tab to speak to the assistant.'**
  String get readerAiSnackbar;

  /// No description provided for @readerAskAiGuide.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Guide'**
  String get readerAskAiGuide;

  /// No description provided for @readerChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get readerChapterLabel;

  /// No description provided for @readerCharactersPresent.
  ///
  /// In en, this message translates to:
  /// **'Characters Present'**
  String get readerCharactersPresent;

  /// No description provided for @readerThemesPrinciples.
  ///
  /// In en, this message translates to:
  /// **'Themes & Principles'**
  String get readerThemesPrinciples;

  /// No description provided for @readerEnglishSummary.
  ///
  /// In en, this message translates to:
  /// **'English Summary'**
  String get readerEnglishSummary;

  /// No description provided for @readerBanglaSummary.
  ///
  /// In en, this message translates to:
  /// **'বাংলা সারসংক্ষেপ'**
  String get readerBanglaSummary;

  /// No description provided for @readerSpanishSummary.
  ///
  /// In en, this message translates to:
  /// **'Resumen en Español'**
  String get readerSpanishSummary;

  /// No description provided for @readerMoralLesson.
  ///
  /// In en, this message translates to:
  /// **'Moral Lesson (Dharma)'**
  String get readerMoralLesson;

  /// No description provided for @readerBanglaMoral.
  ///
  /// In en, this message translates to:
  /// **'নৈতিক শিক্ষা'**
  String get readerBanglaMoral;

  /// No description provided for @readerSpanishMoral.
  ///
  /// In en, this message translates to:
  /// **'Enseñanza Moral'**
  String get readerSpanishMoral;

  /// No description provided for @readerAudioTrack.
  ///
  /// In en, this message translates to:
  /// **'Audio Track'**
  String get readerAudioTrack;

  /// No description provided for @readerAudioEnglish.
  ///
  /// In en, this message translates to:
  /// **'English narration'**
  String get readerAudioEnglish;

  /// No description provided for @readerAudioBangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla explanation'**
  String get readerAudioBangla;

  /// No description provided for @readerAudioMissing.
  ///
  /// In en, this message translates to:
  /// **'Audiobook file is currently missing. It will be added after production recording.'**
  String get readerAudioMissing;

  /// No description provided for @readerSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed}x'**
  String readerSpeedLabel(double speed);

  /// No description provided for @aiGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Scripture Guide'**
  String get aiGuideTitle;

  /// No description provided for @aiGuideDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'SitaRam AI Guide is for learning and reflection, not a religious authority.'**
  String get aiGuideDisclaimer;

  /// No description provided for @aiGuideContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Context: {chapter} ({kanda})'**
  String aiGuideContextLabel(String chapter, String kanda);

  /// No description provided for @aiGuideWelcome.
  ///
  /// In en, this message translates to:
  /// **'Jai Shri Ram! I am your SitaRam AI research guide.\n\nI have loaded the context for {kanda} - {chapter}.\n\nType a question below or tap a suggested prompt to explore!'**
  String aiGuideWelcome(String kanda, String chapter);

  /// No description provided for @aiGuideInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a research question...'**
  String get aiGuideInputHint;

  /// No description provided for @aiGuideResearcher.
  ///
  /// In en, this message translates to:
  /// **'Researcher'**
  String get aiGuideResearcher;

  /// No description provided for @aiGuideBotName.
  ///
  /// In en, this message translates to:
  /// **'SitaRam AI'**
  String get aiGuideBotName;

  /// No description provided for @aiGuideApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Settings'**
  String get aiGuideApiKeyTitle;

  /// No description provided for @aiGuideApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter API Key...'**
  String get aiGuideApiKeyHint;

  /// No description provided for @aiGuideApiKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get aiGuideApiKeySave;

  /// No description provided for @aiGuideApiKeyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Key'**
  String get aiGuideApiKeyDelete;

  /// No description provided for @aiGuideApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved! Live AI activated.'**
  String get aiGuideApiKeySaved;

  /// No description provided for @aiGuideApiKeyDeleted.
  ///
  /// In en, this message translates to:
  /// **'API Key deleted. Reset to simulation mode.'**
  String get aiGuideApiKeyDeleted;

  /// No description provided for @aiGuideApiKeyInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API key to enable live AI queries. Keys are stored safely on your device.'**
  String get aiGuideApiKeyInfo;

  /// No description provided for @aiGuidePrompt1.
  ///
  /// In en, this message translates to:
  /// **'Explain this chapter simply'**
  String get aiGuidePrompt1;

  /// No description provided for @aiGuidePrompt2.
  ///
  /// In en, this message translates to:
  /// **'What is the moral lesson?'**
  String get aiGuidePrompt2;

  /// No description provided for @aiGuidePrompt3.
  ///
  /// In en, this message translates to:
  /// **'Explain Rama and Sita\'s love and duty'**
  String get aiGuidePrompt3;

  /// No description provided for @aiGuidePrompt4.
  ///
  /// In en, this message translates to:
  /// **'Give me a research note'**
  String get aiGuidePrompt4;

  /// No description provided for @aiGuidePrompt5.
  ///
  /// In en, this message translates to:
  /// **'Explain for children'**
  String get aiGuidePrompt5;

  /// No description provided for @aiGuidePrompt6.
  ///
  /// In en, this message translates to:
  /// **'How can I apply this in modern life?'**
  String get aiGuidePrompt6;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research & Study Mode'**
  String get researchTitle;

  /// No description provided for @researchSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search characters, themes, moral lessons, text...'**
  String get researchSearchHint;

  /// No description provided for @researchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get researchFilterAll;

  /// No description provided for @researchFilterCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get researchFilterCharacters;

  /// No description provided for @researchFilterThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get researchFilterThemes;

  /// No description provided for @researchFilterKandas.
  ///
  /// In en, this message translates to:
  /// **'Kandas'**
  String get researchFilterKandas;

  /// No description provided for @researchFilterLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get researchFilterLessons;

  /// No description provided for @researchFilterBangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get researchFilterBangla;

  /// No description provided for @researchFilterSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get researchFilterSpanish;

  /// No description provided for @researchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No Matches Found'**
  String get researchNoResults;

  /// No description provided for @researchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your keywords or clearing filters.'**
  String get researchNoResultsHint;

  /// No description provided for @researchExploreThemes.
  ///
  /// In en, this message translates to:
  /// **'Explore Themes'**
  String get researchExploreThemes;

  /// No description provided for @researchExploreCharacters.
  ///
  /// In en, this message translates to:
  /// **'Explore Characters'**
  String get researchExploreCharacters;

  /// No description provided for @researchNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Reflection Logs'**
  String get researchNotesTitle;

  /// No description provided for @researchNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your notes and insights. Saved locally on your device.'**
  String get researchNotesSubtitle;

  /// No description provided for @researchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Type your reflection notes here...'**
  String get researchNotesHint;

  /// No description provided for @researchNotesSave.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get researchNotesSave;

  /// No description provided for @researchNotesSaved.
  ///
  /// In en, this message translates to:
  /// **'Your reflection notes have been saved locally.'**
  String get researchNotesSaved;

  /// No description provided for @researchAiPrompt.
  ///
  /// In en, this message translates to:
  /// **'Need Deeper Scriptural Insights?'**
  String get researchAiPrompt;

  /// No description provided for @researchAiPromptSub.
  ///
  /// In en, this message translates to:
  /// **'Ask our AI Guide to analyze character motifs, moral structures, or historical context.'**
  String get researchAiPromptSub;

  /// No description provided for @researchAiSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"AI Guide\" tab to open the research assistant.'**
  String get researchAiSnackbar;

  /// No description provided for @donateTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Seva'**
  String get donateTitle;

  /// No description provided for @donateHeading.
  ///
  /// In en, this message translates to:
  /// **'Support SitaRam'**
  String get donateHeading;

  /// No description provided for @donateBody.
  ///
  /// In en, this message translates to:
  /// **'SitaRam is free for everyone. Your donation helps maintain the app, improve audiobook quality, support Bangla, English, and Spanish learning resources, and keep AI explanations available for all.'**
  String get donateBody;

  /// No description provided for @donateNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscriptions Required'**
  String get donateNoSubscription;

  /// No description provided for @donateNoPay.
  ///
  /// In en, this message translates to:
  /// **'Zero Locked Content / Paywalls'**
  String get donateNoPay;

  /// No description provided for @donateNoAds.
  ///
  /// In en, this message translates to:
  /// **'No Ads or Interruptions'**
  String get donateNoAds;

  /// No description provided for @donateOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-Time Blessing'**
  String get donateOneTime;

  /// No description provided for @donateMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Seva'**
  String get donateMonthly;

  /// No description provided for @donateFooter.
  ///
  /// In en, this message translates to:
  /// **'May dharma guide all your actions.'**
  String get donateFooter;

  /// No description provided for @donateSimulatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Acknowledged'**
  String get donateSimulatedTitle;

  /// No description provided for @donateSimulatedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your contribution of {amount} for \"{tier}\" was received. Full payment integration will be connected before store deployment.'**
  String donateSimulatedBody(String amount, String tier);

  /// No description provided for @donateDhanyavad.
  ///
  /// In en, this message translates to:
  /// **'Dhanyavad 🙏'**
  String get donateDhanyavad;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTerms;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About SitaRam'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'SitaRam is a free, devotional Valmiki Ramayana app supporting English, Bangla, and Spanish. Built with love by Lead.AI Labs.'**
  String get settingsAboutBody;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get langBangla;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @sourceSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Safety & Verification'**
  String get sourceSafetyTitle;

  /// No description provided for @sourceBook.
  ///
  /// In en, this message translates to:
  /// **'Source Book'**
  String get sourceBook;

  /// No description provided for @sourceTranslator.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get sourceTranslator;

  /// No description provided for @sourceYear.
  ///
  /// In en, this message translates to:
  /// **'Publication Year'**
  String get sourceYear;

  /// No description provided for @sourceCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright Status'**
  String get sourceCopyright;

  /// No description provided for @sourceReview.
  ///
  /// In en, this message translates to:
  /// **'Review Status'**
  String get sourceReview;

  /// No description provided for @sourceApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get sourceApprovedBy;

  /// No description provided for @sourceApprovalDate.
  ///
  /// In en, this message translates to:
  /// **'Approval Date'**
  String get sourceApprovalDate;

  /// No description provided for @generalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get generalSave;

  /// No description provided for @generalShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get generalShare;

  /// No description provided for @generalBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get generalBookmark;

  /// No description provided for @generalFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get generalFavorite;

  /// No description provided for @generalReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get generalReadMore;

  /// No description provided for @generalListenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen Now'**
  String get generalListenNow;

  /// No description provided for @generalLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get generalLoading;

  /// No description provided for @generalError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get generalError;

  /// No description provided for @generalRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get generalRetry;

  /// No description provided for @generalClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get generalClose;

  /// No description provided for @generalBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get generalBack;

  /// No description provided for @generalSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get generalSearch;

  /// No description provided for @sitaramFreeForAll.
  ///
  /// In en, this message translates to:
  /// **'SitaRam is free for everyone'**
  String get sitaramFreeForAll;

  /// No description provided for @allContentFree.
  ///
  /// In en, this message translates to:
  /// **'All content remains free'**
  String get allContentFree;

  /// No description provided for @fullTextReviewPending.
  ///
  /// In en, this message translates to:
  /// **'Full reviewed text will be added after public-domain review.'**
  String get fullTextReviewPending;

  /// No description provided for @aiPageAnalysisPending.
  ///
  /// In en, this message translates to:
  /// **'AI page analysis will be available after reviewed text extraction is added.'**
  String get aiPageAnalysisPending;

  /// No description provided for @dailyWisdomTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Wisdom'**
  String get dailyWisdomTitle;

  /// No description provided for @dailyWisdomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A verse from the Ramayana'**
  String get dailyWisdomSubtitle;

  /// No description provided for @audiobook.
  ///
  /// In en, this message translates to:
  /// **'Audiobook'**
  String get audiobook;

  /// No description provided for @pdfBook.
  ///
  /// In en, this message translates to:
  /// **'PDF Book'**
  String get pdfBook;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @sourceInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Source Info'**
  String get sourceInfoLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
