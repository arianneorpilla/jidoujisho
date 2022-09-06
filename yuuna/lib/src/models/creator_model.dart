import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

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

  /// Prepare the [CreatorModel]'s final variables for use.
  void initialise() {
    _controllersByField = Map.unmodifiable(
      {for (Field field in globalFields) field: TextEditingController()},
    );
  }

  /// Refresh state for the Card Creator.
  void refresh() {
    notifyListeners();
  }

  /// Clear all fields and current context.
  void clearAll() {
    for (Field field in fieldsByKey.values) {
      clearField(field, notify: false);
    }

    notifyListeners();
  }

  /// Get the [TextEditingController] for a particular field.
  TextEditingController getFieldController(Field field) {
    return _controllersByField[field]!;
  }

  /// Clear a controller for a particular field.
  void clearField(Field field, {bool notify = true}) {
    if (field is ImageExportField) {
      field.clearFieldState(creatorModel: this);
    } else if (field is AudioExportField) {
      field.clearFieldState(creatorModel: this);
    }

    /// Need to clear the audio/image seed when that's implemented as well.
    getFieldController(field).clear();
    if (notify) {
      notifyListeners();
    }
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
