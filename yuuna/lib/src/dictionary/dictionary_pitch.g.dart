// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_pitch.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDictionaryPitchCollection on Isar {
  IsarCollection<DictionaryPitch> get dictionaryPitchs => this.collection();
}

const DictionaryPitchSchema = CollectionSchema(
  name: r'DictionaryPitch',
  id: 7201735020230863881,
  properties: {
    r'downstep': PropertySchema(
      id: 0,
      name: r'downstep',
      type: IsarType.long,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    )
  },
  estimateSize: _dictionaryPitchEstimateSize,
  serialize: _dictionaryPitchSerialize,
  deserialize: _dictionaryPitchDeserialize,
  deserializeProp: _dictionaryPitchDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'heading': LinkSchema(
      id: 3668948122855608015,
      name: r'heading',
      target: r'DictionaryHeading',
      single: true,
    ),
    r'dictionary': LinkSchema(
      id: 4406391262247317541,
      name: r'dictionary',
      target: r'Dictionary',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _dictionaryPitchGetId,
  getLinks: _dictionaryPitchGetLinks,
  attach: _dictionaryPitchAttach,
  version: '3.1.0+1',
);

int _dictionaryPitchEstimateSize(
  DictionaryPitch object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dictionaryPitchSerialize(
  DictionaryPitch object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.downstep);
  writer.writeLong(offsets[1], object.hashCode);
}

DictionaryPitch _dictionaryPitchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryPitch(
    downstep: reader.readLong(offsets[0]),
    id: id,
  );
  return object;
}

P _dictionaryPitchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryPitchGetId(DictionaryPitch object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryPitchGetLinks(DictionaryPitch object) {
  return [object.heading, object.dictionary];
}

void _dictionaryPitchAttach(
    IsarCollection<dynamic> col, Id id, DictionaryPitch object) {
  object.id = id;
  object.heading
      .attach(col, col.isar.collection<DictionaryHeading>(), r'heading', id);
  object.dictionary
      .attach(col, col.isar.collection<Dictionary>(), r'dictionary', id);
}

extension DictionaryPitchQueryWhereSort
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QWhere> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionaryPitchQueryWhere
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QWhereClause> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhereClause>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterWhereClause> idBetween(
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

extension DictionaryPitchQueryFilter
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QFilterCondition> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      downstepEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downstep',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      downstepGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downstep',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      downstepLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downstep',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      downstepBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downstep',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
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
}

extension DictionaryPitchQueryObject
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QFilterCondition> {}

extension DictionaryPitchQueryLinks
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QFilterCondition> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition> heading(
      FilterQuery<DictionaryHeading> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'heading');
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      headingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'heading', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      dictionary(FilterQuery<Dictionary> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'dictionary');
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterFilterCondition>
      dictionaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dictionary', 0, true, 0, true);
    });
  }
}

extension DictionaryPitchQuerySortBy
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QSortBy> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      sortByDownstep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downstep', Sort.asc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      sortByDownstepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downstep', Sort.desc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }
}

extension DictionaryPitchQuerySortThenBy
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QSortThenBy> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      thenByDownstep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downstep', Sort.asc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      thenByDownstepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downstep', Sort.desc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension DictionaryPitchQueryWhereDistinct
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QDistinct> {
  QueryBuilder<DictionaryPitch, DictionaryPitch, QDistinct>
      distinctByDownstep() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downstep');
    });
  }

  QueryBuilder<DictionaryPitch, DictionaryPitch, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }
}

extension DictionaryPitchQueryProperty
    on QueryBuilder<DictionaryPitch, DictionaryPitch, QQueryProperty> {
  QueryBuilder<DictionaryPitch, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryPitch, int, QQueryOperations> downstepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downstep');
    });
  }

  QueryBuilder<DictionaryPitch, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }
}
