/// A dedicated store for localised strings for different supported app
/// languages.
class JidoujishoLocalisations {
  /// A map sorting app language locale tags by their language names as a
  /// native would understand them.
  static Map<String, String> languageNames = {
    'en-US': 'English',
    'tl-PH': 'Tagalog',
  };

  /// A map storing localisation key-value data pairs sorted by app languages.
  static Map<String, Map<String, String>> localisations = {
    'en-US': english,
  };

  /// Localisation for 'en-US'.
  static const Map<String, String> english = {
    'dictionary_media_type': 'Dictionary',
    'player_media_type': 'Player',
    'reader_media_type': 'Reader',
    'viewer_media_type': 'Viewer',
    'preferences': 'Preferences',
    'section_general': 'General',
    'section_desc_general': 'Adjust theme, locale and miscellaneous settings',
    'section_dictionaries': 'Dictionaries',
    'section_desc_dictionaries':
        'Import and manage dictionaries and customise overlay',
    'section_creator': 'Creator',
    'section_desc_creator':
        'Set enhancements and customize export profiles for the card creator',
    'section_media': 'Media',
    'section_desc_media': 'Tailor the player, reader or viewer experience',
    'section_language': 'Language',
    'section_desc_language':
        'Change target language in use and tweak database search and parsing',
    'section_debugging': 'Debugging',
    'section_desc_debugging':
        'View logs for developers and control error reporting',
    'section_licenses': 'Licenses',
    'section_desc_licenses': 'About the app and open source attribution',
  };
}
