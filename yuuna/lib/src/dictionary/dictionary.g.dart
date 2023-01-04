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
    r'collapsed': PropertySchema(
      id: 0,
      name: r'collapsed',
      type: IsarType.bool,
    ),
    r'dictionaryName': PropertySchema(
      id: 1,
      name: r'dictionaryName',
      type: IsarType.string,
    ),
    r'formatName': PropertySchema(
      id: 2,
      name: r'formatName',
      type: IsarType.string,
    ),
    r'hidden': PropertySchema(
      id: 3,
      name: r'hidden',
      type: IsarType.bool,
    ),
    r'order': PropertySchema(
      id: 4,
      name: r'order',
      type: IsarType.long,
    ),
    r'pitchesIsar': PropertySchema(
      id: 5,
      name: r'pitchesIsar',
      type: IsarType.string,
    )
  },
  estimateSize: _dictionaryEstimateSize,
  serialize: _dictionarySerialize,
  deserialize: _dictionaryDeserialize,
  deserializeProp: _dictionaryDeserializeProp,
  idName: r'id',
  indexes: {
    r'dictionaryName': IndexSchema(
      id: 6941277455010515489,
      name: r'dictionaryName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dictionaryName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'order': IndexSchema(
      id: 5897270977454184057,
      name: r'order',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dictionaryGetId,
  getLinks: _dictionaryGetLinks,
  attach: _dictionaryAttach,
  version: '3.0.0',
);

int _dictionaryEstimateSize(
  Dictionary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dictionaryName.length * 3;
  bytesCount += 3 + object.formatName.length * 3;
  bytesCount += 3 + object.pitchesIsar.length * 3;
  return bytesCount;
}

void _dictionarySerialize(
  Dictionary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.collapsed);
  writer.writeString(offsets[1], object.dictionaryName);
  writer.writeString(offsets[2], object.formatName);
  writer.writeBool(offsets[3], object.hidden);
  writer.writeLong(offsets[4], object.order);
  writer.writeString(offsets[5], object.pitchesIsar);
}

Dictionary _dictionaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Dictionary(
    collapsed: reader.readBool(offsets[0]),
    dictionaryName: reader.readString(offsets[1]),
    formatName: reader.readString(offsets[2]),
    hidden: reader.readBool(offsets[3]),
    order: reader.readLong(offsets[4]),
  );
  object.id = id;
  object.pitchesIsar = reader.readString(offsets[5]);
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
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryGetId(Dictionary object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryGetLinks(Dictionary object) {
  return [];
}

void _dictionaryAttach(IsarCollection<dynamic> col, Id id, Dictionary object) {
  object.id = id;
}

extension DictionaryByIndex on IsarCollection<Dictionary> {
  Future<Dictionary?> getByDictionaryName(String dictionaryName) {
    return getByIndex(r'dictionaryName', [dictionaryName]);
  }

  Dictionary? getByDictionaryNameSync(String dictionaryName) {
    return getByIndexSync(r'dictionaryName', [dictionaryName]);
  }

  Future<bool> deleteByDictionaryName(String dictionaryName) {
    return deleteByIndex(r'dictionaryName', [dictionaryName]);
  }

  bool deleteByDictionaryNameSync(String dictionaryName) {
    return deleteByIndexSync(r'dictionaryName', [dictionaryName]);
  }

  Future<List<Dictionary?>> getAllByDictionaryName(
      List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'dictionaryName', values);
  }

  List<Dictionary?> getAllByDictionaryNameSync(
      List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dictionaryName', values);
  }

  Future<int> deleteAllByDictionaryName(List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dictionaryName', values);
  }

  int deleteAllByDictionaryNameSync(List<String> dictionaryNameValues) {
    final values = dictionaryNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dictionaryName', values);
  }

  Future<Id> putByDictionaryName(Dictionary object) {
    return putByIndex(r'dictionaryName', object);
  }

  Id putByDictionaryNameSync(Dictionary object, {bool saveLinks = true}) {
    return putByIndexSync(r'dictionaryName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDictionaryName(List<Dictionary> objects) {
    return putAllByIndex(r'dictionaryName', objects);
  }

  List<Id> putAllByDictionaryNameSync(List<Dictionary> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'dictionaryName', objects, saveLinks: saveLinks);
  }

  Future<Dictionary?> getByOrder(int order) {
    return getByIndex(r'order', [order]);
  }

  Dictionary? getByOrderSync(int order) {
    return getByIndexSync(r'order', [order]);
  }

  Future<bool> deleteByOrder(int order) {
    return deleteByIndex(r'order', [order]);
  }

  bool deleteByOrderSync(int order) {
    return deleteByIndexSync(r'order', [order]);
  }

  Future<List<Dictionary?>> getAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndex(r'order', values);
  }

  List<Dictionary?> getAllByOrderSync(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'order', values);
  }

  Future<int> deleteAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'order', values);
  }

  int deleteAllByOrderSync(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'order', values);
  }

  Future<Id> putByOrder(Dictionary object) {
    return putByIndex(r'order', object);
  }

  Id putByOrderSync(Dictionary object, {bool saveLinks = true}) {
    return putByIndexSync(r'order', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrder(List<Dictionary> objects) {
    return putAllByIndex(r'order', objects);
  }

  List<Id> putAllByOrderSync(List<Dictionary> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'order', objects, saveLinks: saveLinks);
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

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause> dictionaryNameEqualTo(
      String dictionaryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dictionaryName',
        value: [dictionaryName],
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterWhereClause>
      dictionaryNameNotEqualTo(String dictionaryName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [],
              upper: [dictionaryName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [dictionaryName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [dictionaryName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dictionaryName',
              lower: [],
              upper: [dictionaryName],
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
}

extension DictionaryQueryFilter
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {
  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> collapsedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collapsed',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dictionaryName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dictionaryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dictionaryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      dictionaryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dictionaryName',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formatName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formatName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> formatNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formatName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formatName',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      formatNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formatName',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> hiddenEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hidden',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition> idGreaterThan(
    Id? value, {
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
    Id? value, {
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
    Id? lower,
    Id? upper, {
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

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pitchesIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pitchesIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pitchesIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pitchesIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterFilterCondition>
      pitchesIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pitchesIsar',
        value: '',
      ));
    });
  }
}

extension DictionaryQueryObject
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {}

extension DictionaryQueryLinks
    on QueryBuilder<Dictionary, Dictionary, QFilterCondition> {}

extension DictionaryQuerySortBy
    on QueryBuilder<Dictionary, Dictionary, QSortBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByCollapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collapsed', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByCollapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collapsed', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy>
      sortByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatName', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByFormatNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatName', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidden', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidden', Sort.desc);
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

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByPitchesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> sortByPitchesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.desc);
    });
  }
}

