import 'package:chisa/anki/anki_export_params.dart';
import 'package:flutter/material.dart';

abstract class AnkiExportEnhancement {
  AnkiExportEnhancement(
      {required this.enhancementName,
      required this.enhancementDescription,
      required this.enhancementIcon});

  /// Name of the enhancement that very shortly describes what it does.
  late String enhancementName;

  /// A longer description of what the enhancement can do, or details left
  /// by or regarding the developer.
  late String enhancementDescription;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  late IconData enhancementIcon;

  /// Given an already defined set of parameters, enhance them and apply
  /// changes. These will be used to override a user's export parameters.
  AnkiExportParams enhanceParams();
}
