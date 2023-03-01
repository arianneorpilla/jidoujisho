/// Generated file. Do not edit.
///
/// Locales: 1
/// Strings: 298
///
/// Built on 2023-03-01 at 13:45 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, _StringsEn> {
	en(languageCode: 'en', build: _StringsEn.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, _StringsEn> build;

	/// Gets current instance managed by [LocaleSettings].
	_StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider extends BaseTranslationProvider<AppLocale, _StringsEn> {
	TranslationProvider({required super.child}) : super(
		initLocale: LocaleSettings.instance.currentLocale,
		initTranslations: LocaleSettings.instance.currentTranslations,
	);

	static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	_StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale) => instance.setLocale(locale);
	static AppLocale setLocaleRaw(String rawLocale) => instance.setLocaleRaw(rawLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations<AppLocale, _StringsEn> {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, _StringsEn> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get dictionary_media_type => 'Dictionary';
	String get player_media_type => 'Player';
	String get reader_media_type => 'Reader';
	String get viewer_media_type => 'Viewer';
	String get back => 'Back';
	String get search => 'Search';
	String get search_ellipsis => 'Search...';
	String get see_more => 'See More';
	String get show_menu => 'Show Menu';
	String get stash => 'Stash';
	String get pick_image => 'Pick Image';
	String get undo => 'Undo';
	String get copy => 'Copy';
	String get clear => 'Clear';
	String get creator => 'Creator';
	String get resume_last_media => 'Resume Last Media';
	String get change_source => 'Change Source';
	String get launch_source => 'Launch Source';
	String get card_creator => 'Card Creator';
	String get target_language => 'Target language';
	String get show_options => 'Show Options';
	String get switch_profiles => 'Switch Profiles';
	String get dictionaries => 'Dictionaries';
	String get enhancements => 'Enhancements';
	String get app_locale => 'App locale';
	String get app_locale_warning => 'Community addons and enhancements are managed by their respective developers, and these may appear in their original language.';
	String get dialog_play => 'PLAY';
	String get dialog_read => 'READ';
	String get dialog_view => 'VIEW';
	String get dialog_edit => 'EDIT';
	String get dialog_export => 'EXPORT';
	String get dialog_import => 'IMPORT';
	String get dialog_close => 'CLOSE';
	String get dialog_clear => 'CLEAR';
	String get dialog_create => 'CREATE';
	String get dialog_delete => 'DELETE';
	String get dialog_cancel => 'CANCEL';
	String get dialog_select => 'SELECT';
	String get dialog_stash => 'STASH';
	String get dialog_search => 'SEARCH';
	String get dialog_exit => 'EXIT';
	String get dialog_share => 'SHARE';
	String get dialog_pop => 'POP';
	String get dialog_save => 'SAVE';
	String get dialog_set => 'SET';
	String get dialog_channel => 'CHANNEL';
	String get dialog_crop => 'CROP';
	String get dialog_connect => 'CONNECT';
	String get dialog_append => 'APPEND';
	String get reset => 'Reset';
	String get dialog_launch_ankidroid => 'LAUNCH ANKIDROID';
	String get media_item_delete_confirmation => 'This will clear this item from history. Are you sure you want to do this?';
	String get dictionaries_delete_confirmation => 'Deleting a dictionary will also clear all dictionary results from history. Are you sure you want to do this?';
	String get mappings_delete_confirmation => 'This profile will be deleted. Are you sure you want to do this?';
	String get dictionaries_deleting_entries => 'Deleting dictionary entries...';
	String get dictionaries_menu_empty => 'Import a dictionary for use';
	String get options_theme_light => 'Use light theme';
	String get options_theme_dark => 'Use dark theme';
	String get options_incognito_on => 'Turn on incognito mode';
	String get options_incognito_off => 'Turn off incognito mode';
	String get options_dictionaries => 'Manage dictionaries';
	String get options_profiles => 'Export profiles';
	String get options_enhancements => 'User enhancements';
	String get options_language => 'Language settings';
	String get options_github => 'View repository on GitHub';
	String get options_attribution => 'Licenses and attribution';
	String get options_copy => 'Copy';
	String get options_collapse => 'Collapse';
	String get options_expand => 'Expand';
	String get options_delete => 'Delete';
	String get options_show => 'Show';
	String get options_hide => 'Hide';
	String get options_edit => 'Edit';
	String get info_empty_home_tab => 'History is empty';
	String get delete_in_progress => 'Delete in progress';
	String get import_format => 'Import format';
	String get import_in_progress => 'Import in progress';
	String get import_start => 'Preparing for import...';
	String get import_clean => 'Cleaning working space...';
	String get import_extract => 'Extracting files...';
	String import_name({required Object name}) => 'Importing 『${name}』...';
	String get import_entries => 'Processing entries...';
	String import_found_entry({required Object count}) => 'Found ${count} entries...';
	String import_found_tag({required Object count}) => 'Found ${count} tags...';
	String import_found_frequency({required Object count}) => 'Found ${count} frequency entries...';
	String import_found_pitch({required Object count}) => 'Found ${count} pitch accent entries...';
	String import_write_entry({required Object count, required Object total}) => 'Writing entries:\n${count} / ${total}';
	String import_write_tag({required Object count, required Object total}) => 'Writing tags:\n${count} / ${total}';
	String import_write_frequency({required Object count, required Object total}) => 'Writing frequency entries:\n${count} / ${total}';
	String import_write_pitch({required Object count, required Object total}) => 'Writing pitch accent entries:\n${count} / ${total}';
	String get import_failed => 'Dictionary import failed.';
	String get import_complete => 'Dictionary import complete.';
	String import_duplicate({required Object name}) => 'A dictionary with the name『${name}』is already imported.';
	String get dialog_title_dictionary_clear => 'Clear all dictionaries?';
	String get dialog_content_dictionary_clear => 'Wiping the dictionary database will also clear all search results in history.';
	String get delete_dictionary_data => 'Clearing all dictionary data...';
	String dictionary_tag({required Object name}) => 'Imported from ${name}';
	String get legalese => 'A full-featured immersion language learning suite for mobile.\n\nOriginally built for the Japanese language learning community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.\n\njidoujisho is free and open source software. See the project repository for a comprehensive list of other licenses and attribution notices. Enjoying the application? Help out by providing feedback, making a donation, reporting issues or contributing improvements on GitHub.';
	String get same_name_dictionary_found => 'Dictionary with same name found.';
	String import_file_extension_invalid({required Object extensions}) => 'This format expects files with the following extensions: ${extensions}';
	String get field_label_sentence => 'Sentence';
	String get field_label_term => 'Term';
	String get field_label_reading => 'Reading';
	String get field_label_meaning => 'Meaning';
	String get field_label_extra => 'Extra';
	String get field_label_image => 'Image';
	String get field_label_audio => 'Audio';
	String get field_label_context => 'Context';
	String get field_label_empty => 'Empty';
	String get field_hint_sentence => 'Sentence or written context';
	String get field_hint_term => 'The term of the card';
	String get field_hint_reading => 'Reading or pronunciation';
	String get field_hint_meaning => 'Meaning or dictionary definition';
	String get field_hint_extra => 'Any extra information here';
	String get field_hint_image => 'Enter image search term';
	String get field_hint_audio => 'Enter audio search term';
	String get field_hint_context => 'Information on media context';
	String get field_hint_empty => 'Leave field blank';
	String get model_to_map => 'Card type to use for new profile';
	String get mapping_name => 'Profile name';
	String get mapping_name_hint => 'Name to assign to profile';
	String get error_profile_name => 'Invalid profile name';
	String get error_profile_name_content => 'A profile with this name already exists or is not valid and cannot be saved.';
	String get error_standard_profile_name => 'Invalid profile name';
	String get error_standard_profile_name_content => 'Cannot rename the standard profile.';
	String get error_ankidroid_api => 'AnkiDroid error';
	String get error_ankidroid_api_content => 'There was an issue communicating with AnkiDroid.\n\nEnsure that the AnkiDroid background service is active and all relevant app permissions are granted in order to continue.';
	String get info_standard_model => 'Standard model added';
	String get info_standard_model_content => '『jidoujisho Yuuna』 has been added to AnkiDroid as a new card type.\n\nSetups making use of a different card type or field order may be used by adding a new export profile.';
	String get error_model_missing => 'Missing card type';
	String get error_model_missing_content => 'The corresponding card type of the currently selected profile is missing.\n\nThe standard profile has been selected in its place.';
	String get error_model_changed => 'Card type changed';
	String get error_model_changed_content => 'The number of fields of the card type corresponding to the selected profile has changed.\n\nThe fields of the currently selected profile have been reset and will require reconfiguration.';
	String get creator_exporting_as => 'Creating card with profile';
	String get creator_exporting_as_fields_editing => 'Editing fields for profile';
	String get creator_exporting_as_enhancements_editing => 'Editing enhancements for profile';
	String get creator_export_card => 'Create Card';
	String get info_enhancements => 'Enhancements enable the automation of field editing prior to card creation. Pick a slot on the right of a field to allow use of an enhancement. Up to five right slots may be utilised for each field. The enhancement in the left slot of a field will be automatically applied in instant card creation or upon launch of the Card Creator.';
	String get info_actions => 'Quick actions allow for instant card creation and other automations to be used on dictionary search results. Actions can be assigned via the slots below. Up to six slots may be utilised.';
	String get no_more_available_enhancements => 'No more available enhancements for this field';
	String get no_more_available_quick_actions => 'No more available quick actions';
	String get assign_auto_enhancement => 'Assign Auto Enhancement';
	String get assign_manual_enhancement => 'Assign Manual Enhancement';
	String get remove_enhancement => 'Remove Enhancement';
	String copy_of_mapping({required Object name}) => 'Copy of ${name}';
	String get enter_search_term => 'Enter a search term...';
	String searching_for({required Object searchTerm}) => 'Searching for 『${searchTerm}』...';
	String get no_search_results => 'No search results found.';
	String get edit_actions => 'Edit Dictionary Quick Actions';
	String get remove_action => 'Remove Action';
	String get assign_action => 'Assign Action';
	String dictionary_import_tag({required Object name}) => 'Imported from ${name}';
	String stash_added_single({required Object term}) => '『${term}』has been added to the Stash.';
	String get stash_added_multiple => 'Multiple items have been added to the Stash.';
	String stash_clear_single({required Object term}) => '『${term}』has been removed from the Stash.';
	String get stash_clear_title => 'Clear Stash';
	String get stash_clear_description => 'All contents will be cleared. Are you sure?';
	String get stash_placeholder => 'No items in the Stash';
	String get stash_nothing_to_pop => 'No items to be popped from the Stash.';
	String get no_sentences_found => 'No sentences found';
	String get failed_online_service => 'Failed to communicate with online service';
	String get search_label_before => 'Search result ';
	String get search_label_middle => 'out of ';
	String get search_label_after => 'found for';
	String get clear_dictionary_title => 'Clear Dictionary Result History';
	String get clear_dictionary_description => 'This will clear all dictionary results from history. Are you sure?';
	String get clear_search_title => 'Clear Search History';
	String get clear_search_description => 'This will clear all search terms for this history. Are you sure?';
	String get clear_creator_title => 'Clear Creator';
	String get clear_creator_description => 'This will clear all fields. Are you sure?';
	String get copied_to_clipboard => 'Copied to clipboard.';
	String get no_text_to_segment => 'No text to segment.';
	String get info_fields => 'Fields are pre-filled based on the term selected on instant export or prior to opening the Card Creator. In order to include a field for card export, it must be enabled below as well as mapped in the current selected export profile. Enabled fields may also be collapsed below in order to reduce clutter during editing. Use the Clear button on the top-right of the Card Creator in order to wipe these hidden fields quickly when manually editing a card.';
	String get edit_fields => 'Edit and Reorder Fields';
	String get remove_field => 'Remove Field';
	String get add_field => 'Assign Field';
	String get add_field_hint => 'Assign a field to this row';
	String get no_more_available_fields => 'No more available fields';
	String get hidden_fields => 'Additional fields';
	String field_fallback_used({required Object field, required Object secondField}) => 'The ${field} field used ${secondField} as its fallback search term.';
	String get no_text_to_search => 'No text to search.';
	String get image_search_label_before => 'Selecting image ';
	String get image_search_label_middle => 'out of ';
	String get image_search_label_after => 'found for';
	String get image_search_label_none_middle => 'no image ';
	String get image_search_label_none_before => 'Selecting ';
	String get preparing_instant_export => 'Preparing card for export...';
	String get processing_in_progress => 'Preparing images';
	String get searching_in_progress => 'Searching for ';
	String get audio_unavailable => 'No audio could be found.';
	String get no_audio_enhancements => 'No audio enhancements are assigned.';
	String card_exported({required Object deck}) => 'Card exported to 『${deck}』.';
	String get info_incognito_on => 'Incognito mode on. Dictionary, media and search history will not be tracked.';
	String get info_incognito_off => 'Incognito mode off. Dictionary, media and search history will be tracked.';
	String get exit_media_title => 'Exit Media';
	String get exit_media_description => 'This will return you to the main menu. Are you sure?';
	String get unimplemented_source => 'Unimplemented source';
	String get clear_browser_title => 'Clear Browser Data';
	String get clear_browser_description => 'This will clear all browsing data used in media sources that use web content. Are you sure?';
	String get ttu_no_books_added => 'No books added to ッツ Ebook Reader';
	String get local_media_directory_empty => 'Directory has no folders or video';
	String get pick_video_file => 'Pick Video File';
	String get navigate_up_one_directory_level => 'Navigate Up One Directory Level';
	String get player_play => 'Play';
	String get player_pause => 'Pause';
	String get player_replay => 'Replay';
	String get audio_subtitles => 'Audio/Subtitles';
	String get player_option_shadowing => 'Shadowing Mode';
	String get player_option_definition_focus => 'Definition Focus Mode';
	String get player_option_subtitle_focus => 'Subtitle Focus Mode';
	String get player_option_listening_comprehension => 'Listening Comprehension Mode';
	String get player_option_drag_to_select => 'Use Drag to Select Subtitle Selection';
	String get player_option_tap_to_select => 'Use Tap to Select Subtitle Selection';
	String get player_option_dictionary_menu => 'Select Active Dictionary Source';
	String get player_option_cast_video => 'Cast to Display Device';
	String get player_option_share_subtitle => 'Share Current Subtitle';
	String get player_option_export => 'Create Card from Context';
	String get player_option_audio => 'Audio';
	String get player_option_subtitle => 'Subtitle';
	String get player_option_subtitle_external => 'External';
	String get player_option_subtitle_none => 'None';
	String get player_option_select_subtitle => 'Select Subtitle Track';
	String get player_option_select_audio => 'Select Audio Track';
	String get player_option_text_filter => 'Use Regular Expression Filter';
	String get player_option_blur_preferences => 'Blur Widget Preferences';
	String get player_option_blur_use => 'Use Blur Widget';
	String get player_option_blur_radius => 'Blur Radius';
	String get player_option_blur_options => 'Set Blur Widget Color and Bluriness';
	String get player_option_blur_reset => 'Reset Blur Widget Size and Position';
	String get player_align_subtitle_transcript => 'Align Subtitle with Transcript';
	String get player_option_subtitle_appearance => 'Subtitle Timing and Appearance';
	String get player_option_load_subtitles => 'Load External Subtitles';
	String get player_option_subtitle_delay => 'Subtitle Delay';
	String get player_option_audio_allowance => 'Audio Allowance';
	String get player_option_font_name => 'Font Name';
	String get player_option_font_size => 'Font Size';
	String get player_option_regex_filter => 'Regular Expression Filter';
	String get player_subtitles_transcript_empty => 'Transcript is empty.';
	String get player_prepare_export => 'Preparing card...';
	String get player_change_player_orientation => 'Change Player Orientation';
	String get no_current_media => 'Play or refresh media for lyrics';
	String get lyrics_permission_required => 'Required permission not granted';
	String get no_lyrics_found => 'No lyrics found';
	String get trending => 'Trending';
	String get caption_filter => 'Filter Closed';
	String get change_quality => 'Change Quality';
	String get closed_captions_query => 'Querying for captions';
	String get closed_captions_target => 'Target language captions';
	String get closed_captions_app => 'App language captions';
	String get closed_captions_other => 'Other language captions';
	String get closed_captions_unavailable => 'No captions';
	String get closed_captions_error => 'Error while querying captions';
	String get stream_url => 'Stream URL';
	String get paste => 'Paste';
	String get lyrics_title => 'Title';
	String get lyrics_artist => 'Artist';
	String get set_media => 'Set Media';
	String get no_recordings_found => 'No recordings found';
	String get wrap_image_audio => 'Include image/audio HTML tags on export';
	String get server_address => 'Server Address';
	String get no_active_connection => 'No active connection';
	String get failed_server_connection => 'Failed to connect to server';
	String get no_text_received => 'No text received';
	String get text_segmentation => 'Text Segmentation';
	String get connect_disconnect => 'Connect/Disconnect';
	String get clear_text_title => 'Clear Text';
	String get clear_text_description => 'This will clear all received text. Are you sure?';
	String get close_connection_title => 'Close Connection';
	String get close_connection_description => 'This will end the WebSocket connection and clear all received text. Are you sure?';
	String get use_slow_import => 'Slow import (use if failing)';
	String get settings => 'Settings';
	String get manager => 'Manager';
	String get volume_button_page_turning => 'Volume button page turning';
	String get invert_volume_buttons => 'Invert volume buttons';
	String get volume_button_turning_speed => 'Continuous scrolling speed';
	String get extend_page_beyond_navbar => 'Extend page beyond navigation bar';
	String get tweaks => 'Tweaks';
	String get increase => 'Increase';
	String get decrease => 'Decrease';
	String get unit_milliseconds => 'ms';
	String get unit_pixels => 'px';
	String get dictionary_settings => 'Dictionary Settings';
	String get auto_search => 'Auto search';
	String get auto_search_debounce_delay => 'Auto search debounce delay';
	String get dictionary_font_size => 'Dictionary font size';
	String get close_on_export => 'Close on Export';
	String get close_on_export_on => 'The Card Creator will now automatically close upon card export.';
	String get close_on_export_off => 'The Card Creator will no longer close upon card export.';
	String get export_profile_empty => 'Your export profile has no set fields and requires configuration.';
	String get error_export_media_ankidroid => 'There was an error in exporting media to AnkiDroid.';
	String get error_add_note => 'There was an error in adding a note to AnkiDroid.';
	String get first_time_setup => 'First-Time Setup';
	String get first_time_setup_description => 'Welcome to jidoujisho! Set your target language and a default profile will be tailored for you. You can change this later at anytime.';
	String get maximum_entries => 'Maximum dictionary entry query limit';
	String get maximum_terms => 'Maximum dictionary headwords in result';
	String get use_br_tags => 'Use line break tag instead of newline on export';
	String get prepend_dictionary_names => 'Prepend dictionary name in meaning';
	String get highlight_on_tap => 'Highlight text on tap';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'dictionary_media_type': return 'Dictionary';
			case 'player_media_type': return 'Player';
			case 'reader_media_type': return 'Reader';
			case 'viewer_media_type': return 'Viewer';
			case 'back': return 'Back';
			case 'search': return 'Search';
			case 'search_ellipsis': return 'Search...';
			case 'see_more': return 'See More';
			case 'show_menu': return 'Show Menu';
			case 'stash': return 'Stash';
			case 'pick_image': return 'Pick Image';
			case 'undo': return 'Undo';
			case 'copy': return 'Copy';
			case 'clear': return 'Clear';
			case 'creator': return 'Creator';
			case 'resume_last_media': return 'Resume Last Media';
			case 'change_source': return 'Change Source';
			case 'launch_source': return 'Launch Source';
			case 'card_creator': return 'Card Creator';
			case 'target_language': return 'Target language';
			case 'show_options': return 'Show Options';
			case 'switch_profiles': return 'Switch Profiles';
			case 'dictionaries': return 'Dictionaries';
			case 'enhancements': return 'Enhancements';
			case 'app_locale': return 'App locale';
			case 'app_locale_warning': return 'Community addons and enhancements are managed by their respective developers, and these may appear in their original language.';
			case 'dialog_play': return 'PLAY';
			case 'dialog_read': return 'READ';
			case 'dialog_view': return 'VIEW';
			case 'dialog_edit': return 'EDIT';
			case 'dialog_export': return 'EXPORT';
			case 'dialog_import': return 'IMPORT';
			case 'dialog_close': return 'CLOSE';
			case 'dialog_clear': return 'CLEAR';
			case 'dialog_create': return 'CREATE';
			case 'dialog_delete': return 'DELETE';
			case 'dialog_cancel': return 'CANCEL';
			case 'dialog_select': return 'SELECT';
			case 'dialog_stash': return 'STASH';
			case 'dialog_search': return 'SEARCH';
			case 'dialog_exit': return 'EXIT';
			case 'dialog_share': return 'SHARE';
			case 'dialog_pop': return 'POP';
			case 'dialog_save': return 'SAVE';
			case 'dialog_set': return 'SET';
			case 'dialog_channel': return 'CHANNEL';
			case 'dialog_crop': return 'CROP';
			case 'dialog_connect': return 'CONNECT';
			case 'dialog_append': return 'APPEND';
			case 'reset': return 'Reset';
			case 'dialog_launch_ankidroid': return 'LAUNCH ANKIDROID';
			case 'media_item_delete_confirmation': return 'This will clear this item from history. Are you sure you want to do this?';
			case 'dictionaries_delete_confirmation': return 'Deleting a dictionary will also clear all dictionary results from history. Are you sure you want to do this?';
			case 'mappings_delete_confirmation': return 'This profile will be deleted. Are you sure you want to do this?';
			case 'dictionaries_deleting_entries': return 'Deleting dictionary entries...';
			case 'dictionaries_menu_empty': return 'Import a dictionary for use';
			case 'options_theme_light': return 'Use light theme';
			case 'options_theme_dark': return 'Use dark theme';
			case 'options_incognito_on': return 'Turn on incognito mode';
			case 'options_incognito_off': return 'Turn off incognito mode';
			case 'options_dictionaries': return 'Manage dictionaries';
			case 'options_profiles': return 'Export profiles';
			case 'options_enhancements': return 'User enhancements';
			case 'options_language': return 'Language settings';
			case 'options_github': return 'View repository on GitHub';
			case 'options_attribution': return 'Licenses and attribution';
			case 'options_copy': return 'Copy';
			case 'options_collapse': return 'Collapse';
			case 'options_expand': return 'Expand';
			case 'options_delete': return 'Delete';
			case 'options_show': return 'Show';
			case 'options_hide': return 'Hide';
			case 'options_edit': return 'Edit';
			case 'info_empty_home_tab': return 'History is empty';
			case 'delete_in_progress': return 'Delete in progress';
			case 'import_format': return 'Import format';
			case 'import_in_progress': return 'Import in progress';
			case 'import_start': return 'Preparing for import...';
			case 'import_clean': return 'Cleaning working space...';
			case 'import_extract': return 'Extracting files...';
			case 'import_name': return ({required Object name}) => 'Importing 『${name}』...';
			case 'import_entries': return 'Processing entries...';
			case 'import_found_entry': return ({required Object count}) => 'Found ${count} entries...';
			case 'import_found_tag': return ({required Object count}) => 'Found ${count} tags...';
			case 'import_found_frequency': return ({required Object count}) => 'Found ${count} frequency entries...';
			case 'import_found_pitch': return ({required Object count}) => 'Found ${count} pitch accent entries...';
			case 'import_write_entry': return ({required Object count, required Object total}) => 'Writing entries:\n${count} / ${total}';
			case 'import_write_tag': return ({required Object count, required Object total}) => 'Writing tags:\n${count} / ${total}';
			case 'import_write_frequency': return ({required Object count, required Object total}) => 'Writing frequency entries:\n${count} / ${total}';
			case 'import_write_pitch': return ({required Object count, required Object total}) => 'Writing pitch accent entries:\n${count} / ${total}';
			case 'import_failed': return 'Dictionary import failed.';
			case 'import_complete': return 'Dictionary import complete.';
			case 'import_duplicate': return ({required Object name}) => 'A dictionary with the name『${name}』is already imported.';
			case 'dialog_title_dictionary_clear': return 'Clear all dictionaries?';
			case 'dialog_content_dictionary_clear': return 'Wiping the dictionary database will also clear all search results in history.';
			case 'delete_dictionary_data': return 'Clearing all dictionary data...';
			case 'dictionary_tag': return ({required Object name}) => 'Imported from ${name}';
			case 'legalese': return 'A full-featured immersion language learning suite for mobile.\n\nOriginally built for the Japanese language learning community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.\n\njidoujisho is free and open source software. See the project repository for a comprehensive list of other licenses and attribution notices. Enjoying the application? Help out by providing feedback, making a donation, reporting issues or contributing improvements on GitHub.';
			case 'same_name_dictionary_found': return 'Dictionary with same name found.';
			case 'import_file_extension_invalid': return ({required Object extensions}) => 'This format expects files with the following extensions: ${extensions}';
			case 'field_label_sentence': return 'Sentence';
			case 'field_label_term': return 'Term';
			case 'field_label_reading': return 'Reading';
			case 'field_label_meaning': return 'Meaning';
			case 'field_label_extra': return 'Extra';
			case 'field_label_image': return 'Image';
			case 'field_label_audio': return 'Audio';
			case 'field_label_context': return 'Context';
			case 'field_label_empty': return 'Empty';
			case 'field_hint_sentence': return 'Sentence or written context';
			case 'field_hint_term': return 'The term of the card';
			case 'field_hint_reading': return 'Reading or pronunciation';
			case 'field_hint_meaning': return 'Meaning or dictionary definition';
			case 'field_hint_extra': return 'Any extra information here';
			case 'field_hint_image': return 'Enter image search term';
			case 'field_hint_audio': return 'Enter audio search term';
			case 'field_hint_context': return 'Information on media context';
			case 'field_hint_empty': return 'Leave field blank';
			case 'model_to_map': return 'Card type to use for new profile';
			case 'mapping_name': return 'Profile name';
			case 'mapping_name_hint': return 'Name to assign to profile';
			case 'error_profile_name': return 'Invalid profile name';
			case 'error_profile_name_content': return 'A profile with this name already exists or is not valid and cannot be saved.';
			case 'error_standard_profile_name': return 'Invalid profile name';
			case 'error_standard_profile_name_content': return 'Cannot rename the standard profile.';
			case 'error_ankidroid_api': return 'AnkiDroid error';
			case 'error_ankidroid_api_content': return 'There was an issue communicating with AnkiDroid.\n\nEnsure that the AnkiDroid background service is active and all relevant app permissions are granted in order to continue.';
			case 'info_standard_model': return 'Standard model added';
			case 'info_standard_model_content': return '『jidoujisho Yuuna』 has been added to AnkiDroid as a new card type.\n\nSetups making use of a different card type or field order may be used by adding a new export profile.';
			case 'error_model_missing': return 'Missing card type';
			case 'error_model_missing_content': return 'The corresponding card type of the currently selected profile is missing.\n\nThe standard profile has been selected in its place.';
			case 'error_model_changed': return 'Card type changed';
			case 'error_model_changed_content': return 'The number of fields of the card type corresponding to the selected profile has changed.\n\nThe fields of the currently selected profile have been reset and will require reconfiguration.';
			case 'creator_exporting_as': return 'Creating card with profile';
			case 'creator_exporting_as_fields_editing': return 'Editing fields for profile';
			case 'creator_exporting_as_enhancements_editing': return 'Editing enhancements for profile';
			case 'creator_export_card': return 'Create Card';
			case 'info_enhancements': return 'Enhancements enable the automation of field editing prior to card creation. Pick a slot on the right of a field to allow use of an enhancement. Up to five right slots may be utilised for each field. The enhancement in the left slot of a field will be automatically applied in instant card creation or upon launch of the Card Creator.';
			case 'info_actions': return 'Quick actions allow for instant card creation and other automations to be used on dictionary search results. Actions can be assigned via the slots below. Up to six slots may be utilised.';
			case 'no_more_available_enhancements': return 'No more available enhancements for this field';
			case 'no_more_available_quick_actions': return 'No more available quick actions';
			case 'assign_auto_enhancement': return 'Assign Auto Enhancement';
			case 'assign_manual_enhancement': return 'Assign Manual Enhancement';
			case 'remove_enhancement': return 'Remove Enhancement';
			case 'copy_of_mapping': return ({required Object name}) => 'Copy of ${name}';
			case 'enter_search_term': return 'Enter a search term...';
			case 'searching_for': return ({required Object searchTerm}) => 'Searching for 『${searchTerm}』...';
			case 'no_search_results': return 'No search results found.';
			case 'edit_actions': return 'Edit Dictionary Quick Actions';
			case 'remove_action': return 'Remove Action';
			case 'assign_action': return 'Assign Action';
			case 'dictionary_import_tag': return ({required Object name}) => 'Imported from ${name}';
			case 'stash_added_single': return ({required Object term}) => '『${term}』has been added to the Stash.';
			case 'stash_added_multiple': return 'Multiple items have been added to the Stash.';
			case 'stash_clear_single': return ({required Object term}) => '『${term}』has been removed from the Stash.';
			case 'stash_clear_title': return 'Clear Stash';
			case 'stash_clear_description': return 'All contents will be cleared. Are you sure?';
			case 'stash_placeholder': return 'No items in the Stash';
			case 'stash_nothing_to_pop': return 'No items to be popped from the Stash.';
			case 'no_sentences_found': return 'No sentences found';
			case 'failed_online_service': return 'Failed to communicate with online service';
			case 'search_label_before': return 'Search result ';
			case 'search_label_middle': return 'out of ';
			case 'search_label_after': return 'found for';
			case 'clear_dictionary_title': return 'Clear Dictionary Result History';
			case 'clear_dictionary_description': return 'This will clear all dictionary results from history. Are you sure?';
			case 'clear_search_title': return 'Clear Search History';
			case 'clear_search_description': return 'This will clear all search terms for this history. Are you sure?';
			case 'clear_creator_title': return 'Clear Creator';
			case 'clear_creator_description': return 'This will clear all fields. Are you sure?';
			case 'copied_to_clipboard': return 'Copied to clipboard.';
			case 'no_text_to_segment': return 'No text to segment.';
			case 'info_fields': return 'Fields are pre-filled based on the term selected on instant export or prior to opening the Card Creator. In order to include a field for card export, it must be enabled below as well as mapped in the current selected export profile. Enabled fields may also be collapsed below in order to reduce clutter during editing. Use the Clear button on the top-right of the Card Creator in order to wipe these hidden fields quickly when manually editing a card.';
			case 'edit_fields': return 'Edit and Reorder Fields';
			case 'remove_field': return 'Remove Field';
			case 'add_field': return 'Assign Field';
			case 'add_field_hint': return 'Assign a field to this row';
			case 'no_more_available_fields': return 'No more available fields';
			case 'hidden_fields': return 'Additional fields';
			case 'field_fallback_used': return ({required Object field, required Object secondField}) => 'The ${field} field used ${secondField} as its fallback search term.';
			case 'no_text_to_search': return 'No text to search.';
			case 'image_search_label_before': return 'Selecting image ';
			case 'image_search_label_middle': return 'out of ';
			case 'image_search_label_after': return 'found for';
			case 'image_search_label_none_middle': return 'no image ';
			case 'image_search_label_none_before': return 'Selecting ';
			case 'preparing_instant_export': return 'Preparing card for export...';
			case 'processing_in_progress': return 'Preparing images';
			case 'searching_in_progress': return 'Searching for ';
			case 'audio_unavailable': return 'No audio could be found.';
			case 'no_audio_enhancements': return 'No audio enhancements are assigned.';
			case 'card_exported': return ({required Object deck}) => 'Card exported to 『${deck}』.';
			case 'info_incognito_on': return 'Incognito mode on. Dictionary, media and search history will not be tracked.';
			case 'info_incognito_off': return 'Incognito mode off. Dictionary, media and search history will be tracked.';
			case 'exit_media_title': return 'Exit Media';
			case 'exit_media_description': return 'This will return you to the main menu. Are you sure?';
			case 'unimplemented_source': return 'Unimplemented source';
			case 'clear_browser_title': return 'Clear Browser Data';
			case 'clear_browser_description': return 'This will clear all browsing data used in media sources that use web content. Are you sure?';
			case 'ttu_no_books_added': return 'No books added to ッツ Ebook Reader';
			case 'local_media_directory_empty': return 'Directory has no folders or video';
			case 'pick_video_file': return 'Pick Video File';
			case 'navigate_up_one_directory_level': return 'Navigate Up One Directory Level';
			case 'player_play': return 'Play';
			case 'player_pause': return 'Pause';
			case 'player_replay': return 'Replay';
			case 'audio_subtitles': return 'Audio/Subtitles';
			case 'player_option_shadowing': return 'Shadowing Mode';
			case 'player_option_definition_focus': return 'Definition Focus Mode';
			case 'player_option_subtitle_focus': return 'Subtitle Focus Mode';
			case 'player_option_listening_comprehension': return 'Listening Comprehension Mode';
			case 'player_option_drag_to_select': return 'Use Drag to Select Subtitle Selection';
			case 'player_option_tap_to_select': return 'Use Tap to Select Subtitle Selection';
			case 'player_option_dictionary_menu': return 'Select Active Dictionary Source';
			case 'player_option_cast_video': return 'Cast to Display Device';
			case 'player_option_share_subtitle': return 'Share Current Subtitle';
			case 'player_option_export': return 'Create Card from Context';
			case 'player_option_audio': return 'Audio';
			case 'player_option_subtitle': return 'Subtitle';
			case 'player_option_subtitle_external': return 'External';
			case 'player_option_subtitle_none': return 'None';
			case 'player_option_select_subtitle': return 'Select Subtitle Track';
			case 'player_option_select_audio': return 'Select Audio Track';
			case 'player_option_text_filter': return 'Use Regular Expression Filter';
			case 'player_option_blur_preferences': return 'Blur Widget Preferences';
			case 'player_option_blur_use': return 'Use Blur Widget';
			case 'player_option_blur_radius': return 'Blur Radius';
			case 'player_option_blur_options': return 'Set Blur Widget Color and Bluriness';
			case 'player_option_blur_reset': return 'Reset Blur Widget Size and Position';
			case 'player_align_subtitle_transcript': return 'Align Subtitle with Transcript';
			case 'player_option_subtitle_appearance': return 'Subtitle Timing and Appearance';
			case 'player_option_load_subtitles': return 'Load External Subtitles';
			case 'player_option_subtitle_delay': return 'Subtitle Delay';
			case 'player_option_audio_allowance': return 'Audio Allowance';
			case 'player_option_font_name': return 'Font Name';
			case 'player_option_font_size': return 'Font Size';
			case 'player_option_regex_filter': return 'Regular Expression Filter';
			case 'player_subtitles_transcript_empty': return 'Transcript is empty.';
			case 'player_prepare_export': return 'Preparing card...';
			case 'player_change_player_orientation': return 'Change Player Orientation';
			case 'no_current_media': return 'Play or refresh media for lyrics';
			case 'lyrics_permission_required': return 'Required permission not granted';
			case 'no_lyrics_found': return 'No lyrics found';
			case 'trending': return 'Trending';
			case 'caption_filter': return 'Filter Closed';
			case 'change_quality': return 'Change Quality';
			case 'closed_captions_query': return 'Querying for captions';
			case 'closed_captions_target': return 'Target language captions';
			case 'closed_captions_app': return 'App language captions';
			case 'closed_captions_other': return 'Other language captions';
			case 'closed_captions_unavailable': return 'No captions';
			case 'closed_captions_error': return 'Error while querying captions';
			case 'stream_url': return 'Stream URL';
			case 'paste': return 'Paste';
			case 'lyrics_title': return 'Title';
			case 'lyrics_artist': return 'Artist';
			case 'set_media': return 'Set Media';
			case 'no_recordings_found': return 'No recordings found';
			case 'wrap_image_audio': return 'Include image/audio HTML tags on export';
			case 'server_address': return 'Server Address';
			case 'no_active_connection': return 'No active connection';
			case 'failed_server_connection': return 'Failed to connect to server';
			case 'no_text_received': return 'No text received';
			case 'text_segmentation': return 'Text Segmentation';
			case 'connect_disconnect': return 'Connect/Disconnect';
			case 'clear_text_title': return 'Clear Text';
			case 'clear_text_description': return 'This will clear all received text. Are you sure?';
			case 'close_connection_title': return 'Close Connection';
			case 'close_connection_description': return 'This will end the WebSocket connection and clear all received text. Are you sure?';
			case 'use_slow_import': return 'Slow import (use if failing)';
			case 'settings': return 'Settings';
			case 'manager': return 'Manager';
			case 'volume_button_page_turning': return 'Volume button page turning';
			case 'invert_volume_buttons': return 'Invert volume buttons';
			case 'volume_button_turning_speed': return 'Continuous scrolling speed';
			case 'extend_page_beyond_navbar': return 'Extend page beyond navigation bar';
			case 'tweaks': return 'Tweaks';
			case 'increase': return 'Increase';
			case 'decrease': return 'Decrease';
			case 'unit_milliseconds': return 'ms';
			case 'unit_pixels': return 'px';
			case 'dictionary_settings': return 'Dictionary Settings';
			case 'auto_search': return 'Auto search';
			case 'auto_search_debounce_delay': return 'Auto search debounce delay';
			case 'dictionary_font_size': return 'Dictionary font size';
			case 'close_on_export': return 'Close on Export';
			case 'close_on_export_on': return 'The Card Creator will now automatically close upon card export.';
			case 'close_on_export_off': return 'The Card Creator will no longer close upon card export.';
			case 'export_profile_empty': return 'Your export profile has no set fields and requires configuration.';
			case 'error_export_media_ankidroid': return 'There was an error in exporting media to AnkiDroid.';
			case 'error_add_note': return 'There was an error in adding a note to AnkiDroid.';
			case 'first_time_setup': return 'First-Time Setup';
			case 'first_time_setup_description': return 'Welcome to jidoujisho! Set your target language and a default profile will be tailored for you. You can change this later at anytime.';
			case 'maximum_entries': return 'Maximum dictionary entry query limit';
			case 'maximum_terms': return 'Maximum dictionary headwords in result';
			case 'use_br_tags': return 'Use line break tag instead of newline on export';
			case 'prepend_dictionary_names': return 'Prepend dictionary name in meaning';
			case 'highlight_on_tap': return 'Highlight text on tap';
			default: return null;
		}
	}
}
