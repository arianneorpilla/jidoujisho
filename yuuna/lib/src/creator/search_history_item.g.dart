// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchHistoryItemCollection on Isar {
  IsarCollection<SearchHistoryItem> get searchHistoryItems => this.collection();
}

const SearchHistoryItemSchema = CollectionSchema(
  name: r'SearchHistoryItem',
  id: 7309085037371405047,
  properties: {
    r'historyKey': PropertySchema(
      id: 0,
      name: r'historyKey',
      type: IsarType.string,
    ),
    r'searchTerm': PropertySchema(
      id: 1,
      name: r'searchTerm',
      type: IsarType.string,
    ),
    r'uniqueKey': PropertySchema(
      id: 2,
      name: r'uniqueKey',
      type: IsarType.string,
    )
  },
  estimateSize: _searchHistoryItemEstimateSize,
  serialize: _searchHistoryItemSerialize,
  deserialize: _searchHistoryItemDeserialize,
  deserializeProp: _searchHistoryItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'historyKey': IndexSchema(
      id: 5177523953167790614,
      name: r'historyKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'historyKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'searchTerm': IndexSchema(
      id: 6747083501682260651,
      name: r'searchTerm',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchTerm',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uniqueKey': IndexSchema(
      id: -866995956150369819,
      name: r'uniqueKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uniqueKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _searchHistoryItemGetId,
  getLinks: _searchHistoryItemGetLinks,
  attach: _searchHistoryItemAttach,
  version: '3.1.0',
);

int _searchHistoryItemEstimateSize(
  SearchHistoryItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.historyKey.length * 3;
  bytesCount += 3 + object.searchTerm.length * 3;
  bytesCount += 3 + object.uniqueKey.length * 3;
  return bytesCount;
}

void _searchHistoryItemSerialize(
  SearchHistoryItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.historyKey);
  writer.writeString(offsets[1], object.searchTerm);
  writer.writeString(offsets[2], object.uniqueKey);
}

SearchHistoryItem _searchHistoryItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchHistoryItem(
    historyKey: reader.readString(offsets[0]),
    id: id,
    searchTerm: reader.readString(offsets[1]),
  );
  return object;
}

P _searchHistoryItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchHistoryItemGetId(SearchHistoryItem object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _searchHistoryItemGetLinks(
    SearchHistoryItem object) {
  return [];
}

void _searchHistoryItemAttach(
    IsarCollection<dynamic> col, Id id, SearchHistoryItem object) {
  object.id = id;
}

extension SearchHistoryItemByIndex on IsarCollection<SearchHistoryItem> {
  Future<SearchHistoryItem?> getByUniqueKey(String uniqueKey) {
    return getByIndex(r'uniqueKey', [uniqueKey]);
  }

  SearchHistoryItem? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync(r'uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex(r'uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync(r'uniqueKey', [uniqueKey]);
  }

  Future<List<SearchHistoryItem?>> getAllByUniqueKey(
      List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'uniqueKey', values);
  }

  List<SearchHistoryItem?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uniqueKey', values);
  }

  Future<int> deleteAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uniqueKey', values);
  }

  int deleteAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uniqueKey', values);
  }

  Future<Id> putByUniqueKey(SearchHistoryItem object) {
    return putByIndex(r'uniqueKey', object);
  }

  Id putByUniqueKeySync(SearchHistoryItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'uniqueKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUniqueKey(List<SearchHistoryItem> objects) {
    return putAllByIndex(r'uniqueKey', objects);
  }

  List<Id> putAllByUniqueKeySync(List<SearchHistoryItem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uniqueKey', objects, saveLinks: saveLinks);
  }
}

extension SearchHistoryItemQueryWhereSort
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QWhere> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SearchHistoryItemQueryWhere
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QWhereClause> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      historyKeyEqualTo(String historyKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'historyKey',
        value: [historyKey],
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      historyKeyNotEqualTo(String historyKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyKey',
              lower: [],
              upper: [historyKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyKey',
              lower: [historyKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyKey',
              lower: [historyKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'historyKey',
              lower: [],
              upper: [historyKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      searchTermEqualTo(String searchTerm) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerm',
        value: [searchTerm],
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      searchTermNotEqualTo(String searchTerm) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [],
              upper: [searchTerm],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [searchTerm],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [searchTerm],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerm',
              lower: [],
              upper: [searchTerm],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      uniqueKeyEqualTo(String uniqueKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uniqueKey',
        value: [uniqueKey],
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterWhereClause>
      uniqueKeyNotEqualTo(String uniqueKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [],
              upper: [uniqueKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [uniqueKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [uniqueKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [],
              upper: [uniqueKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SearchHistoryItemQueryFilter
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QFilterCondition> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'historyKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'historyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'historyKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      historyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'historyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchTerm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTerm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerm',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      searchTermIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTerm',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterFilterCondition>
      uniqueKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }
}

extension SearchHistoryItemQueryObject
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QFilterCondition> {}

extension SearchHistoryItemQueryLinks
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QFilterCondition> {}

extension SearchHistoryItemQuerySortBy
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QSortBy> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByHistoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyKey', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByHistoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyKey', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension SearchHistoryItemQuerySortThenBy
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QSortThenBy> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByHistoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyKey', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByHistoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyKey', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension SearchHistoryItemQueryWhereDistinct
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct> {
  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctByHistoryKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historyKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTerm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryItem, SearchHistoryItem, QDistinct>
      distinctByUniqueKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueKey', caseSensitive: caseSensitive);
    });
  }
}

extension SearchHistoryItemQueryProperty
    on QueryBuilder<SearchHistoryItem, SearchHistoryItem, QQueryProperty> {
  QueryBuilder<SearchHistoryItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      historyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historyKey');
    });
  }

  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      searchTermProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTerm');
    });
  }

  QueryBuilder<SearchHistoryItem, String, QQueryOperations>
      uniqueKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueKey');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) =>
    SearchHistoryItem(
      historyKey: json['historyKey'] as String,
      searchTerm: json['searchTerm'] as String,
      id: json['id'] as int?,
    );

Map<String, dynamic> _$SearchHistoryItemToJson(SearchHistoryItem instance) =>
    <String, dynamic>{
      'historyKey': instance.historyKey,
      'searchTerm': instance.searchTerm,
      'id': instance.id,
    };
