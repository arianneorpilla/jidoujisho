// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetDictionaryEntryCollection on Isar {
  IsarCollection<DictionaryEntry> get dictionaryEntrys => getCollection();
}

const DictionaryEntrySchema = CollectionSchema(
  name: 'DictionaryEntry',
  schema:
      '{"name":"DictionaryEntry","idName":"id","properties":[{"name":"dictionaryName","type":"String"},{"name":"extra","type":"String"},{"name":"hashCode","type":"Long"},{"name":"meaningTags","type":"StringList"},{"name":"meanings","type":"StringList"},{"name":"popularity","type":"Double"},{"name":"reading","type":"String"},{"name":"readingLength","type":"Long"},{"name":"sequence","type":"Long"},{"name":"word","type":"String"},{"name":"wordLength","type":"Long"},{"name":"wordTags","type":"StringList"}],"indexes":[{"name":"dictionaryName","unique":false,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"popularity","unique":false,"properties":[{"name":"popularity","type":"Value","caseSensitive":false}]},{"name":"reading","unique":false,"properties":[{"name":"reading","type":"Hash","caseSensitive":true}]},{"name":"readingLength_popularity","unique":false,"properties":[{"name":"readingLength","type":"Value","caseSensitive":false},{"name":"popularity","type":"Value","caseSensitive":false}]},{"name":"sequence","unique":false,"properties":[{"name":"sequence","type":"Value","caseSensitive":false}]},{"name":"wordLength_popularity","unique":false,"properties":[{"name":"wordLength","type":"Value","caseSensitive":false},{"name":"popularity","type":"Value","caseSensitive":false}]},{"name":"word_reading_popularity","unique":false,"properties":[{"name":"word","type":"Hash","caseSensitive":true},{"name":"reading","type":"Hash","caseSensitive":true},{"name":"popularity","type":"Value","caseSensitive":false}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'dictionaryName': 0,
    'extra': 1,
    'hashCode': 2,
    'meaningTags': 3,
    'meanings': 4,
    'popularity': 5,
    'reading': 6,
    'readingLength': 7,
    'sequence': 8,
    'word': 9,
    'wordLength': 10,
    'wordTags': 11
  },
  listProperties: {'meaningTags', 'meanings', 'wordTags'},
  indexIds: {
    'dictionaryName': 0,
    'popularity': 1,
    'reading': 2,
    'readingLength_popularity': 3,
    'sequence': 4,
    'wordLength_popularity': 5,
    'word_reading_popularity': 6
  },
  indexValueTypes: {
    'dictionaryName': [
      IndexValueType.stringHash,
    ],
    'popularity': [
      IndexValueType.double,
    ],
    'reading': [
      IndexValueType.stringHash,
    ],
    'readingLength_popularity': [
      IndexValueType.long,
      IndexValueType.double,
    ],
    'sequence': [
      IndexValueType.long,
    ],
    'wordLength_popularity': [
      IndexValueType.long,
      IndexValueType.double,
    ],
    'word_reading_popularity': [
      IndexValueType.stringHash,
      IndexValueType.stringHash,
      IndexValueType.double,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _dictionaryEntryGetId,
  setId: _dictionaryEntrySetId,
  getLinks: _dictionaryEntryGetLinks,
  attachLinks: _dictionaryEntryAttachLinks,
  serializeNative: _dictionaryEntrySerializeNative,
  deserializeNative: _dictionaryEntryDeserializeNative,
  deserializePropNative: _dictionaryEntryDeserializePropNative,
  serializeWeb: _dictionaryEntrySerializeWeb,
  deserializeWeb: _dictionaryEntryDeserializeWeb,
  deserializePropWeb: _dictionaryEntryDeserializePropWeb,
  version: 3,
);

int? _dictionaryEntryGetId(DictionaryEntry object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _dictionaryEntrySetId(DictionaryEntry object, int id) {
  object.id = id;
}

List<IsarLinkBase> _dictionaryEntryGetLinks(DictionaryEntry object) {
  return [];
}

void _dictionaryEntrySerializeNative(
    IsarCollection<DictionaryEntry> collection,
    IsarRawObject rawObj,
    DictionaryEntry object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.dictionaryName;
  final _dictionaryName = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_dictionaryName.length) as int;
  final value1 = object.extra;
  IsarUint8List? _extra;
  if (value1 != null) {
    _extra = IsarBinaryWriter.utf8Encoder.convert(value1);
  }
  dynamicSize += (_extra?.length ?? 0) as int;
  final value2 = object.hashCode;
  final _hashCode = value2;
  final value3 = object.meaningTags;
  dynamicSize += (value3.length) * 8;
  final bytesList3 = <IsarUint8List>[];
  for (var str in value3) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList3.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _meaningTags = bytesList3;
  final value4 = object.meanings;
  dynamicSize += (value4.length) * 8;
  final bytesList4 = <IsarUint8List>[];
  for (var str in value4) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList4.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _meanings = bytesList4;
  final value5 = object.popularity;
  final _popularity = value5;
  final value6 = object.reading;
  final _reading = IsarBinaryWriter.utf8Encoder.convert(value6);
  dynamicSize += (_reading.length) as int;
  final value7 = object.readingLength;
  final _readingLength = value7;
  final value8 = object.sequence;
  final _sequence = value8;
  final value9 = object.word;
  final _word = IsarBinaryWriter.utf8Encoder.convert(value9);
  dynamicSize += (_word.length) as int;
  final value10 = object.wordLength;
  final _wordLength = value10;
  final value11 = object.wordTags;
  dynamicSize += (value11.length) * 8;
  final bytesList11 = <IsarUint8List>[];
  for (var str in value11) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList11.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _wordTags = bytesList11;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _dictionaryName);
  writer.writeBytes(offsets[1], _extra);
  writer.writeLong(offsets[2], _hashCode);
  writer.writeStringList(offsets[3], _meaningTags);
  writer.writeStringList(offsets[4], _meanings);
  writer.writeDouble(offsets[5], _popularity);
  writer.writeBytes(offsets[6], _reading);
  writer.writeLong(offsets[7], _readingLength);
  writer.writeLong(offsets[8], _sequence);
  writer.writeBytes(offsets[9], _word);
  writer.writeLong(offsets[10], _wordLength);
  writer.writeStringList(offsets[11], _wordTags);
}

