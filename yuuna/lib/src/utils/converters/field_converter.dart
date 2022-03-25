import 'package:isar/isar.dart';
import 'package:yuuna/creator.dart';

/// A type converter for a [Field] enum to its index for database purposes.
class FieldConverter extends TypeConverter<Field, int> {
  /// Initialise this converter.
  const FieldConverter(); // Converters need to have an empty const constructor

  @override
  Field fromIsar(int object) {
    return Field.values[object];
  }

  @override
  int toIsar(Field object) {
    return object.index;
  }
}
