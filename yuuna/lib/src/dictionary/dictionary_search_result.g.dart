// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_search_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast

extension GetDictionarySearchResultCollection on Isar {
  IsarCollection<DictionarySearchResult> get dictionarySearchResults {
    return getCollection('DictionarySearchResult');
  }
}

final DictionarySearchResultSchema = CollectionSchema(
  name: 'DictionarySearchResult',
  schema:
      '{"name":"DictionarySearchResult","idName":"id","properties":[{"name":"searchTerm","type":"String"}],"indexes":[{"name":"searchTerm","unique":true,"properties":[{"name":"searchTerm","type":"Hash","caseSensitive":true}]}],"links":[]}',
  nativeAdapter: const _DictionarySearchResultNativeAdapter(),
  webAdapter: const _DictionarySearchResultWebAdapter(),
  idName: 'id',
  propertyIds: {'searchTerm': 0},
  listProperties: {},
  indexIds: {'searchTerm': 0},
  indexTypes: {
    'searchTerm': [
      NativeIndexType.stringHash,
    ]
  },
  linkIds: {},
  backlinkIds: {},
  linkedCollections: [],
  getId: (obj) {
    if (obj.id == Isar.autoIncrement) {
      return null;
    } else {
      return obj.id;
    }
  },
  setId: null,
  getLinks: (obj) => [],
  version: 2,
);

class _DictionarySearchResultWebAdapter
    extends IsarWebTypeAdapter<DictionarySearchResult> {
  const _DictionarySearchResultWebAdapter();

  @override
  Object serialize(IsarCollection<DictionarySearchResult> collection,
      DictionarySearchResult object) {
    final jsObj = IsarNative.newJsObject();
    IsarNative.jsObjectSet(jsObj, 'id', object.id);
    IsarNative.jsObjectSet(jsObj, 'searchTerm', object.searchTerm);
    return jsObj;
  }

  @override
  DictionarySearchResult deserialize(
      IsarCollection<DictionarySearchResult> collection, dynamic jsObj) {
    final object = DictionarySearchResult(
      id: IsarNative.jsObjectGet(jsObj, 'id'),
      searchTerm: IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '',
    );
    return object;
  }

  @override
  P deserializeProperty<P>(Object jsObj, String propertyName) {
    switch (propertyName) {
      case 'id':
        return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
      case 'searchTerm':
        return (IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '') as P;
      default:
        throw 'Illegal propertyName';
    }
  }

  @override
  void attachLinks(Isar isar, int id, DictionarySearchResult object) {}
}

class _DictionarySearchResultNativeAdapter
    extends IsarNativeTypeAdapter<DictionarySearchResult> {
  const _DictionarySearchResultNativeAdapter();

  @override
  void serialize(
      IsarCollection<DictionarySearchResult> collection,
      IsarRawObject rawObj,
      DictionarySearchResult object,
      int staticSize,
      List<int> offsets,
      AdapterAlloc alloc) {
    var dynamicSize = 0;
    final value0 = object.searchTerm;
    final _searchTerm = IsarBinaryWriter.utf8Encoder.convert(value0);
    dynamicSize += (_searchTerm.length) as int;
    final size = staticSize + dynamicSize;

    rawObj.buffer = alloc(size);
    rawObj.buffer_length = size;
    final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
    final writer = IsarBinaryWriter(buffer, staticSize);
    writer.writeBytes(offsets[0], _searchTerm);
  }

  @override
  DictionarySearchResult deserialize(
      IsarCollection<DictionarySearchResult> collection,
      int id,
      IsarBinaryReader reader,
      List<int> offsets) {
    final object = DictionarySearchResult(
      id: id,
      searchTerm: reader.readString(offsets[0]),
    );
    return object;
  }

  @override
  P deserializeProperty<P>(
      int id, IsarBinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case -1:
        return id as P;
      case 0:
        return (reader.readString(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }

  @override
  void attachLinks(Isar isar, int id, DictionarySearchResult object) {}
}

extension DictionarySearchResultByIndex
    on IsarCollection<DictionarySearchResult> {
  Future<DictionarySearchResult?> getBySearchTerm(String searchTerm) {
    return getByIndex('searchTerm', [searchTerm]);
  }

  DictionarySearchResult? getBySearchTermSync(String searchTerm) {
    return getByIndexSync('searchTerm', [searchTerm]);
  }

  Future<bool> deleteBySearchTerm(String searchTerm) {
    return deleteByIndex('searchTerm', [searchTerm]);
  }

  bool deleteBySearchTermSync(String searchTerm) {
    return deleteByIndexSync('searchTerm', [searchTerm]);
  }

  Future<List<DictionarySearchResult?>> getAllBySearchTerm(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndex('searchTerm', values);
  }

  List<DictionarySearchResult?> getAllBySearchTermSync(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndexSync('searchTerm', values);
  }

  Future<int> deleteAllBySearchTerm(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndex('searchTerm', values);
  }

  int deleteAllBySearchTermSync(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndexSync('searchTerm', values);
  }
}

extension DictionarySearchResultQueryWhereSort
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QWhere> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterWhere>
      anyId() {
    return addWhereClauseInternal(const WhereClause(indexName: null));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterWhere>
      anySearchTerm() {
    return addWhereClauseInternal(const WhereClause(indexName: 'searchTerm'));
  }
}

extension DictionarySearchResultQueryWhere on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QWhereClause> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: true,
      upper: [id],
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idNotEqualTo(int? id) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(WhereClause(
        indexName: null,
        upper: [id],
        includeUpper: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: null,
        lower: [id],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(WhereClause(
        indexName: null,
        lower: [id],
        includeLower: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: null,
        upper: [id],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idGreaterThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idLessThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      upper: [id],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idBetween(
    int? lowerId,
    int? upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [lowerId],
      includeLower: includeLower,
      upper: [upperId],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> searchTermEqualTo(String searchTerm) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'searchTerm',
      lower: [searchTerm],
      includeLower: true,
      upper: [searchTerm],
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> searchTermNotEqualTo(String searchTerm) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(WhereClause(
        indexName: 'searchTerm',
        upper: [searchTerm],
        includeUpper: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'searchTerm',
        lower: [searchTerm],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(WhereClause(
        indexName: 'searchTerm',
        lower: [searchTerm],
        includeLower: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'searchTerm',
        upper: [searchTerm],
        includeUpper: false,
      ));
    }
  }
}

extension DictionarySearchResultQueryFilter on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QFilterCondition> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'id',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'searchTerm',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
          QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
          QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'searchTerm',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionarySearchResultQueryLinks on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QFilterCondition> {}

extension DictionarySearchResultQueryWhereSortBy
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QSortBy> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }
}

extension DictionarySearchResultQueryWhereSortThenBy on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QSortThenBy> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }
}

extension DictionarySearchResultQueryWhereDistinct
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return addDistinctByInternal('searchTerm', caseSensitive: caseSensitive);
  }
}

extension DictionarySearchResultQueryProperty on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QQueryProperty> {
  QueryBuilder<DictionarySearchResult, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionarySearchResult, String, QQueryOperations>
      searchTermProperty() {
    return addPropertyNameInternal('searchTerm');
  }
}
