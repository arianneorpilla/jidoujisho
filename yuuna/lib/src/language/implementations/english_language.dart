import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:lemmatizerx/lemmatizerx.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';

/// Language implementation of the English language.
class EnglishLanguage extends Language {
  EnglishLanguage._privateConstructor()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          preferVerticalReading: false,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
          helloWorld: 'Hello world',
          prepareSearchResults: prepareSearchResultsEnglishLanguage,
          standardFormat: AbbyyLingvoFormat.instance,
          defaultFontFamily: 'Roboto',
        );

  /// Get the singleton instance of this media type.
  static EnglishLanguage get instance => _instance;

  static final EnglishLanguage _instance =
      EnglishLanguage._privateConstructor();

  @override
  Future<void> prepareResources() async {}

  @override
  List<String> textToWords(String text) {
    return text.splitWithDelim(RegExp('[ -]'));
  }
}

/// Top-level function for use in compute. See [Language] for details.
/// Credits to Matthew Chan for their port of the Yomichan parser to Dart.
Future<DictionaryResult> prepareSearchResultsEnglishLanguage(
    DictionarySearchParams params) async {
  int bestLength = 0;
  String searchTerm = params.searchTerm.toLowerCase().trim();

  /// Handle contractions well enough.
  searchTerm = searchTerm
      .replaceAll('won\'t', 'will not')
      .replaceAll('can\'t', 'cannot')
      .replaceAll('i\'m', 'i am')
      .replaceAll('ain\'t', 'is not')
      .replaceAll('\'ll', ' will')
      .replaceAll('n\'t', ' not')
      .replaceAll('\'ve', ' have')
      .replaceAll('\'s', ' is')
      .replaceAll('\'re', ' are')
      .replaceAll('\'d', ' would')
      .replaceAll('won’t', 'will not')
      .replaceAll('can’t', 'cannot')
      .replaceAll('i’m', 'i am')
      .replaceAll('ain’t', 'is not')
      .replaceAll('’ll', ' will')
      .replaceAll('n’t', ' not')
      .replaceAll('’ve', ' have')
      .replaceAll('’s', ' is')
      .replaceAll('’re', ' are')
      .replaceAll('’d', ' would');

  int limit = params.maximumDictionaryEntrySearchMatch;

  if (searchTerm.isEmpty) {
    return DictionaryResult(
      searchTerm: searchTerm,
    );
  }

  final Lemmatizer lemmatizer = Lemmatizer();
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  Map<int?, DictionaryEntry> uniqueEntriesById = {};

  StringBuffer searchBuffer = StringBuffer();

  Map<int, List<DictionaryEntry>> termExactResultsByLength = {};
  Map<int, List<DictionaryEntry>> termDeinflectedResultsByLength = {};

  List<String> segments = searchTerm.splitWithDelim(RegExp('[ -]'));

  if (segments.length >= 3) {
    String first = segments.removeAt(0);
    String second = segments.removeAt(0);
    String third = segments.removeAt(0);

    segments = [
      ...first.split(''),
      second,
      ...third.split(''),
      ...segments,
    ];
  } else if (segments.length == 1) {
    String first = segments.removeAt(0);
    segments = [
      ...first.split(''),
      ...segments,
    ];
  }

  segments.forEachIndexed((index, word) {
    searchBuffer.write(word);

    if (word == ' ') {
      return;
    }

    String partialTerm =
        searchBuffer.toString().replaceAll(RegExp('[^a-zA-Z -]'), '');

    List<String> possibleDeinflections = lemmatizer
        .lemmas(partialTerm)
        .map((lemma) => lemma.lemmas)
        .flattened
        .where((e) => e.isNotEmpty)
        .toList();

    List<DictionaryEntry> termExactResults = [];
    List<DictionaryEntry> termDeinflectedResults = [];

    termExactResults = database.dictionaryEntrys
        .where(sort: Sort.desc)
        .termEqualTo(partialTerm)
        .limit(limit)
        .findAllSync();

    if (possibleDeinflections.isNotEmpty) {
      termDeinflectedResults = database.dictionaryEntrys
          .where(sort: Sort.desc)
          .anyOf(
              possibleDeinflections,
              // ignore: avoid_types_on_closure_parameters
              (q, String term) => q.termEqualTo(term))
          .limit(limit)
          .findAllSync();
    }

    if (termExactResults.isNotEmpty) {
      termExactResultsByLength[partialTerm.length] = termExactResults;
      bestLength = partialTerm.length;
    }
    if (termDeinflectedResults.isNotEmpty) {
      termDeinflectedResultsByLength[partialTerm.length] =
          termDeinflectedResults;
      bestLength = partialTerm.length;
    }
  });

  List<DictionaryEntry> startsWithResults = database.dictionaryEntrys
      .where()
      .termStartsWith(searchTerm)
      .sortByTermLength()
      .limit(limit)
      .findAllSync();

  for (int length = searchTerm.length; length > 0; length--) {
    List<MapEntry<int?, DictionaryEntry>> exactEntriesToAdd = [
      ...(termExactResultsByLength[length] ?? [])
          .map((entry) => MapEntry(entry.id, entry)),
      ...startsWithResults.map(
        (entry) => MapEntry(entry.id, entry),
      ),
    ];

    List<MapEntry<int?, DictionaryEntry>> deinflectedEntriesToAdd = [
      ...(termDeinflectedResultsByLength[length] ?? [])
          .map((entry) => MapEntry(entry.id, entry)),
    ];

    uniqueEntriesById.addEntries(exactEntriesToAdd);
    uniqueEntriesById.addEntries(deinflectedEntriesToAdd);
  }

  List<DictionaryEntry> entries = uniqueEntriesById.values.toList();

  Map<DictionaryPair, List<DictionaryEntry>> entriesByPair =
      groupBy<DictionaryEntry, DictionaryPair>(
    entries,
    (entry) => DictionaryPair(term: entry.term, reading: entry.reading),
  );

  if (entriesByPair.length >= params.maximumDictionaryTermsInResult) {
    entriesByPair = Map<DictionaryPair, List<DictionaryEntry>>.fromEntries(
        entriesByPair.entries
            .toList()
            .sublist(0, params.maximumDictionaryTermsInResult));
  }

  List<DictionaryTerm> terms = entriesByPair.entries.map((group) {
    DictionaryPair pair = group.key;
    List<DictionaryEntry> entries = group.value;

    List<String> termTagKeys = (entries.fold<List<String>>(
        [],
        (list, e) => list
          ..addAll(e.termTags
              .where((tag) => tag.isNotEmpty)
              .map((tag) => '${e.dictionaryName}/$tag')
              .toList()))).toSet().toList();

    List<List<String>> meaningTagKeysByEntry = entries
        .map((e) => e.meaningTags
            .where((tag) => tag.isNotEmpty)
            .map((tag) => '${e.dictionaryName}/$tag')
            .toList())
        .toList();

    List<DictionaryTag> termTags = database.dictionaryTags
        .getAllByUniqueKeySync(termTagKeys)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    List<DictionaryMetaEntry> metaEntries = database.dictionaryMetaEntrys
        .where()
        .termEqualTo(pair.term)
        .findAllSync();
    List<List<DictionaryTag>> meaningTagsGroups = meaningTagKeysByEntry
        .map((meaningTagKeys) => database.dictionaryTags
            .getAllByUniqueKeySync(meaningTagKeys)
            .where((e) => e != null)
            .map((e) => e!)
            .toList())
        .toList();

    return DictionaryTerm(
      term: pair.term,
      reading: pair.reading,
      entries: entries,
      metaEntries: metaEntries,
      termTags: termTags,
      meaningTagsGroups: meaningTagsGroups,
    );
  }).toList();

  return DictionaryResult(
    searchTerm: searchTerm,
    bestLength: bestLength,
    terms: terms,
  );
}
