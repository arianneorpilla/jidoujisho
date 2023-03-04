import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';

part 'dictionary_heading.g.dart';

/// A database entity that that effectively acts as the primary key for a
/// dictionary search. Dictionary headings, which specify the [term] and
/// [reading], may point to multiple dictionary entries.
///
/// Dictionary keys are shared between multiple imported dictionaries.
@Collection()
class DictionaryHeading {
  /// A heading must have a term and a reading. Different languages may perform
  /// searches based on only the term or only the reading, or both.
  DictionaryHeading({
    required this.term,
    this.reading = '',
  });

  /// Function to generate a lookup ID for heading by its unique string key.
  static int hash({required String term, required String reading}) {
    return fastHash('$term/$reading');
  }

  /// Identifier for database purposes.
  Id get id => hash(term: term, reading: reading);

  /// Sum of popularity of all dictionary entries belonging to this entry.
  @ignore
  double get popularitySum {
    return entries.map((entry) => entry.popularity).sum;
  }

  /// A word or phrase. This effectively acts as the headword, or the primary
  /// concept to be learned or represented in a dictionary entry.
  @Index(type: IndexType.value)
  final String term;

  /// An alternate form of the term. This is useful for languages which have an
  /// which must distinguish different keys which share the same term, but may
  /// have multiple pronunciations.
  @Index(type: IndexType.value)
  final String reading;

  /// Term of the reading. Used for prioritising starts with matches.
  @Index()
  int get termLength => term.length;

  /// A heading may have multiple dictionary entries.
  @Backlink(to: 'heading')
  final IsarLinks<DictionaryEntry> entries = IsarLinks<DictionaryEntry>();

  /// A heading may have multiple pitch data.
  @Backlink(to: 'heading')
  final IsarLinks<DictionaryPitch> pitches = IsarLinks<DictionaryPitch>();

  /// A heading may have multiple tags.
  final IsarLinks<DictionaryTag> tags = IsarLinks<DictionaryTag>();

  /// A heading may have multiple frequency data.
  @Backlink(to: 'heading')
  final IsarLinks<DictionaryFrequency> frequencies =
      IsarLinks<DictionaryFrequency>();

  @override
  bool operator ==(Object other) =>
      other is DictionaryHeading &&
      term == other.term &&
      reading == other.reading;

  @override
  int get hashCode => term.hashCode * reading.hashCode;
}
