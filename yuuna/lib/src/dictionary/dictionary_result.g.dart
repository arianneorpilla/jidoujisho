// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetDictionaryResultCollection on Isar {
  IsarCollection<DictionaryResult> get dictionaryResults => getCollection();
}

const DictionaryResultSchema = CollectionSchema(
  name: 'DictionaryResult',
  schema:
      '{"name":"DictionaryResult","idName":"id","properties":[{"name":"mapping","type":"String"},{"name":"searchTerm","type":"String"}],"indexes":[{"name":"searchTerm","unique":true,"properties":[{"name":"searchTerm","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'mapping': 0, 'searchTerm': 1},
  listProperties: {},
  indexIds: {'searchTerm': 0},
  indexValueTypes: {
    'searchTerm': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _dictionaryResultGetId,
  getLinks: _dictionaryResultGetLinks,
  attachLinks: _dictionaryResultAttachLinks,
  serializeNative: _dictionaryResultSerializeNative,
  deserializeNative: _dictionaryResultDeserializeNative,
  deserializePropNative: _dictionaryResultDeserializePropNative,
  serializeWeb: _dictionaryResultSerializeWeb,
  deserializeWeb: _dictionaryResultDeserializeWeb,
  deserializePropWeb: _dictionaryResultDeserializePropWeb,
  version: 3,
);

int? _dictionaryResultGetId(DictionaryResult object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

List<IsarLinkBase> _dictionaryResultGetLinks(DictionaryResult object) {
  return [];
}

const _dictionaryResultDictionaryEntriesConverter =
    DictionaryEntriesConverter();

void _dictionaryResultSerializeNative(
    IsarCollection<DictionaryResult> collection,
    IsarRawObject rawObj,
    DictionaryResult object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 =
      _dictionaryResultDictionaryEntriesConverter.toIsar(object.mapping);
  final _mapping = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_mapping.length) as int;
  final value1 = object.searchTerm;
  final _searchTerm = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_searchTerm.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _mapping);
  writer.writeBytes(offsets[1], _searchTerm);
}

DictionaryResult _dictionaryResultDeserializeNative(
    IsarCollection<DictionaryResult> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryResult(
    id: id,
    mapping: _dictionaryResultDictionaryEntriesConverter
        .fromIsar(reader.readString(offsets[0])),
    searchTerm: reader.readString(offsets[1]),
  );
  return object;
}

P _dictionaryResultDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (_dictionaryResultDictionaryEntriesConverter
          .fromIsar(reader.readString(offset))) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryResultSerializeWeb(
    IsarCollection<DictionaryResult> collection, DictionaryResult object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'mapping',
      _dictionaryResultDictionaryEntriesConverter.toIsar(object.mapping));
  IsarNative.jsObjectSet(jsObj, 'searchTerm', object.searchTerm);
  return jsObj;
}

DictionaryResult _dictionaryResultDeserializeWeb(
    IsarCollection<DictionaryResult> collection, dynamic jsObj) {
  final object = DictionaryResult(
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    mapping: _dictionaryResultDictionaryEntriesConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'mapping') ?? ''),
    searchTerm: IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '',
  );
  return object;
}

P _dictionaryResultDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'mapping':
      return (_dictionaryResultDictionaryEntriesConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'mapping') ?? '')) as P;
    case 'searchTerm':
      return (IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _dictionaryResultAttachLinks(
    IsarCollection col, int id, DictionaryResult object) {}

extension DictionaryResultByIndex on IsarCollection<DictionaryResult> {
  Future<DictionaryResult?> getBySearchTerm(String searchTerm) {
    return getByIndex('searchTerm', [searchTerm]);
  }

  DictionaryResult? getBySearchTermSync(String searchTerm) {
    return getByIndexSync('searchTerm', [searchTerm]);
  }

  Future<bool> deleteBySearchTerm(String searchTerm) {
    return deleteByIndex('searchTerm', [searchTerm]);
  }

  bool deleteBySearchTermSync(String searchTerm) {
    return deleteByIndexSync('searchTerm', [searchTerm]);
  }

  Future<List<DictionaryResult?>> getAllBySearchTerm(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndex('searchTerm', values);
  }

  List<DictionaryResult?> getAllBySearchTermSync(
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

extension DictionaryResultQueryWhereSort
    on QueryBuilder<DictionaryResult, DictionaryResult, QWhere> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhere>
      anySearchTerm() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'searchTerm'));
  }
}

extension DictionaryResultQueryWhere
    on QueryBuilder<DictionaryResult, DictionaryResult, QWhereClause> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
      searchTermEqualTo(String searchTerm) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'searchTerm',
      value: [searchTerm],
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterWhereClause>
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
}

extension DictionaryResultQueryFilter
    on QueryBuilder<DictionaryResult, DictionaryResult, QFilterCondition> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      idEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingEqualTo(
    List<List<DictionaryEntry>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingGreaterThan(
    List<List<DictionaryEntry>> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingLessThan(
    List<List<DictionaryEntry>> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingBetween(
    List<List<DictionaryEntry>> lower,
    List<List<DictionaryEntry>> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'mapping',
      lower: _dictionaryResultDictionaryEntriesConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _dictionaryResultDictionaryEntriesConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingStartsWith(
    List<List<DictionaryEntry>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingEndsWith(
    List<List<DictionaryEntry>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingContains(List<List<DictionaryEntry>> value,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'mapping',
      value: _dictionaryResultDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      mappingMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'mapping',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'searchTerm',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'searchTerm',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionaryResultQueryLinks
    on QueryBuilder<DictionaryResult, DictionaryResult, QFilterCondition> {}

extension DictionaryResultQueryWhereSortBy
    on QueryBuilder<DictionaryResult, DictionaryResult, QSortBy> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByMapping() {
    return addSortByInternal('mapping', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByMappingDesc() {
    return addSortByInternal('mapping', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }
}

extension DictionaryResultQueryWhereSortThenBy
    on QueryBuilder<DictionaryResult, DictionaryResult, QSortThenBy> {
  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByMapping() {
    return addSortByInternal('mapping', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByMappingDesc() {
    return addSortByInternal('mapping', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }
}

extension DictionaryResultQueryWhereDistinct
    on QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> {
  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> distinctByMapping(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('mapping', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return addDistinctByInternal('searchTerm', caseSensitive: caseSensitive);
  }
}

extension DictionaryResultQueryProperty
    on QueryBuilder<DictionaryResult, DictionaryResult, QQueryProperty> {
  QueryBuilder<DictionaryResult, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryResult, List<List<DictionaryEntry>>, QQueryOperations>
      mappingProperty() {
    return addPropertyNameInternal('mapping');
  }

  QueryBuilder<DictionaryResult, String, QQueryOperations>
      searchTermProperty() {
    return addPropertyNameInternal('searchTerm');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryResult _$DictionaryResultFromJson(Map<String, dynamic> json) =>
    DictionaryResult(
      searchTerm: json['searchTerm'] as String,
      mapping: (json['mapping'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) =>
                      DictionaryEntry.fromJson(e as Map<String, dynamic>))
                  .toList())
              .toList() ??
          const [],
      id: json['id'] as int?,
    );

Map<String, dynamic> _$DictionaryResultToJson(DictionaryResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'searchTerm': instance.searchTerm,
      'mapping': instance.mapping,
    };
