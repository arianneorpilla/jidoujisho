import 'package:isar/isar.dart';
import 'package:yuuna/creator.dart';

part 'anki_mapping.g.dart';

/// A user-generated mapping to allow customisation of the fields exported from
/// the application. A mapping is bound to a [model], which must have a length
/// of fields equal or more than the length of [getFields].
@Collection()
class AnkiMapping {
  /// Initialise a model mapping with the given parameters.
  AnkiMapping({
    required this.label,
    required this.model,
    required this.fieldIndexes,
    required this.order,
    required this.tags,
    this.id,
  });

  /// Get the default mapping that is included with the application at first
  /// startup.
  factory AnkiMapping.defaultMapping(int order) {
    return AnkiMapping(
      label: standardProfileName,
      model: standardModelName,
      fieldIndexes: [
        Field.sentence.index,
        Field.word.index,
        Field.reading.index,
        Field.meaning.index,
        Field.extra.index,
        Field.image.index,
        Field.audio.index,
        Field.context.index,
      ],
      order: order,
      tags: [standardModelName],
    );
  }

  /// The default mapping name which cannot be deleted or reused.
  static String standardModelName = 'jidoujisho Yuuna';

  /// The default mapping name which cannot be deleted or reused.
  static String standardProfileName = 'Standard';

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;

  /// The name of this mapping.
  @Index(unique: true)
  final String label;

  /// The name of the model to use when exporting with this mapping.
  final String model;

  /// Returns the index equivalents of the [Field] in [getFields] that can be
  /// stored in a database.
  List<int?> fieldIndexes;

  /// A collection of tags to always include when exporting with this mapping.
  final List<String> tags;

  /// The order of this dictionary in terms of user sorting, relative to other
  /// dictionaries.
  @Index(unique: true)
  int order;

  /// The ordering of the fields to use when exporting with this mapping. The
  /// length of this must be less or equal the length of the model being used
  /// for export to work correctly.
  List<Field?> getFields() {
    List<Field?> fields = [];

    for (int? index in fieldIndexes) {
      if (index == null) {
        fields.add(null);
      } else {
        Field field = Field.values.elementAt(index);
        fields.add(field);
      }
    }

    return fields;
  }

  /// Creates a deep copy of this mapping but with the given variables replaced
  /// with the new values.
  AnkiMapping copyWith({
    String? label,
    String? model,
    List<int?>? fieldIndexes,
    List<String>? tags,
    int? order,
    int? id,
  }) {
    return AnkiMapping(
      label: label ?? this.label,
      model: model ?? this.model,
      fieldIndexes: fieldIndexes ?? this.fieldIndexes,
      tags: tags ?? this.tags,
      order: order ?? this.order,
      id: id ?? this.id,
    );
  }
}
