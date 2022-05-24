// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_context.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetCreatorContextCollection on Isar {
  IsarCollection<CreatorContext> get creatorContexts => getCollection();
}

const CreatorContextSchema = CollectionSchema(
  name: 'CreatorContext',
  schema:
      '{"name":"CreatorContext","idName":"id","properties":[{"name":"audioSearch","type":"String"},{"name":"audioSeed","type":"String"},{"name":"context","type":"String"},{"name":"extra","type":"String"},{"name":"imageSearch","type":"String"},{"name":"imageSeed","type":"String"},{"name":"meaning","type":"String"},{"name":"reading","type":"String"},{"name":"sentence","type":"String"},{"name":"term","type":"String"}],"indexes":[],"links":[]}',
  idName: 'id',
  propertyIds: {
    'audioSearch': 0,
    'audioSeed': 1,
    'context': 2,
    'extra': 3,
    'imageSearch': 4,
    'imageSeed': 5,
    'meaning': 6,
    'reading': 7,
    'sentence': 8,
    'term': 9
  },
  listProperties: {},
  indexIds: {},
  indexValueTypes: {},
  linkIds: {},
  backlinkLinkNames: {},
  getId: _creatorContextGetId,
  setId: _creatorContextSetId,
  getLinks: _creatorContextGetLinks,
  attachLinks: _creatorContextAttachLinks,
  serializeNative: _creatorContextSerializeNative,
  deserializeNative: _creatorContextDeserializeNative,
  deserializePropNative: _creatorContextDeserializePropNative,
  serializeWeb: _creatorContextSerializeWeb,
  deserializeWeb: _creatorContextDeserializeWeb,
  deserializePropWeb: _creatorContextDeserializePropWeb,
  version: 3,
);

int? _creatorContextGetId(CreatorContext object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _creatorContextSetId(CreatorContext object, int id) {
  object.id = id;
}

List<IsarLinkBase> _creatorContextGetLinks(CreatorContext object) {
  return [];
}

const _creatorContextMediaItemConverter = MediaItemConverter();

void _creatorContextSerializeNative(
    IsarCollection<CreatorContext> collection,
    IsarRawObject rawObj,
    CreatorContext object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.audioSearch;
  IsarUint8List? _audioSearch;
  if (value0 != null) {
    _audioSearch = IsarBinaryWriter.utf8Encoder.convert(value0);
  }
  dynamicSize += (_audioSearch?.length ?? 0) as int;
  final value1 = _creatorContextMediaItemConverter.toIsar(object.audioSeed);
  IsarUint8List? _audioSeed;
  if (value1 != null) {
    _audioSeed = IsarBinaryWriter.utf8Encoder.convert(value1);
  }
  dynamicSize += (_audioSeed?.length ?? 0) as int;
  final value2 = _creatorContextMediaItemConverter.toIsar(object.context);
  IsarUint8List? _context;
  if (value2 != null) {
    _context = IsarBinaryWriter.utf8Encoder.convert(value2);
  }
  dynamicSize += (_context?.length ?? 0) as int;
  final value3 = object.extra;
  IsarUint8List? _extra;
  if (value3 != null) {
    _extra = IsarBinaryWriter.utf8Encoder.convert(value3);
  }
  dynamicSize += (_extra?.length ?? 0) as int;
  final value4 = object.imageSearch;
  IsarUint8List? _imageSearch;
  if (value4 != null) {
    _imageSearch = IsarBinaryWriter.utf8Encoder.convert(value4);
  }
  dynamicSize += (_imageSearch?.length ?? 0) as int;
  final value5 = _creatorContextMediaItemConverter.toIsar(object.imageSeed);
  IsarUint8List? _imageSeed;
  if (value5 != null) {
    _imageSeed = IsarBinaryWriter.utf8Encoder.convert(value5);
  }
  dynamicSize += (_imageSeed?.length ?? 0) as int;
  final value6 = object.meaning;
  IsarUint8List? _meaning;
  if (value6 != null) {
    _meaning = IsarBinaryWriter.utf8Encoder.convert(value6);
  }
  dynamicSize += (_meaning?.length ?? 0) as int;
  final value7 = object.reading;
  IsarUint8List? _reading;
  if (value7 != null) {
    _reading = IsarBinaryWriter.utf8Encoder.convert(value7);
  }
  dynamicSize += (_reading?.length ?? 0) as int;
  final value8 = object.sentence;
  IsarUint8List? _sentence;
  if (value8 != null) {
    _sentence = IsarBinaryWriter.utf8Encoder.convert(value8);
  }
  dynamicSize += (_sentence?.length ?? 0) as int;
  final value9 = object.term;
  IsarUint8List? _term;
  if (value9 != null) {
    _term = IsarBinaryWriter.utf8Encoder.convert(value9);
  }
  dynamicSize += (_term?.length ?? 0) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _audioSearch);
  writer.writeBytes(offsets[1], _audioSeed);
  writer.writeBytes(offsets[2], _context);
  writer.writeBytes(offsets[3], _extra);
  writer.writeBytes(offsets[4], _imageSearch);
  writer.writeBytes(offsets[5], _imageSeed);
  writer.writeBytes(offsets[6], _meaning);
  writer.writeBytes(offsets[7], _reading);
  writer.writeBytes(offsets[8], _sentence);
  writer.writeBytes(offsets[9], _term);
}

