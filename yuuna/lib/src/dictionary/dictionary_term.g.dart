// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_term.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionaryTermCollection on Isar {
  IsarCollection<DictionaryTerm> get dictionaryTerms => this.collection();
}

const DictionaryTermSchema = CollectionSchema(
  name: r'DictionaryTerm',
  id: 2352896169497870156,
  properties: {
    r'entriesIsar': PropertySchema(
      id: 0,
      name: r'entriesIsar',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'meaningTagsGroupsIsar': PropertySchema(
      id: 2,
      name: r'meaningTagsGroupsIsar',
      type: IsarType.string,
    ),
    r'metaEntriesIsar': PropertySchema(
      id: 3,
      name: r'metaEntriesIsar',
      type: IsarType.string,
    ),
    r'reading': PropertySchema(
      id: 4,
      name: r'reading',
      type: IsarType.string,
    ),
    r'term': PropertySchema(
      id: 5,
      name: r'term',
      type: IsarType.string,
    ),
    r'termTagsIsar': PropertySchema(
      id: 6,
      name: r'termTagsIsar',
      type: IsarType.string,
    )
  },
  estimateSize: _dictionaryTermEstimateSize,
  serialize: _dictionaryTermSerialize,
  deserialize: _dictionaryTermDeserialize,
  deserializeProp: _dictionaryTermDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dictionaryTermGetId,
  getLinks: _dictionaryTermGetLinks,
  attach: _dictionaryTermAttach,
  version: '3.0.6-dev.0',
);

int _dictionaryTermEstimateSize(
  DictionaryTerm object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entriesIsar.length * 3;
  bytesCount += 3 + object.meaningTagsGroupsIsar.length * 3;
  bytesCount += 3 + object.metaEntriesIsar.length * 3;
  bytesCount += 3 + object.reading.length * 3;
  bytesCount += 3 + object.term.length * 3;
  bytesCount += 3 + object.termTagsIsar.length * 3;
  return bytesCount;
}

void _dictionaryTermSerialize(
  DictionaryTerm object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entriesIsar);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeString(offsets[2], object.meaningTagsGroupsIsar);
  writer.writeString(offsets[3], object.metaEntriesIsar);
  writer.writeString(offsets[4], object.reading);
  writer.writeString(offsets[5], object.term);
  writer.writeString(offsets[6], object.termTagsIsar);
}

DictionaryTerm _dictionaryTermDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryTerm(
    reading: reader.readString(offsets[4]),
    term: reader.readString(offsets[5]),
  );
  object.entriesIsar = reader.readString(offsets[0]);
  object.id = id;
  object.meaningTagsGroupsIsar = reader.readString(offsets[2]);
  object.metaEntriesIsar = reader.readString(offsets[3]);
  object.termTagsIsar = reader.readString(offsets[6]);
  return object;
}

P _dictionaryTermDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryTermGetId(DictionaryTerm object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryTermGetLinks(DictionaryTerm object) {
  return [];
}

void _dictionaryTermAttach(
    IsarCollection<dynamic> col, Id id, DictionaryTerm object) {
  object.id = id;
}

extension DictionaryTermQueryWhereSort
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QWhere> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionaryTermQueryWhere
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QWhereClause> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idBetween(
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
}

extension DictionaryTermQueryFilter
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QFilterCondition> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entriesIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entriesIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entriesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entriesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'meaningTagsGroupsIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'meaningTagsGroupsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'meaningTagsGroupsIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'meaningTagsGroupsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      meaningTagsGroupsIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'meaningTagsGroupsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metaEntriesIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metaEntriesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metaEntriesIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metaEntriesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      metaEntriesIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metaEntriesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reading',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reading',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reading',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'term',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termTagsIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termTagsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termTagsIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termTagsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termTagsIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termTagsIsar',
        value: '',
      ));
    });
  }
}

extension DictionaryTermQueryObject
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QFilterCondition> {}

extension DictionaryTermQueryLinks
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QFilterCondition> {}

extension DictionaryTermQuerySortBy
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QSortBy> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByEntriesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByEntriesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByMeaningTagsGroupsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningTagsGroupsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByMeaningTagsGroupsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningTagsGroupsIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByMetaEntriesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaEntriesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByMetaEntriesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaEntriesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByTermTagsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termTagsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByTermTagsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termTagsIsar', Sort.desc);
    });
  }
}

extension DictionaryTermQuerySortThenBy
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QSortThenBy> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByEntriesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByEntriesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByMeaningTagsGroupsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningTagsGroupsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByMeaningTagsGroupsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningTagsGroupsIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByMetaEntriesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaEntriesIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByMetaEntriesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metaEntriesIsar', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByTermTagsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termTagsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByTermTagsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termTagsIsar', Sort.desc);
    });
  }
}

extension DictionaryTermQueryWhereDistinct
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByEntriesIsar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entriesIsar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct>
      distinctByMeaningTagsGroupsIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meaningTagsGroupsIsar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct>
      distinctByMetaEntriesIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metaEntriesIsar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByReading(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reading', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct>
      distinctByTermTagsIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termTagsIsar', caseSensitive: caseSensitive);
    });
  }
}

extension DictionaryTermQueryProperty
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QQueryProperty> {
  QueryBuilder<DictionaryTerm, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations> entriesIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entriesIsar');
    });
  }

  QueryBuilder<DictionaryTerm, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations>
      meaningTagsGroupsIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meaningTagsGroupsIsar');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations>
      metaEntriesIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metaEntriesIsar');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations> readingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reading');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations>
      termTagsIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termTagsIsar');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryTerm _$DictionaryTermFromJson(Map<String, dynamic> json) =>
    DictionaryTerm(
      term: json['term'] as String,
      reading: json['reading'] as String,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      metaEntries: (json['metaEntries'] as List<dynamic>?)
              ?.map((e) =>
                  DictionaryMetaEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      termTags: (json['termTags'] as List<dynamic>?)
              ?.map((e) => DictionaryTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      meaningTagsGroups: (json['meaningTagsGroups'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => DictionaryTag.fromJson(e as Map<String, dynamic>))
                  .toList())
              .toList() ??
          const [],
    )
      ..entriesIsar = json['entriesIsar'] as String
      ..metaEntriesIsar = json['metaEntriesIsar'] as String
      ..termTagsIsar = json['termTagsIsar'] as String
      ..meaningTagsGroupsIsar = json['meaningTagsGroupsIsar'] as String
      ..id = json['id'] as int?;

Map<String, dynamic> _$DictionaryTermToJson(DictionaryTerm instance) =>
    <String, dynamic>{
      'term': instance.term,
      'reading': instance.reading,
      'entries': instance.entries,
      'metaEntries': instance.metaEntries,
      'termTags': instance.termTags,
      'meaningTagsGroups': instance.meaningTagsGroups,
      'entriesIsar': instance.entriesIsar,
      'metaEntriesIsar': instance.metaEntriesIsar,
      'termTagsIsar': instance.termTagsIsar,
      'meaningTagsGroupsIsar': instance.meaningTagsGroupsIsar,
      'id': instance.id,
    };
