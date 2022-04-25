// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast

extension GetDictionaryCollection on Isar {
  IsarCollection<Dictionary> get dictionarys {
    return getCollection('Dictionary');
  }
}

final DictionarySchema = CollectionSchema(
  name: 'Dictionary',
  schema:
      '{"name":"Dictionary","idName":"id","properties":[{"name":"collapsed","type":"Bool"},{"name":"dictionaryName","type":"String"},{"name":"formatName","type":"String"},{"name":"hidden","type":"Bool"},{"name":"metadata","type":"String"},{"name":"order","type":"Long"}],"indexes":[{"name":"dictionaryName","unique":true,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"order","unique":true,"properties":[{"name":"order","type":"Value","caseSensitive":false}]}],"links":[]}',
  nativeAdapter: const _DictionaryNativeAdapter(),
  webAdapter: const _DictionaryWebAdapter(),
  idName: 'id',
  propertyIds: {
    'collapsed': 0,
    'dictionaryName': 1,
    'formatName': 2,
    'hidden': 3,
    'metadata': 4,
    'order': 5
  },
  listProperties: {},
  indexIds: {'dictionaryName': 0, 'order': 1},
  indexTypes: {
    'dictionaryName': [
      NativeIndexType.stringHash,
    ],
    'order': [
      NativeIndexType.long,
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
  setId: (obj, id) => obj.id = id,
  getLinks: (obj) => [],
  version: 2,
);

const _dictionaryImmutableStringMapConverter = ImmutableStringMapConverter();

class _DictionaryWebAdapter extends IsarWebTypeAdapter<Dictionary> {
  const _DictionaryWebAdapter();

  @override
  Object serialize(IsarCollection<Dictionary> collection, Dictionary object) {
    final jsObj = IsarNative.newJsObject();
    IsarNative.jsObjectSet(jsObj, 'collapsed', object.collapsed);
    IsarNative.jsObjectSet(jsObj, 'dictionaryName', object.dictionaryName);
    IsarNative.jsObjectSet(jsObj, 'formatName', object.formatName);
    IsarNative.jsObjectSet(jsObj, 'hidden', object.hidden);
    IsarNative.jsObjectSet(jsObj, 'id', object.id);
    IsarNative.jsObjectSet(jsObj, 'metadata',
        _dictionaryImmutableStringMapConverter.toIsar(object.metadata));
    IsarNative.jsObjectSet(jsObj, 'order', object.order);
    return jsObj;
  }

  @override
  Dictionary deserialize(IsarCollection<Dictionary> collection, dynamic jsObj) {
    final object = Dictionary(
      collapsed: IsarNative.jsObjectGet(jsObj, 'collapsed') ?? false,
      dictionaryName: IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '',
      formatName: IsarNative.jsObjectGet(jsObj, 'formatName') ?? '',
      hidden: IsarNative.jsObjectGet(jsObj, 'hidden') ?? false,
      metadata: _dictionaryImmutableStringMapConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'metadata') ?? ''),
      order: IsarNative.jsObjectGet(jsObj, 'order') ?? double.negativeInfinity,
    );
    object.id = IsarNative.jsObjectGet(jsObj, 'id');
    return object;
  }

  @override
  P deserializeProperty<P>(Object jsObj, String propertyName) {
    switch (propertyName) {
      case 'collapsed':
        return (IsarNative.jsObjectGet(jsObj, 'collapsed') ?? false) as P;
      case 'dictionaryName':
        return (IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '') as P;
      case 'formatName':
        return (IsarNative.jsObjectGet(jsObj, 'formatName') ?? '') as P;
      case 'hidden':
        return (IsarNative.jsObjectGet(jsObj, 'hidden') ?? false) as P;
      case 'id':
        return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
      case 'metadata':
        return (_dictionaryImmutableStringMapConverter
            .fromIsar(IsarNative.jsObjectGet(jsObj, 'metadata') ?? '')) as P;
      case 'order':
        return (IsarNative.jsObjectGet(jsObj, 'order') ??
            double.negativeInfinity) as P;
      default:
        throw 'Illegal propertyName';
    }
  }

  @override
  void attachLinks(Isar isar, int id, Dictionary object) {}
}

