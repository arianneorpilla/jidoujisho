// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetMediaItemCollection on Isar {
  IsarCollection<MediaItem> get mediaItems => getCollection();
}

const MediaItemSchema = CollectionSchema(
  name: 'MediaItem',
  schema:
      '{"name":"MediaItem","idName":"id","properties":[{"name":"audioUrl","type":"String"},{"name":"author","type":"String"},{"name":"authorIdentifier","type":"String"},{"name":"base64Image","type":"String"},{"name":"canDelete","type":"Bool"},{"name":"canEdit","type":"Bool"},{"name":"duration","type":"Long"},{"name":"hashCode","type":"Long"},{"name":"imageUrl","type":"String"},{"name":"mediaIdentifier","type":"String"},{"name":"mediaSourceIdentifier","type":"String"},{"name":"mediaTypeIdentifier","type":"String"},{"name":"position","type":"Long"},{"name":"sourceMetadata","type":"String"},{"name":"title","type":"String"},{"name":"uniqueKey","type":"String"}],"indexes":[{"name":"mediaIdentifier","unique":false,"properties":[{"name":"mediaIdentifier","type":"Hash","caseSensitive":true}]},{"name":"mediaSourceIdentifier","unique":false,"properties":[{"name":"mediaSourceIdentifier","type":"Hash","caseSensitive":true}]},{"name":"mediaTypeIdentifier","unique":false,"properties":[{"name":"mediaTypeIdentifier","type":"Hash","caseSensitive":true}]},{"name":"uniqueKey","unique":true,"properties":[{"name":"uniqueKey","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'audioUrl': 0,
    'author': 1,
    'authorIdentifier': 2,
    'base64Image': 3,
    'canDelete': 4,
    'canEdit': 5,
    'duration': 6,
    'hashCode': 7,
    'imageUrl': 8,
    'mediaIdentifier': 9,
    'mediaSourceIdentifier': 10,
    'mediaTypeIdentifier': 11,
    'position': 12,
    'sourceMetadata': 13,
    'title': 14,
    'uniqueKey': 15
  },
  listProperties: {},
  indexIds: {
    'mediaIdentifier': 0,
    'mediaSourceIdentifier': 1,
    'mediaTypeIdentifier': 2,
    'uniqueKey': 3
  },
  indexValueTypes: {
    'mediaIdentifier': [
      IndexValueType.stringHash,
    ],
    'mediaSourceIdentifier': [
      IndexValueType.stringHash,
    ],
    'mediaTypeIdentifier': [
      IndexValueType.stringHash,
    ],
    'uniqueKey': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _mediaItemGetId,
  setId: _mediaItemSetId,
  getLinks: _mediaItemGetLinks,
  attachLinks: _mediaItemAttachLinks,
  serializeNative: _mediaItemSerializeNative,
  deserializeNative: _mediaItemDeserializeNative,
  deserializePropNative: _mediaItemDeserializePropNative,
  serializeWeb: _mediaItemSerializeWeb,
  deserializeWeb: _mediaItemDeserializeWeb,
  deserializePropWeb: _mediaItemDeserializePropWeb,
  version: 3,
);

