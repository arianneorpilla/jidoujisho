// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_heading.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDictionaryHeadingCollection on Isar {
  IsarCollection<DictionaryHeading> get dictionaryHeadings => this.collection();
}

const DictionaryHeadingSchema = CollectionSchema(
  name: r'DictionaryHeading',
  id: 6765306005060595698,
  properties: {
    r'hashCode': PropertySchema(
      id: 0,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'reading': PropertySchema(
      id: 1,
      name: r'reading',
      type: IsarType.string,
    ),
    r'term': PropertySchema(
      id: 2,
      name: r'term',
      type: IsarType.string,
    ),
    r'termLength': PropertySchema(
      id: 3,
      name: r'termLength',
      type: IsarType.long,
    )
  },
  estimateSize: _dictionaryHeadingEstimateSize,
  serialize: _dictionaryHeadingSerialize,
  deserialize: _dictionaryHeadingDeserialize,
  deserializeProp: _dictionaryHeadingDeserializeProp,
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
          caseSensitive: false,
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
          caseSensitive: false,
        )
      ],
    ),
    r'termLength': IndexSchema(
      id: 3077462675055986876,
      name: r'termLength',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'termLength',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'entries': LinkSchema(
      id: -6287349905872287099,
      name: r'entries',
      target: r'DictionaryEntry',
      single: false,
      linkName: r'heading',
    ),
    r'pitches': LinkSchema(
      id: 1828666613806831240,
      name: r'pitches',
      target: r'DictionaryPitch',
      single: false,
      linkName: r'heading',
    ),
    r'tags': LinkSchema(
      id: 5886139192145298467,
      name: r'tags',
      target: r'DictionaryTag',
      single: false,
    ),
    r'frequencies': LinkSchema(
      id: 6135777493922970745,
      name: r'frequencies',
      target: r'DictionaryFrequency',
      single: false,
      linkName: r'heading',
    )
  },
  embeddedSchemas: {},
  getId: _dictionaryHeadingGetId,
  getLinks: _dictionaryHeadingGetLinks,
  attach: _dictionaryHeadingAttach,
  version: '3.1.0',
);

int _dictionaryHeadingEstimateSize(
  DictionaryHeading object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reading.length * 3;
  bytesCount += 3 + object.term.length * 3;
  return bytesCount;
}

void _dictionaryHeadingSerialize(
  DictionaryHeading object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hashCode);
  writer.writeString(offsets[1], object.reading);
  writer.writeString(offsets[2], object.term);
  writer.writeLong(offsets[3], object.termLength);
}

DictionaryHeading _dictionaryHeadingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryHeading(
    reading: reader.readStringOrNull(offsets[1]) ?? '',
    term: reader.readString(offsets[2]),
  );
  return object;
}

P _dictionaryHeadingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryHeadingGetId(DictionaryHeading object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dictionaryHeadingGetLinks(
    DictionaryHeading object) {
  return [object.entries, object.pitches, object.tags, object.frequencies];
}

void _dictionaryHeadingAttach(
    IsarCollection<dynamic> col, Id id, DictionaryHeading object) {
  object.entries
      .attach(col, col.isar.collection<DictionaryEntry>(), r'entries', id);
  object.pitches
      .attach(col, col.isar.collection<DictionaryPitch>(), r'pitches', id);
  object.tags.attach(col, col.isar.collection<DictionaryTag>(), r'tags', id);
  object.frequencies.attach(
      col, col.isar.collection<DictionaryFrequency>(), r'frequencies', id);
}

extension DictionaryHeadingQueryWhereSort
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QWhere> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhere> anyTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'term'),
      );
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhere> anyReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'reading'),
      );
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhere>
      anyTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'termLength'),
      );
    });
  }
}

extension DictionaryHeadingQueryWhere
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QWhereClause> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termEqualTo(String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'term',
        value: [term],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termBetween(
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termStartsWith(String TermPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'term',
        lower: [TermPrefix],
        upper: ['$TermPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'term',
        value: [''],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      readingEqualTo(String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reading',
        value: [reading],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      readingStartsWith(String ReadingPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'reading',
        lower: [ReadingPrefix],
        upper: ['$ReadingPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reading',
        value: [''],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termLengthEqualTo(int termLength) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termLength',
        value: [termLength],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termLengthNotEqualTo(int termLength) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength',
              lower: [],
              upper: [termLength],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength',
              lower: [termLength],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength',
              lower: [termLength],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength',
              lower: [],
              upper: [termLength],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termLengthGreaterThan(
    int termLength, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength',
        lower: [termLength],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termLengthLessThan(
    int termLength, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength',
        lower: [],
        upper: [termLength],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterWhereClause>
      termLengthBetween(
    int lowerTermLength,
    int upperTermLength, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength',
        lower: [lowerTermLength],
        includeLower: includeLower,
        upper: [upperTermLength],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DictionaryHeadingQueryFilter
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QFilterCondition> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      idLessThan(
    Id value, {
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reading',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      readingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
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

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'term',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      termLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DictionaryHeadingQueryObject
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QFilterCondition> {}

extension DictionaryHeadingQueryLinks
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QFilterCondition> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entries(FilterQuery<DictionaryEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'entries');
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      entriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'entries', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitches(FilterQuery<DictionaryPitch> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'pitches');
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      pitchesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'pitches', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tags(FilterQuery<DictionaryTag> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequencies(FilterQuery<DictionaryFrequency> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'frequencies');
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterFilterCondition>
      frequenciesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'frequencies', lower, includeLower, upper, includeUpper);
    });
  }
}

extension DictionaryHeadingQuerySortBy
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QSortBy> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      sortByTermLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.desc);
    });
  }
}

extension DictionaryHeadingQuerySortThenBy
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QSortThenBy> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.asc);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QAfterSortBy>
      thenByTermLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.desc);
    });
  }
}

extension DictionaryHeadingQueryWhereDistinct
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QDistinct> {
  QueryBuilder<DictionaryHeading, DictionaryHeading, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QDistinct>
      distinctByReading({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reading', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryHeading, DictionaryHeading, QDistinct>
      distinctByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termLength');
    });
  }
}

extension DictionaryHeadingQueryProperty
    on QueryBuilder<DictionaryHeading, DictionaryHeading, QQueryProperty> {
  QueryBuilder<DictionaryHeading, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryHeading, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DictionaryHeading, String, QQueryOperations> readingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reading');
    });
  }

  QueryBuilder<DictionaryHeading, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }

  QueryBuilder<DictionaryHeading, int, QQueryOperations> termLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termLength');
    });
  }
}
