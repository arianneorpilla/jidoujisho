/// A dedicated store for localised strings for different supported app
/// languages.
class JidoujishoLocalisations {
  /// A map sorting app language locale tags by their language names as a
  /// native would understand them.
  static Map<String, String> localeNames = {
    'en-US': 'English',
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
    'search': 'Search',
    'show_menu': 'Show Menu',
    'stash': 'Stash',
    'card_creator': 'Card Creator',
    'target_language': 'Target language',
    'show_options': 'Show Options',
    'app_locale': 'App locale',
    'app_locale_warning': 'Community addons and enhancements are managed '
        'by their respective developers, and these may appear in their '
        'original language.',
    'dialog_import': 'IMPORT',
    'dialog_close': 'CLOSE',
    'dialog_add_new': 'ADD NEW',
    'dialog_delete': 'DELETE',
    'dialog_cancel': 'CANCEL',
    'dialog_save': 'SAVE',
    'dictionaries_delete_confirmation':
        'This dictionary and its searched entries will be deleted. Are you '
            'sure you want to do this?',
    'mappings_delete_confirmation': 'This mapping will be deleted. Are you '
        'sure you want to do this?',
    'dictionaries_deleting_entries': 'Deleting dictionary entries...',
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
    'options_collapse': 'Collapse',
    'options_expand': 'Expand',
    'options_delete': 'Delete',
    'options_show': 'Show',
    'options_hide': 'Hide',
    'options_edit': 'Edit',
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
    'field_label_sentence': 'Sentence',
    'field_label_word': 'Word',
    'field_label_reading': 'Reading',
    'field_label_meaning': 'Meaning',
    'field_label_extra': 'Extra',
    'field_label_image': 'Image',
    'field_label_audio': 'Audio',
    'field_label_context': 'Context',
    'field_label_empty': 'Empty',
    'field_hint_sentence': 'Sentence or written context',
    'field_hint_word': 'The headword of the card',
    'field_hint_reading': 'Reading or pronunciation',
    'field_hint_meaning': 'Meaning or dictionary definition',
    'field_hint_extra': 'Any extra information here',
    'field_hint_image': 'Enter image search term',
    'field_hint_audio': 'Enter audio search term',
    'field_hint_context': 'Information on media context',
    'field_hint_empty': 'Leave field blank',
    'model_to_map': 'Model to map',
    'mapping_name': 'Mapping name',
    'mapping_name_hint': 'Name to assign to mapping',
    'invalid_mapping_name': 'Invalid mapping name',
    'invalid_mapping_name_content':
        'A mapping with this name already exists or is not valid and cannot be '
            'added.'
  };
}
