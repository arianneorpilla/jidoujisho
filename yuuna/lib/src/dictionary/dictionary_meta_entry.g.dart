// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_meta_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetDictionaryMetaEntryCollection on Isar {
  IsarCollection<DictionaryMetaEntry> get dictionaryMetaEntrys =>
      getCollection();
}

const DictionaryMetaEntrySchema = CollectionSchema(
  name: 'DictionaryMetaEntry',
  schema:
      '{"name":"DictionaryMetaEntry","idName":"id","properties":[{"name":"dictionaryName","type":"String"},{"name":"frequency","type":"Long"},{"name":"pitches","type":"String"},{"name":"word","type":"String"}],"indexes":[{"name":"dictionaryName","unique":false,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"frequency","unique":false,"properties":[{"name":"frequency","type":"Value","caseSensitive":false}]},{"name":"word","unique":false,"properties":[{"name":"word","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'dictionaryName': 0, 'frequency': 1, 'pitches': 2, 'word': 3},
  listProperties: {},
  indexIds: {'dictionaryName': 0, 'frequency': 1, 'word': 2},
  indexValueTypes: {
    'dictionaryName': [
      IndexValueType.stringHash,
    ],
    'frequency': [
      IndexValueType.long,
    ],
    'word': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _dictionaryMetaEntryGetId,
  setId: _dictionaryMetaEntrySetId,
  getLinks: _dictionaryMetaEntryGetLinks,
  attachLinks: _dictionaryMetaEntryAttachLinks,
  serializeNative: _dictionaryMetaEntrySerializeNative,
  deserializeNative: _dictionaryMetaEntryDeserializeNative,
  deserializePropNative: _dictionaryMetaEntryDeserializePropNative,
  serializeWeb: _dictionaryMetaEntrySerializeWeb,
  deserializeWeb: _dictionaryMetaEntryDeserializeWeb,
  deserializePropWeb: _dictionaryMetaEntryDeserializePropWeb,
  version: 3,
);

int? _dictionaryMetaEntryGetId(DictionaryMetaEntry object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _dictionaryMetaEntrySetId(DictionaryMetaEntry object, int id) {
  object.id = id;
}

List<IsarLinkBase> _dictionaryMetaEntryGetLinks(DictionaryMetaEntry object) {
  return [];
}

const _dictionaryMetaEntryPitchDataConverter = PitchDataConverter();

void _dictionaryMetaEntrySerializeNative(
    IsarCollection<DictionaryMetaEntry> collection,
    IsarRawObject rawObj,
    DictionaryMetaEntry object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.dictionaryName;
  final _dictionaryName = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_dictionaryName.length) as int;
  final value1 = object.frequency;
  final _frequency = value1;
  final value2 = _dictionaryMetaEntryPitchDataConverter.toIsar(object.pitches);
  IsarUint8List? _pitches;
  if (value2 != null) {
    _pitches = IsarBinaryWriter.utf8Encoder.convert(value2);
  }
  dynamicSize += (_pitches?.length ?? 0) as int;
  final value3 = object.word;
  final _word = IsarBinaryWriter.utf8Encoder.convert(value3);
  dynamicSize += (_word.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _dictionaryName);
  writer.writeLong(offsets[1], _frequency);
  writer.writeBytes(offsets[2], _pitches);
  writer.writeBytes(offsets[3], _word);
}

DictionaryMetaEntry _dictionaryMetaEntryDeserializeNative(
    IsarCollection<DictionaryMetaEntry> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryMetaEntry(
    dictionaryName: reader.readString(offsets[0]),
    frequency: reader.readLongOrNull(offsets[1]),
    id: id,
    pitches: _dictionaryMetaEntryPitchDataConverter
        .fromIsar(reader.readStringOrNull(offsets[2])),
    word: reader.readString(offsets[3]),
  );
  return object;
}

P _dictionaryMetaEntryDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (_dictionaryMetaEntryPitchDataConverter
          .fromIsar(reader.readStringOrNull(offset))) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryMetaEntrySerializeWeb(
    IsarCollection<DictionaryMetaEntry> collection,
    DictionaryMetaEntry object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'dictionaryName', object.dictionaryName);
  IsarNative.jsObjectSet(jsObj, 'frequency', object.frequency);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'pitches',
      _dictionaryMetaEntryPitchDataConverter.toIsar(object.pitches));
  IsarNative.jsObjectSet(jsObj, 'word', object.word);
  return jsObj;
}

DictionaryMetaEntry _dictionaryMetaEntryDeserializeWeb(
    IsarCollection<DictionaryMetaEntry> collection, dynamic jsObj) {
  final object = DictionaryMetaEntry(
    dictionaryName: IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '',
    frequency: IsarNative.jsObjectGet(jsObj, 'frequency'),
    id: IsarNative.jsObjectGet(jsObj, 'id'),
    pitches: _dictionaryMetaEntryPitchDataConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'pitches')),
    word: IsarNative.jsObjectGet(jsObj, 'word') ?? '',
  );
  return object;
}

P _dictionaryMetaEntryDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'dictionaryName':
      return (IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '') as P;
    case 'frequency':
      return (IsarNative.jsObjectGet(jsObj, 'frequency')) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'pitches':
      return (_dictionaryMetaEntryPitchDataConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'pitches'))) as P;
    case 'word':
      return (IsarNative.jsObjectGet(jsObj, 'word') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _dictionaryMetaEntryAttachLinks(
    IsarCollection col, int id, DictionaryMetaEntry object) {}

extension DictionaryMetaEntryQueryWhereSort
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QWhere> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere>
      anyDictionaryName() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'dictionaryName'));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere>
      anyFrequency() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'frequency'));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere>
      anyWord() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'word'));
  }
}

