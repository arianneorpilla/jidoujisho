// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionaryResultCollection on Isar {
  IsarCollection<DictionaryResult> get dictionaryResults => this.collection();
}

const DictionaryResultSchema = CollectionSchema(
  name: r'DictionaryResult',
  id: -570485563317248426,
  properties: {
    r'scrollIndex': PropertySchema(
      id: 0,
      name: r'scrollIndex',
      type: IsarType.long,
    ),
    r'searchTerm': PropertySchema(
      id: 1,
      name: r'searchTerm',
      type: IsarType.string,
    ),
    r'termsIsar': PropertySchema(
      id: 2,
      name: r'termsIsar',
      type: IsarType.string,
    )
  },
  estimateSize: _dictionaryResultEstimateSize,
  serialize: _dictionaryResultSerialize,
  deserialize: _dictionaryResultDeserialize,
  deserializeProp: _dictionaryResultDeserializeProp,
  idName: r'id',
  indexes: {
    r'searchTerm': IndexSchema(
      id: 6747083501682260651,
      name: r'searchTerm',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchTerm',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dictionaryResultGetId,
  getLinks: _dictionaryResultGetLinks,
  attach: _dictionaryResultAttach,
  version: '3.0.6-dev.0',
);

int _dictionaryResultEstimateSize(
  DictionaryResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.searchTerm.length * 3;
  bytesCount += 3 + object.termsIsar.length * 3;
  return bytesCount;
}

void _dictionaryResultSerialize(
  DictionaryResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.scrollIndex);
  writer.writeString(offsets[1], object.searchTerm);
  writer.writeString(offsets[2], object.termsIsar);
}

DictionaryResult _dictionaryResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryResult(
    id: id,
    scrollIndex: reader.readLongOrNull(offsets[0]) ?? 0,
    searchTerm: reader.readString(offsets[1]),
  );
  object.termsIsar = reader.readString(offsets[2]);
  return object;
}

P _dictionaryResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryResultGetId(DictionaryResult object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryResultGetLinks(DictionaryResult object) {
  return [];
}

void _dictionaryResultAttach(
    IsarCollection<dynamic> col, Id id, DictionaryResult object) {
  object.id = id;
}

extension DictionaryResultByIndex on IsarCollection<DictionaryResult> {
  Future<DictionaryResult?> getBySearchTerm(String searchTerm) {
    return getByIndex(r'searchTerm', [searchTerm]);
  }

  DictionaryResult? getBySearchTermSync(String searchTerm) {
    return getByIndexSync(r'searchTerm', [searchTerm]);
  }

  Future<bool> deleteBySearchTerm(String searchTerm) {
    return deleteByIndex(r'searchTerm', [searchTerm]);
  }

  bool deleteBySearchTermSync(String searchTerm) {
    return deleteByIndexSync(r'searchTerm', [searchTerm]);
  }

  Future<List<DictionaryResult?>> getAllBySearchTerm(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndex(r'searchTerm', values);
  }

  List<DictionaryResult?> getAllBySearchTermSync(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'searchTerm', values);
  }

  Future<int> deleteAllBySearchTerm(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'searchTerm', values);
  }

  int deleteAllBySearchTermSync(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'searchTerm', values);
  }

  Future<Id> putBySearchTerm(DictionaryResult object) {
    return putByIndex(r'searchTerm', object);
  }

  Id putBySearchTermSync(DictionaryResult object, {bool saveLinks = true}) {
    return putByIndexSync(r'searchTerm', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySearchTerm(List<DictionaryResult> objects) {
    return putAllByIndex(r'searchTerm', objects);
  }

  List<Id> putAllBySearchTermSync(List<DictionaryResult> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'searchTerm', objects, saveLinks: saveLinks);
  }
}

extension DictionaryResultQueryWhereSort
    on QueryBuilder<DictionaryResult, DictionaryResult, QWhere> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionaryResultQueryWhere
    on QueryBuilder<DictionaryResult, DictionaryResult, QWhereClause> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      searchTermEqualTo(String searchTerm) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerm',
        value: [searchTerm],
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      searchTermNotEqualTo(String searchTerm) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [],
              upper: [searchTerm],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [searchTerm],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [searchTerm],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [],
              upper: [searchTerm],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DictionaryResultQueryFilter
    on QueryBuilder<DictionaryResult, DictionaryResult, QFilterCondition> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrollIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrollIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrollIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrollIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchTerm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTerm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerm',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTerm',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termsIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termsIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termsIsar',
        value: '',
      ));
    });
  }
}

extension DictionaryResultQueryObject
    on QueryBuilder<DictionaryResult, DictionaryResult, QFilterCondition> {}

extension DictionaryResultQueryLinks
    on QueryBuilder<DictionaryResult, DictionaryResult, QFilterCondition> {}

extension DictionaryResultQuerySortBy
    on QueryBuilder<DictionaryResult, DictionaryResult, QSortBy> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByScrollIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollIndex', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByScrollIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollIndex', Sort.desc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByTermsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByTermsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termsIsar', Sort.desc);
    });
  }
}

extension DictionaryResultQuerySortThenBy
    on QueryBuilder<DictionaryResult, DictionaryResult, QSortThenBy> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByScrollIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollIndex', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByScrollIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollIndex', Sort.desc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByTermsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termsIsar', Sort.asc);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByTermsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termsIsar', Sort.desc);
    });
  }
}

extension DictionaryResultQueryWhereDistinct
    on QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> {
  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctByScrollIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrollIndex');
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTerm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctByTermsIsar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termsIsar', caseSensitive: caseSensitive);
    });
  }
}

extension DictionaryResultQueryProperty
    on QueryBuilder<DictionaryResult, DictionaryResult, QQueryProperty> {
  QueryBuilder<DictionaryResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryResult, int, QQueryOperations> scrollIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrollIndex');
    });
  }

  QueryBuilder<DictionaryResult, String, QQueryOperations>
      searchTermProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTerm');
    });
  }

  QueryBuilder<DictionaryResult, String, QQueryOperations> termsIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termsIsar');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryResult _$DictionaryResultFromJson(Map<String, dynamic> json) =>
    DictionaryResult(
      searchTerm: json['searchTerm'] as String,
      terms: (json['terms'] as List<dynamic>?)
              ?.map((e) => DictionaryTerm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      scrollIndex: json['scrollIndex'] as int? ?? 0,
      id: json['id'] as int?,
    )..termsIsar = json['termsIsar'] as String;

Map<String, dynamic> _$DictionaryResultToJson(DictionaryResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scrollIndex': instance.scrollIndex,
      'searchTerm': instance.searchTerm,
      'terms': instance.terms,
      'termsIsar': instance.termsIsar,
    };