CreatorContext _creatorContextDeserializeNative(
    IsarCollection<CreatorContext> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = CreatorContext(
    audioSearch: reader.readStringOrNull(offsets[0]),
    audioSeed: _creatorContextMediaItemConverter
        .fromIsar(reader.readStringOrNull(offsets[1])),
    context: _creatorContextMediaItemConverter
        .fromIsar(reader.readStringOrNull(offsets[2])),
    extra: reader.readStringOrNull(offsets[3]),
    id: id,
    imageSearch: reader.readStringOrNull(offsets[4]),
    imageSeed: _creatorContextMediaItemConverter
        .fromIsar(reader.readStringOrNull(offsets[5])),
    meaning: reader.readStringOrNull(offsets[6]),
    reading: reader.readStringOrNull(offsets[7]),
    sentence: reader.readStringOrNull(offsets[8]),
    term: reader.readStringOrNull(offsets[9]),
  );
  return object;
}

P _creatorContextDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (_creatorContextMediaItemConverter
          .fromIsar(reader.readStringOrNull(offset))) as P;
    case 2:
      return (_creatorContextMediaItemConverter
          .fromIsar(reader.readStringOrNull(offset))) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_creatorContextMediaItemConverter
          .fromIsar(reader.readStringOrNull(offset))) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _creatorContextSerializeWeb(
    IsarCollection<CreatorContext> collection, CreatorContext object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'audioSearch', object.audioSearch);
  IsarNative.jsObjectSet(jsObj, 'audioSeed',
      _creatorContextMediaItemConverter.toIsar(object.audioSeed));
  IsarNative.jsObjectSet(jsObj, 'context',
      _creatorContextMediaItemConverter.toIsar(object.context));
  IsarNative.jsObjectSet(jsObj, 'extra', object.extra);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'imageSearch', object.imageSearch);
  IsarNative.jsObjectSet(jsObj, 'imageSeed',
      _creatorContextMediaItemConverter.toIsar(object.imageSeed));
  IsarNative.jsObjectSet(jsObj, 'meaning', object.meaning);
  IsarNative.jsObjectSet(jsObj, 'reading', object.reading);
  IsarNative.jsObjectSet(jsObj, 'sentence', object.sentence);
  IsarNative.jsObjectSet(jsObj, 'term', object.term);
  return jsObj;
}

CreatorContext _creatorContextDeserializeWeb(
    IsarCollection<CreatorContext> collection, dynamic jsObj) {
  final object = CreatorContext(
    audioSearch: IsarNative.jsObjectGet(jsObj, 'audioSearch'),
    audioSeed: _creatorContextMediaItemConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'audioSeed')),
    context: _creatorContextMediaItemConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'context')),
    extra: IsarNative.jsObjectGet(jsObj, 'extra'),
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    imageSearch: IsarNative.jsObjectGet(jsObj, 'imageSearch'),
    imageSeed: _creatorContextMediaItemConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'imageSeed')),
    meaning: IsarNative.jsObjectGet(jsObj, 'meaning'),
    reading: IsarNative.jsObjectGet(jsObj, 'reading'),
    sentence: IsarNative.jsObjectGet(jsObj, 'sentence'),
    term: IsarNative.jsObjectGet(jsObj, 'term'),
  );
  return object;
}

