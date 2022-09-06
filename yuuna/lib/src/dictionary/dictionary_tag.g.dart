// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_tag.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetDictionaryTagCollection on Isar {
  IsarCollection<DictionaryTag> get dictionaryTags => getCollection();
}

const DictionaryTagSchema = CollectionSchema(
  name: 'DictionaryTag',
  schema:
      '{"name":"DictionaryTag","idName":"id","properties":[{"name":"category","type":"String"},{"name":"dictionaryName","type":"String"},{"name":"name","type":"String"},{"name":"notes","type":"String"},{"name":"popularity","type":"Double"},{"name":"sortingOrder","type":"Long"},{"name":"uniqueKey","type":"String"}],"indexes":[{"name":"dictionaryName","unique":false,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"name","unique":false,"properties":[{"name":"name","type":"Hash","caseSensitive":true}]},{"name":"uniqueKey","unique":true,"properties":[{"name":"uniqueKey","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'category': 0,
    'dictionaryName': 1,
    'name': 2,
    'notes': 3,
    'popularity': 4,
    'sortingOrder': 5,
    'uniqueKey': 6
  },
  listProperties: {},
  indexIds: {'dictionaryName': 0, 'name': 1, 'uniqueKey': 2},
  indexValueTypes: {
    'dictionaryName': [
      IndexValueType.stringHash,
    ],
    'name': [
      IndexValueType.stringHash,
    ],
    'uniqueKey': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _dictionaryTagGetId,
  setId: _dictionaryTagSetId,
  getLinks: _dictionaryTagGetLinks,
  attachLinks: _dictionaryTagAttachLinks,
  serializeNative: _dictionaryTagSerializeNative,
  deserializeNative: _dictionaryTagDeserializeNative,
  deserializePropNative: _dictionaryTagDeserializePropNative,
  serializeWeb: _dictionaryTagSerializeWeb,
  deserializeWeb: _dictionaryTagDeserializeWeb,
  deserializePropWeb: _dictionaryTagDeserializePropWeb,
  version: 3,
);

int? _dictionaryTagGetId(DictionaryTag object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _dictionaryTagSetId(DictionaryTag object, int id) {
  object.id = id;
}

List<IsarLinkBase> _dictionaryTagGetLinks(DictionaryTag object) {
  return [];
}

void _dictionaryTagSerializeNative(
    IsarCollection<DictionaryTag> collection,
    IsarRawObject rawObj,
    DictionaryTag object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.category;
  final _category = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_category.length) as int;
  final value1 = object.dictionaryName;
  final _dictionaryName = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_dictionaryName.length) as int;
  final value2 = object.name;
  final _name = IsarBinaryWriter.utf8Encoder.convert(value2);
  dynamicSize += (_name.length) as int;
  final value3 = object.notes;
  final _notes = IsarBinaryWriter.utf8Encoder.convert(value3);
  dynamicSize += (_notes.length) as int;
  final value4 = object.popularity;
  final _popularity = value4;
  final value5 = object.sortingOrder;
  final _sortingOrder = value5;
  final value6 = object.uniqueKey;
  final _uniqueKey = IsarBinaryWriter.utf8Encoder.convert(value6);
  dynamicSize += (_uniqueKey.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _category);
  writer.writeBytes(offsets[1], _dictionaryName);
  writer.writeBytes(offsets[2], _name);
  writer.writeBytes(offsets[3], _notes);
  writer.writeDouble(offsets[4], _popularity);
  writer.writeLong(offsets[5], _sortingOrder);
  writer.writeBytes(offsets[6], _uniqueKey);
}

DictionaryTag _dictionaryTagDeserializeNative(
    IsarCollection<DictionaryTag> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryTag(
    category: reader.readString(offsets[0]),
    dictionaryName: reader.readString(offsets[1]),
    id: id,
    name: reader.readString(offsets[2]),
    notes: reader.readString(offsets[3]),
    popularity: reader.readDoubleOrNull(offsets[4]),
    sortingOrder: reader.readLong(offsets[5]),
  );
  return object;
}

