import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// A special kind of field that has a special widget at the top of the creator.
/// For example, the audio field has a media player that can be controlled
/// based on its values.
abstract class ImageExportField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  ImageExportField({
    required super.uniqueKey,
    required super.label,
    required super.description,
    required super.icon,
  });

  /// The image file selected for export.
  NetworkToFileImage? get exportFile => _exportFile;
  NetworkToFileImage? _exportFile;

  /// The images shown in a carousel for selection.
  List<NetworkToFileImage>? get currentImageSuggestions => _imageSuggestions;
  List<NetworkToFileImage>? _imageSuggestions;

  /// Selected index for [currentImageSuggestions].
  int? get selectedIndex => _indexNotifier.value;

  /// Notifier for updating the count.
  ValueNotifier<int> get indexNotifier => _indexNotifier;
  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);

  /// The current search term for the image.
  String? get currentSearchTerm => _currentSearchTerm;
  String? _currentSearchTerm;

  /// Whether or not searching is in progress.
  bool get isSearching => _isSearching;
  bool _isSearching = false;

  /// Whether or not the current media cannot be overridden by an auto enhancement.
  bool _autoCannotOverride = false;

  /// Whether or not to show the top widget.
  bool get showWidget => currentImageSuggestions != null && exportFile != null;

  /// Clears this field's data. The state refresh afterwards is not performed
  /// here and should be performed by the invocation of the clear field button.
  void clearFieldState({
    required CreatorModel creatorModel,
  }) {
    _exportFile = null;
    _imageSuggestions = null;
    _indexNotifier.value = 0;
    _currentSearchTerm = null;
    _isSearching = false;
    _autoCannotOverride = false;

    creatorModel.refresh();
  }

  /// Perform a function that generates a list of images and attempt a search
  /// with a given search term.
  Future<void> setImages({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required Future<List<NetworkToFileImage>> Function() generateImages,
    required EnhancementTriggerCause cause,
    required bool newAutoCannotOverride,
    String? searchTerm,
  }) async {
    if (_autoCannotOverride && cause == EnhancementTriggerCause.auto) {
      return;
    }

    /// Show loading state.
    setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: true,
        searchTerm: searchTerm);
    try {
      List<NetworkToFileImage> images = await generateImages();

      setSearchSuggestions(
        appModel: appModel,
        creatorModel: creatorModel,
        images: images,
        searchTermUsed: searchTerm,
      );
      _autoCannotOverride = newAutoCannotOverride;
    } finally {
      /// Finish loading state.
      setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: false,
        searchTerm: searchTerm,
      );
    }
  }

  /// Flag for showing the loading state of the picker.
  void setSearching({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required bool isSearching,
    String? searchTerm,
  }) {
    _isSearching = isSearching;
    _currentSearchTerm = searchTerm;
    creatorModel.refresh();
  }

  /// Takes a non-empty new list of images to set as the new image suggestions.
  /// By default, this replaces the [exportFile] with the index set in
  /// [newSelectedSuggestionIndex].
  void setSearchSuggestions({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required List<NetworkToFileImage> images,
    String? searchTermUsed,
    int newSelectedSuggestionIndex = 0,
  }) {
    creatorModel.getFieldController(this).clear();
    if (images.isEmpty ||
        newSelectedSuggestionIndex < 0 &&
            newSelectedSuggestionIndex >= images.length) {
      clearFieldState(
        creatorModel: creatorModel,
      );
    }

    _imageSuggestions = images;
    _exportFile = images.first;
    _indexNotifier.value = newSelectedSuggestionIndex;
    _currentSearchTerm = searchTermUsed;
    _isSearching = false;
    creatorModel.refresh();
  }

  /// Change the index of the selected search suggestion and update the state
  /// of the image picker.
  void setSelectedSearchSuggestion({
    required int index,
  }) {
    _exportFile = _imageSuggestions![index];
    _indexNotifier.value = index;
  }

  /// Fetches the search term to use from the [CreatorModel]. If the field
  /// controller is empty, use a fallback and inform the user that a fallback
  /// has been used.
  String? getSearchTermWithFallback({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required List<Field> fallbackSearchTerms,
  }) {
    String fallbackMessage = appModel.translate('field_fallback_used');
    String noTextToSearch = appModel.translate('no_text_to_search');

    String searchTerm = creatorModel.getFieldController(this).text.trim();
    if (searchTerm.isNotEmpty) {
      return searchTerm;
    } else {
      for (Field fallbackField in fallbackSearchTerms) {
        String fallbackTerm =
            creatorModel.getFieldController(fallbackField).text.trim();
        if (fallbackTerm.isNotEmpty) {
          Fluttertoast.showToast(
            msg: fallbackMessage
                .replaceAll('%field%', getLocalisedLabel(appModel))
                .replaceAll(
                  '%secondField%',
                  fallbackField.getLocalisedLabel(appModel),
                ),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          return fallbackTerm;
        }
      }
    }

    Fluttertoast.showToast(
      msg: noTextToSearch,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    return null;
  }

  /// Media fields are special and have a [Widget] that is shown at the top of
  /// the Card Creator.
  Widget buildTopWidget({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required Orientation orientation,
  });
}
