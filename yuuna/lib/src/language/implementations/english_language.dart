import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lemmatizerx/lemmatizerx.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';

/// Language implementation of the Japanese language.
class EnglishLanguage extends Language {
  EnglishLanguage._privateConstructor()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          threeLetterCode: 'eng',
          preferVerticalReading: false,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
          helloWorld: 'Hello world',
          prepareSearchResults: prepareSearchResultsEnglishLanguage,
          standardFormat: MigakuFormat.instance,
          defaultFontFamily: 'Roboto',
        );

  /// Get the singleton instance of this language.
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
Future<int?> prepareSearchResultsEnglishLanguage(
    DictionarySearchParams params) async {
  final Lemmatizer lemmatizer = Lemmatizer();
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  int bestLength = 0;
  String searchTerm = params.searchTerm.toLowerCase().trim();

  /// Handles contractions well enough.
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

  if (searchTerm.isEmpty) {
    return null;
  }

  int maximumHeadings = params.maximumDictionarySearchResults;

  Map<int, DictionaryHeading> uniqueHeadingsById = {};

  int limit() {
    return maximumHeadings - uniqueHeadingsById.length;
  }

  bool shouldSearchWildcards = params.searchWithWildcards &&
      (searchTerm.contains('*') || searchTerm.contains('?'));

  if (shouldSearchWildcards) {
    bool noExactMatches = database.dictionaryHeadings
        .where()
        .termEqualTo(searchTerm)
        .isEmptySync();

    if (noExactMatches) {
      String matchesTerm = searchTerm;

      List<DictionaryHeading> termMatchHeadings = [];

      bool questionMarkOnly = !matchesTerm.contains('*');
      String noAsterisks = searchTerm
          .replaceAll('※', '*')
          .replaceAll('？', '?')
          .replaceAll('*', '');

      if (params.maximumDictionaryTermsInResult > uniqueHeadingsById.length) {
        if (questionMarkOnly) {
          termMatchHeadings = database.dictionaryHeadings
              .where()
              .termLengthEqualTo(searchTerm.length)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .entriesIsNotEmpty()
              .limit(maximumHeadings - uniqueHeadingsById.length)
              .findAllSync();
        } else {
          termMatchHeadings = database.dictionaryHeadings
              .where()
              .termLengthGreaterThan(noAsterisks.length, include: true)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .entriesIsNotEmpty()
              .limit(maximumHeadings - uniqueHeadingsById.length)
              .findAllSync();
        }
      }

      uniqueHeadingsById.addEntries(
        termMatchHeadings.map(
          (heading) => MapEntry(heading.id, heading),
        ),
      );
    }
  } else {
    Map<int, List<DictionaryHeading>> termExactResultsByLength = {};
    Map<int, List<DictionaryHeading>> termDeinflectedResultsByLength = {};

    List<String> segments = searchTerm.splitWithDelim(RegExp('[ -]'));

    if (segments.length > 20) {
      segments = segments.sublist(0, 20);
    }

    segments = segments.map((e) => e.characters).flattened.toList();

    if (segments.length > 50) {
      segments = segments.sublist(0, 50);
    }

    StringBuffer searchBuffer = StringBuffer();

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

      List<DictionaryHeading> termExactResults = [];
      List<DictionaryHeading> termDeinflectedResults = [];

      termExactResults = database.dictionaryHeadings
          .where(sort: Sort.desc)
          .termEqualTo(partialTerm)
          .limit(limit())
          .findAllSync();

      if (possibleDeinflections.isNotEmpty) {
        termDeinflectedResults = database.dictionaryHeadings
            .where()
            .anyOf<String, String>(
                possibleDeinflections, (q, term) => q.termEqualTo(term))
            .limit(limit())
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

    List<DictionaryHeading> startsWithResults = database.dictionaryHeadings
        .where()
        .termStartsWith(searchTerm)
        .sortByTermLength()
        .limit(limit())
        .findAllSync();

    for (int length = searchTerm.length; length > 0; length--) {
      List<MapEntry<int, DictionaryHeading>> exactHeadingsToAdd = [
        ...(termExactResultsByLength[length] ?? [])
            .map((heading) => MapEntry(heading.id, heading)),
        ...startsWithResults.map(
          (heading) => MapEntry(heading.id, heading),
        ),
      ];

      List<MapEntry<int, DictionaryHeading>> deinflectedHeadingsToAdd = [
        ...(termDeinflectedResultsByLength[length] ?? [])
            .map((entry) => MapEntry(entry.id, entry)),
      ];

      uniqueHeadingsById.addEntries(exactHeadingsToAdd);
      uniqueHeadingsById.addEntries(deinflectedHeadingsToAdd);
    }
  }

  List<DictionaryHeading> headings =
      uniqueHeadingsById.values.where((e) => e.entries.isNotEmpty).toList();

  if (headings.isEmpty) {
    return null;
  }

  DictionarySearchResult unsortedResult = DictionarySearchResult(
    searchTerm: searchTerm,
    bestLength: bestLength,
  );
  unsortedResult.headings.addAll(headings);

  late int resultId;
  database.writeTxnSync(() async {
    database.dictionarySearchResults.deleteBySearchTermSync(searchTerm);
    resultId = database.dictionarySearchResults.putSync(unsortedResult);
  });

  preloadResultSync(resultId);

  headings = headings.sublist(
      0, min(headings.length, params.maximumDictionaryTermsInResult));
  List<int> headingIds = headings.map((e) => e.id).toList();

  DictionarySearchResult result = DictionarySearchResult(
    id: resultId,
    searchTerm: searchTerm,
    bestLength: bestLength,
    headingIds: headingIds,
  );

  database.writeTxnSync(() async {
    resultId = database.dictionarySearchResults.putSync(result);

    int countInSameHistory = database.dictionarySearchResults.countSync();

    if (params.maximumDictionarySearchResults < countInSameHistory) {
      int surplus = countInSameHistory - params.maximumDictionarySearchResults;
      database.dictionarySearchResults
          .where()
          .limit(surplus)
          .build()
          .deleteAllSync();
    }
  });

  return resultId;
}
