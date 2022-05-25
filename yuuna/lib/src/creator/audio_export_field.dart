import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// A special kind of field that has a special widget at the top of the creator.
/// For example, the audio field has a media player that can be controlled
/// based on its values.
abstract class AudioExportField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  AudioExportField({
    required super.uniqueKey,
    required super.label,
    required super.description,
    required super.icon,
  });

  /// The image file selected for export.
  File? get exportFile => _exportFile;
  File? _exportFile;

  /// The current search term for the image.
  String? get currentSearchTerm => _currentSearchTerm;
  String? _currentSearchTerm;

  /// Whether or not searching is in progress
  bool get isSearching => _isSearching;
  bool _isSearching = false;

  /// Whether or not to show the top widget.
  bool get showWidget => exportFile != null;

  /// Clears this field's data. The state refresh afterwards is not performed
  /// here and should be performed by the invocation of the clear field button.
  void clearFieldState({
    required CreatorModel creatorModel,
  }) {
    _exportFile = null;
    _currentSearchTerm = null;
    creatorModel.refresh();
  }

  /// Flag for showing the loading state of the picker.
  void setSearching({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required bool isSearching,
    required String searchTerm,
  }) {
    _isSearching = isSearching;
    _currentSearchTerm = searchTerm;
    creatorModel.refresh();
  }

  /// Takes a new file as the audio file.
  void setAudioFile({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required File file,
    String? searchTermUsed,
  }) {
    creatorModel.getFieldController(this).clear();
    _exportFile = file;
    _currentSearchTerm = searchTermUsed;
    _isSearching = false;
    creatorModel.refresh();
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
  });
}
