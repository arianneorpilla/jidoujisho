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
      '{"name":"AnkiMapping","idName":"id","properties":[{"name":"actions","type":"String"},{"name":"creatorCollapsedFieldKeys","type":"StringList"},{"name":"creatorFieldKeys","type":"StringList"},{"name":"enhancements","type":"String"},{"name":"exportFieldKeys","type":"StringList"},{"name":"label","type":"String"},{"name":"model","type":"String"},{"name":"order","type":"Long"},{"name":"tags","type":"StringList"}],"indexes":[{"name":"label","unique":true,"properties":[{"name":"label","type":"Hash","caseSensitive":true}]},{"name":"order","unique":true,"properties":[{"name":"order","type":"Value","caseSensitive":false}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'actions': 0,
    'creatorCollapsedFieldKeys': 1,
    'creatorFieldKeys': 2,
    'enhancements': 3,
    'exportFieldKeys': 4,
    'label': 5,
    'model': 6,
    'order': 7,
    'tags': 8
  },
  listProperties: {
    'creatorCollapsedFieldKeys',
    'creatorFieldKeys',
    'exportFieldKeys',
    'tags'
  },
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

const _ankiMappingQuickActionsConverter = QuickActionsConverter();
const _ankiMappingEnhancementsConverter = EnhancementsConverter();

void _ankiMappingSerializeNative(
    IsarCollection<AnkiMapping> collection,
    IsarRawObject rawObj,
    AnkiMapping object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = _ankiMappingQuickActionsConverter.toIsar(object.actions);
  final _actions = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_actions.length) as int;
  final value1 = object.creatorCollapsedFieldKeys;
  dynamicSize += (value1.length) * 8;
  final bytesList1 = <IsarUint8List>[];
  for (var str in value1) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList1.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _creatorCollapsedFieldKeys = bytesList1;
  final value2 = object.creatorFieldKeys;
  dynamicSize += (value2.length) * 8;
  final bytesList2 = <IsarUint8List>[];
  for (var str in value2) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList2.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _creatorFieldKeys = bytesList2;
  final value3 = _ankiMappingEnhancementsConverter.toIsar(object.enhancements);
  final _enhancements = IsarBinaryWriter.utf8Encoder.convert(value3);
  dynamicSize += (_enhancements.length) as int;
  final value4 = object.exportFieldKeys;
  dynamicSize += (value4.length) * 8;
  final bytesList4 = <IsarUint8List?>[];
  for (var str in value4) {
    if (str != null) {
      final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
      bytesList4.add(bytes);
      dynamicSize += bytes.length as int;
    } else {
      bytesList4.add(null);
    }
  }
  final _exportFieldKeys = bytesList4;
  final value5 = object.label;
  final _label = IsarBinaryWriter.utf8Encoder.convert(value5);
  dynamicSize += (_label.length) as int;
  final value6 = object.model;
  final _model = IsarBinaryWriter.utf8Encoder.convert(value6);
  dynamicSize += (_model.length) as int;
  final value7 = object.order;
  final _order = value7;
  final value8 = object.tags;
  dynamicSize += (value8.length) * 8;
  final bytesList8 = <IsarUint8List>[];
  for (var str in value8) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList8.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _tags = bytesList8;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _actions);
  writer.writeStringList(offsets[1], _creatorCollapsedFieldKeys);
  writer.writeStringList(offsets[2], _creatorFieldKeys);
  writer.writeBytes(offsets[3], _enhancements);
  writer.writeStringList(offsets[4], _exportFieldKeys);
  writer.writeBytes(offsets[5], _label);
  writer.writeBytes(offsets[6], _model);
  writer.writeLong(offsets[7], _order);
  writer.writeStringList(offsets[8], _tags);
}

AnkiMapping _ankiMappingDeserializeNative(
    IsarCollection<AnkiMapping> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = AnkiMapping(
    actions: _ankiMappingQuickActionsConverter
        .fromIsar(reader.readString(offsets[0])),
    creatorCollapsedFieldKeys: reader.readStringList(offsets[1]) ?? [],
    creatorFieldKeys: reader.readStringList(offsets[2]) ?? [],
    enhancements: _ankiMappingEnhancementsConverter
        .fromIsar(reader.readString(offsets[3])),
    exportFieldKeys: reader.readStringOrNullList(offsets[4]) ?? [],
    id: id,
    label: reader.readString(offsets[5]),
    model: reader.readString(offsets[6]),
    order: reader.readLong(offsets[7]),
    tags: reader.readStringList(offsets[8]) ?? [],
  );
  return object;
}