int? _mediaItemGetId(MediaItem object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _mediaItemSetId(MediaItem object, int id) {
  object.id = id;
}

List<IsarLinkBase> _mediaItemGetLinks(MediaItem object) {
  return [];
}

void _mediaItemSerializeNative(
    IsarCollection<MediaItem> collection,
    IsarRawObject rawObj,
    MediaItem object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.audioUrl;
  IsarUint8List? _audioUrl;
  if (value0 != null) {
    _audioUrl = IsarBinaryWriter.utf8Encoder.convert(value0);
  }
  dynamicSize += (_audioUrl?.length ?? 0) as int;
  final value1 = object.author;
  IsarUint8List? _author;
  if (value1 != null) {
    _author = IsarBinaryWriter.utf8Encoder.convert(value1);
  }
  dynamicSize += (_author?.length ?? 0) as int;
  final value2 = object.authorIdentifier;
  IsarUint8List? _authorIdentifier;
  if (value2 != null) {
    _authorIdentifier = IsarBinaryWriter.utf8Encoder.convert(value2);
  }
  dynamicSize += (_authorIdentifier?.length ?? 0) as int;
  final value3 = object.base64Image;
  IsarUint8List? _base64Image;
  if (value3 != null) {
    _base64Image = IsarBinaryWriter.utf8Encoder.convert(value3);
  }
  dynamicSize += (_base64Image?.length ?? 0) as int;
  final value4 = object.canDelete;
  final _canDelete = value4;
  final value5 = object.canEdit;
  final _canEdit = value5;
  final value6 = object.duration;
  final _duration = value6;
  final value7 = object.hashCode;
  final _hashCode = value7;
  final value8 = object.imageUrl;
  IsarUint8List? _imageUrl;
  if (value8 != null) {
    _imageUrl = IsarBinaryWriter.utf8Encoder.convert(value8);
  }
  dynamicSize += (_imageUrl?.length ?? 0) as int;
  final value9 = object.mediaIdentifier;
  final _mediaIdentifier = IsarBinaryWriter.utf8Encoder.convert(value9);
  dynamicSize += (_mediaIdentifier.length) as int;
  final value10 = object.mediaSourceIdentifier;
  final _mediaSourceIdentifier = IsarBinaryWriter.utf8Encoder.convert(value10);
  dynamicSize += (_mediaSourceIdentifier.length) as int;
  final value11 = object.mediaTypeIdentifier;
  final _mediaTypeIdentifier = IsarBinaryWriter.utf8Encoder.convert(value11);
  dynamicSize += (_mediaTypeIdentifier.length) as int;
  final value12 = object.position;
  final _position = value12;
  final value13 = object.sourceMetadata;
  IsarUint8List? _sourceMetadata;
  if (value13 != null) {
    _sourceMetadata = IsarBinaryWriter.utf8Encoder.convert(value13);
  }
  dynamicSize += (_sourceMetadata?.length ?? 0) as int;
  final value14 = object.title;
  final _title = IsarBinaryWriter.utf8Encoder.convert(value14);
  dynamicSize += (_title.length) as int;
  final value15 = object.uniqueKey;
  final _uniqueKey = IsarBinaryWriter.utf8Encoder.convert(value15);
  dynamicSize += (_uniqueKey.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _audioUrl);
  writer.writeBytes(offsets[1], _author);
  writer.writeBytes(offsets[2], _authorIdentifier);
  writer.writeBytes(offsets[3], _base64Image);
  writer.writeBool(offsets[4], _canDelete);
  writer.writeBool(offsets[5], _canEdit);
  writer.writeLong(offsets[6], _duration);
  writer.writeLong(offsets[7], _hashCode);
  writer.writeBytes(offsets[8], _imageUrl);
  writer.writeBytes(offsets[9], _mediaIdentifier);
  writer.writeBytes(offsets[10], _mediaSourceIdentifier);
  writer.writeBytes(offsets[11], _mediaTypeIdentifier);
  writer.writeLong(offsets[12], _position);
  writer.writeBytes(offsets[13], _sourceMetadata);
  writer.writeBytes(offsets[14], _title);
  writer.writeBytes(offsets[15], _uniqueKey);
}

MediaItem _mediaItemDeserializeNative(IsarCollection<MediaItem> collection,
    int id, IsarBinaryReader reader, List<int> offsets) {
  final object = MediaItem(
    audioUrl: reader.readStringOrNull(offsets[0]),
    author: reader.readStringOrNull(offsets[1]),
    authorIdentifier: reader.readStringOrNull(offsets[2]),
    base64Image: reader.readStringOrNull(offsets[3]),
    canDelete: reader.readBool(offsets[4]),
    canEdit: reader.readBool(offsets[5]),
    duration: reader.readLong(offsets[6]),
    id: id,
    imageUrl: reader.readStringOrNull(offsets[8]),
    mediaIdentifier: reader.readString(offsets[9]),
    mediaSourceIdentifier: reader.readString(offsets[10]),
    mediaTypeIdentifier: reader.readString(offsets[11]),
    position: reader.readLong(offsets[12]),
    sourceMetadata: reader.readStringOrNull(offsets[13]),
    title: reader.readString(offsets[14]),
  );
  return object;
}

P _mediaItemDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _mediaItemSerializeWeb(
    IsarCollection<MediaItem> collection, MediaItem object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'audioUrl', object.audioUrl);
  IsarNative.jsObjectSet(jsObj, 'author', object.author);
  IsarNative.jsObjectSet(jsObj, 'authorIdentifier', object.authorIdentifier);
  IsarNative.jsObjectSet(jsObj, 'base64Image', object.base64Image);
  IsarNative.jsObjectSet(jsObj, 'canDelete', object.canDelete);
  IsarNative.jsObjectSet(jsObj, 'canEdit', object.canEdit);
  IsarNative.jsObjectSet(jsObj, 'duration', object.duration);
  IsarNative.jsObjectSet(jsObj, 'hashCode', object.hashCode);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'imageUrl', object.imageUrl);
  IsarNative.jsObjectSet(jsObj, 'mediaIdentifier', object.mediaIdentifier);
  IsarNative.jsObjectSet(
      jsObj, 'mediaSourceIdentifier', object.mediaSourceIdentifier);
  IsarNative.jsObjectSet(
      jsObj, 'mediaTypeIdentifier', object.mediaTypeIdentifier);
  IsarNative.jsObjectSet(jsObj, 'position', object.position);
  IsarNative.jsObjectSet(jsObj, 'sourceMetadata', object.sourceMetadata);
  IsarNative.jsObjectSet(jsObj, 'title', object.title);
  IsarNative.jsObjectSet(jsObj, 'uniqueKey', object.uniqueKey);
  return jsObj;
}