P _creatorContextDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'audioSearch':
      return (IsarNative.jsObjectGet(jsObj, 'audioSearch')) as P;
    case 'audioSeed':
      return (_creatorContextMediaItemConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'audioSeed'))) as P;
    case 'context':
      return (_creatorContextMediaItemConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'context'))) as P;
    case 'extra':
      return (IsarNative.jsObjectGet(jsObj, 'extra')) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'imageSearch':
      return (IsarNative.jsObjectGet(jsObj, 'imageSearch')) as P;
    case 'imageSeed':
      return (_creatorContextMediaItemConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'imageSeed'))) as P;
    case 'meaning':
      return (IsarNative.jsObjectGet(jsObj, 'meaning')) as P;
    case 'reading':
      return (IsarNative.jsObjectGet(jsObj, 'reading')) as P;
    case 'sentence':
      return (IsarNative.jsObjectGet(jsObj, 'sentence')) as P;
    case 'term':
      return (IsarNative.jsObjectGet(jsObj, 'term')) as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _creatorContextAttachLinks(
    IsarCollection col, int id, CreatorContext object) {}

extension CreatorContextQueryWhereSort
    on QueryBuilder<CreatorContext, CreatorContext, QWhere> {
  QueryBuilder<CreatorContext, CreatorContext, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }
}

