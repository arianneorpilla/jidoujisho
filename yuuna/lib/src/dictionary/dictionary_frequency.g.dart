// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_frequency.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDictionaryFrequencyCollection on Isar {
  IsarCollection<DictionaryFrequency> get dictionaryFrequencys =>
      this.collection();
}

const DictionaryFrequencySchema = CollectionSchema(
  name: r'DictionaryFrequency',
  id: 2045353883102057112,
  properties: {
    r'displayValue': PropertySchema(
      id: 0,
      name: r'displayValue',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'value': PropertySchema(
      id: 2,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _dictionaryFrequencyEstimateSize,
  serialize: _dictionaryFrequencySerialize,
  deserialize: _dictionaryFrequencyDeserialize,
  deserializeProp: _dictionaryFrequencyDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'heading': LinkSchema(
      id: -3519613892290749971,
      name: r'heading',
      target: r'DictionaryHeading',
      single: true,
    ),
    r'dictionary': LinkSchema(
      id: 7440249776312249317,
      name: r'dictionary',
      target: r'Dictionary',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _dictionaryFrequencyGetId,
  getLinks: _dictionaryFrequencyGetLinks,
  attach: _dictionaryFrequencyAttach,
  version: '3.1.0',
);

int _dictionaryFrequencyEstimateSize(
  DictionaryFrequency object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayValue.length * 3;
  return bytesCount;
}

void _dictionaryFrequencySerialize(
  DictionaryFrequency object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayValue);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeDouble(offsets[2], object.value);
}

DictionaryFrequency _dictionaryFrequencyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryFrequency(
    displayValue: reader.readString(offsets[0]),
    id: id,
    value: reader.readDouble(offsets[2]),
  );
  return object;
}

P _dictionaryFrequencyDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryFrequencyGetId(DictionaryFrequency object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryFrequencyGetLinks(
    DictionaryFrequency object) {
  return [object.heading, object.dictionary];
}

void _dictionaryFrequencyAttach(
    IsarCollection<dynamic> col, Id id, DictionaryFrequency object) {
  object.id = id;
  object.heading
      .attach(col, col.isar.collection<DictionaryHeading>(), r'heading', id);
  object.dictionary
      .attach(col, col.isar.collection<Dictionary>(), r'dictionary', id);
}

extension DictionaryFrequencyQueryWhereSort
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QWhere> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionaryFrequencyQueryWhere
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QWhereClause> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhereClause>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterWhereClause>
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
}

extension DictionaryFrequencyQueryFilter on QueryBuilder<DictionaryFrequency,
    DictionaryFrequency, QFilterCondition> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayValue',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      displayValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayValue',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
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

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      valueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension DictionaryFrequencyQueryObject on QueryBuilder<DictionaryFrequency,
    DictionaryFrequency, QFilterCondition> {}

extension DictionaryFrequencyQueryLinks on QueryBuilder<DictionaryFrequency,
    DictionaryFrequency, QFilterCondition> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      heading(FilterQuery<DictionaryHeading> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'heading');
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      headingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'heading', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      dictionary(FilterQuery<Dictionary> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'dictionary');
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterFilterCondition>
      dictionaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dictionary', 0, true, 0, true);
    });
  }
}

extension DictionaryFrequencyQuerySortBy
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QSortBy> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByDisplayValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayValue', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByDisplayValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayValue', Sort.desc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension DictionaryFrequencyQuerySortThenBy
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QSortThenBy> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByDisplayValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayValue', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByDisplayValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayValue', Sort.desc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QAfterSortBy>
      thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension DictionaryFrequencyQueryWhereDistinct
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QDistinct> {
  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QDistinct>
      distinctByDisplayValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DictionaryFrequency, DictionaryFrequency, QDistinct>
      distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension DictionaryFrequencyQueryProperty
    on QueryBuilder<DictionaryFrequency, DictionaryFrequency, QQueryProperty> {
  QueryBuilder<DictionaryFrequency, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryFrequency, String, QQueryOperations>
      displayValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayValue');
    });
  }

  QueryBuilder<DictionaryFrequency, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DictionaryFrequency, double, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