MediaItem _mediaItemDeserializeWeb(
    IsarCollection<MediaItem> collection, dynamic jsObj) {
  final object = MediaItem(
    audioUrl: IsarNative.jsObjectGet(jsObj, 'audioUrl'),
    author: IsarNative.jsObjectGet(jsObj, 'author'),
    authorIdentifier: IsarNative.jsObjectGet(jsObj, 'authorIdentifier'),
    base64Image: IsarNative.jsObjectGet(jsObj, 'base64Image'),
    canDelete: IsarNative.jsObjectGet(jsObj, 'canDelete') ?? false,
    canEdit: IsarNative.jsObjectGet(jsObj, 'canEdit') ?? false,
    duration:
        IsarNative.jsObjectGet(jsObj, 'duration') ?? double.negativeInfinity,
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    imageUrl: IsarNative.jsObjectGet(jsObj, 'imageUrl'),
    mediaIdentifier: IsarNative.jsObjectGet(jsObj, 'mediaIdentifier') ?? '',
    mediaSourceIdentifier:
        IsarNative.jsObjectGet(jsObj, 'mediaSourceIdentifier') ?? '',
    mediaTypeIdentifier:
        IsarNative.jsObjectGet(jsObj, 'mediaTypeIdentifier') ?? '',
    position:
        IsarNative.jsObjectGet(jsObj, 'position') ?? double.negativeInfinity,
    sourceMetadata: IsarNative.jsObjectGet(jsObj, 'sourceMetadata'),
    title: IsarNative.jsObjectGet(jsObj, 'title') ?? '',
  );
  return object;
}

P _mediaItemDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'audioUrl':
      return (IsarNative.jsObjectGet(jsObj, 'audioUrl')) as P;
    case 'author':
      return (IsarNative.jsObjectGet(jsObj, 'author')) as P;
    case 'authorIdentifier':
      return (IsarNative.jsObjectGet(jsObj, 'authorIdentifier')) as P;
    case 'base64Image':
      return (IsarNative.jsObjectGet(jsObj, 'base64Image')) as P;
    case 'canDelete':
      return (IsarNative.jsObjectGet(jsObj, 'canDelete') ?? false) as P;
    case 'canEdit':
      return (IsarNative.jsObjectGet(jsObj, 'canEdit') ?? false) as P;
    case 'duration':
      return (IsarNative.jsObjectGet(jsObj, 'duration') ??
          double.negativeInfinity) as P;
    case 'hashCode':
      return (IsarNative.jsObjectGet(jsObj, 'hashCode') ??
          double.negativeInfinity) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'imageUrl':
      return (IsarNative.jsObjectGet(jsObj, 'imageUrl')) as P;
    case 'mediaIdentifier':
      return (IsarNative.jsObjectGet(jsObj, 'mediaIdentifier') ?? '') as P;
    case 'mediaSourceIdentifier':
      return (IsarNative.jsObjectGet(jsObj, 'mediaSourceIdentifier') ?? '')
          as P;
    case 'mediaTypeIdentifier':
      return (IsarNative.jsObjectGet(jsObj, 'mediaTypeIdentifier') ?? '') as P;
    case 'position':
      return (IsarNative.jsObjectGet(jsObj, 'position') ??
          double.negativeInfinity) as P;
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

