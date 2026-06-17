// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SitaRam';

  @override
  String get appTagline => 'Read • Listen • Reflect';

  @override
  String get navHome => 'Home';

  @override
  String get navRead => 'Read';

  @override
  String get navListen => 'Listen';

  @override
  String get navReflect => 'Reflect';

  @override
  String get navAiGuide => 'AI Guide';

  @override
  String get navResearch => 'Research';

  @override
  String get navDonate => 'Support';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'SitaRam';

  @override
  String get homeSubtitle => 'Valmiki Ramayana';

  @override
  String get homeTagline => 'Read  •  Listen  •  Reflect';

  @override
  String get homeKandaLibrary => 'Kanda Library';

  @override
  String get homeDailyWisdom => 'Daily Wisdom';

  @override
  String get homeContinueReading => 'Continue Reading';

  @override
  String get homeContinueListening => 'Continue Listening';

  @override
  String get homeOpenChapterLibrary => 'Open Chapter Library';

  @override
  String get homeReadMainBook => 'Read the Main Book';

  @override
  String get homeOpenPdfBook => 'Open PDF Book';

  @override
  String get homeSourcePdf => 'Source PDF';

  @override
  String homeChaptersLoaded(int count) {
    return '$count Chapter(s) loaded';
  }

  @override
  String get homeNotYetCompiled => 'This Kanda is not yet compiled.';

  @override
  String get homeNoChaptersImported => 'No Chapters Imported Yet';

  @override
  String get kandaNameBala => 'Bala Kanda';

  @override
  String get kandaNameAyodhya => 'Ayodhya Kanda';

  @override
  String get kandaNameAranya => 'Aranya Kanda';

  @override
  String get kandaNameKishkindha => 'Kishkindha Kanda';

  @override
  String get kandaNameSundara => 'Sundara Kanda';

  @override
  String get kandaNameYuddha => 'Yuddha Kanda';

  @override
  String get kandaNameUttara => 'Uttara Kanda';

  @override
  String get kandaDescBala =>
      'Book of Youth — The birth, youth, and education of Sri Rama, and his holy marriage to Sita.';

  @override
  String get kandaDescAyodhya =>
      'Book of Ayodhya — The preparation for Rama\'s coronation, the boons of Kaikeyi, and the sorrowful exile.';

  @override
  String get kandaDescAranya =>
      'Book of Forest — The forest life, encounters with sages and demons, and abduction of Sita by Ravana.';

  @override
  String get kandaDescKishkindha =>
      'Book of Kishkindha — The alliance of Rama with Sugriva, the monkey kingdom, and launching the search.';

  @override
  String get kandaDescSundara =>
      'Book of Beauty — Hanuman\'s miraculous flight to Lanka, locating Sita, and the burning of Lanka.';

  @override
  String get kandaDescYuddha =>
      'Book of War — The construction of the bridge, the great battle with Ravana, and rescue of Sita.';

  @override
  String get kandaDescUttara =>
      'Last Book — The return to Ayodhya, coronation of Sri Rama, and final pastimes.';

  @override
  String get readerTabEnglish => 'English';

  @override
  String get readerTabBangla => 'বাংলা';

  @override
  String get readerTabSpanish => 'Español';

  @override
  String get readerTabInsights => 'Insights';

  @override
  String get readerTabAudio => 'Audio';

  @override
  String get readerSourceInfo => 'Source Info';

  @override
  String get readerBanglaNotLoaded => 'Bangla translation not available.';

  @override
  String get readerSpanishNotLoaded =>
      'Spanish placeholder — reviewed text will be added after public-domain review.';

  @override
  String get readerSetAiContext => 'Set as AI Context';

  @override
  String get readerAiSnackbar =>
      'Switched context. Tap the AI Guide tab to speak to the assistant.';

  @override
  String get readerAskAiGuide => 'Ask AI Guide';

  @override
  String get readerChapterLabel => 'Chapter';

  @override
  String get readerCharactersPresent => 'Characters Present';

  @override
  String get readerThemesPrinciples => 'Themes & Principles';

  @override
  String get readerEnglishSummary => 'English Summary';

  @override
  String get readerBanglaSummary => 'বাংলা সারসংক্ষেপ';

  @override
  String get readerSpanishSummary => 'Resumen en Español';

  @override
  String get readerMoralLesson => 'Moral Lesson (Dharma)';

  @override
  String get readerBanglaMoral => 'নৈতিক শিক্ষা';

  @override
  String get readerSpanishMoral => 'Enseñanza Moral';

  @override
  String get readerAudioTrack => 'Audio Track';

  @override
  String get readerAudioEnglish => 'English narration';

  @override
  String get readerAudioBangla => 'Bangla explanation';

  @override
  String get readerAudioMissing =>
      'Audiobook file is currently missing. It will be added after production recording.';

  @override
  String readerSpeedLabel(double speed) {
    return 'Speed: ${speed}x';
  }

  @override
  String get aiGuideTitle => 'AI Scripture Guide';

  @override
  String get aiGuideDisclaimer =>
      'SitaRam AI Guide is for learning and reflection, not a religious authority.';

  @override
  String aiGuideContextLabel(String chapter, String kanda) {
    return 'Context: $chapter ($kanda)';
  }

  @override
  String aiGuideWelcome(String kanda, String chapter) {
    return 'Jai Shri Ram! I am your SitaRam AI research guide.\n\nI have loaded the context for $kanda - $chapter.\n\nType a question below or tap a suggested prompt to explore!';
  }

  @override
  String get aiGuideInputHint => 'Ask a research question...';

  @override
  String get aiGuideResearcher => 'Researcher';

  @override
  String get aiGuideBotName => 'SitaRam AI';

  @override
  String get aiGuideApiKeyTitle => 'Gemini API Settings';

  @override
  String get aiGuideApiKeyHint => 'Enter API Key...';

  @override
  String get aiGuideApiKeySave => 'Save';

  @override
  String get aiGuideApiKeyDelete => 'Delete Key';

  @override
  String get aiGuideApiKeySaved => 'API Key saved! Live AI activated.';

  @override
  String get aiGuideApiKeyDeleted =>
      'API Key deleted. Reset to simulation mode.';

  @override
  String get aiGuideApiKeyInfo =>
      'Enter your Gemini API key to enable live AI queries. Keys are stored safely on your device.';

  @override
  String get aiGuidePrompt1 => 'Explain this chapter simply';

  @override
  String get aiGuidePrompt2 => 'What is the moral lesson?';

  @override
  String get aiGuidePrompt3 => 'Explain Rama and Sita\'s love and duty';

  @override
  String get aiGuidePrompt4 => 'Give me a research note';

  @override
  String get aiGuidePrompt5 => 'Explain for children';

  @override
  String get aiGuidePrompt6 => 'How can I apply this in modern life?';

  @override
  String get researchTitle => 'Research & Study Mode';

  @override
  String get researchSearchHint =>
      'Search characters, themes, moral lessons, text...';

  @override
  String get researchFilterAll => 'All';

  @override
  String get researchFilterCharacters => 'Characters';

  @override
  String get researchFilterThemes => 'Themes';

  @override
  String get researchFilterKandas => 'Kandas';

  @override
  String get researchFilterLessons => 'Lessons';

  @override
  String get researchFilterBangla => 'Bangla';

  @override
  String get researchFilterSpanish => 'Spanish';

  @override
  String get researchNoResults => 'No Matches Found';

  @override
  String get researchNoResultsHint =>
      'Try adjusting your keywords or clearing filters.';

  @override
  String get researchExploreThemes => 'Explore Themes';

  @override
  String get researchExploreCharacters => 'Explore Characters';

  @override
  String get researchNotesTitle => 'Saved Reflection Logs';

  @override
  String get researchNotesSubtitle =>
      'Write your notes and insights. Saved locally on your device.';

  @override
  String get researchNotesHint => 'Type your reflection notes here...';

  @override
  String get researchNotesSave => 'Save Note';

  @override
  String get researchNotesSaved =>
      'Your reflection notes have been saved locally.';

  @override
  String get researchAiPrompt => 'Need Deeper Scriptural Insights?';

  @override
  String get researchAiPromptSub =>
      'Ask our AI Guide to analyze character motifs, moral structures, or historical context.';

  @override
  String get researchAiSnackbar =>
      'Tap the \"AI Guide\" tab to open the research assistant.';

  @override
  String get donateTitle => 'Support & Seva';

  @override
  String get donateHeading => 'Support SitaRam';

  @override
  String get donateBody =>
      'SitaRam is free for everyone. Your donation helps maintain the app, improve audiobook quality, support Bangla, English, and Spanish learning resources, and keep AI explanations available for all.';

  @override
  String get donateNoSubscription => 'No Subscriptions Required';

  @override
  String get donateNoPay => 'Zero Locked Content / Paywalls';

  @override
  String get donateNoAds => 'No Ads or Interruptions';

  @override
  String get donateOneTime => 'One-Time Blessing';

  @override
  String get donateMonthly => 'Monthly Seva';

  @override
  String get donateFooter => 'May dharma guide all your actions.';

  @override
  String get donateSimulatedTitle => 'Support Acknowledged';

  @override
  String donateSimulatedBody(String amount, String tier) {
    return 'Thank you! Your contribution of $amount for \"$tier\" was received. Full payment integration will be connected before store deployment.';
  }

  @override
  String get donateDhanyavad => 'Dhanyavad 🙏';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsAbout => 'About SitaRam';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutBody =>
      'SitaRam is a free, devotional Valmiki Ramayana app supporting English, Bangla, and Spanish. Built with love by Lead.AI Labs.';

  @override
  String get langEnglish => 'English';

  @override
  String get langBangla => 'বাংলা';

  @override
  String get langSpanish => 'Español';

  @override
  String get sourceSafetyTitle => 'Source Safety & Verification';

  @override
  String get sourceBook => 'Source Book';

  @override
  String get sourceTranslator => 'Translator';

  @override
  String get sourceYear => 'Publication Year';

  @override
  String get sourceCopyright => 'Copyright Status';

  @override
  String get sourceReview => 'Review Status';

  @override
  String get sourceApprovedBy => 'Approved By';

  @override
  String get sourceApprovalDate => 'Approval Date';

  @override
  String get generalSave => 'Save';

  @override
  String get generalShare => 'Share';

  @override
  String get generalBookmark => 'Bookmark';

  @override
  String get generalFavorite => 'Favorite';

  @override
  String get generalReadMore => 'Read More';

  @override
  String get generalListenNow => 'Listen Now';

  @override
  String get generalLoading => 'Loading...';

  @override
  String get generalError => 'Something went wrong. Please try again.';

  @override
  String get generalRetry => 'Retry';

  @override
  String get generalClose => 'Close';

  @override
  String get generalBack => 'Back';

  @override
  String get generalSearch => 'Search';

  @override
  String get sitaramFreeForAll => 'SitaRam is free for everyone';

  @override
  String get allContentFree => 'All content remains free';

  @override
  String get fullTextReviewPending =>
      'Full reviewed text will be added after public-domain review.';

  @override
  String get aiPageAnalysisPending =>
      'AI page analysis will be available after reviewed text extraction is added.';

  @override
  String get dailyWisdomTitle => 'Daily Wisdom';

  @override
  String get dailyWisdomSubtitle => 'A verse from the Ramayana';

  @override
  String get audiobook => 'Audiobook';

  @override
  String get pdfBook => 'PDF Book';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get notes => 'Notes';

  @override
  String get sourceInfoLabel => 'Source Info';
}