DictionaryEntry _dictionaryEntryDeserializeNative(
    IsarCollection<DictionaryEntry> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryEntry(
    dictionaryName: reader.readString(offsets[0]),
    extra: reader.readStringOrNull(offsets[1]),
    id: id,
    meaningTags: reader.readStringList(offsets[3]) ?? [],
    meanings: reader.readStringList(offsets[4]) ?? [],
    popularity: reader.readDoubleOrNull(offsets[5]),
    reading: reader.readString(offsets[6]),
    sequence: reader.readLongOrNull(offsets[8]),
    word: reader.readString(offsets[9]),
    wordTags: reader.readStringList(offsets[11]) ?? [],
  );
  return object;
}

P _dictionaryEntryDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryEntrySerializeWeb(
    IsarCollection<DictionaryEntry> collection, DictionaryEntry object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'dictionaryName', object.dictionaryName);
  IsarNative.jsObjectSet(jsObj, 'extra', object.extra);
  IsarNative.jsObjectSet(jsObj, 'hashCode', object.hashCode);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'meaningTags', object.meaningTags);
  IsarNative.jsObjectSet(jsObj, 'meanings', object.meanings);
  IsarNative.jsObjectSet(jsObj, 'popularity', object.popularity);
  IsarNative.jsObjectSet(jsObj, 'reading', object.reading);
  IsarNative.jsObjectSet(jsObj, 'readingLength', object.readingLength);
  IsarNative.jsObjectSet(jsObj, 'sequence', object.sequence);
  IsarNative.jsObjectSet(jsObj, 'word', object.word);
  IsarNative.jsObjectSet(jsObj, 'wordLength', object.wordLength);
  IsarNative.jsObjectSet(jsObj, 'wordTags', object.wordTags);
  return jsObj;
}

DictionaryEntry _dictionaryEntryDeserializeWeb(
    IsarCollection<DictionaryEntry> collection, dynamic jsObj) {
  final object = DictionaryEntry(
    dictionaryName: IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '',
    extra: IsarNative.jsObjectGet(jsObj, 'extra'),
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    meaningTags: (IsarNative.jsObjectGet(jsObj, 'meaningTags') as List?)
            ?.map((e) => e ?? '')
            .toList()
            .cast<String>() ??
        [],
    meanings: (IsarNative.jsObjectGet(jsObj, 'meanings') as List?)
            ?.map((e) => e ?? '')
            .toList()
            .cast<String>() ??
        [],
    popularity: IsarNative.jsObjectGet(jsObj, 'popularity'),
    reading: IsarNative.jsObjectGet(jsObj, 'reading') ?? '',
    sequence: IsarNative.jsObjectGet(jsObj, 'sequence'),
    word: IsarNative.jsObjectGet(jsObj, 'word') ?? '',
    wordTags: (IsarNative.jsObjectGet(jsObj, 'wordTags') as List?)
            ?.map((e) => e ?? '')
            .toList()
            .cast<String>() ??
        [],
  );
  return object;
}