extension DictionaryQuerySortThenBy
    on QueryBuilder<Dictionary, Dictionary, QSortThenBy> {
  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByCollapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collapsed', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByCollapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collapsed', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByDictionaryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy>
      thenByDictionaryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryName', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatName', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByFormatNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formatName', Sort.desc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidden', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidden', Sort.desc);
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

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByPitchesIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.asc);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QAfterSortBy> thenByPitchesIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pitchesIsar', Sort.desc);
    });
  }
}

extension DictionaryQueryWhereDistinct
    on QueryBuilder<Dictionary, Dictionary, QDistinct> {
  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByCollapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collapsed');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByDictionaryName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dictionaryName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByFormatName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formatName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hidden');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<Dictionary, Dictionary, QDistinct> distinctByPitchesIsar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pitchesIsar', caseSensitive: caseSensitive);
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

  QueryBuilder<Dictionary, bool, QQueryOperations> collapsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collapsed');
    });
  }

  QueryBuilder<Dictionary, String, QQueryOperations> dictionaryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dictionaryName');
    });
  }

  QueryBuilder<Dictionary, String, QQueryOperations> formatNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formatName');
    });
  }

  QueryBuilder<Dictionary, bool, QQueryOperations> hiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hidden');
    });
  }

  QueryBuilder<Dictionary, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<Dictionary, String, QQueryOperations> pitchesIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pitchesIsar');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dictionary _$DictionaryFromJson(Map<String, dynamic> json) => Dictionary(
      dictionaryName: json['dictionaryName'] as String,
      formatName: json['formatName'] as String,
      order: json['order'] as int,
      collapsed: json['collapsed'] as bool,
      hidden: json['hidden'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
    )
      ..id = json['id'] as int?
      ..pitchesIsar = json['pitchesIsar'] as String;

Map<String, dynamic> _$DictionaryToJson(Dictionary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dictionaryName': instance.dictionaryName,
      'formatName': instance.formatName,
      'order': instance.order,
      'collapsed': instance.collapsed,
      'hidden': instance.hidden,
      'metadata': instance.metadata,
      'pitchesIsar': instance.pitchesIsar,
    };
