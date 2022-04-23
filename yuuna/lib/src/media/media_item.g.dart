// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast

extension GetMediaItemCollection on Isar {
  IsarCollection<MediaItem> get mediaItems {
    return getCollection('MediaItem');
  }
}

final MediaItemSchema = CollectionSchema(
  name: 'MediaItem',
  schema:
      '{"name":"MediaItem","idName":"id","properties":[{"name":"author","type":"String"},{"name":"duration","type":"Long"},{"name":"fromEnhancement","type":"Bool"},{"name":"fromMedia","type":"Bool"},{"name":"hashCode","type":"Long"},{"name":"identifierCategory","type":"String"},{"name":"identifierKey","type":"String"},{"name":"identifierType","type":"String"},{"name":"position","type":"Long"},{"name":"references","type":"LongList"},{"name":"sourceIdentifier","type":"String"},{"name":"sourceMetadata","type":"String"},{"name":"title","type":"String"},{"name":"uniqueKey","type":"String"}],"indexes":[],"links":[]}',
  nativeAdapter: const _MediaItemNativeAdapter(),
  webAdapter: const _MediaItemWebAdapter(),
  idName: 'id',
  propertyIds: {
    'author': 0,
    'duration': 1,
    'fromEnhancement': 2,
    'fromMedia': 3,
    'hashCode': 4,
    'identifierCategory': 5,
    'identifierKey': 6,
    'identifierType': 7,
    'position': 8,
    'references': 9,
    'sourceIdentifier': 10,
    'sourceMetadata': 11,
    'title': 12,
    'uniqueKey': 13
  },
  listProperties: {'references'},
  indexIds: {},
  indexTypes: {},
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

class _MediaItemWebAdapter extends IsarWebTypeAdapter<MediaItem> {
  const _MediaItemWebAdapter();

  @override
  Object serialize(IsarCollection<MediaItem> collection, MediaItem object) {
    final jsObj = IsarNative.newJsObject();
    IsarNative.jsObjectSet(jsObj, 'author', object.author);
    IsarNative.jsObjectSet(jsObj, 'duration', object.duration);
    IsarNative.jsObjectSet(jsObj, 'fromEnhancement', object.fromEnhancement);
    IsarNative.jsObjectSet(jsObj, 'fromMedia', object.fromMedia);
    IsarNative.jsObjectSet(jsObj, 'hashCode', object.hashCode);
    IsarNative.jsObjectSet(jsObj, 'id', object.id);
    IsarNative.jsObjectSet(
        jsObj, 'identifierCategory', object.identifierCategory);
    IsarNative.jsObjectSet(jsObj, 'identifierKey', object.identifierKey);
    IsarNative.jsObjectSet(jsObj, 'identifierType', object.identifierType);
    IsarNative.jsObjectSet(jsObj, 'position', object.position);
    IsarNative.jsObjectSet(jsObj, 'references', object.references);
    IsarNative.jsObjectSet(jsObj, 'sourceIdentifier', object.sourceIdentifier);
    IsarNative.jsObjectSet(jsObj, 'sourceMetadata', object.sourceMetadata);
    IsarNative.jsObjectSet(jsObj, 'title', object.title);
    IsarNative.jsObjectSet(jsObj, 'uniqueKey', object.uniqueKey);
    return jsObj;
  }

  @override
  MediaItem deserialize(IsarCollection<MediaItem> collection, dynamic jsObj) {
    final object = MediaItem(
      author: IsarNative.jsObjectGet(jsObj, 'author'),
      duration: IsarNative.jsObjectGet(jsObj, 'duration'),
      id: IsarNative.jsObjectGet(jsObj, 'id'),
      position: IsarNative.jsObjectGet(jsObj, 'position'),
      references: (IsarNative.jsObjectGet(jsObj, 'references') as List?)
          ?.map((e) => e ?? double.negativeInfinity)
          .toList()
          .cast<int>(),
      sourceIdentifier: IsarNative.jsObjectGet(jsObj, 'sourceIdentifier') ?? '',
      sourceMetadata: IsarNative.jsObjectGet(jsObj, 'sourceMetadata'),
      title: IsarNative.jsObjectGet(jsObj, 'title') ?? '',
      uniqueKey: IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '',
    );
    return object;
  }

  @override
  P deserializeProperty<P>(Object jsObj, String propertyName) {
    switch (propertyName) {
      case 'author':
        return (IsarNative.jsObjectGet(jsObj, 'author')) as P;
      case 'duration':
        return (IsarNative.jsObjectGet(jsObj, 'duration')) as P;
      case 'fromEnhancement':
        return (IsarNative.jsObjectGet(jsObj, 'fromEnhancement') ?? false) as P;
      case 'fromMedia':
        return (IsarNative.jsObjectGet(jsObj, 'fromMedia') ?? false) as P;
      case 'hashCode':
        return (IsarNative.jsObjectGet(jsObj, 'hashCode') ??
            double.negativeInfinity) as P;
      case 'id':
        return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
      case 'identifierCategory':
        return (IsarNative.jsObjectGet(jsObj, 'identifierCategory') ?? '') as P;
      case 'identifierKey':
        return (IsarNative.jsObjectGet(jsObj, 'identifierKey') ?? '') as P;
      case 'identifierType':
        return (IsarNative.jsObjectGet(jsObj, 'identifierType') ?? '') as P;
      case 'position':
        return (IsarNative.jsObjectGet(jsObj, 'position')) as P;
      case 'references':
        return ((IsarNative.jsObjectGet(jsObj, 'references') as List?)
            ?.map((e) => e ?? double.negativeInfinity)
            .toList()
            .cast<int>()) as P;
      case 'sourceIdentifier':
        return (IsarNative.jsObjectGet(jsObj, 'sourceIdentifier') ?? '') as P;
      case 'sourceMetadata':
        return (IsarNative.jsObjectGet(jsObj, 'sourceMetadata')) as P;
      case 'title':
        return (IsarNative.jsObjectGet(jsObj, 'title') ?? '') as P;
      case 'uniqueKey':
        return (IsarNative.jsObjectGet(jsObj, 'uniqueKey') ?? '') as P;
      default:
        throw 'Illegal propertyName';
    }
  }

  @override
  void attachLinks(Isar isar, int id, MediaItem object) {}
}

class _MediaItemNativeAdapter extends IsarNativeTypeAdapter<MediaItem> {
  const _MediaItemNativeAdapter();

  @override
  void serialize(IsarCollection<MediaItem> collection, IsarRawObject rawObj,
      MediaItem object, int staticSize, List<int> offsets, AdapterAlloc alloc) {
    var dynamicSize = 0;
    final value0 = object.author;
    IsarUint8List? _author;
    if (value0 != null) {
      _author = IsarBinaryWriter.utf8Encoder.convert(value0);
    }
    dynamicSize += (_author?.length ?? 0) as int;
    final value1 = object.duration;
    final _duration = value1;
    final value2 = object.fromEnhancement;
    final _fromEnhancement = value2;
    final value3 = object.fromMedia;
    final _fromMedia = value3;
    final value4 = object.hashCode;
    final _hashCode = value4;
    final value5 = object.identifierCategory;
    final _identifierCategory = IsarBinaryWriter.utf8Encoder.convert(value5);
    dynamicSize += (_identifierCategory.length) as int;
    final value6 = object.identifierKey;
    final _identifierKey = IsarBinaryWriter.utf8Encoder.convert(value6);
    dynamicSize += (_identifierKey.length) as int;
    final value7 = object.identifierType;
    final _identifierType = IsarBinaryWriter.utf8Encoder.convert(value7);
    dynamicSize += (_identifierType.length) as int;
    final value8 = object.position;
    final _position = value8;
    final value9 = object.references;
    dynamicSize += (value9?.length ?? 0) * 8;
    final _references = value9;
    final value10 = object.sourceIdentifier;
    final _sourceIdentifier = IsarBinaryWriter.utf8Encoder.convert(value10);
    dynamicSize += (_sourceIdentifier.length) as int;
    final value11 = object.sourceMetadata;
    IsarUint8List? _sourceMetadata;
    if (value11 != null) {
      _sourceMetadata = IsarBinaryWriter.utf8Encoder.convert(value11);
    }
    dynamicSize += (_sourceMetadata?.length ?? 0) as int;
    final value12 = object.title;
    final _title = IsarBinaryWriter.utf8Encoder.convert(value12);
    dynamicSize += (_title.length) as int;
    final value13 = object.uniqueKey;
    final _uniqueKey = IsarBinaryWriter.utf8Encoder.convert(value13);
    dynamicSize += (_uniqueKey.length) as int;
    final size = staticSize + dynamicSize;

    rawObj.buffer = alloc(size);
    rawObj.buffer_length = size;
    final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
    final writer = IsarBinaryWriter(buffer, staticSize);
    writer.writeBytes(offsets[0], _author);
    writer.writeLong(offsets[1], _duration);
    writer.writeBool(offsets[2], _fromEnhancement);
    writer.writeBool(offsets[3], _fromMedia);
    writer.writeLong(offsets[4], _hashCode);
    writer.writeBytes(offsets[5], _identifierCategory);
    writer.writeBytes(offsets[6], _identifierKey);
    writer.writeBytes(offsets[7], _identifierType);
    writer.writeLong(offsets[8], _position);
    writer.writeLongList(offsets[9], _references);
    writer.writeBytes(offsets[10], _sourceIdentifier);
    writer.writeBytes(offsets[11], _sourceMetadata);
    writer.writeBytes(offsets[12], _title);
    writer.writeBytes(offsets[13], _uniqueKey);
  }

  @override
  MediaItem deserialize(IsarCollection<MediaItem> collection, int id,
      IsarBinaryReader reader, List<int> offsets) {
    final object = MediaItem(
      author: reader.readStringOrNull(offsets[0]),
      duration: reader.readLongOrNull(offsets[1]),
      id: id,
      position: reader.readLongOrNull(offsets[8]),
      references: reader.readLongList(offsets[9]),
      sourceIdentifier: reader.readString(offsets[10]),
      sourceMetadata: reader.readStringOrNull(offsets[11]),
      title: reader.readString(offsets[12]),
      uniqueKey: reader.readString(offsets[13]),
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
        return (reader.readStringOrNull(offset)) as P;
      case 1:
        return (reader.readLongOrNull(offset)) as P;
      case 2:
        return (reader.readBool(offset)) as P;
      case 3:
        return (reader.readBool(offset)) as P;
      case 4:
        return (reader.readLong(offset)) as P;
      case 5:
        return (reader.readString(offset)) as P;
      case 6:
        return (reader.readString(offset)) as P;
      case 7:
        return (reader.readString(offset)) as P;
      case 8:
        return (reader.readLongOrNull(offset)) as P;
      case 9:
        return (reader.readLongList(offset)) as P;
      case 10:
        return (reader.readString(offset)) as P;
      case 11:
        return (reader.readStringOrNull(offset)) as P;
      case 12:
        return (reader.readString(offset)) as P;
      case 13:
        return (reader.readString(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }

  @override
  void attachLinks(Isar isar, int id, MediaItem object) {}
}

extension MediaItemQueryWhereSort
    on QueryBuilder<MediaItem, MediaItem, QWhere> {
  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyId() {
    return addWhereClauseInternal(const WhereClause(indexName: null));
  }
}

extension MediaItemQueryWhere
    on QueryBuilder<MediaItem, MediaItem, QWhereClause> {
  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: true,
      upper: [id],
      includeUpper: true,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idNotEqualTo(int? id) {
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

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idGreaterThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: include,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idLessThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      upper: [id],
      includeUpper: include,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idBetween(
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
}

extension MediaItemQueryFilter
    on QueryBuilder<MediaItem, MediaItem, QFilterCondition> {
  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'author',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'author',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'author',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'author',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'duration',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'duration',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'duration',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'duration',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'duration',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      fromEnhancementEqualTo(bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'fromEnhancement',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> fromMediaEqualTo(
      bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'fromMedia',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'hashCode',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'hashCode',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'hashCode',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'hashCode',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idEqualTo(
      int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'identifierCategory',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'identifierCategory',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'identifierCategory',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'identifierKey',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'identifierKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierKeyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'identifierKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'identifierType',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'identifierType',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      identifierTypeMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'identifierType',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'position',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionEqualTo(
      int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'position',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'position',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'position',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'position',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> referencesIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'references',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      referencesAnyIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'references',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      referencesAnyEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'references',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      referencesAnyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'references',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      referencesAnyLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'references',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      referencesAnyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'references',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sourceIdentifier',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'sourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'sourceIdentifier',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'sourceMetadata',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sourceMetadata',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'sourceMetadata',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      sourceMetadataMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'sourceMetadata',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'title',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'title',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyEqualTo(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyLessThan(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyBetween(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyStartsWith(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyEndsWith(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'uniqueKey',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> uniqueKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'uniqueKey',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension MediaItemQueryLinks
    on QueryBuilder<MediaItem, MediaItem, QFilterCondition> {}

extension MediaItemQueryWhereSortBy
    on QueryBuilder<MediaItem, MediaItem, QSortBy> {
  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAuthor() {
    return addSortByInternal('author', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAuthorDesc() {
    return addSortByInternal('author', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByDuration() {
    return addSortByInternal('duration', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByDurationDesc() {
    return addSortByInternal('duration', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByFromEnhancement() {
    return addSortByInternal('fromEnhancement', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByFromEnhancementDesc() {
    return addSortByInternal('fromEnhancement', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByFromMedia() {
    return addSortByInternal('fromMedia', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByFromMediaDesc() {
    return addSortByInternal('fromMedia', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdentifierCategory() {
    return addSortByInternal('identifierCategory', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortByIdentifierCategoryDesc() {
    return addSortByInternal('identifierCategory', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdentifierKey() {
    return addSortByInternal('identifierKey', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdentifierKeyDesc() {
    return addSortByInternal('identifierKey', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdentifierType() {
    return addSortByInternal('identifierType', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByIdentifierTypeDesc() {
    return addSortByInternal('identifierType', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByPosition() {
    return addSortByInternal('position', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByPositionDesc() {
    return addSortByInternal('position', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortBySourceIdentifier() {
    return addSortByInternal('sourceIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortBySourceIdentifierDesc() {
    return addSortByInternal('sourceIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortBySourceMetadata() {
    return addSortByInternal('sourceMetadata', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortBySourceMetadataDesc() {
    return addSortByInternal('sourceMetadata', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByTitle() {
    return addSortByInternal('title', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByTitleDesc() {
    return addSortByInternal('title', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension MediaItemQueryWhereSortThenBy
    on QueryBuilder<MediaItem, MediaItem, QSortThenBy> {
  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAuthor() {
    return addSortByInternal('author', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAuthorDesc() {
    return addSortByInternal('author', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByDuration() {
    return addSortByInternal('duration', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByDurationDesc() {
    return addSortByInternal('duration', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByFromEnhancement() {
    return addSortByInternal('fromEnhancement', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByFromEnhancementDesc() {
    return addSortByInternal('fromEnhancement', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByFromMedia() {
    return addSortByInternal('fromMedia', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByFromMediaDesc() {
    return addSortByInternal('fromMedia', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdentifierCategory() {
    return addSortByInternal('identifierCategory', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenByIdentifierCategoryDesc() {
    return addSortByInternal('identifierCategory', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdentifierKey() {
    return addSortByInternal('identifierKey', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdentifierKeyDesc() {
    return addSortByInternal('identifierKey', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdentifierType() {
    return addSortByInternal('identifierType', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByIdentifierTypeDesc() {
    return addSortByInternal('identifierType', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByPosition() {
    return addSortByInternal('position', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByPositionDesc() {
    return addSortByInternal('position', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenBySourceIdentifier() {
    return addSortByInternal('sourceIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenBySourceIdentifierDesc() {
    return addSortByInternal('sourceIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenBySourceMetadata() {
    return addSortByInternal('sourceMetadata', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenBySourceMetadataDesc() {
    return addSortByInternal('sourceMetadata', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByTitle() {
    return addSortByInternal('title', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByTitleDesc() {
    return addSortByInternal('title', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByUniqueKey() {
    return addSortByInternal('uniqueKey', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByUniqueKeyDesc() {
    return addSortByInternal('uniqueKey', Sort.desc);
  }
}

extension MediaItemQueryWhereDistinct
    on QueryBuilder<MediaItem, MediaItem, QDistinct> {
  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('author', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByDuration() {
    return addDistinctByInternal('duration');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByFromEnhancement() {
    return addDistinctByInternal('fromEnhancement');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByFromMedia() {
    return addDistinctByInternal('fromMedia');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByHashCode() {
    return addDistinctByInternal('hashCode');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByIdentifierCategory(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('identifierCategory',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByIdentifierKey(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('identifierKey', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByIdentifierType(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('identifierType',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByPosition() {
    return addDistinctByInternal('position');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctBySourceIdentifier(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('sourceIdentifier',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctBySourceMetadata(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('sourceMetadata',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('title', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByUniqueKey(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('uniqueKey', caseSensitive: caseSensitive);
  }
}

extension MediaItemQueryProperty
    on QueryBuilder<MediaItem, MediaItem, QQueryProperty> {
  QueryBuilder<MediaItem, String?, QQueryOperations> authorProperty() {
    return addPropertyNameInternal('author');
  }

  QueryBuilder<MediaItem, int?, QQueryOperations> durationProperty() {
    return addPropertyNameInternal('duration');
  }

  QueryBuilder<MediaItem, bool, QQueryOperations> fromEnhancementProperty() {
    return addPropertyNameInternal('fromEnhancement');
  }

  QueryBuilder<MediaItem, bool, QQueryOperations> fromMediaProperty() {
    return addPropertyNameInternal('fromMedia');
  }

  QueryBuilder<MediaItem, int, QQueryOperations> hashCodeProperty() {
    return addPropertyNameInternal('hashCode');
  }

  QueryBuilder<MediaItem, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<MediaItem, String, QQueryOperations>
      identifierCategoryProperty() {
    return addPropertyNameInternal('identifierCategory');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> identifierKeyProperty() {
    return addPropertyNameInternal('identifierKey');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> identifierTypeProperty() {
    return addPropertyNameInternal('identifierType');
  }

  QueryBuilder<MediaItem, int?, QQueryOperations> positionProperty() {
    return addPropertyNameInternal('position');
  }

  QueryBuilder<MediaItem, List<int>?, QQueryOperations> referencesProperty() {
    return addPropertyNameInternal('references');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> sourceIdentifierProperty() {
    return addPropertyNameInternal('sourceIdentifier');
  }

  QueryBuilder<MediaItem, String?, QQueryOperations> sourceMetadataProperty() {
    return addPropertyNameInternal('sourceMetadata');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> titleProperty() {
    return addPropertyNameInternal('title');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> uniqueKeyProperty() {
    return addPropertyNameInternal('uniqueKey');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      uniqueKey: json['uniqueKey'] as String,
      title: json['title'] as String,
      sourceIdentifier: json['sourceIdentifier'] as String,
      id: json['id'] as int?,
      author: json['author'] as String?,
      sourceMetadata: json['sourceMetadata'] as String?,
      references:
          (json['references'] as List<dynamic>?)?.map((e) => e as int).toList(),
      position: json['position'] as int?,
      duration: json['duration'] as int?,
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'uniqueKey': instance.uniqueKey,
      'title': instance.title,
      'sourceIdentifier': instance.sourceIdentifier,
      'author': instance.author,
      'sourceMetadata': instance.sourceMetadata,
      'references': instance.references,
      'position': instance.position,
      'duration': instance.duration,
    };