P _ankiMappingDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (_ankiMappingQuickActionsConverter
          .fromIsar(reader.readString(offset))) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (_ankiMappingEnhancementsConverter
          .fromIsar(reader.readString(offset))) as P;
    case 4:
      return (reader.readStringOrNullList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _ankiMappingSerializeWeb(
    IsarCollection<AnkiMapping> collection, AnkiMapping object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'actions',
      _ankiMappingQuickActionsConverter.toIsar(object.actions));
  IsarNative.jsObjectSet(
      jsObj, 'creatorCollapsedFieldKeys', object.creatorCollapsedFieldKeys);
  IsarNative.jsObjectSet(jsObj, 'creatorFieldKeys', object.creatorFieldKeys);
  IsarNative.jsObjectSet(jsObj, 'enhancements',
      _ankiMappingEnhancementsConverter.toIsar(object.enhancements));
  IsarNative.jsObjectSet(jsObj, 'exportFieldKeys', object.exportFieldKeys);
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
    actions: _ankiMappingQuickActionsConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'actions') ?? ''),
    creatorCollapsedFieldKeys:
        (IsarNative.jsObjectGet(jsObj, 'creatorCollapsedFieldKeys') as List?)
                ?.map((e) => e ?? '')
                .toList()
                .cast<String>() ??
            [],
    creatorFieldKeys:
        (IsarNative.jsObjectGet(jsObj, 'creatorFieldKeys') as List?)
                ?.map((e) => e ?? '')
                .toList()
                .cast<String>() ??
            [],
    enhancements: _ankiMappingEnhancementsConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'enhancements') ?? ''),
    exportFieldKeys: (IsarNative.jsObjectGet(jsObj, 'exportFieldKeys') as List?)
            ?.cast<String?>() ??
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
    case 'actions':
      return (_ankiMappingQuickActionsConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'actions') ?? '')) as P;
    case 'creatorCollapsedFieldKeys':
      return ((IsarNative.jsObjectGet(jsObj, 'creatorCollapsedFieldKeys')
                  as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    case 'creatorFieldKeys':
      return ((IsarNative.jsObjectGet(jsObj, 'creatorFieldKeys') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    case 'enhancements':
      return (_ankiMappingEnhancementsConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'enhancements') ?? '')) as P;
    case 'exportFieldKeys':
      return ((IsarNative.jsObjectGet(jsObj, 'exportFieldKeys') as List?)
              ?.cast<String?>() ??
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
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsEqualTo(
    Map<int, String> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsGreaterThan(
    Map<int, String> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsLessThan(
    Map<int, String> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsBetween(
    Map<int, String> lower,
    Map<int, String> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'actions',
      lower: _ankiMappingQuickActionsConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _ankiMappingQuickActionsConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsStartsWith(
    Map<int, String> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsEndsWith(
    Map<int, String> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsContains(
      Map<int, String> value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'actions',
      value: _ankiMappingQuickActionsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> actionsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'actions',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'creatorCollapsedFieldKeys',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyContains(String value,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'creatorCollapsedFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysAnyMatches(String pattern,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'creatorCollapsedFieldKeys',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'creatorFieldKeys',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'creatorFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'creatorFieldKeys',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsEqualTo(
    Map<String, Map<int, String>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsGreaterThan(
    Map<String, Map<int, String>> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsLessThan(
    Map<String, Map<int, String>> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsBetween(
    Map<String, Map<int, String>> lower,
    Map<String, Map<int, String>> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'enhancements',
      lower: _ankiMappingEnhancementsConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _ankiMappingEnhancementsConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsStartsWith(
    Map<String, Map<int, String>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsEndsWith(
    Map<String, Map<int, String>> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsContains(Map<String, Map<int, String>> value,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'enhancements',
      value: _ankiMappingEnhancementsConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'enhancements',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'exportFieldKeys',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'exportFieldKeys',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'exportFieldKeys',
      value: pattern,
      caseSensitive: caseSensitive,
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
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByActions() {
    return addSortByInternal('actions', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByActionsDesc() {
    return addSortByInternal('actions', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByEnhancements() {
    return addSortByInternal('enhancements', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      sortByEnhancementsDesc() {
    return addSortByInternal('enhancements', Sort.desc);
  }

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
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByActions() {
    return addSortByInternal('actions', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByActionsDesc() {
    return addSortByInternal('actions', Sort.desc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByEnhancements() {
    return addSortByInternal('enhancements', Sort.asc);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      thenByEnhancementsDesc() {
    return addSortByInternal('enhancements', Sort.desc);
  }

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
  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByActions(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('actions', caseSensitive: caseSensitive);
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByEnhancements(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('enhancements', caseSensitive: caseSensitive);
  }

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
  QueryBuilder<AnkiMapping, Map<int, String>, QQueryOperations>
      actionsProperty() {
    return addPropertyNameInternal('actions');
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations>
      creatorCollapsedFieldKeysProperty() {
    return addPropertyNameInternal('creatorCollapsedFieldKeys');
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations>
      creatorFieldKeysProperty() {
    return addPropertyNameInternal('creatorFieldKeys');
  }

  QueryBuilder<AnkiMapping, Map<String, Map<int, String>>, QQueryOperations>
      enhancementsProperty() {
    return addPropertyNameInternal('enhancements');
  }

  QueryBuilder<AnkiMapping, List<String?>, QQueryOperations>
      exportFieldKeysProperty() {
    return addPropertyNameInternal('exportFieldKeys');
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnkiMapping _$AnkiMappingFromJson(Map<String, dynamic> json) => AnkiMapping(
      label: json['label'] as String,
      model: json['model'] as String,
      exportFieldKeys: (json['exportFieldKeys'] as List<dynamic>)
          .map((e) => e as String?)
          .toList(),
      creatorFieldKeys: (json['creatorFieldKeys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      creatorCollapsedFieldKeys:
          (json['creatorCollapsedFieldKeys'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      order: json['order'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      enhancements: (json['enhancements'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(int.parse(k), e as String),
            )),
      ),
      actions: (json['actions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      id: json['id'] as int?,
    );

Map<String, dynamic> _$AnkiMappingToJson(AnkiMapping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'model': instance.model,
      'exportFieldKeys': instance.exportFieldKeys,
      'creatorFieldKeys': instance.creatorFieldKeys,
      'creatorCollapsedFieldKeys': instance.creatorCollapsedFieldKeys,
      'tags': instance.tags,
      'actions': instance.actions.map((k, e) => MapEntry(k.toString(), e)),
      'enhancements': instance.enhancements.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'order': instance.order,
    };
