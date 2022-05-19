// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetSearchHistoryCollection on Isar {
  IsarCollection<SearchHistory> get searchHistorys => getCollection();
}

const SearchHistorySchema = CollectionSchema(
  name: 'SearchHistory',
  schema:
      '{"name":"SearchHistory","idName":"id","properties":[{"name":"items","type":"StringList"},{"name":"uniqueKey","type":"String"}],"indexes":[{"name":"uniqueKey","unique":true,"properties":[{"name":"uniqueKey","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'items': 0, 'uniqueKey': 1},
  listProperties: {'items'},
  indexIds: {'uniqueKey': 0},
  indexValueTypes: {
    'uniqueKey': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _searchHistoryGetId,
  setId: _searchHistorySetId,
  getLinks: _searchHistoryGetLinks,
  attachLinks: _searchHistoryAttachLinks,
  serializeNative: _searchHistorySerializeNative,
  deserializeNative: _searchHistoryDeserializeNative,
  deserializePropNative: _searchHistoryDeserializePropNative,
  serializeWeb: _searchHistorySerializeWeb,
  deserializeWeb: _searchHistoryDeserializeWeb,
  deserializePropWeb: _searchHistoryDeserializePropWeb,
  version: 3,
);

int? _searchHistoryGetId(SearchHistory object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _searchHistorySetId(SearchHistory object, int id) {
  object.id = id;
}

List<IsarLinkBase> _searchHistoryGetLinks(SearchHistory object) {
  return [];
}

void _searchHistorySerializeNative(
    IsarCollection<SearchHistory> collection,
    IsarRawObject rawObj,
    SearchHistory object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.items;
  dynamicSize += (value0.length) * 8;
  final bytesList0 = <IsarUint8List>[];
  for (var str in value0) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList0.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _items = bytesList0;
  final value1 = object.uniqueKey;
  final _uniqueKey = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_uniqueKey.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeStringList(offsets[0], _items);
  writer.writeBytes(offsets[1], _uniqueKey);
}

SearchHistory _searchHistoryDeserializeNative(
    IsarCollection<SearchHistory> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = SearchHistory(
    id: id,
    items: reader.readStringList(offsets[0]) ?? [],
    uniqueKey: reader.readString(offsets[1]),
  );
  return object;
}

P _searchHistoryDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _searchHistorySerializeWeb(
    IsarCollection<SearchHistory> collection, SearchHistory object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'items', object.items);
  IsarNative.jsObjectSet(jsObj, 'uniqueKey', object.uniqueKey);
  return jsObj;
}

SearchHistory _searchHistoryDeserializeWeb(
    IsarCollection<SearchHistory> collection, dynamic jsObj) {
  final object = SearchHistory(
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    items: (IsarNative.jsObjectGet(jsObj, 'items') as List?)
            ?.map((e) => e ?? '')
            .toList()
            .cast<String>() ??
        [],
    uniqueKey: IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '',
  );
  return object;
}

P _searchHistoryDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'items':
      return ((IsarNative.jsObjectGet(jsObj, 'items') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    case 'uniqueKey':
      return (IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _searchHistoryAttachLinks(
    IsarCollection col, int id, SearchHistory object) {}

extension SearchHistoryByIndex on IsarCollection<SearchHistory> {
  Future<SearchHistory?> getByUniqueKey(String uniqueKey) {
    return getByIndex('uniqueKey', [uniqueKey]);
  }

  SearchHistory? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex('uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<List<SearchHistory?>> getAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex('uniqueKey', values);
  }

  List<SearchHistory?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
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

extension SearchHistoryQueryWhereSort
    on QueryBuilder<SearchHistory, SearchHistory, QWhere> {
  QueryBuilder<SearchHistory, SearchHistory, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhere> anyUniqueKey() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'uniqueKey'));
  }
}

extension SearchHistoryQueryWhere
    on QueryBuilder<SearchHistory, SearchHistory, QWhereClause> {
  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause> idNotEqualTo(
      int id) {
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause> idLessThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause>
      uniqueKeyEqualTo(String uniqueKey) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'uniqueKey',
      value: [uniqueKey],
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterWhereClause>
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

extension SearchHistoryQueryFilter
    on QueryBuilder<SearchHistory, SearchHistory, QFilterCondition> {
  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'items',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'items',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      itemsAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'items',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
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

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'uniqueKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension SearchHistoryQueryLinks
    on QueryBuilder<SearchHistory, SearchHistory, QFilterCondition> {}

extension SearchHistoryQueryWhereSortBy
    on QueryBuilder<SearchHistory, SearchHistory, QSortBy> {
  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> sortByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension SearchHistoryQueryWhereSortThenBy
    on QueryBuilder<SearchHistory, SearchHistory, QSortThenBy> {
  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy> thenByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<SearchHistory, SearchHistory, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension SearchHistoryQueryWhereDistinct
    on QueryBuilder<SearchHistory, SearchHistory, QDistinct> {
  QueryBuilder<SearchHistory, SearchHistory, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<SearchHistory, SearchHistory, QDistinct> distinctByUniqueKey(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('uniqueKey', caseSensitive: caseSensitive);
  }
}

extension SearchHistoryQueryProperty
    on QueryBuilder<SearchHistory, SearchHistory, QQueryProperty> {
  QueryBuilder<SearchHistory, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<SearchHistory, List<String>, QQueryOperations> itemsProperty() {
    return addPropertyNameInternal('items');
  }

  QueryBuilder<SearchHistory, String, QQueryOperations> uniqueKeyProperty() {
    return addPropertyNameInternal('uniqueKey');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistory _$SearchHistoryFromJson(Map<String, dynamic> json) =>
    SearchHistory(
      uniqueKey: json['uniqueKey'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      id: json['id'] as int?,
    );

Map<String, dynamic> _$SearchHistoryToJson(SearchHistory instance) =>
    <String, dynamic>{
      'uniqueKey': instance.uniqueKey,
      'items': instance.items,
      'id': instance.id,
    };
