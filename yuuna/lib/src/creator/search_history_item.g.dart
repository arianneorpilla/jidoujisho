// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable, no_leading_underscores_for_local_identifiers

extension GetSearchHistoryItemCollection on Isar {
  IsarCollection<SearchHistoryItem> get searchHistoryItems => getCollection();
}

const SearchHistoryItemSchema = CollectionSchema(
  name: 'SearchHistoryItem',
  schema:
      '{"name":"SearchHistoryItem","idName":"id","properties":[{"name":"historyKey","type":"String"},{"name":"searchTerm","type":"String"},{"name":"uniqueKey","type":"String"}],"indexes":[{"name":"historyKey","unique":false,"replace":false,"properties":[{"name":"historyKey","type":"Hash","caseSensitive":true}]},{"name":"searchTerm","unique":false,"replace":false,"properties":[{"name":"searchTerm","type":"Hash","caseSensitive":true}]},{"name":"uniqueKey","unique":true,"replace":false,"properties":[{"name":"uniqueKey","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'historyKey': 0, 'searchTerm': 1, 'uniqueKey': 2},
  listProperties: {},
  indexIds: {'historyKey': 0, 'searchTerm': 1, 'uniqueKey': 2},
  indexValueTypes: {
    'historyKey': [
      IndexValueType.stringHash,
    ],
    'searchTerm': [
      IndexValueType.stringHash,
    ],
    'uniqueKey': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _searchHistoryItemGetId,
  setId: _searchHistoryItemSetId,
  getLinks: _searchHistoryItemGetLinks,
  attachLinks: _searchHistoryItemAttachLinks,
  serializeNative: _searchHistoryItemSerializeNative,
  deserializeNative: _searchHistoryItemDeserializeNative,
  deserializePropNative: _searchHistoryItemDeserializePropNative,
  serializeWeb: _searchHistoryItemSerializeWeb,
  deserializeWeb: _searchHistoryItemDeserializeWeb,
  deserializePropWeb: _searchHistoryItemDeserializePropWeb,
  version: 4,
);

int? _searchHistoryItemGetId(SearchHistoryItem object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _searchHistoryItemSetId(SearchHistoryItem object, int id) {
  object.id = id;
}

List<IsarLinkBase> _searchHistoryItemGetLinks(SearchHistoryItem object) {
  return [];
}

void _searchHistoryItemSerializeNative(
    IsarCollection<SearchHistoryItem> collection,
    IsarCObject cObj,
    SearchHistoryItem object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.historyKey;
  final _historyKey = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_historyKey.length) as int;
  final value1 = object.searchTerm;
  final _searchTerm = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_searchTerm.length) as int;
  final value2 = object.uniqueKey;
  final _uniqueKey = IsarBinaryWriter.utf8Encoder.convert(value2);
  dynamicSize += (_uniqueKey.length) as int;
  final size = staticSize + dynamicSize;

  cObj.buffer = alloc(size);
  cObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(cObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _historyKey);
  writer.writeBytes(offsets[1], _searchTerm);
  writer.writeBytes(offsets[2], _uniqueKey);
}

SearchHistoryItem _searchHistoryItemDeserializeNative(
    IsarCollection<SearchHistoryItem> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = SearchHistoryItem(
    historyKey: reader.readString(offsets[0]),
    id: id,
    searchTerm: reader.readString(offsets[1]),
  );
  return object;
}

P _searchHistoryItemDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _searchHistoryItemSerializeWeb(
    IsarCollection<SearchHistoryItem> collection, SearchHistoryItem object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'historyKey', object.historyKey);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'searchTerm', object.searchTerm);
  IsarNative.jsObjectSet(jsObj, 'uniqueKey', object.uniqueKey);
  return jsObj;
}

SearchHistoryItem _searchHistoryItemDeserializeWeb(
    IsarCollection<SearchHistoryItem> collection, dynamic jsObj) {
  final object = SearchHistoryItem(
    historyKey: IsarNative.jsObjectGet(jsObj, 'historyKey') ?? '',
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    searchTerm: IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '',
  );
  return object;
}