extension CreatorContextQueryWhere
    on QueryBuilder<CreatorContext, CreatorContext, QWhereClause> {
  QueryBuilder<CreatorContext, CreatorContext, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CreatorContext, CreatorContext, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterWhereClause> idLessThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterWhereClause> idBetween(
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
}

extension CreatorContextQueryFilter
    on QueryBuilder<CreatorContext, CreatorContext, QFilterCondition> {
  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'audioSearch',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'audioSearch',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'audioSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSearchMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'audioSearch',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'audioSeed',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedEqualTo(
    MediaItem? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedGreaterThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedLessThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedBetween(
    MediaItem? lower,
    MediaItem? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'audioSeed',
      lower: _creatorContextMediaItemConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _creatorContextMediaItemConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedStartsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedEndsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedContains(MediaItem value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'audioSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      audioSeedMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'audioSeed',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'context',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextEqualTo(
    MediaItem? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextGreaterThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextLessThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextBetween(
    MediaItem? lower,
    MediaItem? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'context',
      lower: _creatorContextMediaItemConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _creatorContextMediaItemConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextStartsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextEndsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextContains(MediaItem value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'context',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      contextMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'context',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'extra',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'extra',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      extraMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'extra',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
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

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
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

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'imageSearch',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'imageSearch',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'imageSearch',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSearchMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'imageSearch',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'imageSeed',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedEqualTo(
    MediaItem? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedGreaterThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedLessThan(
    MediaItem? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedBetween(
    MediaItem? lower,
    MediaItem? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'imageSeed',
      lower: _creatorContextMediaItemConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _creatorContextMediaItemConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedStartsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedEndsWith(
    MediaItem value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedContains(MediaItem value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'imageSeed',
      value: _creatorContextMediaItemConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      imageSeedMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'imageSeed',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'meaning',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'meaning',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'meaning',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      meaningMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'meaning',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'reading',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'reading',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'reading',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'sentence',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sentence',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'sentence',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      sentenceMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'sentence',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'term',
      value: null,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'term',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'term',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension CreatorContextQueryLinks
    on QueryBuilder<CreatorContext, CreatorContext, QFilterCondition> {}

extension CreatorContextQueryWhereSortBy
    on QueryBuilder<CreatorContext, CreatorContext, QSortBy> {
  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByAudioSearch() {
    return addSortByInternal('audioSearch', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByAudioSearchDesc() {
    return addSortByInternal('audioSearch', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByAudioSeed() {
    return addSortByInternal('audioSeed', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByAudioSeedDesc() {
    return addSortByInternal('audioSeed', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByContext() {
    return addSortByInternal('context', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByContextDesc() {
    return addSortByInternal('context', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByExtra() {
    return addSortByInternal('extra', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByExtraDesc() {
    return addSortByInternal('extra', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByImageSearch() {
    return addSortByInternal('imageSearch', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByImageSearchDesc() {
    return addSortByInternal('imageSearch', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByImageSeed() {
    return addSortByInternal('imageSeed', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByImageSeedDesc() {
    return addSortByInternal('imageSeed', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByMeaning() {
    return addSortByInternal('meaning', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByMeaningDesc() {
    return addSortByInternal('meaning', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortBySentence() {
    return addSortByInternal('sentence', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      sortBySentenceDesc() {
    return addSortByInternal('sentence', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> sortByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }
}

extension CreatorContextQueryWhereSortThenBy
    on QueryBuilder<CreatorContext, CreatorContext, QSortThenBy> {
  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByAudioSearch() {
    return addSortByInternal('audioSearch', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByAudioSearchDesc() {
    return addSortByInternal('audioSearch', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByAudioSeed() {
    return addSortByInternal('audioSeed', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByAudioSeedDesc() {
    return addSortByInternal('audioSeed', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByContext() {
    return addSortByInternal('context', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByContextDesc() {
    return addSortByInternal('context', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByExtra() {
    return addSortByInternal('extra', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByExtraDesc() {
    return addSortByInternal('extra', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByImageSearch() {
    return addSortByInternal('imageSearch', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByImageSearchDesc() {
    return addSortByInternal('imageSearch', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByImageSeed() {
    return addSortByInternal('imageSeed', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByImageSeedDesc() {
    return addSortByInternal('imageSeed', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByMeaning() {
    return addSortByInternal('meaning', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByMeaningDesc() {
    return addSortByInternal('meaning', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenBySentence() {
    return addSortByInternal('sentence', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy>
      thenBySentenceDesc() {
    return addSortByInternal('sentence', Sort.desc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<CreatorContext, CreatorContext, QAfterSortBy> thenByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }
}

extension CreatorContextQueryWhereDistinct
    on QueryBuilder<CreatorContext, CreatorContext, QDistinct> {
  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByAudioSearch(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('audioSearch', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByAudioSeed(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('audioSeed', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByContext(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('context', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByExtra(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('extra', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByImageSearch(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('imageSearch', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByImageSeed(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('imageSeed', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByMeaning(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('meaning', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByReading(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('reading', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctBySentence(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('sentence', caseSensitive: caseSensitive);
  }

  QueryBuilder<CreatorContext, CreatorContext, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('term', caseSensitive: caseSensitive);
  }
}

extension CreatorContextQueryProperty
    on QueryBuilder<CreatorContext, CreatorContext, QQueryProperty> {
  QueryBuilder<CreatorContext, String?, QQueryOperations>
      audioSearchProperty() {
    return addPropertyNameInternal('audioSearch');
  }

  QueryBuilder<CreatorContext, MediaItem?, QQueryOperations>
      audioSeedProperty() {
    return addPropertyNameInternal('audioSeed');
  }

  QueryBuilder<CreatorContext, MediaItem?, QQueryOperations> contextProperty() {
    return addPropertyNameInternal('context');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations> extraProperty() {
    return addPropertyNameInternal('extra');
  }

  QueryBuilder<CreatorContext, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations>
      imageSearchProperty() {
    return addPropertyNameInternal('imageSearch');
  }

  QueryBuilder<CreatorContext, MediaItem?, QQueryOperations>
      imageSeedProperty() {
    return addPropertyNameInternal('imageSeed');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations> meaningProperty() {
    return addPropertyNameInternal('meaning');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations> readingProperty() {
    return addPropertyNameInternal('reading');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations> sentenceProperty() {
    return addPropertyNameInternal('sentence');
  }

  QueryBuilder<CreatorContext, String?, QQueryOperations> termProperty() {
    return addPropertyNameInternal('term');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatorContext _$CreatorContextFromJson(Map<String, dynamic> json) =>
    CreatorContext(
      sentence: json['sentence'] as String?,
      term: json['term'] as String?,
      reading: json['reading'] as String?,
      meaning: json['meaning'] as String?,
      extra: json['extra'] as String?,
      imageSeed: json['imageSeed'] == null
          ? null
          : MediaItem.fromJson(json['imageSeed'] as Map<String, dynamic>),
      imageSearch: json['imageSearch'] as String?,
      imageSuggestions: (json['imageSuggestions'] as List<dynamic>?)
          ?.map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      audioSeed: json['audioSeed'] == null
          ? null
          : MediaItem.fromJson(json['audioSeed'] as Map<String, dynamic>),
      audioSearch: json['audioSearch'] as String?,
      context: json['context'] == null
          ? null
          : MediaItem.fromJson(json['context'] as Map<String, dynamic>),
      id: json['id'] as int?,
    );

Map<String, dynamic> _$CreatorContextToJson(CreatorContext instance) =>
    <String, dynamic>{
      'sentence': instance.sentence,
      'term': instance.term,
      'reading': instance.reading,
      'meaning': instance.meaning,
      'extra': instance.extra,
      'imageSeed': instance.imageSeed,
      'imageSuggestions': instance.imageSuggestions,
      'audioSeed': instance.audioSeed,
      'imageSearch': instance.imageSearch,
      'audioSearch': instance.audioSearch,
      'context': instance.context,
      'id': instance.id,
    };
