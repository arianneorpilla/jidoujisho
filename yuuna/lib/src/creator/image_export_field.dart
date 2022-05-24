import 'package:yuuna/creator.dart';

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
}
