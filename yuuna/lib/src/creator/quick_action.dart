import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// An entity that executes an action when selected on the upper-right of a
/// dictionary entry widget. An action is initialised at runtime in the
/// initialisation step, and can be assigned to a quick action slot.
/// When dictionary search results are displayed, the user can then tap on the
/// icon representing the action to execute its functionality for a certain
/// dictionary entry.
abstract class QuickAction {
  /// Initialise this action with the predetermined and hardset values.
  QuickAction({
    required this.uniqueKey,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys.
  final String uniqueKey;

  /// Name of the action that very shortly describes what it does.
  final String label;

  /// A longer description of what the action can do, or details left
  /// by or regarding the developer.
  final String description;

  /// An icon that will show the action if activated by the user in the
  /// quick menu.
  final IconData icon;

  /// Localisations for this action, where the key is a locale tag and
  /// the value is the [label] of the action. If the value for the current
  /// locale is non-null, it will be used instead of [label].
  final Map<String, String> labelLocalisation = const {};

  /// Localisations for this action, where the key is a locale tag and
  /// the value is the [description] of the action. If the value for the
  /// current locale is non-null, it will be used instead of [description].
  final Map<String, String> descriptionLocalisation = const {};

  /// Get the best localisation for the label of this action. If there
  /// is no localisation, the fallback is [label].
  String getLocalisedLabel(AppModel appModel) {
    return labelLocalisation[appModel.appLocale.toLanguageTag()] ?? label;
  }

  /// Get the best localisation for the description of this action. If
  /// there is no localisation, the fallback is [description].
  String getLocalisedDescription(AppModel appModel) {
    return descriptionLocalisation[appModel.appLocale.toLanguageTag()] ??
        description;
  }

  /// Whether or not [initialise] has been called for this action.
  bool _initialised = false;

  /// This function is run at startup or when changing languages. It is not
  /// called again if already run.
  Future<void> initialise() async {
    if (_initialised) {
      return;
    } else {
      await prepareResources();
      _initialised = true;
    }
  }

  /// If an enhancement requires resources to function, they can be prepared
  /// here and this function will be run once only at runtime during the
  /// initialisation step.
  Future<void> prepareResources() async {}

  /// Get a custom enabled color that this action should have for a certain
  /// condition in the application. By default, this is the foreground color.
  Color getIconColor({
    required BuildContext context,
    required AppModel appModel,
    required DictionaryTerm dictionaryTerm,
  }) {
    return Theme.of(context).appBarTheme.foregroundColor!;
  }

  /// Execute the functionality of this action.
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
  });
}