P _searchHistoryItemDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'historyKey':
      return (IsarNative.jsObjectGet(jsObj, 'historyKey') ?? '') as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'searchTerm':
      return (IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '') as P;
    case 'uniqueKey':
      return (IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _searchHistoryItemAttachLinks(
    IsarCollection col, int id, SearchHistoryItem object) {}

extension SearchHistoryItemByIndex on IsarCollection<SearchHistoryItem> {
  Future<SearchHistoryItem?> getByUniqueKey(String uniqueKey) {
    return getByIndex('uniqueKey', [uniqueKey]);
  }

  SearchHistoryItem? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex('uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<List<SearchHistoryItem?>> getAllByUniqueKey(
      List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex('uniqueKey', values);
  }

  List<SearchHistoryItem?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync('uniqueKey', values);
  }

  Future<int> deleteAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex('uniqueKey', values);
  }

  int deleteAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync('uniqueKey', values);
  }
}

extension SearchHistoryItemQueryWhereSort
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QWhere> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhere>
      anyHistoryKey() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'historyKey'));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhere>
      anySearchTerm() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'searchTerm'));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhere>
      anyUniqueKey() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'uniqueKey'));
  }
}

extension SearchHistoryItemQueryWhere
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QWhereClause> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idEqualTo(int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idNotEqualTo(int id) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(
        IdWhereClause.lessThan(upper: id, includeUpper: false),
      ).addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: id, includeLower: false),
      );
    } else {
      return addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: id, includeLower: false),
      ).addWhereClauseInternal(
        IdWhereClause.lessThan(upper: id, includeUpper: false),
      );
    }
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idBetween(
    int lowerId,
    int upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: lowerId,
      includeLower: includeLower,
      upper: upperId,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      historyKeyEqualTo(String historyKey) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'historyKey',
      value: [historyKey],
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      historyKeyNotEqualTo(String historyKey) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'historyKey',
        upper: [historyKey],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'historyKey',
        lower: [historyKey],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'historyKey',
        lower: [historyKey],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'historyKey',
        upper: [historyKey],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      searchTermEqualTo(String searchTerm) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'searchTerm',
      value: [searchTerm],
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      searchTermNotEqualTo(String searchTerm) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'searchTerm',
        upper: [searchTerm],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'searchTerm',
        lower: [searchTerm],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'searchTerm',
        lower: [searchTerm],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'searchTerm',
        upper: [searchTerm],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      uniqueKeyEqualTo(String uniqueKey) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'uniqueKey',
      value: [uniqueKey],
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      uniqueKeyNotEqualTo(String uniqueKey) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'uniqueKey',
        upper: [uniqueKey],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'uniqueKey',
        lower: [uniqueKey],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'uniqueKey',
        lower: [uniqueKey],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'uniqueKey',
        upper: [uniqueKey],
        includeUpper: false,
      ));
    }
  }
}

extension SearchHistoryItemQueryFilter
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QFilterCondition> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'historyKey',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'historyKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'historyKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idBetween(
    int lower,
    int upper, {
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermEqualTo(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermGreaterThan(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermLessThan(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermBetween(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermStartsWith(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermEndsWith(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'searchTerm',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'uniqueKey',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'uniqueKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension SearchHistoryItemQueryLinks
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QFilterCondition> {}

extension SearchHistoryItemQueryWhereSortBy
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QSortBy> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByHistoryKey() {
    return addSortByInternal('historyKey', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByHistoryKeyDesc() {
    return addSortByInternal('historyKey', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension SearchHistoryItemQueryWhereSortThenBy
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QSortThenBy> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByHistoryKey() {
    return addSortByInternal('historyKey', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByHistoryKeyDesc() {
    return addSortByInternal('historyKey', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension SearchHistoryItemQueryWhereDistinct
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctByHistoryKey({bool caseSensitive = true}) {
    return addDistinctByInternal('historyKey', caseSensitive: caseSensitive);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return addDistinctByInternal('searchTerm', caseSensitive: caseSensitive);
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctByUniqueKey({bool caseSensitive = true}) {
    return addDistinctByInternal('uniqueKey', caseSensitive: caseSensitive);
  }
}

extension SearchHistoryItemQueryProperty
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QQueryProperty> {
  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      historyKeyProperty() {
    return addPropertyNameInternal('historyKey');
  }

  QueryBuilder<SearchHistoryItem, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      searchTermProperty() {
    return addPropertyNameInternal('searchTerm');
  }

  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      uniqueKeyProperty() {
    return addPropertyNameInternal('uniqueKey');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) =>
    SearchHistoryItem(
      historyKey: json['historyKey'] as String,
      searchTerm: json['searchTerm'] as String,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$SearchHistoryItemToJson(SearchHistoryItem instance) =>
    <String, dynamic>{
      'historyKey': instance.historyKey,
      'searchTerm': instance.searchTerm,
      'id': instance.id,
    };
