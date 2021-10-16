class AppLocalizations {
  AppLocalizations();

  static const _localizedValues = <String, Map<String, String>>{
    'English': {
      'app_title': 'jidoujisho',
      'target_language': 'Target language',
      'app_language': 'App language',
      'player_media_type': 'Player',
      'reader_media_type': 'Reader',
      'dictionary_media_type': 'Dictionary',
      'options_theme_light': 'Use light theme',
      'options_theme_dark': 'Use dark theme',
      'options_dictionaries': 'Manage dictionaries',
      'options_language': 'Language settings',
      'options_github': 'View repository on GitHub',
      'options_licenses': 'Licenses and attribution',
      'dialog_close': 'CLOSE',
      'dialog_import': 'IMPORT',
      'import_format': 'Import format',
      'start_reading': 'Start Reading',
      'no_available_dictionaries': 'No available dictionaries',
      'license_screen_legalese': "A mobile video player, reader assistant, "
          "image mining workflow and card creation toolkit tailored for "
          "language learners.\n\nBuilt for the language learning community "
          "by Leo Rafael Orpilla. Logo by Aaron Marbella.\n\njidoujisho is "
          "free and open source software. Liking the application? Help out "
          "by providing feedback, making a donation, reporting issues or "
          "collaborating for further improvements on GitHub.",
    },
    'Tagalog': {
      'app_title': 'jidoujisho',
      'target_language': 'Wika na pakay',
      'app_language': 'Wika ng aplikasyon',
      'player_media_type': 'Manood',
      'reader_media_type': 'Magbasa',
      'dictionary_media_type': 'Diksyunaryo',
      'options_theme_light': 'Magaan na tema',
      'options_theme_dark': 'Madilim na tema',
      'options_dictionaries': 'Mga diksyunaryo',
      'options_language': 'Pagpipiliang wika',
      'options_github': 'Makibahagi sa GitHub',
      'options_licenses': 'Mga pagpapatungkol',
      'dialog_close': 'ISARA',
      'dialog_import': 'DAGDAGAN',
      'import_format': 'Klase ng idadagdag na diksyunaryo',
      'start_reading': 'Magsimulang Magbasa',
      'no_available_dictionaries': 'Walang diksyunaryo',
      'license_screen_legalese': "Kagamitang nakakatulong sa pagnood ng bidyo, "
          "pagbasa ng libro at komiks at pagkabisado ng mga salita ng mga "
          "wikang banyaga.\n\nGawa ni Leo Rafael Orpilla para sa magaaral ng "
          "iba't ibang wika. Tatak ng aplikasyon, gawa ni Aaron Marbella.\n\n"
          "Ang programa na ito ay libre na gamitin at ipagbuti para sa lahat. "
          "Nagustuhan mo ba? Maari kang makatulong sa pamamagitan ng donasyon "
          "o kontribusyon o ng puna, at sa pagbahagi at pagbatid ng apliksayon "
          "na ito sa kapwa.",
    },
  };

  static List<String> localizations() => _localizedValues.keys.toList();

  static String getLocalizedValue(String localization, String key) {
    return _localizedValues[localization]![key]!;
  }
}
