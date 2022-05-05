// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anki_mapping.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetAnkiMappingCollection on Isar {
  IsarCollection<AnkiMapping> get ankiMappings => getCollection();
}

const AnkiMappingSchema = CollectionSchema(
  name: 'AnkiMapping',
  schema:
      '{"name":"AnkiMapping","idName":"id","properties":[{"name":"fieldIndexes","type":"LongList"},{"name":"label","type":"String"},{"name":"model","type":"String"},{"name":"order","type":"Long"},{"name":"tags","type":"StringList"}],"indexes":[{"name":"label","unique":true,"properties":[{"name":"label","type":"Hash","caseSensitive":true}]},{"name":"order","unique":true,"properties":[{"name":"order","type":"Value","caseSensitive":false}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'fieldIndexes': 0,
    'label': 1,
    'model': 2,
    'order': 3,
    'tags': 4
  },
  listProperties: {'fieldIndexes', 'tags'},
  indexIds: {'label': 0, 'order': 1},
  indexValueTypes: {
    'label': [
      IndexValueType.stringHash,
    ],
    'order': [
      IndexValueType.long,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _ankiMappingGetId,
  setId: _ankiMappingSetId,
  getLinks: _ankiMappingGetLinks,
  attachLinks: _ankiMappingAttachLinks,
  serializeNative: _ankiMappingSerializeNative,
  deserializeNative: _ankiMappingDeserializeNative,
  deserializePropNative: _ankiMappingDeserializePropNative,
  serializeWeb: _ankiMappingSerializeWeb,
  deserializeWeb: _ankiMappingDeserializeWeb,
  deserializePropWeb: _ankiMappingDeserializePropWeb,
  version: 3,
);

int? _ankiMappingGetId(AnkiMapping object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _ankiMappingSetId(AnkiMapping object, int id) {
  object.id = id;
}

List<IsarLinkBase> _ankiMappingGetLinks(AnkiMapping object) {
  return [];
}

void _ankiMappingSerializeNative(
    IsarCollection<AnkiMapping> collection,
    IsarRawObject rawObj,
    AnkiMapping object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.fieldIndexes;
  dynamicSize += (value0.length) * 8;
  final _fieldIndexes = value0;
  final value1 = object.label;
  final _label = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_label.length) as int;
  final value2 = object.model;
  final _model = IsarBinaryWriter.utf8Encoder.convert(value2);
  dynamicSize += (_model.length) as int;
  final value3 = object.order;
  final _order = value3;
  final value4 = object.tags;
  dynamicSize += (value4.length) * 8;
  final bytesList4 = <IsarUint8List>[];
  for (var str in value4) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList4.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _tags = bytesList4;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeLongList(offsets[0], _fieldIndexes);
  writer.writeBytes(offsets[1], _label);
  writer.writeBytes(offsets[2], _model);
  writer.writeLong(offsets[3], _order);
  writer.writeStringList(offsets[4], _tags);
}

AnkiMapping _ankiMappingDeserializeNative(
    IsarCollection<AnkiMapping> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = AnkiMapping(
    fieldIndexes: reader.readLongOrNullList(offsets[0]) ?? [],
    id: id,
    label: reader.readString(offsets[1]),
    model: reader.readString(offsets[2]),
    order: reader.readLong(offsets[3]),
    tags: reader.readStringList(offsets[4]) ?? [],
  );
  return object;
}

P _ankiMappingDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readLongOrNullList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _ankiMappingSerializeWeb(
    IsarCollection<AnkiMapping> collection, AnkiMapping object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'fieldIndexes', object.fieldIndexes);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'label', object.label);
  IsarNative.jsObjectSet(jsObj, 'model', object.model);
  IsarNative.jsObjectSet(jsObj, 'order', object.order);
  IsarNative.jsObjectSet(jsObj, 'tags', object.tags);
  return jsObj;
}

AnkiMapping _ankiMappingDeserializeWeb(
    IsarCollection<AnkiMapping> collection, dynamic jsObj) {
  final object = AnkiMapping(
    fieldIndexes: (IsarNative.jsObjectGet(jsObj, 'fieldIndexes') as List?)
            ?.cast<int?>() ??
        [],
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    label: IsarNative.jsObjectGet(jsObj, 'label') ?? '',
    model: IsarNative.jsObjectGet(jsObj, 'model') ?? '',
    order: IsarNative.jsObjectGet(jsObj, 'order') ?? double.negativeInfinity,
    tags: (IsarNative.jsObjectGet(jsObj, 'tags') as List?)
            ?.map((e) => e ?? '')
            .toList()
            .cast<String>() ??
        [],
  );
  return object;
}

