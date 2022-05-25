// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_term.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetDictionaryTermCollection on Isar {
  IsarCollection<DictionaryTerm> get dictionaryTerms => getCollection();
}

const DictionaryTermSchema = CollectionSchema(
  name: 'DictionaryTerm',
  schema:
      '{"name":"DictionaryTerm","idName":"id","properties":[{"name":"entries","type":"String"},{"name":"reading","type":"String"},{"name":"term","type":"String"}],"indexes":[],"links":[]}',
  idName: 'id',
  propertyIds: {'entries': 0, 'reading': 1, 'term': 2},
  listProperties: {},
  indexIds: {},
  indexValueTypes: {},
  linkIds: {},
  backlinkLinkNames: {},
  getId: _dictionaryTermGetId,
  setId: _dictionaryTermSetId,
  getLinks: _dictionaryTermGetLinks,
  attachLinks: _dictionaryTermAttachLinks,
  serializeNative: _dictionaryTermSerializeNative,
  deserializeNative: _dictionaryTermDeserializeNative,
  deserializePropNative: _dictionaryTermDeserializePropNative,
  serializeWeb: _dictionaryTermSerializeWeb,
  deserializeWeb: _dictionaryTermDeserializeWeb,
  deserializePropWeb: _dictionaryTermDeserializePropWeb,
  version: 3,
);

int? _dictionaryTermGetId(DictionaryTerm object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _dictionaryTermSetId(DictionaryTerm object, int id) {
  object.id = id;
}

List<IsarLinkBase> _dictionaryTermGetLinks(DictionaryTerm object) {
  return [];
}

const _dictionaryTermDictionaryEntriesConverter = DictionaryEntriesConverter();

void _dictionaryTermSerializeNative(
    IsarCollection<DictionaryTerm> collection,
    IsarRawObject rawObj,
    DictionaryTerm object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 =
      _dictionaryTermDictionaryEntriesConverter.toIsar(object.entries);
  final _entries = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_entries.length) as int;
  final value1 = object.reading;
  final _reading = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_reading.length) as int;
  final value2 = object.term;
  final _term = IsarBinaryWriter.utf8Encoder.convert(value2);
  dynamicSize += (_term.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _entries);
  writer.writeBytes(offsets[1], _reading);
  writer.writeBytes(offsets[2], _term);
}

DictionaryTerm _dictionaryTermDeserializeNative(
    IsarCollection<DictionaryTerm> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = DictionaryTerm(
    entries: _dictionaryTermDictionaryEntriesConverter
        .fromIsar(reader.readString(offsets[0])),
    reading: reader.readString(offsets[1]),
    term: reader.readString(offsets[2]),
  );
  object.id = id;
  return object;
}

P _dictionaryTermDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (_dictionaryTermDictionaryEntriesConverter
          .fromIsar(reader.readString(offset))) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _dictionaryTermSerializeWeb(
    IsarCollection<DictionaryTerm> collection, DictionaryTerm object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'entries',
      _dictionaryTermDictionaryEntriesConverter.toIsar(object.entries));
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'reading', object.reading);
  IsarNative.jsObjectSet(jsObj, 'term', object.term);
  return jsObj;
}

DictionaryTerm _dictionaryTermDeserializeWeb(
    IsarCollection<DictionaryTerm> collection, dynamic jsObj) {
  final object = DictionaryTerm(
    entries: _dictionaryTermDictionaryEntriesConverter
        .fromIsar(IsarNative.jsObjectGet(jsObj, 'entries') ?? ''),
    reading: IsarNative.jsObjectGet(jsObj, 'reading') ?? '',
    term: IsarNative.jsObjectGet(jsObj, 'term') ?? '',
  );
  object.id = IsarNative.jsObjectGet(jsObj, 'id');
  return object;
}

P _dictionaryTermDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'entries':
      return (_dictionaryTermDictionaryEntriesConverter
          .fromIsar(IsarNative.jsObjectGet(jsObj, 'entries') ?? '')) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'reading':
      return (IsarNative.jsObjectGet(jsObj, 'reading') ?? '') as P;
    case 'term':
      return (IsarNative.jsObjectGet(jsObj, 'term') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _dictionaryTermAttachLinks(
    IsarCollection col, int id, DictionaryTerm object) {}

extension DictionaryTermQueryWhereSort
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QWhere> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }
}

extension DictionaryTermQueryWhere
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QWhereClause> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idLessThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterWhereClause> idBetween(
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

extension DictionaryTermQueryFilter
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QFilterCondition> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesEqualTo(
    List<DictionaryEntry> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesGreaterThan(
    List<DictionaryEntry> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesLessThan(
    List<DictionaryEntry> value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesBetween(
    List<DictionaryEntry> lower,
    List<DictionaryEntry> upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'entries',
      lower: _dictionaryTermDictionaryEntriesConverter.toIsar(lower),
      includeLower: includeLower,
      upper: _dictionaryTermDictionaryEntriesConverter.toIsar(upper),
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesStartsWith(
    List<DictionaryEntry> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesEndsWith(
    List<DictionaryEntry> value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesContains(List<DictionaryEntry> value,
          {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'entries',
      value: _dictionaryTermDictionaryEntriesConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      entriesMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'entries',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'reading',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      readingMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'reading',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
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

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'term',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'term',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension DictionaryTermQueryLinks
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QFilterCondition> {}

extension DictionaryTermQueryWhereSortBy
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QSortBy> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByEntries() {
    return addSortByInternal('entries', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByEntriesDesc() {
    return addSortByInternal('entries', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      sortByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> sortByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }
}

extension DictionaryTermQueryWhereSortThenBy
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QSortThenBy> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByEntries() {
    return addSortByInternal('entries', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByEntriesDesc() {
    return addSortByInternal('entries', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByReading() {
    return addSortByInternal('reading', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy>
      thenByReadingDesc() {
    return addSortByInternal('reading', Sort.desc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByTerm() {
    return addSortByInternal('term', Sort.asc);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QAfterSortBy> thenByTermDesc() {
    return addSortByInternal('term', Sort.desc);
  }
}

extension DictionaryTermQueryWhereDistinct
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> {
  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByEntries(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('entries', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByReading(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('reading', caseSensitive: caseSensitive);
  }

  QueryBuilder<DictionaryTerm, DictionaryTerm, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('term', caseSensitive: caseSensitive);
  }
}

extension DictionaryTermQueryProperty
    on QueryBuilder<DictionaryTerm, DictionaryTerm, QQueryProperty> {
  QueryBuilder<DictionaryTerm, List<DictionaryEntry>, QQueryOperations>
      entriesProperty() {
    return addPropertyNameInternal('entries');
  }

  QueryBuilder<DictionaryTerm, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations> readingProperty() {
    return addPropertyNameInternal('reading');
  }

  QueryBuilder<DictionaryTerm, String, QQueryOperations> termProperty() {
    return addPropertyNameInternal('term');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryTerm _$DictionaryTermFromJson(Map<String, dynamic> json) =>
    DictionaryTerm(
      term: json['term'] as String,
      reading: json['reading'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..id = json['id'] as int?;

Map<String, dynamic> _$DictionaryTermToJson(DictionaryTerm instance) =>
    <String, dynamic>{
      'term': instance.term,
      'reading': instance.reading,
      'entries': instance.entries,
      'id': instance.id,
    };