void _mediaItemAttachLinks(IsarCollection col, int id, MediaItem object) {}

extension MediaItemByIndex on IsarCollection<MediaItem> {
  Future<MediaItem?> getByUniqueKey(String uniqueKey) {
    return getByIndex('uniqueKey', [uniqueKey]);
  }

  MediaItem? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex('uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync('uniqueKey', [uniqueKey]);
  }

  Future<List<MediaItem?>> getAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex('uniqueKey', values);
  }

  List<MediaItem?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
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

extension MediaItemQueryWhereSort
    on QueryBuilder<MediaItem, MediaItem, QWhere> {
  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyMediaIdentifier() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'mediaIdentifier'));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyMediaSourceIdentifier() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'mediaSourceIdentifier'));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyMediaTypeIdentifier() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'mediaTypeIdentifier'));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhere> anyUniqueKey() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'uniqueKey'));
  }
}

extension MediaItemQueryWhere
    on QueryBuilder<MediaItem, MediaItem, QWhereClause> {
  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idEqualTo(int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idNotEqualTo(int id) {
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

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idGreaterThan(int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idLessThan(int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> mediaIdentifierEqualTo(
      String mediaIdentifier) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'mediaIdentifier',
      value: [mediaIdentifier],
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause>
      mediaIdentifierNotEqualTo(String mediaIdentifier) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaIdentifier',
        upper: [mediaIdentifier],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaIdentifier',
        lower: [mediaIdentifier],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaIdentifier',
        lower: [mediaIdentifier],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaIdentifier',
        upper: [mediaIdentifier],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause>
      mediaSourceIdentifierEqualTo(String mediaSourceIdentifier) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'mediaSourceIdentifier',
      value: [mediaSourceIdentifier],
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause>
      mediaSourceIdentifierNotEqualTo(String mediaSourceIdentifier) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaSourceIdentifier',
        upper: [mediaSourceIdentifier],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaSourceIdentifier',
        lower: [mediaSourceIdentifier],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaSourceIdentifier',
        lower: [mediaSourceIdentifier],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaSourceIdentifier',
        upper: [mediaSourceIdentifier],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause>
      mediaTypeIdentifierEqualTo(String mediaTypeIdentifier) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'mediaTypeIdentifier',
      value: [mediaTypeIdentifier],
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause>
      mediaTypeIdentifierNotEqualTo(String mediaTypeIdentifier) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaTypeIdentifier',
        upper: [mediaTypeIdentifier],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaTypeIdentifier',
        lower: [mediaTypeIdentifier],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'mediaTypeIdentifier',
        lower: [mediaTypeIdentifier],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'mediaTypeIdentifier',
        upper: [mediaTypeIdentifier],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> uniqueKeyEqualTo(
      String uniqueKey) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'uniqueKey',
      value: [uniqueKey],
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterWhereClause> uniqueKeyNotEqualTo(
      String uniqueKey) {
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

extension MediaItemQueryFilter
    on QueryBuilder<MediaItem, MediaItem, QFilterCondition> {
  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'audioUrl',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'audioUrl',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'audioUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> audioUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'audioUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'authorIdentifier',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'authorIdentifier',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'authorIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      authorIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'authorIdentifier',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      base64ImageIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'base64Image',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      base64ImageGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'base64Image',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      base64ImageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'base64Image',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> base64ImageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'base64Image',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> canDeleteEqualTo(
      bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'canDelete',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> canEditEqualTo(
      bool value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'canEdit',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'duration',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> durationGreaterThan(
    int value, {
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
    int value, {
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
    int lower,
    int upper, {
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
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'imageUrl',
      value: null,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'imageUrl',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'imageUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'mediaIdentifier',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'mediaIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'mediaIdentifier',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'mediaSourceIdentifier',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'mediaSourceIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaSourceIdentifierMatches(String pattern,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'mediaSourceIdentifier',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'mediaTypeIdentifier',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'mediaTypeIdentifier',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition>
      mediaTypeIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'mediaTypeIdentifier',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'position',
      value: value,
    ));
  }

  QueryBuilder<MediaItem, MediaItem, QAfterFilterCondition> positionGreaterThan(
    int value, {
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
    int value, {
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
    int lower,
    int upper, {
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
  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAudioUrl() {
    return addSortByInternal('audioUrl', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAudioUrlDesc() {
    return addSortByInternal('audioUrl', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAuthor() {
    return addSortByInternal('author', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAuthorDesc() {
    return addSortByInternal('author', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByAuthorIdentifier() {
    return addSortByInternal('authorIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortByAuthorIdentifierDesc() {
    return addSortByInternal('authorIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByBase64Image() {
    return addSortByInternal('base64Image', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByBase64ImageDesc() {
    return addSortByInternal('base64Image', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByCanDelete() {
    return addSortByInternal('canDelete', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByCanDeleteDesc() {
    return addSortByInternal('canDelete', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByCanEdit() {
    return addSortByInternal('canEdit', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByCanEditDesc() {
    return addSortByInternal('canEdit', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByDuration() {
    return addSortByInternal('duration', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByDurationDesc() {
    return addSortByInternal('duration', Sort.desc);
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

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByImageUrl() {
    return addSortByInternal('imageUrl', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByImageUrlDesc() {
    return addSortByInternal('imageUrl', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByMediaIdentifier() {
    return addSortByInternal('mediaIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByMediaIdentifierDesc() {
    return addSortByInternal('mediaIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortByMediaSourceIdentifier() {
    return addSortByInternal('mediaSourceIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortByMediaSourceIdentifierDesc() {
    return addSortByInternal('mediaSourceIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByMediaTypeIdentifier() {
    return addSortByInternal('mediaTypeIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      sortByMediaTypeIdentifierDesc() {
    return addSortByInternal('mediaTypeIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByPosition() {
    return addSortByInternal('position', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> sortByPositionDesc() {
    return addSortByInternal('position', Sort.desc);
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
  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAudioUrl() {
    return addSortByInternal('audioUrl', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAudioUrlDesc() {
    return addSortByInternal('audioUrl', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAuthor() {
    return addSortByInternal('author', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAuthorDesc() {
    return addSortByInternal('author', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByAuthorIdentifier() {
    return addSortByInternal('authorIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenByAuthorIdentifierDesc() {
    return addSortByInternal('authorIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByBase64Image() {
    return addSortByInternal('base64Image', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByBase64ImageDesc() {
    return addSortByInternal('base64Image', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByCanDelete() {
    return addSortByInternal('canDelete', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByCanDeleteDesc() {
    return addSortByInternal('canDelete', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByCanEdit() {
    return addSortByInternal('canEdit', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByCanEditDesc() {
    return addSortByInternal('canEdit', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByDuration() {
    return addSortByInternal('duration', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByDurationDesc() {
    return addSortByInternal('duration', Sort.desc);
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

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByImageUrl() {
    return addSortByInternal('imageUrl', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByImageUrlDesc() {
    return addSortByInternal('imageUrl', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByMediaIdentifier() {
    return addSortByInternal('mediaIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByMediaIdentifierDesc() {
    return addSortByInternal('mediaIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenByMediaSourceIdentifier() {
    return addSortByInternal('mediaSourceIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenByMediaSourceIdentifierDesc() {
    return addSortByInternal('mediaSourceIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByMediaTypeIdentifier() {
    return addSortByInternal('mediaTypeIdentifier', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy>
      thenByMediaTypeIdentifierDesc() {
    return addSortByInternal('mediaTypeIdentifier', Sort.desc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByPosition() {
    return addSortByInternal('position', Sort.asc);
  }

  QueryBuilder<MediaItem, MediaItem, QAfterSortBy> thenByPositionDesc() {
    return addSortByInternal('position', Sort.desc);
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
  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByAudioUrl(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('audioUrl', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('author', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByAuthorIdentifier(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('authorIdentifier',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByBase64Image(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('base64Image', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByCanDelete() {
    return addDistinctByInternal('canDelete');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByCanEdit() {
    return addDistinctByInternal('canEdit');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByDuration() {
    return addDistinctByInternal('duration');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByHashCode() {
    return addDistinctByInternal('hashCode');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('imageUrl', caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByMediaIdentifier(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('mediaIdentifier',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByMediaSourceIdentifier(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('mediaSourceIdentifier',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByMediaTypeIdentifier(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('mediaTypeIdentifier',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<MediaItem, MediaItem, QDistinct> distinctByPosition() {
    return addDistinctByInternal('position');
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
  QueryBuilder<MediaItem, String?, QQueryOperations> audioUrlProperty() {
    return addPropertyNameInternal('audioUrl');
  }

  QueryBuilder<MediaItem, String?, QQueryOperations> authorProperty() {
    return addPropertyNameInternal('author');
  }

  QueryBuilder<MediaItem, String?, QQueryOperations>
      authorIdentifierProperty() {
    return addPropertyNameInternal('authorIdentifier');
  }

  QueryBuilder<MediaItem, String?, QQueryOperations> base64ImageProperty() {
    return addPropertyNameInternal('base64Image');
  }

  QueryBuilder<MediaItem, bool, QQueryOperations> canDeleteProperty() {
    return addPropertyNameInternal('canDelete');
  }

  QueryBuilder<MediaItem, bool, QQueryOperations> canEditProperty() {
    return addPropertyNameInternal('canEdit');
  }

  QueryBuilder<MediaItem, int, QQueryOperations> durationProperty() {
    return addPropertyNameInternal('duration');
  }

  QueryBuilder<MediaItem, int, QQueryOperations> hashCodeProperty() {
    return addPropertyNameInternal('hashCode');
  }

  QueryBuilder<MediaItem, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<MediaItem, String?, QQueryOperations> imageUrlProperty() {
    return addPropertyNameInternal('imageUrl');
  }

  QueryBuilder<MediaItem, String, QQueryOperations> mediaIdentifierProperty() {
    return addPropertyNameInternal('mediaIdentifier');
  }

  QueryBuilder<MediaItem, String, QQueryOperations>
      mediaSourceIdentifierProperty() {
    return addPropertyNameInternal('mediaSourceIdentifier');
  }

  QueryBuilder<MediaItem, String, QQueryOperations>
      mediaTypeIdentifierProperty() {
    return addPropertyNameInternal('mediaTypeIdentifier');
  }

  QueryBuilder<MediaItem, int, QQueryOperations> positionProperty() {
    return addPropertyNameInternal('position');
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
      mediaIdentifier: json['mediaIdentifier'] as String,
      title: json['title'] as String,
      mediaTypeIdentifier: json['mediaTypeIdentifier'] as String,
      mediaSourceIdentifier: json['mediaSourceIdentifier'] as String,
      position: json['position'] as int,
      duration: json['duration'] as int,
      canDelete: json['canDelete'] as bool,
      canEdit: json['canEdit'] as bool,
      id: json['id'] as int?,
      base64Image: json['base64Image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      author: json['author'] as String?,
      authorIdentifier: json['authorIdentifier'] as String?,
      sourceMetadata: json['sourceMetadata'] as String?,
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'mediaIdentifier': instance.mediaIdentifier,
      'title': instance.title,
      'mediaTypeIdentifier': instance.mediaTypeIdentifier,
      'mediaSourceIdentifier': instance.mediaSourceIdentifier,
      'base64Image': instance.base64Image,
      'imageUrl': instance.imageUrl,
      'audioUrl': instance.audioUrl,
      'author': instance.author,
      'authorIdentifier': instance.authorIdentifier,
      'sourceMetadata': instance.sourceMetadata,
      'position': instance.position,
      'duration': instance.duration,
      'canDelete': instance.canDelete,
      'canEdit': instance.canEdit,
    };