P _dictionaryTagDeserializePropNative<P>(
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
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryTagSerializeWeb(
    IsarCollection<DictionaryTag> collection, DictionaryTag object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'category', object.category);
  IsarNative.jsObjectSet(jsObj, 'dictionaryName', object.dictionaryName);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'name', object.name);
  IsarNative.jsObjectSet(jsObj, 'notes', object.notes);
  IsarNative.jsObjectSet(jsObj, 'popularity', object.popularity);
  IsarNative.jsObjectSet(jsObj, 'sortingOrder', object.sortingOrder);
  IsarNative.jsObjectSet(jsObj, 'uniqueKey', object.uniqueKey);
  return jsObj;
}

DictionaryTag _dictionaryTagDeserializeWeb(
    IsarCollection<DictionaryTag> collection, dynamic jsObj) {
  final object = DictionaryTag(
    category: IsarNative.jsObjectGet(jsObj, 'category') ?? '',
    dictionaryName: IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '',
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    name: IsarNative.jsObjectGet(jsObj, 'name') ?? '',
    notes: IsarNative.jsObjectGet(jsObj, 'notes') ?? '',
    popularity: IsarNative.jsObjectGet(jsObj, 'popularity'),
    sortingOrder: IsarNative.jsObjectGet(jsObj, 'sortingOrder') ??
        double.negativeInfinity,
  );
  return object;
}

P _dictionaryTagDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'category':
      return (IsarNative.jsObjectGet(jsObj, 'category') ?? '') as P;
    case 'dictionaryName':
      return (IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '') as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'name':
      return (IsarNative.jsObjectGet(jsObj, 'name') ?? '') as P;
    case 'notes':
      return (IsarNative.jsObjectGet(jsObj, 'notes') ?? '') as P;
    case 'popularity':
      return (IsarNative.jsObjectGet(jsObj, 'popularity')) as P;
    case 'sortingOrder':
      return (IsarNative.jsObjectGet(jsObj, 'sortingOrder') ??
          double.negativeInfinity) as P;
    case 'uniqueKey':
      return (IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _dictionaryTagAttachLinks(
    IsarCollection col, int id, DictionaryTag object) {}

extension DictionaryTagByIndex on IsarCollection<DictionaryTag> {
  Future<DictionaryTag?> getByUniqueKey(String uniqueKey) {
    return getByIndex('uniqueKey', [uniqueKey]);
  }

  DictionaryTag? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex('uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<List<DictionaryTag?>> getAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex('uniqueKey', values);
  }

  List<DictionaryTag?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
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

extension DictionaryTagQueryWhereSort
    on QueryBuilder<DictionaryTag, DictionaryTag, QWhere> {
  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhere> anyDictionaryName() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'dictionaryName'));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhere> anyName() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'name'));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhere> anyUniqueKey() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'uniqueKey'));
  }
}

