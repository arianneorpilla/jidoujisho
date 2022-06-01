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
      '{"name":"DictionaryMetaEntry","idName":"id","properties":[{"name":"dictionaryName","type":"String"},{"name":"frequency","type":"String"},{"name":"hashCode","type":"Long"},{"name":"pitches","type":"String"},{"name":"term","type":"String"},{"name":"termLength","type":"Long"}],"indexes":[{"name":"dictionaryName","unique":false,"properties":[{"name":"dictionaryName","type":"Hash","caseSensitive":true}]},{"name":"frequency","unique":false,"properties":[{"name":"frequency","type":"Hash","caseSensitive":true}]},{"name":"term","unique":false,"properties":[{"name":"term","type":"Hash","caseSensitive":true}]},{"name":"termLength_term","unique":false,"properties":[{"name":"termLength","type":"Value","caseSensitive":false},{"name":"term","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'dictionaryName': 0,
    'frequency': 1,
    'hashCode': 2,
    'pitches': 3,
    'term': 4,
    'termLength': 5
  },
  listProperties: {},
  indexIds: {
    'dictionaryName': 0,
    'frequency': 1,
    'term': 2,
    'termLength_term': 3
  },
  indexValueTypes: {
    'dictionaryName': [
      IndexValueType.stringHash,
    ],
    'frequency': [
      IndexValueType.stringHash,
    ],
    'term': [
      IndexValueType.stringHash,
    ],
    'termLength_term': [
      IndexValueType.long,
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
  IsarUint8List? _frequency;
  if (value1 != null) {
    _frequency = IsarBinaryWriter.utf8Encoder.convert(value1);
  }
  dynamicSize += (_frequency?.length ?? 0) as int;
  final value2 = object.hashCode;
  final _hashCode = value2;
  final value3 = _dictionaryMetaEntryPitchDataConverter.toIsar(object.pitches);
  IsarUint8List? _pitches;
  if (value3 != null) {
    _pitches = IsarBinaryWriter.utf8Encoder.convert(value3);
  }
  dynamicSize += (_pitches?.length ?? 0) as int;
  final value4 = object.term;
  final _term = IsarBinaryWriter.utf8Encoder.convert(value4);
  dynamicSize += (_term.length) as int;
  final value5 = object.termLength;
  final _termLength = value5;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _dictionaryName);
  writer.writeBytes(offsets[1], _frequency);
  writer.writeLong(offsets[2], _hashCode);
  writer.writeBytes(offsets[3], _pitches);
  writer.writeBytes(offsets[4], _term);
  writer.writeLong(offsets[5], _termLength);
}

DictionaryMetaEntry _dictionaryMetaEntryDeserializeNative(
    IsarCollection<DictionaryMetaEntry> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryMetaEntry(
    dictionaryName: reader.readString(offsets[0]),
    frequency: reader.readStringOrNull(offsets[1]),
    id: id,
    pitches: _dictionaryMetaEntryPitchDataConverter
        .fromIsar(reader.readStringOrNull(offsets[3])),
    term: reader.readString(offsets[4]),
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
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (_dictionaryMetaEntryPitchDataConverter
          .fromIsar(reader.readStringOrNull(offset))) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
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
  IsarNative.jsObjectSet(jsObj, 'hashCode', object.hashCode);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'pitches',
      _dictionaryMetaEntryPitchDataConverter.toIsar(object.pitches));
  IsarNative.jsObjectSet(jsObj, 'term', object.term);
  IsarNative.jsObjectSet(jsObj, 'termLength', object.termLength);
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
    term: IsarNative.jsObjectGet(jsObj, 'term') ?? '',
  );
  return object;
}

