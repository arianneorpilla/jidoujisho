// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anki_mapping.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetAnkiMappingCollection on Isar {
  IsarCollection<AnkiMapping> get ankiMappings => this.collection();
}

const AnkiMappingSchema = CollectionSchema(
  name: r'AnkiMapping',
  id: -9131188405906642167,
  properties: {
    r'actionsIsar': PropertySchema(
      id: 0,
      name: r'actionsIsar',
      type: IsarType.string,
    ),
    r'creatorCollapsedFieldKeys': PropertySchema(
      id: 1,
      name: r'creatorCollapsedFieldKeys',
      type: IsarType.stringList,
    ),
    r'creatorFieldKeys': PropertySchema(
      id: 2,
      name: r'creatorFieldKeys',
      type: IsarType.stringList,
    ),
    r'enhancementsIsar': PropertySchema(
      id: 3,
      name: r'enhancementsIsar',
      type: IsarType.string,
    ),
    r'exportFieldKeys': PropertySchema(
      id: 4,
      name: r'exportFieldKeys',
      type: IsarType.stringList,
    ),
    r'exportMediaTags': PropertySchema(
      id: 5,
      name: r'exportMediaTags',
      type: IsarType.bool,
    ),
    r'label': PropertySchema(
      id: 6,
      name: r'label',
      type: IsarType.string,
    ),
    r'model': PropertySchema(
      id: 7,
      name: r'model',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 8,
      name: r'order',
      type: IsarType.long,
    ),
    r'tags': PropertySchema(
      id: 9,
      name: r'tags',
      type: IsarType.stringList,
    )
  },
  estimateSize: _ankiMappingEstimateSize,
  serialize: _ankiMappingSerialize,
  deserialize: _ankiMappingDeserialize,
  deserializeProp: _ankiMappingDeserializeProp,
  idName: r'id',
  indexes: {
    r'label': IndexSchema(
      id: 6902807635198700142,
      name: r'label',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'label',
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
  getId: _ankiMappingGetId,
  getLinks: _ankiMappingGetLinks,
  attach: _ankiMappingAttach,
  version: '3.0.6-dev.0',
);

int _ankiMappingEstimateSize(
  AnkiMapping object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionsIsar.length * 3;
  bytesCount += 3 + object.creatorCollapsedFieldKeys.length * 3;
  {
    for (var i = 0; i < object.creatorCollapsedFieldKeys.length; i++) {
      final value = object.creatorCollapsedFieldKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.creatorFieldKeys.length * 3;
  {
    for (var i = 0; i < object.creatorFieldKeys.length; i++) {
      final value = object.creatorFieldKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.enhancementsIsar.length * 3;
  bytesCount += 3 + object.exportFieldKeys.length * 3;
  {
    for (var i = 0; i < object.exportFieldKeys.length; i++) {
      final value = object.exportFieldKeys[i];
      if (value != null) {
        bytesCount += value.length * 3;
      }
    }
  }
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _ankiMappingSerialize(
  AnkiMapping object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionsIsar);
  writer.writeStringList(offsets[1], object.creatorCollapsedFieldKeys);
  writer.writeStringList(offsets[2], object.creatorFieldKeys);
  writer.writeString(offsets[3], object.enhancementsIsar);
  writer.writeStringList(offsets[4], object.exportFieldKeys);
  writer.writeBool(offsets[5], object.exportMediaTags);
  writer.writeString(offsets[6], object.label);
  writer.writeString(offsets[7], object.model);
  writer.writeLong(offsets[8], object.order);
  writer.writeStringList(offsets[9], object.tags);
}

AnkiMapping _ankiMappingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnkiMapping(
    creatorCollapsedFieldKeys: reader.readStringList(offsets[1]) ?? [],
    creatorFieldKeys: reader.readStringList(offsets[2]) ?? [],
    exportFieldKeys: reader.readStringOrNullList(offsets[4]) ?? [],
    exportMediaTags: reader.readBoolOrNull(offsets[5]),
    id: id,
    label: reader.readString(offsets[6]),
    model: reader.readString(offsets[7]),
    order: reader.readLong(offsets[8]),
    tags: reader.readStringList(offsets[9]) ?? [],
  );
  object.actionsIsar = reader.readString(offsets[0]);
  object.enhancementsIsar = reader.readString(offsets[3]);
  return object;
}

P _ankiMappingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNullList(offset) ?? []) as P;
    case 5:
      return (reader.readBoolOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ankiMappingGetId(AnkiMapping object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _ankiMappingGetLinks(AnkiMapping object) {
  return [];
}

void _ankiMappingAttach(
    IsarCollection<dynamic> col, Id id, AnkiMapping object) {
  object.id = id;
}

extension AnkiMappingByIndex on IsarCollection<AnkiMapping> {
  Future<AnkiMapping?> getByLabel(String label) {
    return getByIndex(r'label', [label]);
  }

  AnkiMapping? getByLabelSync(String label) {
    return getByIndexSync(r'label', [label]);
  }

  Future<bool> deleteByLabel(String label) {
    return deleteByIndex(r'label', [label]);
  }

  bool deleteByLabelSync(String label) {
    return deleteByIndexSync(r'label', [label]);
  }

  Future<List<AnkiMapping?>> getAllByLabel(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return getAllByIndex(r'label', values);
  }

  List<AnkiMapping?> getAllByLabelSync(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'label', values);
  }

  Future<int> deleteAllByLabel(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'label', values);
  }

  int deleteAllByLabelSync(List<String> labelValues) {
    final values = labelValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'label', values);
  }

  Future<Id> putByLabel(AnkiMapping object) {
    return putByIndex(r'label', object);
  }

  Id putByLabelSync(AnkiMapping object, {bool saveLinks = true}) {
    return putByIndexSync(r'label', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLabel(List<AnkiMapping> objects) {
    return putAllByIndex(r'label', objects);
  }

  List<Id> putAllByLabelSync(List<AnkiMapping> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'label', objects, saveLinks: saveLinks);
  }

  Future<AnkiMapping?> getByOrder(int order) {
    return getByIndex(r'order', [order]);
  }

  AnkiMapping? getByOrderSync(int order) {
    return getByIndexSync(r'order', [order]);
  }

  Future<bool> deleteByOrder(int order) {
    return deleteByIndex(r'order', [order]);
  }

  bool deleteByOrderSync(int order) {
    return deleteByIndexSync(r'order', [order]);
  }

  Future<List<AnkiMapping?>> getAllByOrder(List<int> orderValues) {
    final values = orderValues.map((e) => [e]).toList();
    return getAllByIndex(r'order', values);
  }

  List<AnkiMapping?> getAllByOrderSync(List<int> orderValues) {
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

  Future<Id> putByOrder(AnkiMapping object) {
    return putByIndex(r'order', object);
  }

  Id putByOrderSync(AnkiMapping object, {bool saveLinks = true}) {
    return putByIndexSync(r'order', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrder(List<AnkiMapping> objects) {
    return putAllByIndex(r'order', objects);
  }

  List<Id> putAllByOrderSync(List<AnkiMapping> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'order', objects, saveLinks: saveLinks);
  }
}

extension AnkiMappingQueryWhereSort
    on QueryBuilder<AnkiMapping, AnkiMapping, QWhere> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhere> anyOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'order'),
      );
    });
  }
}

