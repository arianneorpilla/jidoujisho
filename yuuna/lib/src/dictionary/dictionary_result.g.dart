// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable, no_leading_underscores_for_local_identifiers

extension GetDictionaryResultCollection on Isar {
  IsarCollection<DictionaryResult> get dictionaryResults => getCollection();
}

const DictionaryResultSchema = CollectionSchema(
  name: 'DictionaryResult',
  schema:
      '{"name":"DictionaryResult","idName":"id","properties":[{"name":"scrollIndex","type":"Long"},{"name":"searchTerm","type":"String"},{"name":"terms","type":"String"}],"indexes":[{"name":"searchTerm","unique":true,"replace":false,"properties":[{"name":"searchTerm","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'scrollIndex': 0, 'searchTerm': 1, 'terms': 2},
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
  setId: _dictionaryResultSetId,
  getLinks: _dictionaryResultGetLinks,
  attachLinks: _dictionaryResultAttachLinks,
  serializeNative: _dictionaryResultSerializeNative,
  deserializeNative: _dictionaryResultDeserializeNative,
  deserializePropNative: _dictionaryResultDeserializePropNative,
  serializeWeb: _dictionaryResultSerializeWeb,
  deserializeWeb: _dictionaryResultDeserializeWeb,
  deserializePropWeb: _dictionaryResultDeserializePropWeb,
  version: 4,
);

int? _dictionaryResultGetId(DictionaryResult object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _dictionaryResultSetId(DictionaryResult object, int id) {
  object.id = id;
}

List<IsarLinkBase> _dictionaryResultGetLinks(DictionaryResult object) {
  return [];
}

const _dictionaryResultDictionaryTermsConverter = DictionaryTermsConverter();

void _dictionaryResultSerializeNative(
    IsarCollection<DictionaryResult> collection,
    IsarCObject cObj,
    DictionaryResult object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.scrollIndex;
  final _scrollIndex = value0;
  final value1 = object.searchTerm;
  final _searchTerm = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_searchTerm.length) as int;
  final value2 = _dictionaryResultDictionaryTermsConverter.toIsar(object.terms);
  final _terms = IsarBinaryWriter.utf8Encoder.convert(value2);
  dynamicSize += (_terms.length) as int;
  final size = staticSize + dynamicSize;

  cObj.buffer = alloc(size);
  cObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(cObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeLong(offsets[0], _scrollIndex);
  writer.writeBytes(offsets[1], _searchTerm);
  writer.writeBytes(offsets[2], _terms);
}

DictionaryResult _dictionaryResultDeserializeNative(
    IsarCollection<DictionaryResult> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryResult(
    id: id,
    scrollIndex: reader.readLong(offsets[0]),
    searchTerm: reader.readString(offsets[1]),
    terms: _dictionaryResultDictionaryTermsConverter
        .fromIsar(reader.readString(offsets[2])),
  );
  return object;
}

P _dictionaryResultDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (_dictionaryResultDictionaryTermsConverter
          .fromIsar(reader.readString(offset))) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryResultSerializeWeb(
    IsarCollection<DictionaryResult> collection, DictionaryResult object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'scrollIndex', object.scrollIndex);
  IsarNative.jsObjectSet(jsObj, 'searchTerm', object.searchTerm);
  IsarNative.jsObjectSet(jsObj, 'terms',
      _dictionaryResultDictionaryTermsConverter.toIsar(object.terms));
  return jsObj;
}

DictionaryResult _dictionaryResultDeserializeWeb(
    IsarCollection<DictionaryResult> collection, dynamic jsObj) {
  final object = DictionaryResult(
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    scrollIndex:
        IsarNative.jsObjectGet(jsObj, 'scrollIndex') ?? double.negativeInfinity,
    searchTerm: IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '',
    terms: _dictionaryResultDictionaryTermsConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'terms') ?? ''),
  );
  return object;
}

P _dictionaryResultDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'scrollIndex':
      return (IsarNative.jsObjectGet(jsObj, 'scrollIndex') ??
          double.negativeInfinity) as P;
    case 'searchTerm':
      return (IsarNative.jsObjectGet(jsObj, 'searchTerm') ?? '') as P;
    case 'terms':
      return (_dictionaryResultDictionaryTermsConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'terms') ?? '')) as P;
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
      scrollIndexEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'scrollIndex',
      value: value,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'scrollIndex',
      value: value,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'scrollIndex',
      value: value,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      scrollIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'scrollIndex',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
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

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsEqualTo(
    List<DictionaryTerm> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsGreaterThan(
    List<DictionaryTerm> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsLessThan(
    List<DictionaryTerm> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsBetween(
    List<DictionaryTerm> lower,
    List<DictionaryTerm> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'terms',
      lower: _dictionaryResultDictionaryTermsConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _dictionaryResultDictionaryTermsConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsStartsWith(
    List<DictionaryTerm> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsEndsWith(
    List<DictionaryTerm> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsContains(List<DictionaryTerm> value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'terms',
      value: _dictionaryResultDictionaryTermsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterFilterCondition>
      termsMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'terms',
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
      sortByScrollIndex() {
    return addSortByInternal('scrollIndex', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByScrollIndexDesc() {
    return addSortByInternal('scrollIndex', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy> sortByTerms() {
    return addSortByInternal('terms', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      sortByTermsDesc() {
    return addSortByInternal('terms', Sort.desc);
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
      thenByScrollIndex() {
    return addSortByInternal('scrollIndex', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByScrollIndexDesc() {
    return addSortByInternal('scrollIndex', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTerm() {
    return addSortByInternal('searchTerm', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenBySearchTermDesc() {
    return addSortByInternal('searchTerm', Sort.desc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy> thenByTerms() {
    return addSortByInternal('terms', Sort.asc);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QAfterSortBy>
      thenByTermsDesc() {
    return addSortByInternal('terms', Sort.desc);
  }
}

extension DictionaryResultQueryWhereDistinct
    on QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> {
  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctByScrollIndex() {
    return addDistinctByInternal('scrollIndex');
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return addDistinctByInternal('searchTerm', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryResult, DictionaryResult, QDistinct> distinctByTerms(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('terms', caseSensitive: caseSensitive);
  }
}

extension DictionaryResultQueryProperty
    on QueryBuilder<DictionaryResult, DictionaryResult, QQueryProperty> {
  QueryBuilder<DictionaryResult, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryResult, int, QQueryOperations> scrollIndexProperty() {
    return addPropertyNameInternal('scrollIndex');
  }

  QueryBuilder<DictionaryResult, String, QQueryOperations>
      searchTermProperty() {
    return addPropertyNameInternal('searchTerm');
  }

  QueryBuilder<DictionaryResult, List<DictionaryTerm>, QQueryOperations>
      termsProperty() {
    return addPropertyNameInternal('terms');
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
    );

Map<String, dynamic> _$DictionaryResultToJson(DictionaryResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scrollIndex': instance.scrollIndex,
      'searchTerm': instance.searchTerm,
      'terms': instance.terms,
    };