class _DictionaryNativeAdapter extends IsarNativeTypeAdapter<Dictionary> {
  const _DictionaryNativeAdapter();

  @override
  void serialize(
      IsarCollection<Dictionary> collection,
      IsarRawObject rawObj,
      Dictionary object,
      int staticSize,
      List<int> offsets,
      AdapterAlloc alloc) {
    var dynamicSize = 0;
    final value0 = object.collapsed;
    final _collapsed = value0;
    final value1 = object.dictionaryName;
    final _dictionaryName = IsarBinaryWriter.utf8Encoder.convert(value1);
    dynamicSize += (_dictionaryName.length) as int;
    final value2 = object.formatName;
    final _formatName = IsarBinaryWriter.utf8Encoder.convert(value2);
    dynamicSize += (_formatName.length) as int;
    final value3 = object.hidden;
    final _hidden = value3;
    final value4 =
        _dictionaryImmutableStringMapConverter.toIsar(object.metadata);
    final _metadata = IsarBinaryWriter.utf8Encoder.convert(value4);
    dynamicSize += (_metadata.length) as int;
    final value5 = object.order;
    final _order = value5;
    final size = staticSize + dynamicSize;

    rawObj.buffer = alloc(size);
    rawObj.buffer_length = size;
    final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
    final writer = IsarBinaryWriter(buffer, staticSize);
    writer.writeBool(offsets[0], _collapsed);
    writer.writeBytes(offsets[1], _dictionaryName);
    writer.writeBytes(offsets[2], _formatName);
    writer.writeBool(offsets[3], _hidden);
    writer.writeBytes(offsets[4], _metadata);
    writer.writeLong(offsets[5], _order);
  }

  @override
  Dictionary deserialize(IsarCollection<Dictionary> collection, int id,
      IsarBinaryReader reader, List<int> offsets) {
    final object = Dictionary(
      collapsed: reader.readBool(offsets[0]),
      dictionaryName: reader.readString(offsets[1]),
      formatName: reader.readString(offsets[2]),
      hidden: reader.readBool(offsets[3]),
      metadata: _dictionaryImmutableStringMapConverter
          .fromIsar(reader.readString(offsets[4])),
      order: reader.readLong(offsets[5]),
    );
    object.id = id;
    return object;
  }