extension DictionaryMetaEntryQueryWhere
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QWhereClause> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idEqualTo(int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      dictionaryNameEqualTo(String dictionaryName) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'dictionaryName',
      value: [dictionaryName],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyEqualTo(int? frequency) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'frequency',
      value: [frequency],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyNotEqualTo(int? frequency) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'frequency',
        upper: [frequency],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'frequency',
        lower: [frequency],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'frequency',
        lower: [frequency],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'frequency',
        upper: [frequency],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyIsNull() {
    return addWhereClauseInternal(const IndexWhereClause.equalTo(
      indexName: 'frequency',
      value: [null],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyIsNotNull() {
    return addWhereClauseInternal(const IndexWhereClause.greaterThan(
      indexName: 'frequency',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyGreaterThan(
    int? frequency, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'frequency',
      lower: [frequency],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyLessThan(
    int? frequency, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'frequency',
      upper: [frequency],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyBetween(
    int? lowerFrequency,
    int? upperFrequency, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'frequency',
      lower: [lowerFrequency],
      includeLower: includeLower,
      upper: [upperFrequency],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      wordEqualTo(String word) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'word',
      value: [word],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      wordNotEqualTo(String word) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word',
        upper: [word],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word',
        lower: [word],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'word',
        lower: [word],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'word',
        upper: [word],
        includeUpper: false,
      ));
    }
  }
}

extension DictionaryMetaEntryQueryFilter on QueryBuilder<DictionaryMetaEntry,
    DictionaryMetaEntry, QFilterCondition> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'dictionaryName',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'dictionaryName',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'frequency',
      value: null,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'frequency',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'frequency',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'frequency',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'frequency',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      idEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'pitches',
      value: null,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesEqualTo(
    List<PitchData>? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesGreaterThan(
    List<PitchData>? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesLessThan(
    List<PitchData>? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesBetween(
    List<PitchData>? lower,
    List<PitchData>? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'pitches',
      lower: _dictionaryMetaEntryPitchDataConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _dictionaryMetaEntryPitchDataConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesStartsWith(
    List<PitchData> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesEndsWith(
    List<PitchData> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesContains(List<PitchData> value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'pitches',
      value: _dictionaryMetaEntryPitchDataConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      pitchesMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'pitches',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      wordContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'word',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      wordMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'word',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionaryMetaEntryQueryLinks on QueryBuilder<DictionaryMetaEntry,
    DictionaryMetaEntry, QFilterCondition> {}

extension DictionaryMetaEntryQueryWhereSortBy
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QSortBy> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByFrequency() {
    return addSortByInternal('frequency', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByFrequencyDesc() {
    return addSortByInternal('frequency', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByPitches() {
    return addSortByInternal('pitches', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByPitchesDesc() {
    return addSortByInternal('pitches', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByWord() {
    return addSortByInternal('word', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByWordDesc() {
    return addSortByInternal('word', Sort.desc);
  }
}

extension DictionaryMetaEntryQueryWhereSortThenBy
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QSortThenBy> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByDictionaryName() {
    return addSortByInternal('dictionaryName', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return addSortByInternal('dictionaryName', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByFrequency() {
    return addSortByInternal('frequency', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByFrequencyDesc() {
    return addSortByInternal('frequency', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByPitches() {
    return addSortByInternal('pitches', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByPitchesDesc() {
    return addSortByInternal('pitches', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByWord() {
    return addSortByInternal('word', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByWordDesc() {
    return addSortByInternal('word', Sort.desc);
  }
}

extension DictionaryMetaEntryQueryWhereDistinct
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct> {
  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByDictionaryName({bool caseSensitive = true}) {
    return addDistinctByInternal('dictionaryName',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByFrequency() {
    return addDistinctByInternal('frequency');
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByPitches({bool caseSensitive = true}) {
    return addDistinctByInternal('pitches', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByWord({bool caseSensitive = true}) {
    return addDistinctByInternal('word', caseSensitive: caseSensitive);
  }
}

extension DictionaryMetaEntryQueryProperty
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QQueryProperty> {
  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations>
      dictionaryNameProperty() {
    return addPropertyNameInternal('dictionaryName');
  }

  QueryBuilder<DictionaryMetaEntry, int?, QQueryOperations>
      frequencyProperty() {
    return addPropertyNameInternal('frequency');
  }

  QueryBuilder<DictionaryMetaEntry, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryMetaEntry, List<PitchData>?, QQueryOperations>
      pitchesProperty() {
    return addPropertyNameInternal('pitches');
  }

  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations> wordProperty() {
    return addPropertyNameInternal('word');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryMetaEntry _$DictionaryMetaEntryFromJson(Map<String, dynamic> json) =>
    DictionaryMetaEntry(
      dictionaryName: json['dictionaryName'] as String,
      word: json['word'] as String,
      pitches: (json['pitches'] as List<dynamic>?)
          ?.map((e) => PitchData.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequency: json['frequency'] as int?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$DictionaryMetaEntryToJson(
        DictionaryMetaEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'dictionaryName': instance.dictionaryName,
      'frequency': instance.frequency,
      'pitches': instance.pitches,
    };
