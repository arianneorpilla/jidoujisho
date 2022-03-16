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
    'en-US': {
      'dictionary_media_type': 'Dictionary',
      'player_media_type': 'Player',
      'reader_media_type': 'Reader',
      'viewer_media_type': 'Viewer',
    },
  };
}
