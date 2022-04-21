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
    'show_menu': 'Show Menu',
    'stash': 'Stash',
    'card_creator': 'Card Creator',
    'dialog_import': 'IMPORT',
    'dialog_close': 'CLOSE',
    'dialog_delete': 'DELETE',
    'dictionaries_collapse': 'Collapse by default',
    'dictionaries_expand': 'Expand by default',
    'dictionaries_disable': 'Disable dictionary',
    'dictionaries_enable': 'Enable dictionary',
    'dictionaries_delete': 'Delete dictionary',
    'options_theme_light': 'Use light theme',
    'options_theme_dark': 'Use dark theme',
    'options_incognito_on': 'Turn on incognito mode',
    'options_incognito_off': 'Turn off incognito mode',
    'options_dictionaries': 'Manage dictionaries',
    'options_profiles': 'Export profiles',
    'options_enhancements': 'User enhancements',
    'options_language': 'Language settings',
    'options_github': 'View repository on GitHub',
    'options_attribution': 'Licenses and attribution',
    'info_empty_home_tab': 'History is empty',
    'import_format': 'Import format',
  };
}
