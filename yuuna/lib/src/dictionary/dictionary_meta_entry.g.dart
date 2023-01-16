// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_meta_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionaryMetaEntryCollection on Isar {
  IsarCollection<DictionaryMetaEntry> get dictionaryMetaEntrys =>
      this.collection();
}

const DictionaryMetaEntrySchema = CollectionSchema(
  name: r'DictionaryMetaEntry',
  id: -8311599280276678509,
  properties: {
    r'dictionaryName': PropertySchema(
      id: 0,
      name: r'dictionaryName',
      type: IsarType.string,
    ),
    r'frequencyIsar': PropertySchema(
      id: 1,
      name: r'frequencyIsar',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 2,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'pitchesIsar': PropertySchema(
      id: 3,
      name: r'pitchesIsar',
      type: IsarType.string,
    ),
    r'term': PropertySchema(
      id: 4,
      name: r'term',
      type: IsarType.string,
    ),
    r'termLength': PropertySchema(
      id: 5,
      name: r'termLength',
      type: IsarType.long,
    )
  },
  estimateSize: _dictionaryMetaEntryEstimateSize,
  serialize: _dictionaryMetaEntrySerialize,
  deserialize: _dictionaryMetaEntryDeserialize,
  deserializeProp: _dictionaryMetaEntryDeserializeProp,
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
          type: IndexType.hash,
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
    r'termLength_term': IndexSchema(
      id: -7107314842678945486,
      name: r'termLength_term',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'termLength',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'term',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dictionaryMetaEntryGetId,
  getLinks: _dictionaryMetaEntryGetLinks,
  attach: _dictionaryMetaEntryAttach,
  version: '3.0.6-dev.0',
);

int _dictionaryMetaEntryEstimateSize(
  DictionaryMetaEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dictionaryName.length * 3;
  {
    final value = object.frequencyIsar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pitchesIsar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.term.length * 3;
  return bytesCount;
}

void _dictionaryMetaEntrySerialize(
  DictionaryMetaEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dictionaryName);
  writer.writeString(offsets[1], object.frequencyIsar);
  writer.writeLong(offsets[2], object.hashCode);
  writer.writeString(offsets[3], object.pitchesIsar);
  writer.writeString(offsets[4], object.term);
  writer.writeLong(offsets[5], object.termLength);
}

DictionaryMetaEntry _dictionaryMetaEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryMetaEntry(
    dictionaryName: reader.readString(offsets[0]),
    id: id,
    term: reader.readString(offsets[4]),
  );
  object.frequencyIsar = reader.readStringOrNull(offsets[1]);
  object.pitchesIsar = reader.readStringOrNull(offsets[3]);
  return object;
}

P _dictionaryMetaEntryDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryMetaEntryGetId(DictionaryMetaEntry object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryMetaEntryGetLinks(
    DictionaryMetaEntry object) {
  return [];
}

void _dictionaryMetaEntryAttach(
    IsarCollection<dynamic> col, Id id, DictionaryMetaEntry object) {
  object.id = id;
}

extension DictionaryMetaEntryQueryWhereSort
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QWhere> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionaryMetaEntryQueryWhere
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QWhereClause> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termEqualTo(String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'term',
        value: [term],
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      dictionaryNameEqualTo(String dictionaryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dictionaryName',
        value: [dictionaryName],
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthEqualToAnyTerm(int termLength) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termLength_term',
        value: [termLength],
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthNotEqualToAnyTerm(int termLength) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [],
              upper: [termLength],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [],
              upper: [termLength],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthGreaterThanAnyTerm(
    int termLength, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength_term',
        lower: [termLength],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthLessThanAnyTerm(
    int termLength, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength_term',
        lower: [],
        upper: [termLength],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthBetweenAnyTerm(
    int lowerTermLength,
    int upperTermLength, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'termLength_term',
        lower: [lowerTermLength],
        includeLower: includeLower,
        upper: [upperTermLength],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthTermEqualTo(int termLength, String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'termLength_term',
        value: [termLength, term],
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthEqualToTermNotEqualTo(int termLength, String term) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength],
              upper: [termLength, term],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength, term],
              includeLower: false,
              upper: [termLength],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength, term],
              includeLower: false,
              upper: [termLength],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'termLength_term',
              lower: [termLength],
              upper: [termLength, term],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DictionaryMetaEntryQueryFilter on QueryBuilder<DictionaryMetaEntry,
    DictionaryMetaEntry, QFilterCondition> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dictionaryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'frequencyIsar',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'frequencyIsar',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencyIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequencyIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequencyIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequencyIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pitchesIsar',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pitchesIsar',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pitchesIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pitchesIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pitchesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pitchesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'term',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

extension DictionaryMetaEntryQueryObject on QueryBuilder<DictionaryMetaEntry,
    DictionaryMetaEntry, QFilterCondition> {}

extension DictionaryMetaEntryQueryLinks on QueryBuilder<DictionaryMetaEntry,
    DictionaryMetaEntry, QFilterCondition> {}

extension DictionaryMetaEntryQuerySortBy
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QSortBy> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByFrequencyIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByFrequencyIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByPitchesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByPitchesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.desc);
    });
  }
}

extension DictionaryMetaEntryQuerySortThenBy
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QSortThenBy> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByFrequencyIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByFrequencyIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByPitchesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByPitchesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.asc);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termLength', Sort.desc);
    });
  }
}

extension DictionaryMetaEntryQueryWhereDistinct
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByDictionaryName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dictionaryName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByFrequencyIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencyIsar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByPitchesIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pitchesIsar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByTerm({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByTermLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termLength');
    });
  }
}

extension DictionaryMetaEntryQueryProperty
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QQueryProperty> {
  QueryBuilder<DictionaryMetaEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations>
      dictionaryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dictionaryName');
    });
  }

  QueryBuilder<DictionaryMetaEntry, String?, QQueryOperations>
      frequencyIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencyIsar');
    });
  }

  QueryBuilder<DictionaryMetaEntry, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DictionaryMetaEntry, String?, QQueryOperations>
      pitchesIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pitchesIsar');
    });
  }

  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }

  QueryBuilder<DictionaryMetaEntry, int, QQueryOperations>
      termLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termLength');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryMetaEntry _$DictionaryMetaEntryFromJson(Map<String, dynamic> json) =>
    DictionaryMetaEntry(
      dictionaryName: json['dictionaryName'] as String,
      term: json['term'] as String,
      pitches: (json['pitches'] as List<dynamic>?)
          ?.map((e) => PitchData.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequency: json['frequency'] == null
          ? null
          : FrequencyData.fromJson(json['frequency'] as Map<String, dynamic>),
      id: json['id'] as int?,
    )
      ..pitchesIsar = json['pitchesIsar'] as String?
      ..frequencyIsar = json['frequencyIsar'] as String?;

Map<String, dynamic> _$DictionaryMetaEntryToJson(
        DictionaryMetaEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'dictionaryName': instance.dictionaryName,
      'frequency': instance.frequency,
      'pitches': instance.pitches,
      'pitchesIsar': instance.pitchesIsar,
      'frequencyIsar': instance.frequencyIsar,
    };