  @override
  P deserializeProperty<P>(
      int id, IsarBinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case -1:
        return id as P;
      case 0:
        return (reader.readBool(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readString(offset)) as P;
      case 3:
        return (reader.readBool(offset)) as P;
      case 4:
        return (_dictionaryImmutableStringMapConverter
            .fromIsar(reader.readString(offset))) as P;
      case 5:
        return (reader.readLong(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }

  @override
  void attachLinks(Isar isar, int id, Dictionary object) {}
}

extension DictionaryByIndex on IsarCollection<Dictionary> {
  Future<Dictionary?> getByDictionaryName(String dictionaryName) {
    return getByIndex('dictionaryName', [dictionaryName]);
  }

  Dictionary? getByDictionaryNameSync(String dictionaryName) {
    return getByIndexSync('dictionaryName', [dictionaryName]);
  }

  Future<bool> deleteByDictionaryName(String dictionaryName) {
    return deleteByIndex('dictionaryName', [dictionaryName]);
  }

  bool deleteByDictionaryNameSync(String dictionaryName) {
    return deleteByIndexSync('dictionaryName', [dictionaryName]);
  }

  Future<List<Dictionary?>> getAllByDictionaryName(
      List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return getAllByIndex('dictionaryName', values);
  }

  List<Dictionary?> getAllByDictionaryNameSync(
      List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return getAllByIndexSync('dictionaryName', values);
  }

  Future<int> deleteAllByDictionaryName(List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return deleteAllByIndex('dictionaryName', values);
  }

  int deleteAllByDictionaryNameSync(List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync('dictionaryName', values);
  }

  Future<Dictionary?> getByOrder(int order) {
    return getByIndex('order', [order]);
  }

  Dictionary? getByOrderSync(int order) {
    return getByIndexSync('order', [order]);
  }

  Future<bool> deleteByOrder(int order) {
    return deleteByIndex('order', [order]);
  }

  bool deleteByOrderSync(int order) {
    return deleteByIndexSync('order', [order]);
  }

  Future<List<Dictionary?>> getAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndex('order', values);
  }

  List<Dictionary?> getAllByOrderSync(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndexSync('order', values);
  }

  Future<int> deleteAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return deleteAllByIndex('order', values);
  }

  int deleteAllByOrderSync(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return deleteAllByIndexSync('order', values);
  }
}

extension DictionaryQueryWhereSort
    on QueryBuilder<Dictionary, Dictionary, QWhere> {
  QueryBuilder<Dictionary, Dictionary, QAfterWhere> anyId() {
    return addWhereClauseInternal(const WhereClause(indexName: null));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhere> anyDictionaryName() {
    return addWhereClauseInternal(
        const WhereClause(indexName: 'dictionaryName'));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhere> anyOrder() {
    return addWhereClauseInternal(const WhereClause(indexName: 'order'));
  }
}

extension DictionaryQueryWhere
    on QueryBuilder<Dictionary, Dictionary, QWhereClause> {
  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: true,
      upper: [id],
      includeUpper: true,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idNotEqualTo(
      int? id) {
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

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idGreaterThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: include,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idLessThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      upper: [id],
      includeUpper: include,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idBetween(
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

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> dictionaryNameEqualTo(
      String dictionaryName) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'dictionaryName',
      lower: [dictionaryName],
      includeLower: true,
      upper: [dictionaryName],
      includeUpper: true,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      dictionaryNameNotEqualTo(String dictionaryName) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(WhereClause(
        indexName: 'dictionaryName',
        upper: [dictionaryName],
        includeUpper: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'dictionaryName',
        lower: [dictionaryName],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(WhereClause(
        indexName: 'dictionaryName',
        lower: [dictionaryName],
        includeLower: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'dictionaryName',
        upper: [dictionaryName],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderEqualTo(
      int order) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'order',
      lower: [order],
      includeLower: true,
      upper: [order],
      includeUpper: true,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderNotEqualTo(
      int order) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(WhereClause(
        indexName: 'order',
        upper: [order],
        includeUpper: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'order',
        lower: [order],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(WhereClause(
        indexName: 'order',
        lower: [order],
        includeLower: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: 'order',
        upper: [order],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderGreaterThan(
    int order, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'order',
      lower: [order],
      includeLower: include,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderLessThan(
    int order, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'order',
      upper: [order],
      includeUpper: include,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: 'order',
      lower: [lowerOrder],
      includeLower: includeLower,
      upper: [upperOrder],
      includeUpper: includeUpper,
    ));
  }
}

extension DictionaryQueryFilter
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {
  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> collapsedEqualTo(
      bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'collapsed',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'dictionaryName',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'dictionaryName',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'formatName',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'formatName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'formatName',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> hiddenEqualTo(
      bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'hidden',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idEqualTo(
      int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataEqualTo(
    Map<String, dynamic> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      metadataGreaterThan(
    Map<String, dynamic> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataLessThan(
    Map<String, dynamic> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataBetween(
    Map<String, dynamic> lower,
    Map<String, dynamic> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'metadata',
      lower: _dictionaryImmutableStringMapConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _dictionaryImmutableStringMapConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      metadataStartsWith(
    Map<String, dynamic> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataEndsWith(
    Map<String, dynamic> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataContains(
      Map<String, dynamic> value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'metadata',
      value: _dictionaryImmutableStringMapConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> metadataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'metadata',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'order',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }
}

extension DictionaryQueryLinks
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {}

extension DictionaryQueryWhereSortBy
    on QueryBuilder<Dictionary, Dictionary, QSortBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByCollapsed() {
    return addSortByInternal('collapsed', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByCollapsedDesc() {
    return addSortByInternal('collapsed', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatName() {
    return addSortByInternal('formatName', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatNameDesc() {
    return addSortByInternal('formatName', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHidden() {
    return addSortByInternal('hidden', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHiddenDesc() {
    return addSortByInternal('hidden', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByMetadata() {
    return addSortByInternal('metadata', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByMetadataDesc() {
    return addSortByInternal('metadata', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByOrder() {
    return addSortByInternal('order', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByOrderDesc() {
    return addSortByInternal('order', Sort.desc);
  }
}

extension DictionaryQueryWhereSortThenBy
    on QueryBuilder<Dictionary, Dictionary, QSortThenBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByCollapsed() {
    return addSortByInternal('collapsed', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByCollapsedDesc() {
    return addSortByInternal('collapsed', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatName() {
    return addSortByInternal('formatName', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatNameDesc() {
    return addSortByInternal('formatName', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHidden() {
    return addSortByInternal('hidden', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHiddenDesc() {
    return addSortByInternal('hidden', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByMetadata() {
    return addSortByInternal('metadata', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByMetadataDesc() {
    return addSortByInternal('metadata', Sort.desc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByOrder() {
    return addSortByInternal('order', Sort.asc);
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByOrderDesc() {
    return addSortByInternal('order', Sort.desc);
  }
}

extension DictionaryQueryWhereDistinct
    on QueryBuilder<Dictionary, Dictionary, QDistinct> {
  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByCollapsed() {
    return addDistinctByInternal('collapsed');
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByDictionaryName(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('dictionaryName',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByFormatName(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('formatName', caseSensitive: caseSensitive);
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByHidden() {
    return addDistinctByInternal('hidden');
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByMetadata(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('metadata', caseSensitive: caseSensitive);
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByOrder() {
    return addDistinctByInternal('order');
  }
}

extension DictionaryQueryProperty
    on QueryBuilder<Dictionary, Dictionary, QQueryProperty> {
  QueryBuilder<Dictionary, bool, QQueryOperations> collapsedProperty() {
    return addPropertyNameInternal('collapsed');
  }

  QueryBuilder<Dictionary, String, QQueryOperations> dictionaryNameProperty() {
    return addPropertyNameInternal('dictionaryName');
  }

  QueryBuilder<Dictionary, String, QQueryOperations> formatNameProperty() {
    return addPropertyNameInternal('formatName');
  }

  QueryBuilder<Dictionary, bool, QQueryOperations> hiddenProperty() {
    return addPropertyNameInternal('hidden');
  }

  QueryBuilder<Dictionary, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<Dictionary, Map<String, dynamic>, QQueryOperations>
      metadataProperty() {
    return addPropertyNameInternal('metadata');
  }

  QueryBuilder<Dictionary, int, QQueryOperations> orderProperty() {
    return addPropertyNameInternal('order');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dictionary _$DictionaryFromJson(Map<String, dynamic> json) => Dictionary(
      dictionaryName: json['dictionaryName'] as String,
      formatName: json['formatName'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      order: json['order'] as int,
      collapsed: json['collapsed'] as bool,
      hidden: json['hidden'] as bool,
    )..id = json['id'] as int?;

Map<String, dynamic> _$DictionaryToJson(Dictionary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dictionaryName': instance.dictionaryName,
      'formatName': instance.formatName,
      'order': instance.order,
      'collapsed': instance.collapsed,
      'hidden': instance.hidden,
      'metadata': instance.metadata,
    };
