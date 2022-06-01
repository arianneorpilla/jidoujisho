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
      '{"name":"DictionaryEntry","idName":"id","properties":[{"name":"dictionaryName","type":"String"},{"name":"extra","type":"String"},{"name":"hashCode","type":"Long"},{"name":"meaningTags","type":"StringList"},{"name":"meanings","type":"StringList"},{"name":"popularity","type":"Double"},{"name":"reading","type":"String"},{"name":"readingLength","type":"Long"},{"name":"sequence","type":"Long"},{"name":"term","type":"String"},{"name":"termLength","type":"Long"},{"name":"termTags","type":"StringList"}],"indexes":[{"name":"dictionaryName","unique":false,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"popularity","unique":false,"properties":[{"name":"popularity","type":"Value","caseSensitive":false}]},{"name":"reading","unique":false,"properties":[{"name":"reading","type":"Value","caseSensitive":true}]},{"name":"sequence","unique":false,"properties":[{"name":"sequence","type":"Value","caseSensitive":false}]},{"name":"term","unique":false,"properties":[{"name":"term","type":"Value","caseSensitive":true}]}],"links":[]}',
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
    'term': 9,
    'termLength': 10,
    'termTags': 11
  },
  listProperties: {'meaningTags', 'meanings', 'termTags'},
  indexIds: {
    'dictionaryName': 0,
    'popularity': 1,
    'reading': 2,
    'sequence': 3,
    'term': 4
  },
  indexValueTypes: {
    'dictionaryName': [
      IndexValueType.stringHash,
    ],
    'popularity': [
      IndexValueType.double,
    ],
    'reading': [
      IndexValueType.string,
    ],
    'sequence': [
      IndexValueType.long,
    ],
    'term': [
      IndexValueType.string,
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
  final value9 = object.term;
  final _term = IsarBinaryWriter.utf8Encoder.convert(value9);
  dynamicSize += (_term.length) as int;
  final value10 = object.termLength;
  final _termLength = value10;
  final value11 = object.termTags;
  dynamicSize += (value11.length) * 8;
  final bytesList11 = <IsarUint8List>[];
  for (var str in value11) {
    final bytes = IsarBinaryWriter.utf8Encoder.convert(str);
    bytesList11.add(bytes);
    dynamicSize += bytes.length as int;
  }
  final _termTags = bytesList11;
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
  writer.writeBytes(offsets[9], _term);
  writer.writeLong(offsets[10], _termLength);
  writer.writeStringList(offsets[11], _termTags);
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
    term: reader.readString(offsets[9]),
    termTags: reader.readStringList(offsets[11]) ?? [],
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
  IsarNative.jsObjectSet(jsObj, 'term', object.term);
  IsarNative.jsObjectSet(jsObj, 'termLength', object.termLength);
  IsarNative.jsObjectSet(jsObj, 'termTags', object.termTags);
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
    term: IsarNative.jsObjectGet(jsObj, 'term') ?? '',
    termTags: (IsarNative.jsObjectGet(jsObj, 'termTags') as List?)
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
    case 'term':
      return (IsarNative.jsObjectGet(jsObj, 'term') ?? '') as P;
    case 'termLength':
      return (IsarNative.jsObjectGet(jsObj, 'termLength') ??
          double.negativeInfinity) as P;
    case 'termTags':
      return ((IsarNative.jsObjectGet(jsObj, 'termTags') as List?)
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anySequence() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'sequence'));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhere> anyTerm() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'term'));
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
      readingGreaterThan(
    String reading, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'reading',
      lower: [reading],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingLessThan(
    String reading, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'reading',
      upper: [reading],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingBetween(
    String lowerReading,
    String upperReading, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'reading',
      lower: [lowerReading],
      includeLower: includeLower,
      upper: [upperReading],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      readingStartsWith(String ReadingPrefix) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'reading',
      lower: [ReadingPrefix],
      includeLower: true,
      upper: ['$ReadingPrefix\u{FFFFF}'],
      includeUpper: true,
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> termEqualTo(
      String term) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'term',
      value: [term],
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termNotEqualTo(String term) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'term',
        upper: [term],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'term',
        lower: [term],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'term',
        lower: [term],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'term',
        upper: [term],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termGreaterThan(
    String term, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'term',
      lower: [term],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termLessThan(
    String term, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'term',
      upper: [term],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause> termBetween(
    String lowerTerm,
    String upperTerm, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'term',
      lower: [lowerTerm],
      includeLower: includeLower,
      upper: [upperTerm],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterWhereClause>
      termStartsWith(String TermPrefix) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'term',
      lower: [TermPrefix],
      includeLower: true,
      upper: ['$TermPrefix\u{FFFFF}'],
      includeUpper: true,
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
      termEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termGreaterThan(
    String value, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLessThan(
    String value, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'term',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLengthEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'termLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'termLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'termLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'termLength',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'termTags',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'termTags',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      termTagsAnyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'termTags',
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> sortByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByTermLength() {
    return addSortByInternal('termLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      sortByTermLengthDesc() {
    return addSortByInternal('termLength', Sort.desc);
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy> thenByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByTermLength() {
    return addSortByInternal('termLength', Sort.asc);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterSortBy>
      thenByTermLengthDesc() {
    return addSortByInternal('termLength', Sort.desc);
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

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('term', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryEntry, DictionaryEntry, QDistinct>
      distinctByTermLength() {
    return addDistinctByInternal('termLength');
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

  QueryBuilder<DictionaryEntry, String, QQueryOperations> termProperty() {
    return addPropertyNameInternal('term');
  }

  QueryBuilder<DictionaryEntry, int, QQueryOperations> termLengthProperty() {
    return addPropertyNameInternal('termLength');
  }

  QueryBuilder<DictionaryEntry, List<String>, QQueryOperations>
      termTagsProperty() {
    return addPropertyNameInternal('termTags');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    DictionaryEntry(
      term: json['term'] as String,
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
      termTags: (json['termTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      popularity: (json['popularity'] as num?)?.toDouble(),
      sequence: json['sequence'] as int?,
    );

Map<String, dynamic> _$DictionaryEntryToJson(DictionaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'dictionaryName': instance.dictionaryName,
      'reading': instance.reading,
      'meanings': instance.meanings,
      'extra': instance.extra,
      'meaningTags': instance.meaningTags,
      'termTags': instance.termTags,
      'popularity': instance.popularity,
      'sequence': instance.sequence,
    };
