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
    'back': 'Back',
    'search': 'Search',
    'search_ellipsis': 'Search...',
    'show_menu': 'Show Menu',
    'stash': 'Stash',
    'clear': 'Clear',
    'resume_last_media': 'Resume Last Media',
    'card_creator': 'Card Creator',
    'target_language': 'Target language',
    'show_options': 'Show Options',
    'switch_profiles': 'Switch Profiles',
    'dictionaries': 'Dictionaries',
    'enhancements': 'Enhancements',
    'app_locale': 'App locale',
    'app_locale_warning': 'Community addons and enhancements are managed '
        'by their respective developers, and these may appear in their '
        'original language.',
    'dialog_import': 'IMPORT',
    'dialog_close': 'CLOSE',
    'dialog_create': 'CREATE',
    'dialog_delete': 'DELETE',
    'dialog_cancel': 'CANCEL',
    'dialog_save': 'SAVE',
    'dialog_launch_ankidroid': 'LAUNCH ANKIDROID',
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
    'options_copy': 'Copy',
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
    'model_to_map': 'Card type to use for new profile',
    'mapping_name': 'Profile name',
    'mapping_name_hint': 'Name to assign to profile',
    'error_profile_name': 'Invalid profile name',
    'error_profile_name_content':
        'A profile with this name already exists or is not valid and cannot be '
            'saved.',
    'error_standard_profile_name': 'Invalid profile name',
    'error_standard_profile_name_content':
        'Cannot rename the standard profile.',
    'error_ankidroid_api': 'AnkiDroid API',
    'error_ankidroid_api_content':
        'The AnkiDroid API could not be found in the background.\n\nLaunch '
            'AnkiDroid and ensure the app and background service is active in '
            'order to continue.',
    'info_standard_model': 'Standard model added',
    'info_standard_model_content':
        '『jidoujisho Yuuna』 has been added to AnkiDroid as a new card type.'
            '\n\nSetups making use of a different card type or field order may'
            ' be used by adding a new export profile.',
    'error_model_missing': 'Missing card type',
    'error_model_missing_content':
        'The corresponding card type of the currently selected profile is'
            ' missing.\n\nThe standard profile has been selected in its place.',
    'error_model_changed': 'Card type changed',
    'error_model_changed_content':
        'The number of fields of the card type corresponding to the selected'
            ' profile has changed.\n\nThe fields of the currently selected'
            ' profile have been reset and will require reconfiguration.',
    'creator_exporting_as': 'Creating card with profile',
    'creator_exporting_as_editing': 'Editing enhancements for profile',
    'creator_export_card': 'Create Card',
    'info_enhancements':
        'Enhancements enable the automation of field editing prior to card'
            ' creation. Pick a slot on the right of a field to allow use of an'
            ' enhancement. Up to four right slots may be utilised for each'
            ' field. The enhancement in the left slot of a field will be'
            ' automatically applied in instant card creation or upon launch of'
            ' the Card Creator.',
    'info_actions':
        'Quick actions allow for instant card creation and other automations'
            ' to be used on dictionary search results. Actions can be assigned'
            ' via the slots below. Up to six slots may be utilised.',
    'no_more_available_enhancements':
        'No more available enhancements for this field',
    'no_more_available_quick_actions': 'No more available quick actions',
    'assign_auto_enhancement': 'Assign Auto Enhancement',
    'assign_manual_enhancement': 'Assign Manual Enhancement',
    'remove_enhancement': 'Remove Enhancement',
    'copy_of_mapping': 'Copy of %mapping_name%',
    'enter_search_term': 'Enter a search term...',
    'searching_for': 'Searching for 『%searchTerm%』...',
    'no_search_results': 'No search results for 『%searchTerm%』',
    'edit_actions': 'Edit Dictionary Quick Actions',
    'remove_action': 'Remove Action',
    'assign_action': 'Assign Action',
  };
}
