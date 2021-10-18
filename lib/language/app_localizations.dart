class AppLocalizations {
  AppLocalizations();

  static const _localizedValues = <String, Map<String, String>>{
    'English': {
      'app_title': 'Chisa',
      'target_language': 'Target language',
      'app_language': 'App language',
      'player_media_type': 'Player',
      'reader_media_type': 'Reader',
      'dictionary_media_type': 'Dictionary',
      'card_creator': 'Card Creator',
      'options_theme_light': 'Use light theme',
      'options_theme_dark': 'Use dark theme',
      'options_dictionaries': 'Manage dictionaries',
      'options_enhancements': 'User enhancements',
      'options_language': 'Language settings',
      'options_github': 'View repository on GitHub',
      'options_licenses': 'Licenses and attribution',
      'dialog_close': 'CLOSE',
      'dialog_import': 'IMPORT',
      'dialog_delete': 'DELETE',
      'dialog_yes': 'YES',
      'dialog_no': 'NO',
      'creator_options_menu': 'Creator menu addons',
      'creator_options_auto': 'Creator auto addons',
      'widget_options': 'Dictionary widget addons',
      'creator_options_confirm': 'Are you sure you want to leave changes '
          'unsaved?',
      'preparing_card_creator': 'Preparing card creator',
      'delete_dictionary_confirmation':
          'This dictionary will be removed. Are you sure you want to delete '
              'this?',
      'field_label_sentence': 'Sentence',
      'field_label_word': 'Word',
      'field_label_reading': 'Reading',
      'field_label_meaning': 'Meaning',
      'field_label_extra': 'Extra',
      'field_label_image': 'Image',
      'field_label_audio': 'Audio',
      'field_hint_context': 'Enter the sentence here',
      'field_hint_word': 'Enter the word here',
      'field_hint_reading': 'Enter the reading of the word here',
      'field_hint_meaning': 'Enter the meaning of the word here',
      'field_hint_extra': 'Enter extra information here',
      'field_hint_image': 'Enter image search term here',
      'field_hint_audio': 'Enter audio search term here',
      'import_format': 'Import format',
      'import_in_progress': 'Import in progress...',
      'start_reading': 'Start Reading',
      'search': 'Search',
      'enter_search_term_here': 'Enter search term here',
      'import_dictionaries_for_use': 'Import dictionaries to be used',
      'no_more_available_enhancements':
          'No more available enhancements for this field',
      'dictionary_history_empty': 'Dictionary history is empty',
      'license_screen_legalese': "A mobile video player, reader assistant, "
          "image mining workflow and card creation toolkit tailored for "
          "language learners.\n\nBuilt for the language learning community "
          "by Leo Rafael Orpilla. Logo by Aaron Marbella.\n\nChisa is "
          "free and open source software. Liking the application? Help out "
          "by providing feedback, making a donation, reporting issues or "
          "collaborating for further improvements on GitHub.",
    },
    'Tagalog': {
      'app_title': 'Chisa',
      'target_language': 'Wikang pakay',
      'app_language': 'Wika ng aplikasyon',
      'player_media_type': 'Manood',
      'reader_media_type': 'Magbasa',
      'dictionary_media_type': 'Diksyunaryo',
      'card_creator': 'Creator ng Card',
      'options_theme_light': 'Magaan na tema',
      'options_theme_dark': 'Madilim na tema',
      'options_dictionaries': 'Mga diksyunaryo',
      'options_enhancements': 'Dagdagang kagamitan',
      'options_language': 'Pagpipiliang wika',
      'options_github': 'Makibahagi sa GitHub',
      'options_licenses': 'Mga pagpapatungkol',
      'dialog_close': 'ISARA',
      'dialog_import': 'MAGDAGDAG',
      'dialog_delete': 'ITANGGAL',
      'dialog_yes': 'OO',
      'dialog_no': 'HINDI',
      'creator_options_menu': 'Mga creator menu mod',
      'creator_options_auto': 'Mga creator auto mod',
      'widget_options': 'Mga diksyunaryo widget',
      'creator_options_confirm':
          'Walang magbabagong kagamitan. Sigurado ka ba sa pagbalik?',
      'preparing_card_creator': 'Hinahanda ang card',
      'delete_dictionary_confirmation':
          'Mawawala ang diksyunaryo na ito. Sigurado ka ba sa pagtanggal nito?',
      'field_label_sentence': 'Pangungusap',
      'field_label_word': 'Salita',
      'field_label_reading': 'Bigkas',
      'field_label_meaning': 'Kahulugan',
      'field_label_extra': 'Karagdagan',
      'field_label_image': 'Imahe',
      'field_label_audio': 'Tunog',
      'field_hint_context': 'Pangungusap o konteksto',
      'field_hint_word': 'Salitang tinutukoy',
      'field_hint_reading': 'Pagbigkas ng salita',
      'field_hint_meaning': 'Kahulugan ng salita',
      'field_hint_extra': 'Karagdagang impormasyon',
      'field_hint_image': 'Imaheng hahanapin',
      'field_hint_audio': 'Tunog na hahanapin',
      'search': 'Maghanap',
      'enter_search_term_here': 'Salitang hahanapin',
      'import_format': 'Klase ng idadagdag na diksyunaryo',
      'import_in_progress': 'Nagdadagdag ng diksyunaryo...',
      'start_reading': 'Magsimulang Magbasa',
      'no_more_available_enhancements':
          'Wala nang karagdagang kagamitan para dito',
      'import_dictionaries_for_use': 'Magdagdag ng diksyunaryo na gagamitin',
      'dictionary_history_empty': 'Wala pang kasaysayan',
      'license_screen_legalese': "Kagamitang nakakatulong sa pagnood ng bidyo, "
          "pagbasa ng libro at komiks at pagkabisado ng mga salita ng mga "
          "wikang banyaga.\n\nGawa ni Leo Rafael Orpilla para sa magaaral ng "
          "iba't ibang wika. Tatak ng aplikasyon, gawa ni Aaron Marbella.\n\n"
          "Ang aplikasyon na ito ay libre na gamitin at ipagbuti para sa "
          "lahat. Nagustuhan mo ba? Maari kang makatulong sa pamamagitan ng "
          "donasyon o kontribusyon o ng puna, at sa pagbahagi at pagbatid ng "
          "apliksayon na ito sa kapwa.",
    },
  };

  static List<String> localizations() => _localizedValues.keys.toList();

  static String getLocalizedValue(String localization, String key) {
    return _localizedValues[localization]![key]!;
  }
}