P _dictionaryEntryDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'dictionaryName':
      return (IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '') as P;
    case 'extra':
      return (IsarNative.jsObjectGet(jsObj, 'extra')) as P;
    case 'hashCode':
      return (IsarNative.jsObjectGet(jsObj, 'hashCode') ??
          double.negativeInfinity) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'meaningTags':
      return ((IsarNative.jsObjectGet(jsObj, 'meaningTags') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    case 'meanings':
      return ((IsarNative.jsObjectGet(jsObj, 'meanings') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    case 'popularity':
      return (IsarNative.jsObjectGet(jsObj, 'popularity')) as P;
    case 'reading':
      return (IsarNative.jsObjectGet(jsObj, 'reading') ?? '') as P;
    case 'readingLength':
      return (IsarNative.jsObjectGet(jsObj, 'readingLength') ??
          double.negativeInfinity) as P;
    case 'sequence':
      return (IsarNative.jsObjectGet(jsObj, 'sequence')) as P;
    case 'word':
      return (IsarNative.jsObjectGet(jsObj, 'word') ?? '') as P;
    case 'wordLength':
      return (IsarNative.jsObjectGet(jsObj, 'wordLength') ??
          double.negativeInfinity) as P;
    case 'wordTags':
      return ((IsarNative.jsObjectGet(jsObj, 'wordTags') as List?)
              ?.map((e) => e ?? '')
              .toList()
              .cast<String>() ??
          []) as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _dictionaryEntryAttachLinks(
    IsarCollection col, int id, DictionaryEntry object) {}

extension DictionaryEntryQueryWhereSort
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QWhere> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere>
      anyDictionaryName() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'dictionaryName'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyPopularity() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'popularity'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyReading() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'reading'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere>
      anyReadingLengthPopularity() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'readingLength_popularity'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anySequence() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'sequence'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere>
      anyWordLengthPopularity() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'wordLength_popularity'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere>
      anyWordReadingPopularity() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'word_reading_popularity'));
  }
}

