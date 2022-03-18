import 'package:flutter/widgets.dart';
import 'package:yuuna/creator.dart';

/// An entity that functionally mutates creator fields and
/// returns an output. An enhancement is given and assigned
/// a field at runtime in the initialisation step, and can
/// be assigned to a field enhancement slot. In the creator,
/// the user can then tap on the icon representing the
/// enhancement to execute its functionality.
abstract class Enhancement {
  /// Initialise this enhancement with the predetermined and hardset values.
  Enhancement({
    required this.uniqueKey,
    required this.label,
    required this.description,
    required this.field,
    required this.icon,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys.
  final String uniqueKey;

  /// Name of the enhancement that very shortly describes what it does.
  final String label;

  /// A longer description of what the enhancement can do, or details left
  /// by or regarding the developer.
  final String description;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  final IconData icon;

  /// Which field this enhancement is for.
  final Field field;

  /// Whether or not [initialise] has been called for this enhancement.
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
}
