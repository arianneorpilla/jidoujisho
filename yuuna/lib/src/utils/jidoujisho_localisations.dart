/// A dedicated store for localised strings for different supported app
/// languages.
class JidoujishoLocalisations {
  /// A map sorting app language locale tags by their language names as a
  /// native would understand them.
  static Map<String, String> languageNames = {
    'en-US': 'English',
    'ja-JP': '日本語'
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
    'dialog_cancel': 'CANCEL',
    'dictionaries_collapse': 'Collapse',
    'dictionaries_expand': 'Expand',
    'dictionaries_delete': 'Delete',
    'dictionaries_show': 'Show',
    'dictionaries_hide': 'Hide',
    'dictionaries_delete_confirmation':
        'This dictionary and its searched entries will be deleted. Are you '
            'sure you want to do this?',
    'dictionaries_deleting_entries': 'Deleting dictionary entries...',
    'dictionaries_options': 'Dictionary Options',
    'dictionaries_menu_empty': 'Import a dictionary for use',
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
    'delete_in_progress': 'Delete in progress',
    'import_format': 'Import format',
    'import_in_progress': 'Import in progress',
    'import_message_start': 'Importing dictionary...',
    'import_message_clean': 'Clearing working space...',
    'import_message_extraction': 'Extracting files...',
    'import_message_name': 'Importing 『%name%』...',
    'import_message_entries': 'Processing entries...',
    'import_message_count': 'Found %count% entries...',
    'import_message_metadata': 'Processing metadata...',
    'import_message_database': 'Adding entries to database...',
    'import_message_error': 'Import error: %error%',
    'import_message_failed': 'Dictionary import failed.',
    'import_message_complete': 'Dictionary import complete.',
  };
}
