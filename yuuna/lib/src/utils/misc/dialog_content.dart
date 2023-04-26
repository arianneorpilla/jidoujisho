import 'package:json_annotation/json_annotation.dart';

part 'dialog_content.g.dart';

@JsonSerializable()

/// Text information to show in a dialog.
class DialogContent {
  /// Initialise this entity.
  const DialogContent({
    required this.title,
    required this.content,
  });

  /// Create an instance of this class from a serialized format.
  factory DialogContent.fromJson(Map<String, dynamic> json) =>
      _$DialogContentFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$DialogContentToJson(this);

  /// Title text.
  final String title;

  /// Content text.
  final String content;
}
