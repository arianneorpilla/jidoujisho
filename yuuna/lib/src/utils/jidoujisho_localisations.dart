/// A dedicated store for localised strings for different supported app
/// languages.
class JidoujishoLocalisations {
  /// A map sorting app language locale tags by their language names as a
  /// native would understand them.
  static Map<String, String> localeNames = {
    'en-US': 'English',
    'es-ES': 'Español',
  };

  /// A map storing localisation key-value data pairs sorted by app languages.
  static Map<String, Map<String, String>> localisations = {
    'en-US': english,
    'es-ES': spanish,
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
    'application_legalese': 'A full-featured immersion language learning suite for mobile.\n\n'
    'Originally built for the Japanese language learning community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.'
    '\n\nJidoujisho is free and open source software. See the '
    'project repository for a comprehensive list of other licenses '
    'and attribution notices. Enjoying the application? Help out by '
    'providing feedback, making a donation, reporting issues or '
    'contributing improvements on GitHub.',
  };

  /// Localisation for 'es-ES'.
  static const Map<String, String> spanish = {
    'dictionary_media_type': 'Diccionario',
    'player_media_type': 'Reproductor',
    'reader_media_type': 'Lector',
    'viewer_media_type': 'Visualizador',
    'back': 'Atrás',
    'search': 'Buscar',
    'search_ellipsis': 'Buscar...',
    'see_more': 'Ver más',
    'show_menu': 'Mostrar Menú',
    'stash': 'Stash',
    'pick_image': 'Elegir Imagen',
    'undo': 'Deshacer',
    'copy': 'Copiar',
    'clear': 'Limpiar',
    'creator': 'Creador',
    'resume_last_media': 'Resumir Último Contenido Multimedia',
    'change_source': 'Change Source',
    'launch_source': 'Launch Source',
    'card_creator': 'Creador de Tarjetas',
    'target_language': 'Lenguaje Objetivo',
    'show_options': 'Mostrar Opciones',
    'switch_profiles': 'Cambiar perfiles',
    'dictionaries': 'Diccionarios',
    'enhancements': 'Complementos',
    'app_locale': 'Idioma de la aplicación',
    'app_locale_warning': 'Los complementos y extensiones de la comunidad son administrados '
        'por sus respectivos desarrolladores, es posible que estos se muestren en su '
        'idioma original.',
    'dialog_play': 'REPRODUCIR',
    'dialog_read': 'LEER',
    'dialog_view': 'VER',
    'dialog_edit': 'EDITAR',
    'dialog_export': 'EXPORTAR',
    'dialog_import': 'IMPORTAR',
    'dialog_close': 'CERRAR',
    'dialog_clear': 'LIMPIAR',
    'dialog_create': 'CREAR',
    'dialog_delete': 'ELIMINAR',
    'dialog_cancel': 'CANCELAR',
    'dialog_select': 'SELECCIONAR',
    'dialog_stash': 'STASH',
    'dialog_search': 'BUSCAR',
    'dialog_exit': 'SALIR',
    'dialog_share': 'COMPARTIR',
    'dialog_pop': 'POP',
    'dialog_save': 'GUARDAR',
    'dialog_set': 'ESTABLECER',
    'dialog_channel': 'CHANNEL',
    'dialog_crop': 'CORTAR',
    'reset': 'Reiniciar',
    'dialog_launch_ankidroid': 'LAUNCH ANKIDROID',
    'media_item_delete_confirmation':
    'Esto eliminará el item del historial. ¿Está seguro de eliminarlo?',
    'dictionaries_delete_confirmation':
    'Borrar un diccionario también borrará todo el historial de resultados del'
        ' mismo. ¿Está seguro de hacer esto?',
    'mappings_delete_confirmation': 'Este perfil será eliminado. ¿Está '
        'seguro de eliminarlo?',
    'dictionaries_deleting_entries': 'Eliminando entradas del diccionario...',
    'dictionaries_menu_empty': 'Importa un diccionario para su uso',
    'options_theme_light': 'Usar tema claro',
    'options_theme_dark': 'Usar tema oscuro',
    'options_incognito_on': 'Habilitar modo incógnito',
    'options_incognito_off': 'Deshabilitar mdoo incógnito',
    'options_dictionaries': 'Administrar diccionarios',
    'options_profiles': 'Exportar perfiles',
    'options_enhancements': 'Complementos',
    'options_language': 'Ajustes de idioma',
    'options_github': 'Ver repositorio en GitHub',
    'options_attribution': 'Licencias y atribuciones',
    'options_copy': 'Copiar',
    'options_collapse': 'Colapsar',
    'options_expand': 'Expandir',
    'options_delete': 'Borrar',
    'options_show': 'Mostrar',
    'options_hide': 'Ocultar',
    'options_edit': 'Editar',
    'info_empty_home_tab': 'El historial está vacío',
    'delete_in_progress': 'Borrado en progreso...',
    'import_format': 'Importar formato',
    'import_in_progress': 'Importado en progreso',
    'import_message_start': 'Importando diccionario...',
    'import_message_clean': 'Limpiando espacio de trabajo...',
    'import_message_extraction': 'Extrayendo archivos...',
    'import_message_name': 'Importando 『%name%』...',
    'import_message_entries': 'Procesando entradas...',
    'import_message_entry_count': 'Se han encontrado %count% entradas...',
    'import_message_meta_entry_count': 'Se han encontrado %count% metadatos...',
    'import_message_tag_count': 'Se han encontrado %count% etiquetas...',
    'import_message_metadata': 'Procesando metadatos...',
    'import_message_database': 'Añadiendo entradas a la base de datos...',
    'import_message_error': 'Error de importado: %error%',
    'import_message_failed': 'Importado fallido del diccionario.',
    'import_message_complete': 'Importado completo del diccionario.',
    'same_name_dictionary_found': 'Se ha encontrado un diccionario con el mismo nombre.',
    'import_file_extension_invalid':
    'Este formato espera archivos con las siguientes extensiones:'
        ' %extensions%',
    'field_label_sentence': 'Oración',
    'field_label_term': 'Término',
    'field_label_reading': 'Lectura',
    'field_label_meaning': 'Significado',
    'field_label_extra': 'Extra',
    'field_label_image': 'Imagen',
    'field_label_audio': 'Audio',
    'field_label_context': 'Contexto',
    'field_label_empty': 'Vacío',
    'field_hint_sentence': 'Oración o contexto escrito',
    'field_hint_term': 'El término de la tarjeta',
    'field_hint_reading': 'Lectura o pronunciación',
    'field_hint_meaning': 'Significado o definición de diccionario',
    'field_hint_extra': 'Cualquier información extra aquí',
    'field_hint_image': 'Introduzca aquí el término para buscar una imagen',
    'field_hint_audio': 'Introduzca aquí el término para buscar un audio del término',
    'field_hint_context': 'Información sobre el contexto del contenido multimedia',
    'field_hint_empty': 'Deja el campo en blanco',
    'model_to_map': 'Tipo de tarjeta a utilizar para el nuevo perfil',
    'mapping_name': 'Nombre del perfil',
    'mapping_name_hint': 'Nombre a asignar para el perfil',
    'error_profile_name': 'Nombre de perfil inválido',
    'error_profile_name_content':
    'Un perfil con este nombre ya existe o no es válido. No puede ser '
        'guardado.',
    'error_standard_profile_name': 'Nombre de perfil inválido',
    'error_standard_profile_name_content':
    'No se puede renombrar el perfil estándar.',
    'error_ankidroid_api': 'Error de AnkiDroid',
    'error_ankidroid_api_content':
    'Hubo un problema al comunicarse con Ankidroid.\n\nAsegúrese de que'
        ' el servicio de AnkiDroid esté activo y de que todos los permisos'
        ' relevantes de la misma hayan sido concedidos para continuar.',
      'info_standard_model': 'Modelo estándar añadido',
    'info_standard_model_content':
    '『jidoujisho Yuuna』 ha sido añadido a AnkiDroid como un nuevo tipo de tarjeta.'
        '\n\nConfiguraciones que hagan uso de un diferente tipo de tarjeta o campo pueden'
        ' ser utilizadas añadiendo un nuevo perfil.',
    'error_model_missing': 'No se encuentra el tipo de tarjeta',
    'error_model_missing_content':
    'The corresponding card type of the currently selected profile is'
        ' missing.\n\nThe standard profile has been selected in its place.',
    'error_model_changed': 'Card type changed',
    'error_model_changed_content':
    'The number of fields of the card type corresponding to the selected'
        ' profile has changed.\n\nThe fields of the currently selected'
        ' profile have been reset and will require reconfiguration.',
    'creator_exporting_as': 'Creando tarjeta con el perfil',
    'creator_exporting_as_fields_editing': 'Editando campos para el perfil',
    'creator_exporting_as_enhancements_editing':
    'Editando complementos para el perfil',
    'creator_export_card': 'Crear Tarjeta',
    'info_enhancements':
    'Los complementos permite automatizar la edición de algún campo antes de la creación de la tarjeta.'
        ' Seleccione una ranura a la derecha de un campo que permita el uso de un'
        ' complemento. Se pueden utilizar hasta cinco ranuras para cada'
        ' campo. El complemento en la ranura izquierda del campo será aplicado'
        ' automáticamente en la creación de una tarjeta instantánea o al lanzamiento del Creador de'
        ' Tarjetas.',
    'info_actions':
    'Quick actions allow for instant card creation and other automations'
        ' to be used on dictionary search results. Actions can be assigned'
        ' via the slots below. Up to six slots may be utilised.',
    'no_more_available_enhancements':
    'No hay complementos disponibles para este campo',
    'no_more_available_quick_actions': 'No more available quick actions',
    'assign_auto_enhancement': 'Assign Auto Enhancement',
    'assign_manual_enhancement': 'Assign Manual Enhancement',
    'remove_enhancement': 'Remover complemento',
    'copy_of_mapping': 'Copia de %mapping_name%',
    'enter_search_term': 'Ingrese un término a buscar...',
    'searching_for': 'Buscando para 『%searchTerm%』...',
    'no_search_results': 'No se encontraron resultados.',
    'edit_actions': 'Editar Diccionario de Acciones Rápidas',
    'remove_action': 'Remover Acción',
    'assign_action': 'Asignar Acción',
    'dictionary_import_tag': 'Imported from %dictionaryName%',
    'stash_added_single': '『%term%』has been added to the Stash.',
    'stash_added_multiple': 'Multiple items have been added to the Stash.',
    'stash_clear_single': '『%term%』has been removed from the Stash.',
    'stash_clear_title': 'Clear Stash',
    'stash_clear_description': 'All contents will be cleared. Are you sure?',
    'stash_placeholder': 'No items in the Stash',
    'stash_nothing_to_pop': 'No items to be popped from the Stash.',
    'no_sentences_found': 'No se encontraron oraciones',
    'failed_online_service': 'Failed to communicate with online service',
    'search_label_before': 'Resultado de busqueda ',
    'search_label_middle': 'de ',
    'search_label_after': 'encontrados para',
    'clear_dictionary_title': 'Limpiar Historial de Resultados del Diccionario',
    'clear_dictionary_description':
    'This will clear all dictionary results from history. Are you sure?',
    'clear_search_title': 'Limpiar Historial de Busqueda',
    'clear_search_description':
    'This will clear all search terms for this history. Are you sure?',
    'clear_creator_title': 'Limpiar Creador',
    'clear_creator_description': 'This will clear all fields. Are you sure?',
    'copied_to_clipboard': 'Copiado al portapapeles.',
    'no_text_to_segment': 'No text to segment.',
    'info_fields': 'Fields are pre-filled based on the term selected on instant'
        ' export or prior to opening the Card Creator. In order to include a'
        ' field for card export, it must be enabled below as well as mapped in'
        ' the current selected export profile. Enabled fields may also be'
        ' collapsed below in order to reduce clutter during editing. Use the'
        ' Clear button on the top-right of the Card Creator in order to wipe'
        ' these hidden fields quickly when manually editing a card.',
    'edit_fields': 'Editar y Reordenar Campos',
    'remove_field': 'Remover Campo',
    'add_field': 'Asignar Campo',
    'add_field_hint': 'Asigne un campo a esta fila',
    'no_more_available_fields': 'No hay más campos disponibles',
    'hidden_fields': 'Campos adicionales',
    'field_fallback_used':
    'The %field% field used %secondField% as its fallback search term.',
    'no_text_to_search': 'No hay texto para buscar.',
    'image_search_label_before': 'Seleccionando imagen ',
    'image_search_label_middle': 'de ',
    'image_search_label_after': 'encontradas para ',
    'preparing_instant_export': 'Preparando tarjeta para ser exportada...',
    'processing_in_progress': 'Preparando imágenes',
    'searching_in_progress': 'Buscando para ',
    'audio_unavailable': 'No fue posible encontrar un audio.',
    'no_audio_enhancements': 'No audio enhancements are assigned.',
    'card_exported': 'Tarjeta exportada a 『%deck%』.',
    'info_incognito_on':
    'Modo incógnito habilitado. Diccionario, contenido multimedia e historial de buscada no serán'
        ' guardados.',
    'info_incognito_off':
    'Modo incógnito deshabilitado. Diccionario, contenido multimedia e historial de busqueda serán'
        ' guardados.',
    'exit_media_title': 'Salir del contenido multimedia',
    'exit_media_description':
    'Esto le regresará al menú principal. ¿Está seguro?',
    'unimplemented_source': 'Unimplemented source',
    'clear_browser_title': 'Limpiar Historial del Navegador',
    'clear_browser_description':
    'This will clear all browsing data used in media sources that use web'
        ' content. Are you sure?',
    'ttu_no_books_added': 'No hay libros añadidos al lector\nッツ Ebook Reader',
    'local_media_directory_empty': 'Directory has no folders or video',
    'pick_video_file': 'Pick Video File',
    'navigate_up_one_directory_level': 'Navigate Up One Directory Level',
    'player_play': 'Reproducir',
    'player_pause': 'Pausa',
    'player_replay': 'Replay',
    'audio_subtitles': 'Audio/Subtitles',
    'player_option_shadowing': 'Modo Shadowing',
    'player_option_definition_focus': 'Modo Enfoque de Definición',
    'player_option_subtitle_focus': 'Modo Enfoque de Subtítulo',
    'player_option_listening_comprehension': 'Modo Comprensión Auditiva',
    'player_option_drag_to_select': 'Use Drag to Select Subtitle Selection',
    'player_option_tap_to_select': 'Use Tap to Select Subtitle Selection',
    'player_option_dictionary_menu': 'Select Active Dictionary Source',
    'player_option_cast_video': 'Cast to Display Device',
    'player_option_share_subtitle': 'Compartir Subtítulo Actual',
    'player_option_export': 'Crear Tarjeta a partir del Contexto',
    'player_option_audio': 'Audio',
    'player_option_subtitle': 'Subtítulo',
    'player_option_subtitle_external': 'Externo',
    'player_option_subtitle_none': 'Ninguno',
    'player_option_select_subtitle': 'Seleccionar Subtítulos',
    'player_option_select_audio': 'Seleccionar Audio',
    'player_option_text_filter': 'Use Regular Expression Filter',
    'player_option_blur_preferences': 'Preferencias de Difuminado',
    'player_option_blur_use': 'Usar Difuminado',
    'player_option_blur_radius': 'Radio de Difuminado',
    'player_option_blur_options': 'Ajustar Color de Difuminado y Desenfoque',
    'player_option_blur_reset': 'Reiniciar Tamaño de Difuminado y Posición',
    'player_align_subtitle_transcript': 'Ajustar Subtítulo con Transcripción',
    'player_option_subtitle_appearance': 'Apariencia y Sincronización de Subtítulos',
    'player_option_load_subtitles': 'Cargar Subtítulos Externos',
    'player_option_subtitle_delay': 'Retraso Subtítulos (delay)',
    'player_option_audio_allowance': 'Audio Allowance',
    'player_option_font_name': 'Nombre de la Fuente',
    'player_option_font_size': 'Tamaño de la Fuente',
    'player_option_regex_filter': 'Filtro por Expresión Regular',
    'player_subtitles_transcript_empty': 'Transcripción vacía.',
    'player_prepare_export': 'Preparando tarjeta...',
    'player_change_player_orientation': 'Cambiar Orientación del Reproductor',
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
    'paste': 'Pegar',
    'lyrics_title': 'Título',
    'lyrics_artist': 'Artista',
    'set_media': 'Set Media',
    'no_recordings_found': 'No se han encontrado grabaciones',
    'wrap_image_audio': 'Envolver campos de Imagen/Audio con Etiquetas',
    'application_legalese': 'Una herramienta con un paquete completo de características y funciones para aprender lenguajes a través de inmersión.\n\n'
        'Construido originalmente para la comunidad de aprendices del idioma japonés por Leo Rafael Orpilla. Logotipo por suzy y Aaron Marbella.'
        '\n\nJidoujisho es un software libre y de código abierto. Ver el '
        'repositorio del proyecto para obtener una lista detallada de otras licencias '
        'y avisos de atribución. ¿Le gusta la aplicación y desea apoyar su desarrollo? '
        'Puede proveernos sus comentarios, realizar una donación, reportar errores o '
        'contribuir con mejoras en GitHub.',
  };

}