extension AnkiMappingQueryWhere
    on QueryBuilder<AnkiMapping, AnkiMapping, QWhereClause> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> labelEqualTo(
      String label) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'label',
        value: [label],
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> labelNotEqualTo(
      String label) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label',
              lower: [],
              upper: [label],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label',
              lower: [label],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label',
              lower: [label],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label',
              lower: [],
              upper: [label],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderEqualTo(
      int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'order',
        value: [order],
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderNotEqualTo(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderGreaterThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderLessThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterWhereClause> orderBetween(
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

extension AnkiMappingQueryFilter
    on QueryBuilder<AnkiMapping, AnkiMapping, QFilterCondition> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionsIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionsIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      actionsIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorCollapsedFieldKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorCollapsedFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorCollapsedFieldKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorCollapsedFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorCollapsedFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorCollapsedFieldKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorCollapsedFieldKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorFieldKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorFieldKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      creatorFieldKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'creatorFieldKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enhancementsIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enhancementsIsar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enhancementsIsar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enhancementsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      enhancementsIsarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enhancementsIsar',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.elementIsNull(
        property: r'exportFieldKeys',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.elementIsNotNull(
        property: r'exportFieldKeys',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exportFieldKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exportFieldKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exportFieldKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exportFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exportFieldKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportFieldKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exportFieldKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportMediaTagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exportMediaTags',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportMediaTagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exportMediaTags',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      exportMediaTagsEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exportMediaTags',
        value: value,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      orderGreaterThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderLessThan(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> orderBetween(
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

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AnkiMappingQueryObject
    on QueryBuilder<AnkiMapping, AnkiMapping, QFilterCondition> {}

extension AnkiMappingQueryLinks
    on QueryBuilder<AnkiMapping, AnkiMapping, QFilterCondition> {}

extension AnkiMappingQuerySortBy
    on QueryBuilder<AnkiMapping, AnkiMapping, QSortBy> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByActionsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionsIsar', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByActionsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionsIsar', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      sortByEnhancementsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enhancementsIsar', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      sortByEnhancementsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enhancementsIsar', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByExportMediaTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportMediaTags', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      sortByExportMediaTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportMediaTags', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension AnkiMappingQuerySortThenBy
    on QueryBuilder<AnkiMapping, AnkiMapping, QSortThenBy> {
  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByActionsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionsIsar', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByActionsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionsIsar', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      thenByEnhancementsIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enhancementsIsar', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      thenByEnhancementsIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enhancementsIsar', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByExportMediaTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportMediaTags', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy>
      thenByExportMediaTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportMediaTags', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension AnkiMappingQueryWhereDistinct
    on QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> {
  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByActionsIsar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionsIsar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct>
      distinctByCreatorCollapsedFieldKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorCollapsedFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct>
      distinctByCreatorFieldKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByEnhancementsIsar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enhancementsIsar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct>
      distinctByExportFieldKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exportFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct>
      distinctByExportMediaTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exportMediaTags');
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<AnkiMapping, AnkiMapping, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }
}

extension AnkiMappingQueryProperty
    on QueryBuilder<AnkiMapping, AnkiMapping, QQueryProperty> {
  QueryBuilder<AnkiMapping, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations> actionsIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionsIsar');
    });
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations>
      creatorCollapsedFieldKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorCollapsedFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations>
      creatorFieldKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations>
      enhancementsIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enhancementsIsar');
    });
  }

  QueryBuilder<AnkiMapping, List<String?>, QQueryOperations>
      exportFieldKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exportFieldKeys');
    });
  }

  QueryBuilder<AnkiMapping, bool?, QQueryOperations> exportMediaTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exportMediaTags');
    });
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<AnkiMapping, String, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<AnkiMapping, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<AnkiMapping, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnkiMapping _$AnkiMappingFromJson(Map<String, dynamic> json) => AnkiMapping(
      label: json['label'] as String,
      model: json['model'] as String,
      exportFieldKeys: (json['exportFieldKeys'] as List<dynamic>)
          .map((e) => e as String?)
          .toList(),
      creatorFieldKeys: (json['creatorFieldKeys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      creatorCollapsedFieldKeys:
          (json['creatorCollapsedFieldKeys'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      order: json['order'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      exportMediaTags: json['exportMediaTags'] as bool?,
      enhancements: (json['enhancements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(int.parse(k), e as String),
            )),
      ),
      actions: (json['actions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      id: json['id'] as int?,
    )
      ..actionsIsar = json['actionsIsar'] as String
      ..enhancementsIsar = json['enhancementsIsar'] as String;

Map<String, dynamic> _$AnkiMappingToJson(AnkiMapping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'model': instance.model,
      'exportFieldKeys': instance.exportFieldKeys,
      'creatorFieldKeys': instance.creatorFieldKeys,
      'creatorCollapsedFieldKeys': instance.creatorCollapsedFieldKeys,
      'tags': instance.tags,
      'actions': instance.actions?.map((k, e) => MapEntry(k.toString(), e)),
      'actionsIsar': instance.actionsIsar,
      'enhancements': instance.enhancements?.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'enhancementsIsar': instance.enhancementsIsar,
      'exportMediaTags': instance.exportMediaTags,
      'order': instance.order,
    };
