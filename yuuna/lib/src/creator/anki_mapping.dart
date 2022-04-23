import 'package:yuuna/creator.dart';

/// A user-generated mapping to allow customisation of the fields exported from
/// the application. A mapping is bound to a [model], which must have a length
/// of fields equal or more than the length of [fields].
class AnkiMapping {
  /// Initialise a model mapping with the given parameters.
  AnkiMapping({
    required this.label,
    required this.model,
    required this.fields,
    required this.tags,
  });

  /// Get the default mapping that is included with the application at first
  /// startup.
  factory AnkiMapping.defaultMapping() {
    return AnkiMapping(
      label: 'jidoujisho Yuuna Default',
      model: 'jidoujisho Yuuna',
      fields: [
        Field.sentence,
        Field.word,
        Field.reading,
        Field.meaning,
        Field.extra,
        Field.image,
        Field.audio,
        Field.context,
      ],
      tags: ['jidoujisho Yuuna'],
    );
  }

  /// The name of this mapping.
  final String label;

  /// The name of the model to use when exporting with this mapping.
  final String model;

  /// The ordering of the fields to use when exporting with this mapping. The
  /// length of this must be less or equal the length of the model being used
  /// for export to work correctly.
  final List<Field> fields;

  /// A collection of tags to always include when exporting with this mapping.
  final List<String> tags;
}