P _dictionaryMetaEntryDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'dictionaryName':
      return (IsarNative.jsObjectGet(jsObj, 'dictionaryName') ?? '') as P;
    case 'frequency':
      return (IsarNative.jsObjectGet(jsObj, 'frequency')) as P;
    case 'hashCode':
      return (IsarNative.jsObjectGet(jsObj, 'hashCode') ??
          double.negativeInfinity) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'pitches':
      return (_dictionaryMetaEntryPitchDataConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'pitches'))) as P;
    case 'term':
      return (IsarNative.jsObjectGet(jsObj, 'term') ?? '') as P;
    case 'termLength':
      return (IsarNative.jsObjectGet(jsObj, 'termLength') ??
          double.negativeInfinity) as P;
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
      anyTerm() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'term'));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhere>
      anyTermLengthTerm() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'termLength_term'));
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
      frequencyEqualTo(String? frequency) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'frequency',
      value: [frequency],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      frequencyNotEqualTo(String? frequency) {
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
      termEqualTo(String term) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'term',
      value: [term],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthEqualTo(int termLength) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'termLength_term',
      value: [termLength],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthNotEqualTo(int termLength) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'termLength_term',
        upper: [termLength],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'termLength_term',
        lower: [termLength],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'termLength_term',
        lower: [termLength],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'termLength_term',
        upper: [termLength],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthGreaterThan(
    int termLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'termLength_term',
      lower: [termLength],
      includeLower: include,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthLessThan(
    int termLength, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'termLength_term',
      upper: [termLength],
      includeUpper: include,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthBetween(
    int lowerTermLength,
    int upperTermLength, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'termLength_term',
      lower: [lowerTermLength],
      includeLower: includeLower,
      upper: [upperTermLength],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthTermEqualTo(int termLength, String term) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'termLength_term',
      value: [termLength, term],
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterWhereClause>
      termLengthTermNotEqualTo(int termLength, String term) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'termLength_term',
        upper: [termLength, term],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'termLength_term',
        lower: [termLength, term],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'termLength_term',
        lower: [termLength, term],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'termLength_term',
        upper: [termLength, term],
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
      frequencyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'frequency',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'frequency',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      frequencyMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'frequency',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'hashCode',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'term',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
      termLengthEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'termLength',
      value: value,
    ));
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterFilterCondition>
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
      sortByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
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
      sortByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermLength() {
    return addSortByInternal('termLength', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      sortByTermLengthDesc() {
    return addSortByInternal('termLength', Sort.desc);
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
      thenByHashCode() {
    return addSortByInternal('hashCode', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByHashCodeDesc() {
    return addSortByInternal('hashCode', Sort.desc);
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
      thenByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermLength() {
    return addSortByInternal('termLength', Sort.asc);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QAfterSortBy>
      thenByTermLengthDesc() {
    return addSortByInternal('termLength', Sort.desc);
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
      distinctByFrequency({bool caseSensitive = true}) {
    return addDistinctByInternal('frequency', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByHashCode() {
    return addDistinctByInternal('hashCode');
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
      distinctByTerm({bool caseSensitive = true}) {
    return addDistinctByInternal('term', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QDistinct>
      distinctByTermLength() {
    return addDistinctByInternal('termLength');
  }
}

extension DictionaryMetaEntryQueryProperty
    on QueryBuilder<DictionaryMetaEntry, DictionaryMetaEntry, QQueryProperty> {
  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations>
      dictionaryNameProperty() {
    return addPropertyNameInternal('dictionaryName');
  }

  QueryBuilder<DictionaryMetaEntry, String?, QQueryOperations>
      frequencyProperty() {
    return addPropertyNameInternal('frequency');
  }

  QueryBuilder<DictionaryMetaEntry, int, QQueryOperations> hashCodeProperty() {
    return addPropertyNameInternal('hashCode');
  }

  QueryBuilder<DictionaryMetaEntry, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryMetaEntry, List<PitchData>?, QQueryOperations>
      pitchesProperty() {
    return addPropertyNameInternal('pitches');
  }

  QueryBuilder<DictionaryMetaEntry, String, QQueryOperations> termProperty() {
    return addPropertyNameInternal('term');
  }

  QueryBuilder<DictionaryMetaEntry, int, QQueryOperations>
      termLengthProperty() {
    return addPropertyNameInternal('termLength');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryMetaEntry _$DictionaryMetaEntryFromJson(Map<String, dynamic> json) =>
    DictionaryMetaEntry(
      dictionaryName: json['dictionaryName'] as String,
      term: json['term'] as String,
      pitches: (json['pitches'] as List<dynamic>?)
          ?.map((e) => PitchData.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequency: json['frequency'] as String?,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$DictionaryMetaEntryToJson(
        DictionaryMetaEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'term': instance.term,
      'dictionaryName': instance.dictionaryName,
      'frequency': instance.frequency,
      'pitches': instance.pitches,
    };