P _ankiMappingDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'fieldIndexes':
      return ((IsarNative.jsObjectGet(jsObj, 'fieldIndexes') as List?)
              ?.cast<int?>() ??
          []) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'label':
      return (IsarNative.jsObjectGet(jsObj, 'label') ?? '') as P;
    case 'model':
      return (IsarNative.jsObjectGet(jsObj, 'model') ?? '') as P;
    case 'order':
      return (IsarNative.jsObjectGet(jsObj, 'order') ?? double.negativeInfinity)
          as P;
    case 'tags':
      return ((IsarNative.jsObjectGet(jsObj, 'tags') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _ankiMappingAttachLinks(IsarCollection col, int id, AnkiMapping object) {}

extension AnkiMappingByIndex on IsarCollection<AnkiMapping> {
  Future<AnkiMapping?> getByLabel(String label) {
    return getByIndex('label', [label]);
  }

  AnkiMapping? getByLabelSync(String label) {
    return getByIndexSync('label', [label]);
  }

  Future<bool> deleteByLabel(String label) {
    return deleteByIndex('label', [label]);
  }

  bool deleteByLabelSync(String label) {
    return deleteByIndexSync('label', [label]);
  }

  Future<List<AnkiMapping?>> getAllByLabel(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return getAllByIndex('label', values);
  }

  List<AnkiMapping?> getAllByLabelSync(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return getAllByIndexSync('label', values);
  }

  Future<int> deleteAllByLabel(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return deleteAllByIndex('label', values);
  }

  int deleteAllByLabelSync(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return deleteAllByIndexSync('label', values);
  }

  Future<AnkiMapping?> getByOrder(int order) {
    return getByIndex('order', [order]);
  }

  AnkiMapping? getByOrderSync(int order) {
    return getByIndexSync('order', [order]);
  }

  Future<bool> deleteByOrder(int order) {
    return deleteByIndex('order', [order]);
  }

  bool deleteByOrderSync(int order) {
    return deleteByIndexSync('order', [order]);
  }

  Future<List<AnkiMapping?>> getAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndex('order', values);
  }

  List<AnkiMapping?> getAllByOrderSync(List<int> orderValues) {
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

extension AnkiMappingQueryWhereSort
    on QueryBuilder<AnkiMapping, AnkiMapping, QWhere> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhere> anyLabel() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'label'));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhere> anyOrder() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'order'));
  }
}

extension AnkiMappingQueryWhere
    on QueryBuilder<AnkiMapping, AnkiMapping, QWhereClause> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idEqualTo(int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idLessThan(int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> labelEqualTo(
      String label) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'label',
      value: [label],
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> labelNotEqualTo(
      String label) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'label',
        upper: [label],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'label',
        lower: [label],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'label',
        lower: [label],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'label',
        upper: [label],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderEqualTo(
      int order) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'order',
      value: [order],
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderNotEqualTo(
      int order) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'order',
        upper: [order],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'order',
        lower: [order],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'order',
        lower: [order],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'order',
        upper: [order],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderGreaterThan(
    int order, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'order',
      lower: [order],
      includeLower: include,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderLessThan(
    int order, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'order',
      upper: [order],
      includeUpper: include,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'order',
      lower: [lowerOrder],
      includeLower: includeLower,
      upper: [upperOrder],
      includeUpper: includeUpper,
    ));
  }
}

extension AnkiMappingQueryFilter
    on QueryBuilder<AnkiMapping, AnkiMapping, QFilterCondition> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      fieldIndexesAnyEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'fieldIndexes',
      value: value,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      fieldIndexesAnyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'fieldIndexes',
      value: value,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      fieldIndexesAnyLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'fieldIndexes',
      value: value,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      fieldIndexesAnyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'fieldIndexes',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'label',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'label',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'label',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      modelGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'model',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'model',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'model',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      orderGreaterThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderLessThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'tags',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'tags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsAnyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'tags',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension AnkiMappingQueryLinks
    on QueryBuilder<AnkiMapping, AnkiMapping, QFilterCondition> {}

extension AnkiMappingQueryWhereSortBy
    on QueryBuilder<AnkiMapping, AnkiMapping, QSortBy> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByLabel() {
    return addSortByInternal('label', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByLabelDesc() {
    return addSortByInternal('label', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByModel() {
    return addSortByInternal('model', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByModelDesc() {
    return addSortByInternal('model', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByOrder() {
    return addSortByInternal('order', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByOrderDesc() {
    return addSortByInternal('order', Sort.desc);
  }
}

extension AnkiMappingQueryWhereSortThenBy
    on QueryBuilder<AnkiMapping, AnkiMapping, QSortThenBy> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByLabel() {
    return addSortByInternal('label', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByLabelDesc() {
    return addSortByInternal('label', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByModel() {
    return addSortByInternal('model', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByModelDesc() {
    return addSortByInternal('model', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByOrder() {
    return addSortByInternal('order', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByOrderDesc() {
    return addSortByInternal('order', Sort.desc);
  }
}

extension AnkiMappingQueryWhereDistinct
    on QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> {
  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('label', caseSensitive: caseSensitive);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('model', caseSensitive: caseSensitive);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByOrder() {
    return addDistinctByInternal('order');
  }
}

extension AnkiMappingQueryProperty
    on QueryBuilder<AnkiMapping, AnkiMapping, QQueryProperty> {
  QueryBuilder<AnkiMapping, List<int?>, QQueryOperations>
      fieldIndexesProperty() {
    return addPropertyNameInternal('fieldIndexes');
  }

  QueryBuilder<AnkiMapping, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations> labelProperty() {
    return addPropertyNameInternal('label');
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations> modelProperty() {
    return addPropertyNameInternal('model');
  }

  QueryBuilder<AnkiMapping, int, QQueryOperations> orderProperty() {
    return addPropertyNameInternal('order');
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations> tagsProperty() {
    return addPropertyNameInternal('tags');
  }
}