extension DictionaryEntryQueryWhere
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QWhereClause> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idLessThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      dictionaryNameEqualTo(String dictionaryName) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'dictionaryName',
      value: [dictionaryName],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityIsNull() {
    return addWhereClauseInternal(const IndexWhereClause.equalTo(
      indexName: 'popularity',
      value: [null],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityIsNotNull() {
    return addWhereClauseInternal(const IndexWhereClause.greaterThan(
      indexName: 'popularity',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityGreaterThan(double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'popularity',
      lower: [popularity],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityLessThan(double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'popularity',
      upper: [popularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      popularityBetween(double? lowerPopularity, double? upperPopularity) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'popularity',
      lower: [lowerPopularity],
      includeLower: false,
      upper: [upperPopularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingEqualTo(String reading) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'reading',
      value: [reading],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingNotEqualTo(String reading) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'reading',
        upper: [reading],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'reading',
        lower: [reading],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'reading',
        lower: [reading],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'reading',
        upper: [reading],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthEqualTo(int readingLength) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'readingLength_popularity',
      value: [readingLength],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthNotEqualTo(int readingLength) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'readingLength_popularity',
        upper: [readingLength],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'readingLength_popularity',
        lower: [readingLength],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'readingLength_popularity',
        lower: [readingLength],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'readingLength_popularity',
        upper: [readingLength],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthGreaterThan(
    int readingLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'readingLength_popularity',
      lower: [readingLength],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthLessThan(
    int readingLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'readingLength_popularity',
      upper: [readingLength],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthBetween(
    int lowerReadingLength,
    int upperReadingLength, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'readingLength_popularity',
      lower: [lowerReadingLength],
      includeLower: includeLower,
      upper: [upperReadingLength],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthEqualToPopularityGreaterThan(
          int readingLength, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'readingLength_popularity',
      lower: [readingLength, popularity],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthEqualToPopularityLessThan(
          int readingLength, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'readingLength_popularity',
      upper: [readingLength, popularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLengthEqualToPopularityBetween(
          int readingLength, double? lowerPopularity, double? upperPopularity) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'readingLength_popularity',
      lower: [readingLength, lowerPopularity],
      includeLower: false,
      upper: [readingLength, upperPopularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceEqualTo(int? sequence) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'sequence',
      value: [sequence],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceNotEqualTo(int? sequence) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'sequence',
        upper: [sequence],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'sequence',
        lower: [sequence],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'sequence',
        lower: [sequence],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'sequence',
        upper: [sequence],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceIsNull() {
    return addWhereClauseInternal(const IndexWhereClause.equalTo(
      indexName: 'sequence',
      value: [null],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceIsNotNull() {
    return addWhereClauseInternal(const IndexWhereClause.greaterThan(
      indexName: 'sequence',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceGreaterThan(
    int? sequence, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'sequence',
      lower: [sequence],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceLessThan(
    int? sequence, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'sequence',
      upper: [sequence],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      sequenceBetween(
    int? lowerSequence,
    int? upperSequence, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'sequence',
      lower: [lowerSequence],
      includeLower: includeLower,
      upper: [upperSequence],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthEqualTo(int wordLength) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'wordLength_popularity',
      value: [wordLength],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthNotEqualTo(int wordLength) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'wordLength_popularity',
        upper: [wordLength],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'wordLength_popularity',
        lower: [wordLength],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'wordLength_popularity',
        lower: [wordLength],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'wordLength_popularity',
        upper: [wordLength],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthGreaterThan(
    int wordLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'wordLength_popularity',
      lower: [wordLength],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthLessThan(
    int wordLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'wordLength_popularity',
      upper: [wordLength],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthBetween(
    int lowerWordLength,
    int upperWordLength, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'wordLength_popularity',
      lower: [lowerWordLength],
      includeLower: includeLower,
      upper: [upperWordLength],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthEqualToPopularityGreaterThan(
          int wordLength, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'wordLength_popularity',
      lower: [wordLength, popularity],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthEqualToPopularityLessThan(int wordLength, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'wordLength_popularity',
      upper: [wordLength, popularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordLengthEqualToPopularityBetween(
          int wordLength, double? lowerPopularity, double? upperPopularity) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'wordLength_popularity',
      lower: [wordLength, lowerPopularity],
      includeLower: false,
      upper: [wordLength, upperPopularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> wordEqualTo(
      String word) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'word_reading_popularity',
      value: [word],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordNotEqualTo(String word) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word_reading_popularity',
        upper: [word],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word_reading_popularity',
        lower: [word],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word_reading_popularity',
        lower: [word],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word_reading_popularity',
        upper: [word],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordReadingEqualTo(String word, String reading) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'word_reading_popularity',
      value: [word, reading],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordReadingNotEqualTo(String word, String reading) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word_reading_popularity',
        upper: [word, reading],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word_reading_popularity',
        lower: [word, reading],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word_reading_popularity',
        lower: [word, reading],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word_reading_popularity',
        upper: [word, reading],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordReadingEqualToPopularityGreaterThan(
          String word, String reading, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'word_reading_popularity',
      lower: [word, reading, popularity],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordReadingEqualToPopularityLessThan(
          String word, String reading, double? popularity) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'word_reading_popularity',
      upper: [word, reading, popularity],
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      wordReadingEqualToPopularityBetween(String word, String reading,
          double? lowerPopularity, double? upperPopularity) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'word_reading_popularity',
      lower: [word, reading, lowerPopularity],
      includeLower: false,
      upper: [word, reading, upperPopularity],
      includeUpper: false,
    ));
  }
}

extension DictionaryEntryQueryFilter
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QFilterCondition> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'dictionaryName',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'extra',
      value: null,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'extra',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      extraMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'extra',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'hashCode',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      hashCodeGreaterThan(
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      hashCodeLessThan(
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      hashCodeBetween(
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      idEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'meaningTags',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'meaningTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningTagsAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'meaningTags',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'meanings',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'meanings',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      meaningsAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'meanings',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'popularity',
      value: null,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityGreaterThan(double? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: false,
      property: 'popularity',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityLessThan(double? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: false,
      property: 'popularity',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      popularityBetween(double? lower, double? upper) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'popularity',
      lower: lower,
      includeLower: false,
      upper: upper,
      includeUpper: false,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingGreaterThan(
    String value, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLessThan(
    String value, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'reading',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLengthEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'readingLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'readingLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'readingLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      readingLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'readingLength',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      sequenceIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'sequence',
      value: null,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      sequenceEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sequence',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      sequenceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sequence',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      sequenceLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sequence',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      sequenceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sequence',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'word',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'word',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordLengthEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'wordLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'wordLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'wordLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'wordLength',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'wordTags',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'wordTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      wordTagsAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'wordTags',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionaryEntryQueryLinks
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QFilterCondition> {}

extension DictionaryEntryQueryWhereSortBy
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QSortBy> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByExtra() {
    return addSortByInternal('extra', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByExtraDesc() {
    return addSortByInternal('extra', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByPopularity() {
    return addSortByInternal('popularity', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByPopularityDesc() {
    return addSortByInternal('popularity', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByReadingLength() {
    return addSortByInternal('readingLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByReadingLengthDesc() {
    return addSortByInternal('readingLength', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortBySequence() {
    return addSortByInternal('sequence', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortBySequenceDesc() {
    return addSortByInternal('sequence', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByWord() {
    return addSortByInternal('word', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByWordDesc() {
    return addSortByInternal('word', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByWordLength() {
    return addSortByInternal('wordLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByWordLengthDesc() {
    return addSortByInternal('wordLength', Sort.desc);
  }
}

extension DictionaryEntryQueryWhereSortThenBy
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QSortThenBy> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByExtra() {
    return addSortByInternal('extra', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByExtraDesc() {
    return addSortByInternal('extra', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByPopularity() {
    return addSortByInternal('popularity', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByPopularityDesc() {
    return addSortByInternal('popularity', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByReadingLength() {
    return addSortByInternal('readingLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByReadingLengthDesc() {
    return addSortByInternal('readingLength', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenBySequence() {
    return addSortByInternal('sequence', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenBySequenceDesc() {
    return addSortByInternal('sequence', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByWord() {
    return addSortByInternal('word', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByWordDesc() {
    return addSortByInternal('word', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByWordLength() {
    return addSortByInternal('wordLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByWordLengthDesc() {
    return addSortByInternal('wordLength', Sort.desc);
  }
}

extension DictionaryEntryQueryWhereDistinct
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> {
  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByDictionaryName({bool caseSensitive = true}) {
    return addDistinctByInternal('dictionaryName',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByExtra(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('extra', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByHashCode() {
    return addDistinctByInternal('hashCode');
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByPopularity() {
    return addDistinctByInternal('popularity');
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByReading(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('reading', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByReadingLength() {
    return addDistinctByInternal('readingLength');
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctBySequence() {
    return addDistinctByInternal('sequence');
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByWord(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('word', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByWordLength() {
    return addDistinctByInternal('wordLength');
  }
}

extension DictionaryEntryQueryProperty
    on QueryBuilder<DictionaryEntry, DictionaryEntry, QQueryProperty> {
  QueryBuilder<DictionaryEntry, String, QQueryOperations>
      dictionaryNameProperty() {
    return addPropertyNameInternal('dictionaryName');
  }

  QueryBuilder<DictionaryEntry, String?, QQueryOperations> extraProperty() {
    return addPropertyNameInternal('extra');
  }

  QueryBuilder<DictionaryEntry, int, QQueryOperations> hashCodeProperty() {
    return addPropertyNameInternal('hashCode');
  }

  QueryBuilder<DictionaryEntry, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      meaningTagsProperty() {
    return addPropertyNameInternal('meaningTags');
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      meaningsProperty() {
    return addPropertyNameInternal('meanings');
  }

  QueryBuilder<DictionaryEntry, double?, QQueryOperations>
      popularityProperty() {
    return addPropertyNameInternal('popularity');
  }

  QueryBuilder<DictionaryEntry, String, QQueryOperations> readingProperty() {
    return addPropertyNameInternal('reading');
  }

  QueryBuilder<DictionaryEntry, int, QQueryOperations> readingLengthProperty() {
    return addPropertyNameInternal('readingLength');
  }

  QueryBuilder<DictionaryEntry, int?, QQueryOperations> sequenceProperty() {
    return addPropertyNameInternal('sequence');
  }

  QueryBuilder<DictionaryEntry, String, QQueryOperations> wordProperty() {
    return addPropertyNameInternal('word');
  }

  QueryBuilder<DictionaryEntry, int, QQueryOperations> wordLengthProperty() {
    return addPropertyNameInternal('wordLength');
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      wordTagsProperty() {
    return addPropertyNameInternal('wordTags');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    DictionaryEntry(
      word: json['word'] as String,
      dictionaryName: json['dictionaryName'] as String,
      meanings:
          (json['meanings'] as List<dynamic>).map((e) => e as String).toList(),
      reading: json['reading'] as String? ?? '',
      id: json['id'] as int?,
      extra: json['extra'] as String?,
      meaningTags: (json['meaningTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      wordTags: (json['wordTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      popularity: (json['popularity'] as num?)?.toDouble(),
      sequence: json['sequence'] as int?,
    );

Map<String, dynamic> _$DictionaryEntryToJson(DictionaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'dictionaryName': instance.dictionaryName,
      'reading': instance.reading,
      'meanings': instance.meanings,
      'extra': instance.extra,
      'meaningTags': instance.meaningTags,
      'wordTags': instance.wordTags,
      'popularity': instance.popularity,
      'sequence': instance.sequence,
    };
