// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionaryEntryCollection on Isar {
  IsarCollection<DictionaryEntry> get dictionaryEntrys => this.collection();
}

const DictionaryEntrySchema = CollectionSchema(
  name: r'DictionaryEntry',
  id: 433168435156867289,
  properties: {
    r'dictionaryName': PropertySchema(
      id: 0,
      name: r'dictionaryName',
      type: IsarType.string,
    ),
    r'extra': PropertySchema(
      id: 1,
      name: r'extra',
      type: IsarType.string,
    ),
    r'meaningTags': PropertySchema(
      id: 2,
      name: r'meaningTags',
      type: IsarType.stringList,
    ),
    r'meanings': PropertySchema(
      id: 3,
      name: r'meanings',
      type: IsarType.stringList,
    ),
    r'popularity': PropertySchema(
      id: 4,
      name: r'popularity',
      type: IsarType.double,
    ),
    r'reading': PropertySchema(
      id: 5,
      name: r'reading',
      type: IsarType.string,
    ),
    r'term': PropertySchema(
      id: 6,
      name: r'term',
      type: IsarType.string,
    ),
    r'termTags': PropertySchema(
      id: 7,
      name: r'termTags',
      type: IsarType.stringList,
    )
  },
  estimateSize: _dictionaryEntryEstimateSize,
  serialize: _dictionaryEntrySerialize,
  deserialize: _dictionaryEntryDeserialize,
  deserializeProp: _dictionaryEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'term': IndexSchema(
      id: 5114652110782333408,
      name: r'term',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'term',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'termComposite': IndexSchema(
      id: -6405999970609981681,
      name: r'termComposite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'term',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'popularity',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'dictionaryName': IndexSchema(
      id: 6941277455010515489,
      name: r'dictionaryName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dictionaryName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'reading': IndexSchema(
      id: -8872607090340677149,
      name: r'reading',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reading',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'readingComposite': IndexSchema(
      id: 1103315040918879110,
      name: r'readingComposite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reading',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'popularity',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'popularity': IndexSchema(
      id: -817613675826504681,
      name: r'popularity',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'popularity',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dictionaryEntryGetId,
  getLinks: _dictionaryEntryGetLinks,
  attach: _dictionaryEntryAttach,
  version: '3.0.6-dev.0',
);

int _dictionaryEntryEstimateSize(
  DictionaryEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dictionaryName.length * 3;
  {
    final value = object.extra;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.meaningTags.length * 3;
  {
    for (var i = 0; i < object.meaningTags.length; i++) {
      final value = object.meaningTags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.meanings.length * 3;
  {
    for (var i = 0; i < object.meanings.length; i++) {
      final value = object.meanings[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.reading.length * 3;
  bytesCount += 3 + object.term.length * 3;
  bytesCount += 3 + object.termTags.length * 3;
  {
    for (var i = 0; i < object.termTags.length; i++) {
      final value = object.termTags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _dictionaryEntrySerialize(
  DictionaryEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dictionaryName);
  writer.writeString(offsets[1], object.extra);
  writer.writeStringList(offsets[2], object.meaningTags);
  writer.writeStringList(offsets[3], object.meanings);
  writer.writeDouble(offsets[4], object.popularity);
  writer.writeString(offsets[5], object.reading);
  writer.writeString(offsets[6], object.term);
  writer.writeStringList(offsets[7], object.termTags);
}

DictionaryEntry _dictionaryEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryEntry(
    dictionaryName: reader.readString(offsets[0]),
    extra: reader.readStringOrNull(offsets[1]),
    id: id,
    meaningTags: reader.readStringList(offsets[2]) ?? const [],
    meanings: reader.readStringList(offsets[3]) ?? [],
    popularity: reader.readDoubleOrNull(offsets[4]),
    reading: reader.readStringOrNull(offsets[5]) ?? '',
    term: reader.readString(offsets[6]),
    termTags: reader.readStringList(offsets[7]) ?? const [],
  );
  return object;
}

P _dictionaryEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? const []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryEntryGetId(DictionaryEntry object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryEntryGetLinks(DictionaryEntry object) {
  return [];
}

void _dictionaryEntryAttach(
    IsarCollection<dynamic> col, Id id, DictionaryEntry object) {
  object.id = id;
}

extension DictionaryEntryQueryWhereSort
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QWhere> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'term'),
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'reading'),
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'popularity'),
      );
    });
  }
}

extension DictionaryEntryQueryWhere
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QWhereClause> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> termEqualTo(
      String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'term',
        value: [term],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termNotEqualTo(String term) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'term',
              lower: [],
              upper: [term],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'term',
              lower: [term],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'term',
              lower: [term],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'term',
              lower: [],
              upper: [term],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termGreaterThan(
    String term, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'term',
        lower: [term],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termLessThan(
    String term, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'term',
        lower: [],
        upper: [term],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> termBetween(
    String lowerTerm,
    String upperTerm, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'term',
        lower: [lowerTerm],
        includeLower: includeLower,
        upper: [upperTerm],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termStartsWith(String TermPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'term',
        lower: [TermPrefix],
        upper: ['$TermPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'term',
        value: [''],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'term',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'term',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'term',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'term',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToAnyPopularity(String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termComposite',
        value: [term],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termNotEqualToAnyPopularity(String term) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [],
              upper: [term],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [],
              upper: [term],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityIsNull(String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termComposite',
        value: [term, null],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityIsNotNull(String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termComposite',
        lower: [term, null],
        includeLower: false,
        upper: [
          term,
        ],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termPopularityEqualTo(String term, double? popularity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termComposite',
        value: [term, popularity],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityNotEqualTo(String term, double? popularity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term],
              upper: [term, popularity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term, popularity],
              includeLower: false,
              upper: [term],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term, popularity],
              includeLower: false,
              upper: [term],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termComposite',
              lower: [term],
              upper: [term, popularity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityGreaterThan(
    String term,
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termComposite',
        lower: [term, popularity],
        includeLower: include,
        upper: [term],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityLessThan(
    String term,
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termComposite',
        lower: [term],
        upper: [term, popularity],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termEqualToPopularityBetween(
    String term,
    double? lowerPopularity,
    double? upperPopularity, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termComposite',
        lower: [term, lowerPopularity],
        includeLower: includeLower,
        upper: [term, upperPopularity],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      dictionaryNameEqualTo(String dictionaryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dictionaryName',
        value: [dictionaryName],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      dictionaryNameNotEqualTo(String dictionaryName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [],
              upper: [dictionaryName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [dictionaryName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [dictionaryName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [],
              upper: [dictionaryName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualTo(String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reading',
        value: [reading],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingNotEqualTo(String reading) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reading',
              lower: [],
              upper: [reading],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reading',
              lower: [reading],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reading',
              lower: [reading],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reading',
              lower: [],
              upper: [reading],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingGreaterThan(
    String reading, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reading',
        lower: [reading],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLessThan(
    String reading, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reading',
        lower: [],
        upper: [reading],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingBetween(
    String lowerReading,
    String upperReading, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reading',
        lower: [lowerReading],
        includeLower: includeLower,
        upper: [upperReading],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingStartsWith(String ReadingPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reading',
        lower: [ReadingPrefix],
        upper: ['$ReadingPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reading',
        value: [''],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'reading',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'reading',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'reading',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'reading',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToAnyPopularity(String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'readingComposite',
        value: [reading],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingNotEqualToAnyPopularity(String reading) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [],
              upper: [reading],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [],
              upper: [reading],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityIsNull(String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'readingComposite',
        value: [reading, null],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityIsNotNull(String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'readingComposite',
        lower: [reading, null],
        includeLower: false,
        upper: [
          reading,
        ],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingPopularityEqualTo(String reading, double? popularity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'readingComposite',
        value: [reading, popularity],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityNotEqualTo(String reading, double? popularity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading],
              upper: [reading, popularity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading, popularity],
              includeLower: false,
              upper: [reading],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading, popularity],
              includeLower: false,
              upper: [reading],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'readingComposite',
              lower: [reading],
              upper: [reading, popularity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityGreaterThan(
    String reading,
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'readingComposite',
        lower: [reading, popularity],
        includeLower: include,
        upper: [reading],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityLessThan(
    String reading,
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'readingComposite',
        lower: [reading],
        upper: [reading, popularity],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualToPopularityBetween(
    String reading,
    double? lowerPopularity,
    double? upperPopularity, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'readingComposite',
        lower: [reading, lowerPopularity],
        includeLower: includeLower,
        upper: [reading, upperPopularity],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'popularity',
        value: [null],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'popularity',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityEqualTo(double? popularity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'popularity',
        value: [popularity],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityNotEqualTo(double? popularity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'popularity',
              lower: [],
              upper: [popularity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'popularity',
              lower: [popularity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'popularity',
              lower: [popularity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'popularity',
              lower: [],
              upper: [popularity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityGreaterThan(
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'popularity',
        lower: [popularity],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityLessThan(
    double? popularity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'popularity',
        lower: [],
        upper: [popularity],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityBetween(
    double? lowerPopularity,
    double? upperPopularity, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'popularity',
        lower: [lowerPopularity],
        includeLower: includeLower,
        upper: [upperPopularity],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DictionaryEntryQueryFilter
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QFilterCondition> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dictionaryName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dictionaryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extra',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extra',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extra',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extra',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extra',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extra',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extra',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'meaningTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'meaningTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'meaningTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meaningTags',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'meaningTags',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meaningTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'meanings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'meanings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'meanings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meanings',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'meanings',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'popularity',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'popularity',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'popularity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'popularity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'popularity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'popularity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reading',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reading',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'term',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'term',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termTags',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termTags',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'termTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension DictionaryEntryQueryObject
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QFilterCondition> {}

extension DictionaryEntryQueryLinks
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QFilterCondition> {}

extension DictionaryEntryQuerySortBy
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QSortBy> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByExtra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByExtraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByPopularityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }
}

extension DictionaryEntryQuerySortThenBy
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QSortThenBy> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByExtra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByExtraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extra', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByPopularityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }
}

extension DictionaryEntryQueryWhereDistinct
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByDictionaryName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dictionaryName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByExtra(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extra', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByMeaningTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meaningTags');
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByMeanings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meanings');
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'popularity');
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByReading(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reading', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByTermTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termTags');
    });
  }
}

extension DictionaryEntryQueryProperty
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QQueryProperty> {
  QueryBuilder<DictionaryEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryEntry, String, QQueryOperations>
      dictionaryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dictionaryName');
    });
  }

  QueryBuilder<DictionaryEntry, String?, QQueryOperations> extraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extra');
    });
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      meaningTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meaningTags');
    });
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      meaningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meanings');
    });
  }

  QueryBuilder<DictionaryEntry, double?, QQueryOperations>
      popularityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'popularity');
    });
  }

  QueryBuilder<DictionaryEntry, String, QQueryOperations> readingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reading');
    });
  }

  QueryBuilder<DictionaryEntry, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      termTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termTags');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    DictionaryEntry(
      term: json['term'] as String,
      dictionaryName: json['dictionaryName'] as String,
      meanings:
          (json['meanings'] as List<dynamic>).map((e) => e as String).toList(),
      reading: json['reading'] as String? ?? '',
      id: json['id'] as int?,
      extra: json['extra'] as String?,
      meaningTags: (json['meaningTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      termTags: (json['termTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DictionaryEntryToJson(DictionaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'dictionaryName': instance.dictionaryName,
      'reading': instance.reading,
      'meanings': instance.meanings,
      'extra': instance.extra,
      'meaningTags': instance.meaningTags,
      'termTags': instance.termTags,
      'popularity': instance.popularity,
    };
