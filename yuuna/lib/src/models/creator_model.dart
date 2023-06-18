import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for the card creator.
final creatorProvider = ChangeNotifierProvider<CreatorModel>((ref) {
  CreatorModel creatorModel = CreatorModel();
  creatorModel.initialise();

  return creatorModel;
});

/// A global [Provider] for separately handling instant export.
final instantExportProvider = ChangeNotifierProvider<CreatorModel>((ref) {
  CreatorModel creatorModel = CreatorModel();
  creatorModel.initialise();

  return creatorModel;
});

/// A scoped model for parameters that affect the card creator. RiverPod is
/// used for global state management across multiple layers, and is useful for
/// showing the creator and sharing code across the entire application.
class CreatorModel with ChangeNotifier {
  /// A map of [TextEditingController] for every creator field.
  Map<Field, TextEditingController> get controllersByField =>
      _controllersByField;
  late final Map<Field, TextEditingController> _controllersByField;
  late final Map<Field, ValueNotifier<bool>> _lockNotifiersByField;

  /// Scroll controller for the Creator page.
  final ScrollController scrollController = ScrollController();

  /// Prepare the [CreatorModel]'s final variables for use.
  void initialise() {
    _controllersByField = Map.unmodifiable(
      {for (Field field in globalFields) field: TextEditingController()},
    );
    _lockNotifiersByField = Map.unmodifiable(
      {for (Field field in globalFields) field: ValueNotifier<bool>(false)},
    );
  }

  /// Refresh state for the Card Creator.
  void refresh() {
    notifyListeners();
  }

  /// Clear all fields and current context.
  void clearAll({
    required bool overrideLocks,
    required String savedTags,
  }) {
    if (overrideLocks) {
      for (Field field in fieldsByKey.values) {
        getLockedNotifier(field).value = false;
      }
    }

    for (Field field in fieldsByKey.values) {
      clearField(
        field,
        savedTags: savedTags,
        notify: false,
        overrideLocks: overrideLocks,
      );
    }

    notifyListeners();
  }

  /// Set the sentence and cloze fields with a new selection.
  void setSentenceAndCloze(JidoujishoTextSelection selection) {
    getFieldController(SentenceField.instance).text = selection.text;
    getFieldController(ClozeBeforeField.instance).text = selection.textBefore;
    getFieldController(ClozeInsideField.instance).text = selection.textInside;
    getFieldController(ClozeAfterField.instance).text = selection.textAfter;
  }

  /// Append the appropriate fields for cloze compatibility.
  void appendSentenceAndCloze(String sentence) {
    getFieldController(SentenceField.instance).text += '\n\n$sentence';
    getFieldController(ClozeAfterField.instance).text += '\n\n$sentence';
    getFieldController(SentenceField.instance).text =
        getFieldController(SentenceField.instance).text.trim();
    getFieldController(ClozeAfterField.instance).text =
        getFieldController(SentenceField.instance).text.trim();
  }

  /// Get the [TextEditingController] for a particular field.
  TextEditingController getFieldController(Field field) {
    return _controllersByField[field]!;
  }

  /// Get the [ValueNotifier] for a particular field.
  ValueNotifier<bool> getLockedNotifier(Field field) {
    return _lockNotifiersByField[field]!;
  }

  /// Get the [TextEditingController] for a particular field.
  void toggleLock(Field field) {
    _lockNotifiersByField[field]!.value = !_lockNotifiersByField[field]!.value;
  }

  /// Clear a controller for a particular field.
  void clearField(
    Field field, {
    required String savedTags,
    bool overrideLocks = false,
    bool notify = true,
  }) {
    if (isLocked(field) && !overrideLocks) {
      return;
    } else {
      if (field is ImageExportField) {
        field.clearFieldState(creatorModel: this);
      } else if (field is AudioExportField) {
        field.clearFieldState(creatorModel: this);
      }

      /// Need to clear the audio/image seed when that's implemented as well.
      if (field is TagsField) {
        getFieldController(field).text = savedTags;
      } else {
        getFieldController(field).clear();
      }

      if (field is SentenceField) {
        getFieldController(SentenceField.instance).clear();
        getFieldController(ClozeBeforeField.instance).clear();
        getFieldController(ClozeInsideField.instance).clear();
        getFieldController(ClozeAfterField.instance).clear();
      }

      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Whether or not a field is locked and should not be cleared on export.
  bool isLocked(Field field) {
    return _lockNotifiersByField[field]!.value;
  }

  /// Clone the [CreatorFieldValues]'s contents into the model.
  void copyContext(CreatorFieldValues creatorFieldValues) {
    /// Also need to update the generated media using the seeds.

    for (MapEntry<Field, String> entry
        in creatorFieldValues.textValues.entries) {
      TextEditingController controller = getFieldController(entry.key);
      controller.text = entry.value;
    }
  }

  /// Get a snapshot of the relevant parameters of the model for card export.
  CreatorFieldValues getExportDetails(WidgetRef ref) {
    return CreatorFieldValues(
      textValues: controllersByField.map(
        (field, controller) => MapEntry(field, controller.text),
      ),
    );
  }
}
