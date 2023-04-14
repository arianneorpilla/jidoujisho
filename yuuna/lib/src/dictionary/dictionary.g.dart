// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionaryCollection on Isar {
  IsarCollection<Dictionary> get dictionarys => this.collection();
}

const DictionarySchema = CollectionSchema(
  name: r'Dictionary',
  id: 9038313064164341215,
  properties: {
    r'collapsedLanguages': PropertySchema(
      id: 0,
      name: r'collapsedLanguages',
      type: IsarType.stringList,
    ),
    r'formatKey': PropertySchema(
      id: 1,
      name: r'formatKey',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 2,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'hiddenLanguages': PropertySchema(
      id: 3,
      name: r'hiddenLanguages',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 5,
      name: r'order',
      type: IsarType.long,
    )
  },
  estimateSize: _dictionaryEstimateSize,
  serialize: _dictionarySerialize,
  deserialize: _dictionaryDeserialize,
  deserializeProp: _dictionaryDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'order': IndexSchema(
      id: 5897270977454184057,
      name: r'order',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'hiddenLanguages': IndexSchema(
      id: 7420903376471065299,
      name: r'hiddenLanguages',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hiddenLanguages',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collapsedLanguages': IndexSchema(
      id: 2603546669418382826,
      name: r'collapsedLanguages',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collapsedLanguages',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'entries': LinkSchema(
      id: 4394075202200805384,
      name: r'entries',
      target: r'DictionaryEntry',
      single: false,
      linkName: r'dictionary',
    ),
    r'tags': LinkSchema(
      id: 3275231140928199068,
      name: r'tags',
      target: r'DictionaryTag',
      single: false,
      linkName: r'dictionary',
    ),
    r'pitches': LinkSchema(
      id: -7520712212815729325,
      name: r'pitches',
      target: r'DictionaryPitch',
      single: false,
      linkName: r'dictionary',
    ),
    r'frequencies': LinkSchema(
      id: -268974686324604299,
      name: r'frequencies',
      target: r'DictionaryFrequency',
      single: false,
      linkName: r'dictionary',
    )
  },
  embeddedSchemas: {},
  getId: _dictionaryGetId,
  getLinks: _dictionaryGetLinks,
  attach: _dictionaryAttach,
  version: '3.0.6-dev.0',
);

int _dictionaryEstimateSize(
  Dictionary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collapsedLanguages.length * 3;
  {
    for (var i = 0; i < object.collapsedLanguages.length; i++) {
      final value = object.collapsedLanguages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.formatKey.length * 3;
  bytesCount += 3 + object.hiddenLanguages.length * 3;
  {
    for (var i = 0; i < object.hiddenLanguages.length; i++) {
      final value = object.hiddenLanguages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _dictionarySerialize(
  Dictionary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.collapsedLanguages);
  writer.writeString(offsets[1], object.formatKey);
  writer.writeLong(offsets[2], object.hashCode);
  writer.writeStringList(offsets[3], object.hiddenLanguages);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.order);
}

Dictionary _dictionaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Dictionary(
    collapsedLanguages: reader.readStringList(offsets[0]) ?? const [],
    formatKey: reader.readString(offsets[1]),
    hiddenLanguages: reader.readStringList(offsets[3]) ?? const [],
    name: reader.readString(offsets[4]),
    order: reader.readLong(offsets[5]),
  );
  return object;
}

P _dictionaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? const []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? const []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryGetId(Dictionary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dictionaryGetLinks(Dictionary object) {
  return [object.entries, object.tags, object.pitches, object.frequencies];
}

void _dictionaryAttach(IsarCollection<dynamic> col, Id id, Dictionary object) {
  object.entries
      .attach(col, col.isar.collection<DictionaryEntry>(), r'entries', id);
  object.tags.attach(col, col.isar.collection<DictionaryTag>(), r'tags', id);
  object.pitches
      .attach(col, col.isar.collection<DictionaryPitch>(), r'pitches', id);
  object.frequencies.attach(
      col, col.isar.collection<DictionaryFrequency>(), r'frequencies', id);
}

extension DictionaryByIndex on IsarCollection<Dictionary> {
  Future<Dictionary?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Dictionary? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Dictionary?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Dictionary?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Dictionary object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Dictionary object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Dictionary> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Dictionary> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension DictionaryQueryWhereSort
    on QueryBuilder<Dictionary, Dictionary, QWhere> {
  QueryBuilder<Dictionary, Dictionary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhere> anyOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'order'),
      );
    });
  }
}

extension DictionaryQueryWhere
    on QueryBuilder<Dictionary, Dictionary, QWhereClause> {
  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderEqualTo(
      int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'order',
        value: [order],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderNotEqualTo(
      int order) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderGreaterThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [order],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderLessThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [],
        upper: [order],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [lowerOrder],
        includeLower: includeLower,
        upper: [upperOrder],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      hiddenLanguagesEqualTo(List<String> hiddenLanguages) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hiddenLanguages',
        value: [hiddenLanguages],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      hiddenLanguagesNotEqualTo(List<String> hiddenLanguages) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hiddenLanguages',
              lower: [],
              upper: [hiddenLanguages],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hiddenLanguages',
              lower: [hiddenLanguages],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hiddenLanguages',
              lower: [hiddenLanguages],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hiddenLanguages',
              lower: [],
              upper: [hiddenLanguages],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      collapsedLanguagesEqualTo(List<String> collapsedLanguages) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collapsedLanguages',
        value: [collapsedLanguages],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      collapsedLanguagesNotEqualTo(List<String> collapsedLanguages) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collapsedLanguages',
              lower: [],
              upper: [collapsedLanguages],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collapsedLanguages',
              lower: [collapsedLanguages],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collapsedLanguages',
              lower: [collapsedLanguages],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collapsedLanguages',
              lower: [],
              upper: [collapsedLanguages],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DictionaryQueryFilter
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {
  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collapsedLanguages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collapsedLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collapsedLanguages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collapsedLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collapsedLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      collapsedLanguagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collapsedLanguages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formatKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formatKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formatKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formatKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formatKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hiddenLanguages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hiddenLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hiddenLanguages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hiddenLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hiddenLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      hiddenLanguagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenLanguages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DictionaryQueryObject
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {}

extension DictionaryQueryLinks
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {
  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> entries(
      FilterQuery<DictionaryEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'entries');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      entriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', length, true, length, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> entriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, true, 0, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      entriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, false, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      entriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', 0, true, length, include);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      entriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'entries', length, include, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      entriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'entries', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> tags(
      FilterQuery<DictionaryTag> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> pitches(
      FilterQuery<DictionaryPitch> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'pitches');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', length, true, length, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> pitchesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, true, 0, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, false, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', 0, true, length, include);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pitches', length, include, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'pitches', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> frequencies(
      FilterQuery<DictionaryFrequency> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'frequencies');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', length, true, length, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, true, 0, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, false, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', 0, true, length, include);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'frequencies', length, include, 999999, true);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      frequenciesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'frequencies', lower, includeLower, upper, includeUpper);
    });
  }
}

extension DictionaryQuerySortBy
    on QueryBuilder<Dictionary, Dictionary, QSortBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatKey', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatKey', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension DictionaryQuerySortThenBy
    on QueryBuilder<Dictionary, Dictionary, QSortThenBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatKey', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatKey', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension DictionaryQueryWhereDistinct
    on QueryBuilder<Dictionary, Dictionary, QDistinct> {
  QueryBuilder<Dictionary, Dictionary, QDistinct>
      distinctByCollapsedLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collapsedLanguages');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByFormatKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formatKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByHiddenLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hiddenLanguages');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }
}

extension DictionaryQueryProperty
    on QueryBuilder<Dictionary, Dictionary, QQueryProperty> {
  QueryBuilder<Dictionary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Dictionary, List<String>, QQueryOperations>
      collapsedLanguagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collapsedLanguages');
    });
  }

  QueryBuilder<Dictionary, String, QQueryOperations> formatKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formatKey');
    });
  }

  QueryBuilder<Dictionary, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<Dictionary, List<String>, QQueryOperations>
      hiddenLanguagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hiddenLanguages');
    });
  }

  QueryBuilder<Dictionary, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Dictionary, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }
}