extension DictionaryTagQueryWhere
    on QueryBuilder<DictionaryTag, DictionaryTag, QWhereClause> {
  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> idLessThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause>
      dictionaryNameEqualTo(String dictionaryName) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'dictionaryName',
      value: [dictionaryName],
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause>
      dictionaryNameNotEqualTo(String dictionaryName) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'dictionaryName',
        upper: [dictionaryName],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'dictionaryName',
        lower: [dictionaryName],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'dictionaryName',
        lower: [dictionaryName],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'dictionaryName',
        upper: [dictionaryName],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> nameEqualTo(
      String name) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'name',
      value: [name],
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause> nameNotEqualTo(
      String name) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'name',
        upper: [name],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'name',
        lower: [name],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'name',
        lower: [name],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'name',
        upper: [name],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause>
      uniqueKeyEqualTo(String uniqueKey) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'uniqueKey',
      value: [uniqueKey],
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterWhereClause>
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

extension DictionaryTagQueryFilter
    on QueryBuilder<DictionaryTag, DictionaryTag, QFilterCondition> {
  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'category',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'category',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'category',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'dictionaryName',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'name',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'name',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'notes',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'notes',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'notes',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      popularityIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'popularity',
      value: null,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      popularityGreaterThan(double? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: false,
      property: 'popularity',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      popularityLessThan(double? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: false,
      property: 'popularity',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      popularityBetween(double? lower, double? upper) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'popularity',
      lower: lower,
      includeLower: false,
      upper: upper,
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      sortingOrderEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sortingOrder',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      sortingOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sortingOrder',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      sortingOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sortingOrder',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      sortingOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sortingOrder',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'uniqueKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionaryTagQueryLinks
    on QueryBuilder<DictionaryTag, DictionaryTag, QFilterCondition> {}

extension DictionaryTagQueryWhereSortBy
    on QueryBuilder<DictionaryTag, DictionaryTag, QSortBy> {
  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByCategory() {
    return addSortByInternal('category', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortByCategoryDesc() {
    return addSortByInternal('category', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByName() {
    return addSortByInternal('name', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByNameDesc() {
    return addSortByInternal('name', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByNotes() {
    return addSortByInternal('notes', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByNotesDesc() {
    return addSortByInternal('notes', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByPopularity() {
    return addSortByInternal('popularity', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortByPopularityDesc() {
    return addSortByInternal('popularity', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortBySortingOrder() {
    return addSortByInternal('sortingOrder', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortBySortingOrderDesc() {
    return addSortByInternal('sortingOrder', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> sortByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension DictionaryTagQueryWhereSortThenBy
    on QueryBuilder<DictionaryTag, DictionaryTag, QSortThenBy> {
  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByCategory() {
    return addSortByInternal('category', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenByCategoryDesc() {
    return addSortByInternal('category', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByName() {
    return addSortByInternal('name', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByNameDesc() {
    return addSortByInternal('name', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByNotes() {
    return addSortByInternal('notes', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByNotesDesc() {
    return addSortByInternal('notes', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByPopularity() {
    return addSortByInternal('popularity', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenByPopularityDesc() {
    return addSortByInternal('popularity', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenBySortingOrder() {
    return addSortByInternal('sortingOrder', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenBySortingOrderDesc() {
    return addSortByInternal('sortingOrder', Sort.desc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy> thenByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension DictionaryTagQueryWhereDistinct
    on QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> {
  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('category', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct>
      distinctByDictionaryName({bool caseSensitive = true}) {
    return addDistinctByInternal('dictionaryName',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('name', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('notes', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctByPopularity() {
    return addDistinctByInternal('popularity');
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct>
      distinctBySortingOrder() {
    return addDistinctByInternal('sortingOrder');
  }

  QueryBuilder<DictionaryTag, DictionaryTag, QDistinct> distinctByUniqueKey(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('uniqueKey', caseSensitive: caseSensitive);
  }
}

extension DictionaryTagQueryProperty
    on QueryBuilder<DictionaryTag, DictionaryTag, QQueryProperty> {
  QueryBuilder<DictionaryTag, String, QQueryOperations> categoryProperty() {
    return addPropertyNameInternal('category');
  }

  QueryBuilder<DictionaryTag, String, QQueryOperations>
      dictionaryNameProperty() {
    return addPropertyNameInternal('dictionaryName');
  }

  QueryBuilder<DictionaryTag, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryTag, String, QQueryOperations> nameProperty() {
    return addPropertyNameInternal('name');
  }

  QueryBuilder<DictionaryTag, String, QQueryOperations> notesProperty() {
    return addPropertyNameInternal('notes');
  }

  QueryBuilder<DictionaryTag, double?, QQueryOperations> popularityProperty() {
    return addPropertyNameInternal('popularity');
  }

  QueryBuilder<DictionaryTag, int, QQueryOperations> sortingOrderProperty() {
    return addPropertyNameInternal('sortingOrder');
  }

  QueryBuilder<DictionaryTag, String, QQueryOperations> uniqueKeyProperty() {
    return addPropertyNameInternal('uniqueKey');
  }
}
