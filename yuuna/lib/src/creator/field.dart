import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// An entity that represents a broad characteristic of an item being
/// exported that is distinguishable enough to deserve its own core
/// functionality and family of user extensions. For example, a field
/// could handle exclusively images, or dictionary definitions.
abstract class Field {
  /// Initialise this field with the predetermined and hardset values.
  Field({
    required this.uniqueKey,
    required this.label,
    required this.description,
    required this.icon,
    this.multiline = true,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys.
  final String uniqueKey;

  /// Name of the field that very shortly describes what it does.
  final String label;

  /// A longer description of the field that will be used as its placeholder
  /// message.
  final String description;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  final IconData icon;

  /// Controls whether this field is multiline or not.
  final bool multiline;

  /// Depends on whether this is [multiline] or not.
  int? get maxLines => multiline ? null : 1;

  /// Localisations for this enhancement, where the key is a locale tag and
  /// the value is the [label] of the enhancement. If the value for the current
  /// locale is non-null, it will be used instead of [label].
  final Map<String, String> labelLocalisation = const {};

  /// Localisations for this enhancement, where the key is a locale tag and
  /// the value is the [description] of the enhancement. If the value for the
  /// current locale is non-null, it will be used instead of [description].
  final Map<String, String> descriptionLocalisation = const {};

  /// Get the best localisation for the label of this enhancement. If there
  /// is no localisation, the fallback is [label].
  String getLocalisedLabel(AppModel appModel) {
    return labelLocalisation[appModel.appLocale.toLanguageTag()] ?? label;
  }

  /// Get the best localisation for the description of this enhancement. If
  /// there is no localisation, the fallback is [description].
  String getLocalisedDescription(AppModel appModel) {
    return descriptionLocalisation[appModel.appLocale.toLanguageTag()] ??
        description;
  }

  /// Return the value that this field must have upon opening the Card Creator.
  /// For example, the Sentence field must provide the current context or the
  /// sentence that is stored in the app state, while the Image field may be
  /// used to return a snapshot of the current app context.
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    throw UnimplementedError(
      'Field must generate a value upon opening creator',
    );
  }
}
