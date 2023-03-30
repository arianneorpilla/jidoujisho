// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetMessageItemCollection on Isar {
  IsarCollection<MessageItem> get messageItems => this.collection();
}

const MessageItemSchema = CollectionSchema(
  name: r'MessageItem',
  id: -5146512751102916430,
  properties: {
    r'isBot': PropertySchema(
      id: 0,
      name: r'isBot',
      type: IsarType.bool,
    ),
    r'message': PropertySchema(
      id: 1,
      name: r'message',
      type: IsarType.string,
    )
  },
  estimateSize: _messageItemEstimateSize,
  serialize: _messageItemSerialize,
  deserialize: _messageItemDeserialize,
  deserializeProp: _messageItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _messageItemGetId,
  getLinks: _messageItemGetLinks,
  attach: _messageItemAttach,
  version: '3.0.6-dev.0',
);

int _messageItemEstimateSize(
  MessageItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.message.length * 3;
  return bytesCount;
}

void _messageItemSerialize(
  MessageItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isBot);
  writer.writeString(offsets[1], object.message);
}

MessageItem _messageItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageItem(
    id: id,
    isBot: reader.readBool(offsets[0]),
    message: reader.readString(offsets[1]),
  );
  return object;
}

P _messageItemDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageItemGetId(MessageItem object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _messageItemGetLinks(MessageItem object) {
  return [];
}

void _messageItemAttach(
    IsarCollection<dynamic> col, Id id, MessageItem object) {
  object.id = id;
}

extension MessageItemQueryWhereSort
    on QueryBuilder<MessageItem, MessageItem, QWhere> {
  QueryBuilder<MessageItem, MessageItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MessageItemQueryWhere
    on QueryBuilder<MessageItem, MessageItem, QWhereClause> {
  QueryBuilder<MessageItem, MessageItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MessageItem, MessageItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterWhereClause> idBetween(
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
}

extension MessageItemQueryFilter
    on QueryBuilder<MessageItem, MessageItem, QFilterCondition> {
  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> isBotEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBot',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition>
      messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'message',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition>
      messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition> messageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'message',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition>
      messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterFilterCondition>
      messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'message',
        value: '',
      ));
    });
  }
}

extension MessageItemQueryObject
    on QueryBuilder<MessageItem, MessageItem, QFilterCondition> {}

extension MessageItemQueryLinks
    on QueryBuilder<MessageItem, MessageItem, QFilterCondition> {}

extension MessageItemQuerySortBy
    on QueryBuilder<MessageItem, MessageItem, QSortBy> {
  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> sortByIsBot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBot', Sort.asc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> sortByIsBotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBot', Sort.desc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }
}

extension MessageItemQuerySortThenBy
    on QueryBuilder<MessageItem, MessageItem, QSortThenBy> {
  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenByIsBot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBot', Sort.asc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenByIsBotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBot', Sort.desc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<MessageItem, MessageItem, QAfterSortBy> thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }
}

extension MessageItemQueryWhereDistinct
    on QueryBuilder<MessageItem, MessageItem, QDistinct> {
  QueryBuilder<MessageItem, MessageItem, QDistinct> distinctByIsBot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBot');
    });
  }

  QueryBuilder<MessageItem, MessageItem, QDistinct> distinctByMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }
}

extension MessageItemQueryProperty
    on QueryBuilder<MessageItem, MessageItem, QQueryProperty> {
  QueryBuilder<MessageItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageItem, bool, QQueryOperations> isBotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBot');
    });
  }

  QueryBuilder<MessageItem, String, QQueryOperations> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }
}
