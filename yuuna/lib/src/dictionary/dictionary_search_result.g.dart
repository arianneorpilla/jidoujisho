// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_search_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetDictionarySearchResultCollection on Isar {
  IsarCollection<DictionarySearchResult> get dictionarySearchResults =>
      this.collection();
}

const DictionarySearchResultSchema = CollectionSchema(
  name: r'DictionarySearchResult',
  id: -3666556092569216780,
  properties: {
    r'bestLength': PropertySchema(
      id: 0,
      name: r'bestLength',
      type: IsarType.long,
    ),
    r'headingIds': PropertySchema(
      id: 1,
      name: r'headingIds',
      type: IsarType.longList,
    ),
    r'scrollPosition': PropertySchema(
      id: 2,
      name: r'scrollPosition',
      type: IsarType.long,
    ),
    r'searchTerm': PropertySchema(
      id: 3,
      name: r'searchTerm',
      type: IsarType.string,
    )
  },
  estimateSize: _dictionarySearchResultEstimateSize,
  serialize: _dictionarySearchResultSerialize,
  deserialize: _dictionarySearchResultDeserialize,
  deserializeProp: _dictionarySearchResultDeserializeProp,
  idName: r'id',
  indexes: {
    r'searchTerm': IndexSchema(
      id: 6747083501682260651,
      name: r'searchTerm',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'searchTerm',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'headings': LinkSchema(
      id: -7187889133092877001,
      name: r'headings',
      target: r'DictionaryHeading',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _dictionarySearchResultGetId,
  getLinks: _dictionarySearchResultGetLinks,
  attach: _dictionarySearchResultAttach,
  version: '3.0.6-dev.0',
);

int _dictionarySearchResultEstimateSize(
  DictionarySearchResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.headingIds.length * 8;
  bytesCount += 3 + object.searchTerm.length * 3;
  return bytesCount;
}

void _dictionarySearchResultSerialize(
  DictionarySearchResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bestLength);
  writer.writeLongList(offsets[1], object.headingIds);
  writer.writeLong(offsets[2], object.scrollPosition);
  writer.writeString(offsets[3], object.searchTerm);
}

DictionarySearchResult _dictionarySearchResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionarySearchResult(
    bestLength: reader.readLongOrNull(offsets[0]) ?? 0,
    headingIds: reader.readLongList(offsets[1]) ?? const [],
    id: id,
    scrollPosition: reader.readLongOrNull(offsets[2]) ?? 0,
    searchTerm: reader.readString(offsets[3]),
  );
  return object;
}

P _dictionarySearchResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongList(offset) ?? const []) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionarySearchResultGetId(DictionarySearchResult object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionarySearchResultGetLinks(
    DictionarySearchResult object) {
  return [object.headings];
}

void _dictionarySearchResultAttach(
    IsarCollection<dynamic> col, Id id, DictionarySearchResult object) {
  object.id = id;
  object.headings
      .attach(col, col.isar.collection<DictionaryHeading>(), r'headings', id);
}

extension DictionarySearchResultByIndex
    on IsarCollection<DictionarySearchResult> {
  Future<DictionarySearchResult?> getBySearchTerm(String searchTerm) {
    return getByIndex(r'searchTerm', [searchTerm]);
  }

  DictionarySearchResult? getBySearchTermSync(String searchTerm) {
    return getByIndexSync(r'searchTerm', [searchTerm]);
  }

  Future<bool> deleteBySearchTerm(String searchTerm) {
    return deleteByIndex(r'searchTerm', [searchTerm]);
  }

  bool deleteBySearchTermSync(String searchTerm) {
    return deleteByIndexSync(r'searchTerm', [searchTerm]);
  }

  Future<List<DictionarySearchResult?>> getAllBySearchTerm(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndex(r'searchTerm', values);
  }

  List<DictionarySearchResult?> getAllBySearchTermSync(
      List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'searchTerm', values);
  }

  Future<int> deleteAllBySearchTerm(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'searchTerm', values);
  }

  int deleteAllBySearchTermSync(List<String> searchTermValues) {
    final values = searchTermValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'searchTerm', values);
  }

  Future<Id> putBySearchTerm(DictionarySearchResult object) {
    return putByIndex(r'searchTerm', object);
  }

  Id putBySearchTermSync(DictionarySearchResult object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'searchTerm', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySearchTerm(List<DictionarySearchResult> objects) {
    return putAllByIndex(r'searchTerm', objects);
  }

  List<Id> putAllBySearchTermSync(List<DictionarySearchResult> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'searchTerm', objects, saveLinks: saveLinks);
  }
}

extension DictionarySearchResultQueryWhereSort
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QWhere> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DictionarySearchResultQueryWhere on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QWhereClause> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> searchTermEqualTo(String searchTerm) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerm',
        value: [searchTerm],
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterWhereClause> searchTermNotEqualTo(String searchTerm) {
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
}

extension DictionarySearchResultQueryFilter on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QFilterCondition> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> bestLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> bestLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> bestLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestLength',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> bestLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'headingIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'headingIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'headingIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'headingIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'headingIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> scrollPositionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrollPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> scrollPositionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrollPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> scrollPositionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrollPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> scrollPositionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrollPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermEqualTo(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermGreaterThan(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermLessThan(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermBetween(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermStartsWith(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermEndsWith(
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

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
          QAfterFilterCondition>
      searchTermContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTerm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
          QAfterFilterCondition>
      searchTermMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTerm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerm',
        value: '',
      ));
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> searchTermIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTerm',
        value: '',
      ));
    });
  }
}

extension DictionarySearchResultQueryObject on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QFilterCondition> {}

extension DictionarySearchResultQueryLinks on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QFilterCondition> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headings(FilterQuery<DictionaryHeading> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'headings');
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'headings', length, true, length, true);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'headings', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'headings', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'headings', 0, true, length, include);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'headings', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult,
      QAfterFilterCondition> headingsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'headings', lower, includeLower, upper, includeUpper);
    });
  }
}

extension DictionarySearchResultQuerySortBy
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QSortBy> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortByBestLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestLength', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortByBestLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestLength', Sort.desc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortByScrollPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollPosition', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortByScrollPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollPosition', Sort.desc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      sortBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }
}

extension DictionarySearchResultQuerySortThenBy on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QSortThenBy> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByBestLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestLength', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByBestLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestLength', Sort.desc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByScrollPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollPosition', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenByScrollPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrollPosition', Sort.desc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenBySearchTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.asc);
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QAfterSortBy>
      thenBySearchTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchTerm', Sort.desc);
    });
  }
}

extension DictionarySearchResultQueryWhereDistinct
    on QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct> {
  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctByBestLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestLength');
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctByHeadingIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'headingIds');
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctByScrollPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrollPosition');
    });
  }

  QueryBuilder<DictionarySearchResult, DictionarySearchResult, QDistinct>
      distinctBySearchTerm({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTerm', caseSensitive: caseSensitive);
    });
  }
}

extension DictionarySearchResultQueryProperty on QueryBuilder<
    DictionarySearchResult, DictionarySearchResult, QQueryProperty> {
  QueryBuilder<DictionarySearchResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionarySearchResult, int, QQueryOperations>
      bestLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestLength');
    });
  }

  QueryBuilder<DictionarySearchResult, List<int>, QQueryOperations>
      headingIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'headingIds');
    });
  }

  QueryBuilder<DictionarySearchResult, int, QQueryOperations>
      scrollPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrollPosition');
    });
  }

  QueryBuilder<DictionarySearchResult, String, QQueryOperations>
      searchTermProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTerm');
    });
  }
}
