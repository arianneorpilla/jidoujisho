import 'package:yuuna/creator.dart';

/// A special kind of field that has a special widget at the top of the creator.
/// For example, the audio field has a media player that can be controlled
/// based on its values.
abstract class MediaField extends FieldNua {
  /// Initialise this field with the predetermined and hardset values.
  MediaField({
    required super.uniqueKey,
    required super.label,
    required super.description,
    required super.icon,
  });
}
