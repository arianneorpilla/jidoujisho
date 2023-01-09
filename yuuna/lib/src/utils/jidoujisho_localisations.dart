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
    'see_more': 'See More',
    'show_menu': 'Show Menu',
    'stash': 'Stash',
    'pick_image': 'Pick Image',
    'undo': 'Undo',
    'copy': 'Copy',
    'clear': 'Clear',
    'creator': 'Creator',
    'resume_last_media': 'Resume Last Media',
    'change_source': 'Change Source',
    'launch_source': 'Launch Source',
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
    'dialog_play': 'PLAY',
    'dialog_read': 'READ',
    'dialog_view': 'VIEW',
    'dialog_edit': 'EDIT',
    'dialog_export': 'EXPORT',
    'dialog_import': 'IMPORT',
    'dialog_close': 'CLOSE',
    'dialog_clear': 'CLEAR',
    'dialog_create': 'CREATE',
    'dialog_delete': 'DELETE',
    'dialog_cancel': 'CANCEL',
    'dialog_select': 'SELECT',
    'dialog_stash': 'STASH',
    'dialog_search': 'SEARCH',
    'dialog_exit': 'EXIT',
    'dialog_share': 'SHARE',
    'dialog_pop': 'POP',
    'dialog_save': 'SAVE',
    'dialog_set': 'SET',
    'dialog_channel': 'CHANNEL',
    'dialog_crop': 'CROP',
    'dialog_connect': 'CONNECT',
    'reset': 'Reset',
    'dialog_launch_ankidroid': 'LAUNCH ANKIDROID',
    'media_item_delete_confirmation':
        'This will clear this item from history. Are you sure you want to do'
            ' this?',
    'dictionaries_delete_confirmation':
        'Deleting a dictionary will also clear all dictionary results from'
            ' history. Are you sure you want to do this?',
    'mappings_delete_confirmation': 'This profile will be deleted. Are you '
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
    'import_message_entry_count': 'Found %count% entries...',
    'import_message_meta_entry_count': 'Found %count% meta entries...',
    'import_message_tag_count': 'Found %count% tags...',
    'import_message_entry_import_count': 'Adding entries...\n%count% / %total%',
    'import_message_meta_entry_import_count':
        'Adding meta entries...\n%count% / %total%',
    'import_message_tag_import_count': 'Adding tags...\n%count% / %total%',
    'import_message_metadata': 'Processing metadata...',
    'import_message_database': 'Adding entries to database...',
    'import_message_error': 'Import error: %error%',
    'import_message_failed': 'Dictionary import failed.',
    'import_message_complete': 'Dictionary import complete.',
    'same_name_dictionary_found': 'Dictionary with same name found.',
    'import_file_extension_invalid':
        'This format expects files with the following extensions:'
            ' %extensions%',
    'field_label_sentence': 'Sentence',
    'field_label_term': 'Term',
    'field_label_reading': 'Reading',
    'field_label_meaning': 'Meaning',
    'field_label_extra': 'Extra',
    'field_label_image': 'Image',
    'field_label_audio': 'Audio',
    'field_label_context': 'Context',
    'field_label_empty': 'Empty',
    'field_hint_sentence': 'Sentence or written context',
    'field_hint_term': 'The term of the card',
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
    'error_ankidroid_api': 'AnkiDroid error',
    'error_ankidroid_api_content':
        'There was an issue communicating with AnkiDroid.\n\nEnsure that the'
            ' AnkiDroid background service is active and all relevant app'
            ' permissions are granted in order to continue.',
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
    'creator_exporting_as_fields_editing': 'Editing fields for profile',
    'creator_exporting_as_enhancements_editing':
        'Editing enhancements for profile',
    'creator_export_card': 'Create Card',
    'info_enhancements':
        'Enhancements enable the automation of field editing prior to card'
            ' creation. Pick a slot on the right of a field to allow use of an'
            ' enhancement. Up to five right slots may be utilised for each'
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
    'no_search_results': 'No search results found.',
    'edit_actions': 'Edit Dictionary Quick Actions',
    'remove_action': 'Remove Action',
    'assign_action': 'Assign Action',
    'dictionary_import_tag': 'Imported from %dictionaryName%',
    'stash_added_single': '『%term%』has been added to the Stash.',
    'stash_added_multiple': 'Multiple items have been added to the Stash.',
    'stash_clear_single': '『%term%』has been removed from the Stash.',
    'stash_clear_title': 'Clear Stash',
    'stash_clear_description': 'All contents will be cleared. Are you sure?',
    'stash_placeholder': 'No items in the Stash',
    'stash_nothing_to_pop': 'No items to be popped from the Stash.',
    'no_sentences_found': 'No sentences found',
    'failed_online_service': 'Failed to communicate with online service',
    'search_label_before': 'Search result ',
    'search_label_middle': 'out of ',
    'search_label_after': 'found for',
    'clear_dictionary_title': 'Clear Dictionary Result History',
    'clear_dictionary_description':
        'This will clear all dictionary results from history. Are you sure?',
    'clear_search_title': 'Clear Search History',
    'clear_search_description':
        'This will clear all search terms for this history. Are you sure?',
    'clear_creator_title': 'Clear Creator',
    'clear_creator_description': 'This will clear all fields. Are you sure?',
    'copied_to_clipboard': 'Copied to clipboard.',
    'no_text_to_segment': 'No text to segment.',
    'info_fields': 'Fields are pre-filled based on the term selected on instant'
        ' export or prior to opening the Card Creator. In order to include a'
        ' field for card export, it must be enabled below as well as mapped in'
        ' the current selected export profile. Enabled fields may also be'
        ' collapsed below in order to reduce clutter during editing. Use the'
        ' Clear button on the top-right of the Card Creator in order to wipe'
        ' these hidden fields quickly when manually editing a card.',
    'edit_fields': 'Edit and Reorder Fields',
    'remove_field': 'Remove Field',
    'add_field': 'Assign Field',
    'add_field_hint': 'Assign a field to this row',
    'no_more_available_fields': 'No more available fields',
    'hidden_fields': 'Additional fields',
    'field_fallback_used':
        'The %field% field used %secondField% as its fallback search term.',
    'no_text_to_search': 'No text to search.',
    'image_search_label_before': 'Selecting image ',
    'image_search_label_middle': 'out of ',
    'image_search_label_after': 'found for',
    'preparing_instant_export': 'Preparing card for export...',
    'processing_in_progress': 'Preparing images',
    'searching_in_progress': 'Searching for ',
    'audio_unavailable': 'No audio could be found.',
    'no_audio_enhancements': 'No audio enhancements are assigned.',
    'card_exported': 'Card exported to 『%deck%』.',
    'info_incognito_on':
        'Incognito mode on. Dictionary, media and search history will not be'
            ' tracked.',
    'info_incognito_off':
        'Incognito mode off. Dictionary, media and search history will be'
            ' tracked.',
    'exit_media_title': 'Exit Media',
    'exit_media_description':
        'This will return you to the main menu. Are you sure?',
    'unimplemented_source': 'Unimplemented source',
    'clear_browser_title': 'Clear Browser Data',
    'clear_browser_description':
        'This will clear all browsing data used in media sources that use web'
            ' content. Are you sure?',
    'ttu_no_books_added': 'No books added to ッツ Ebook Reader',
    'local_media_directory_empty': 'Directory has no folders or video',
    'pick_video_file': 'Pick Video File',
    'navigate_up_one_directory_level': 'Navigate Up One Directory Level',
    'player_play': 'Play',
    'player_pause': 'Pause',
    'player_replay': 'Replay',
    'audio_subtitles': 'Audio/Subtitles',
    'player_option_shadowing': 'Shadowing Mode',
    'player_option_definition_focus': 'Definition Focus Mode',
    'player_option_subtitle_focus': 'Subtitle Focus Mode',
    'player_option_listening_comprehension': 'Listening Comprehension Mode',
    'player_option_drag_to_select': 'Use Drag to Select Subtitle Selection',
    'player_option_tap_to_select': 'Use Tap to Select Subtitle Selection',
    'player_option_dictionary_menu': 'Select Active Dictionary Source',
    'player_option_cast_video': 'Cast to Display Device',
    'player_option_share_subtitle': 'Share Current Subtitle',
    'player_option_export': 'Create Card from Context',
    'player_option_audio': 'Audio',
    'player_option_subtitle': 'Subtitle',
    'player_option_subtitle_external': 'External',
    'player_option_subtitle_none': 'None',
    'player_option_select_subtitle': 'Select Subtitle Track',
    'player_option_select_audio': 'Select Audio Track',
    'player_option_text_filter': 'Use Regular Expression Filter',
    'player_option_blur_preferences': 'Blur Widget Preferences',
    'player_option_blur_use': 'Use Blur Widget',
    'player_option_blur_radius': 'Blur Radius',
    'player_option_blur_options': 'Set Blur Widget Color and Bluriness',
    'player_option_blur_reset': 'Reset Blur Widget Size and Position',
    'player_align_subtitle_transcript': 'Align Subtitle with Transcript',
    'player_option_subtitle_appearance': 'Subtitle Timing and Appearance',
    'player_option_load_subtitles': 'Load External Subtitles',
    'player_option_subtitle_delay': 'Subtitle Delay',
    'player_option_audio_allowance': 'Audio Allowance',
    'player_option_font_name': 'Font Name',
    'player_option_font_size': 'Font Size',
    'player_option_regex_filter': 'Regular Expression Filter',
    'player_subtitles_transcript_empty': 'Transcript is empty.',
    'player_prepare_export': 'Preparing card...',
    'player_change_player_orientation': 'Change Player Orientation',
    'no_current_media': 'Play or refresh media for lyrics',
    'lyrics_permission_required': 'Required permission not granted',
    'no_lyrics_found': 'No lyrics found',
    'trending': 'Trending',
    'caption_filter': 'Filter Closed',
    'change_quality': 'Change Quality',
    'closed_captions_query': 'Querying for captions',
    'closed_captions_target': 'Target language captions',
    'closed_captions_app': 'App language captions',
    'closed_captions_other': 'Other language captions',
    'closed_captions_unavailable': 'No captions',
    'closed_captions_error': 'Error while querying captions',
    'stream_url': 'Stream URL',
    'paste': 'Paste',
    'lyrics_title': 'Title',
    'lyrics_artist': 'Artist',
    'set_media': 'Set Media',
    'no_recordings_found': 'No recordings found',
    'wrap_image_audio': 'Wrap Image/Audio with Tags',
    'server_address': 'Server Address',
    'no_active_connection': 'No active connection',
    'failed_server_connection': 'Failed to connect to server',
    'no_text_received': 'No text received',
    'text_segmentation': 'Text Segmentation',
    'connect_disconnect': 'Connect/Disconnect',
    'clear_text_title': 'Clear Text',
    'clear_text_description':
        'This will clear all received text. Are you sure?',
    'close_connection_title': 'Close Connection',
    'close_connection_description':
        'This will end the WebSocket connection and clear all received text. Are you sure?',
    'use_slow_import': 'Slow import (use if crashing)',
    'settings': 'Settings',
    'manager': 'Manager',
    'volume_button_page_turning': 'Volume button page turning',
    'invert_volume_buttons': 'Invert volume buttons',
    'volume_button_turning_speed': 'Continuous scrolling speed',
    'volume_button_preferences': 'Volume Button Preferences',
    'increase': 'Increase',
    'decrease': 'Decrease',
    'unit_milliseconds': 'ms',
    'unit_pixels': 'px',
  };
}
