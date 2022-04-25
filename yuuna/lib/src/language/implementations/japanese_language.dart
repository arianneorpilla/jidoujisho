import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/utils.dart';

/// Language implementation of the Japanese language.
class JapaneseLanguage extends Language {
  JapaneseLanguage._privateConstructor()
      : super(
          languageName: '日本語',
          languageCode: 'ja',
          countryCode: 'JP',
          preferVerticalReading: true,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: false,
          textBaseline: TextBaseline.ideographic,
          prepareSearchResults: prepareSearchResultsJapaneseLanguage,
        );

  /// Get the singleton instance of this language.
  static JapaneseLanguage get instance => _instance;

  static final JapaneseLanguage _instance =
      JapaneseLanguage._privateConstructor();

  /// Used for text segmentation and deinflection.
  static Mecab mecab = Mecab();

  /// Used for processing Japanese characters from Kana to Romaji and so on.
  static KanaKit kanaKit = const KanaKit();

  @override
  Future<void> prepareResources() async {
    await mecab.init('assets/language/japanese/ipadic', true);
  }

  @override
  FutureOr<String> getRootForm(String word) {
    try {
      if (kanaKit.isRomaji(word)) {
        return kanaKit.toHiragana(word);
      }

      List<Word> wordTokens = parseVe(mecab, word);

      if (wordTokens.first.lemma == '*') {
        return word[0];
      }
      return wordTokens.first.lemma ?? '';
    } catch (e) {
      return word[0];
    }
  }

  @override
  FutureOr<List<String>> textToWords(String text) {
    String delimiterSanitisedText = text
        .replaceAll('﻿', '␝')
        .replaceAll('　', '␝')
        .replaceAll('\n', '␜')
        .replaceAll(' ', '␝');

    List<Word> tokens = parseVe(mecab, delimiterSanitisedText);

    List<String> words = [];

    for (Word token in tokens) {
      final buffer = StringBuffer();
      for (TokenNode token in token.tokens) {
        buffer.write(token.surface);
      }

      String word = buffer.toString();
      word = word.replaceAll('␜', '\n').replaceAll('␝', ' ');
      words.add(word);
    }

    return words;
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<List<DictionaryEntry>> prepareSearchResultsJapaneseLanguage(
    DictionarySearchParams params) async {
  String searchTerm = params.searchTerm;
  String fallbackTerm = params.fallbackTerm;

  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: [
      DictionarySchema,
      DictionaryEntrySchema,
      MediaItemSchema,
      CreatorContextSchema,
    ],
  );

  Map<int?, DictionaryEntry> results = {};

  late QueryBuilder<DictionaryEntry, DictionaryEntry, QAfterFilterCondition>
      builder;

  KanaKit kanaKit = const KanaKit();
  if (kanaKit.isRomaji(searchTerm)) {
    searchTerm = kanaKit.toHiragana(searchTerm);
  }

  late List<DictionaryEntry> exactResults;
  late List<DictionaryEntry> containsResults;
  late List<DictionaryEntry> fallbackResults;
  late List<DictionaryEntry> prefixResults;
  late bool hasStartsWithResults;
  late List<String> prefixes;

  exactResults = database.dictionaryEntrys
      .filter()
      .wordEqualTo(searchTerm)
      .sortByWordLength()
      .thenByPopularityDesc()
      .limit(25)
      .findAllSync();

  if (kanaKit.isHiragana(searchTerm) && searchTerm.length > 1) {
    containsResults = database.dictionaryEntrys
        .filter()
        .readingContains(searchTerm)
        .sortByReadingLength()
        .thenByPopularityDesc()
        .limit(50)
        .findAllSync();

    fallbackResults = database.dictionaryEntrys
        .filter()
        .wordContains(fallbackTerm)
        .sortByWordLength()
        .thenByPopularityDesc()
        .limit(25)
        .findAllSync();

    hasStartsWithResults = database.dictionaryEntrys
            .filter()
            .readingStartsWith(searchTerm)
            .findFirstSync() !=
        null;

    builder = database.dictionaryEntrys.filter().readingEqualTo(searchTerm);

    String prefixSeed = searchTerm;
    if (searchTerm.length >= 10) {
      searchTerm = searchTerm.substring(0, 10);
    }
    prefixes = JidoujishoCommon.allPrefixes(prefixSeed);
    for (String prefix in prefixes) {
      if (prefix == searchTerm) {
        continue;
      }

      builder = builder.or().readingEqualTo(prefix);
    }
  } else {
    containsResults = database.dictionaryEntrys
        .filter()
        .wordContains(searchTerm)
        .sortByWordLength()
        .thenByPopularityDesc()
        .limit(25)
        .findAllSync();

    hasStartsWithResults = database.dictionaryEntrys
            .filter()
            .wordStartsWith(searchTerm)
            .findFirstSync() !=
        null;

    builder = database.dictionaryEntrys.filter().wordEqualTo(searchTerm);

    String prefixSeed = searchTerm;
    if (searchTerm.length >= 10) {
      searchTerm = searchTerm.substring(0, 10);
    }
    prefixes = JidoujishoCommon.allPrefixes(prefixSeed);
    for (String prefix in prefixes) {
      if (prefix == searchTerm) {
        continue;
      }

      if (kanaKit.isKana(prefix)) {
        builder = builder.or().readingEqualTo(prefix);
      }
      builder = builder.or().wordEqualTo(prefix);
    }
  }

  prefixResults = builder
      .sortByWordLengthDesc()
      .thenByPopularityDesc()
      .limit(50)
      .findAllSync();

  late bool fallbackTermUseful;

  if (prefixResults.isEmpty) {
    fallbackTermUseful = true;
    if (kanaKit.isHiragana(fallbackTerm) && fallbackTerm.length > 1) {
      fallbackResults = database.dictionaryEntrys
          .filter()
          .readingStartsWith(fallbackTerm)
          .sortByReadingLength()
          .thenByPopularityDesc()
          .limit(50)
          .findAllSync();
    } else {
      fallbackResults = database.dictionaryEntrys
          .filter()
          .wordEqualTo(fallbackTerm)
          .sortByWordLength()
          .thenByPopularityDesc()
          .limit(50)
          .findAllSync();
    }
  } else {
    if (kanaKit.isHiragana(searchTerm)) {
      fallbackTermUseful = searchTerm != fallbackTerm;
    } else {
      fallbackTermUseful = prefixResults.first.word == fallbackTerm;
    }

    fallbackResults = fallbackResults = database.dictionaryEntrys
        .filter()
        .wordEqualTo(fallbackTerm)
        .limit(50)
        .findAllSync();

    if (fallbackResults.isEmpty) {
      fallbackResults = database.dictionaryEntrys
          .filter()
          .readingEqualTo(fallbackTerm)
          .limit(50)
          .findAllSync();
    }
  }

  debugPrint('$hasStartsWithResults');
  debugPrint('$fallbackTermUseful');

  results.addEntries(exactResults.map((e) => MapEntry(e.id, e)));

  if (fallbackResults.isNotEmpty &&
      prefixResults.isNotEmpty &&
      (fallbackResults.first.reading ?? '').length >
          (prefixResults.first.reading ?? '').length) {
    results.addEntries(fallbackResults.map((e) => MapEntry(e.id, e)));
    results.addEntries(prefixResults.map((e) => MapEntry(e.id, e)));
    results.addEntries(containsResults.map((e) => MapEntry(e.id, e)));
  } else if (!hasStartsWithResults && fallbackTermUseful) {
    results.addEntries(prefixResults.map((e) => MapEntry(e.id, e)));
    results.addEntries(fallbackResults.map((e) => MapEntry(e.id, e)));
    results.addEntries(containsResults.map((e) => MapEntry(e.id, e)));
  } else {
    if (searchTerm.length > 1) {
      results.addEntries(containsResults.map((e) => MapEntry(e.id, e)));
      results.addEntries(prefixResults.map((e) => MapEntry(e.id, e)));
    } else {
      results.addEntries(prefixResults.map((e) => MapEntry(e.id, e)));
      results.addEntries(containsResults.map((e) => MapEntry(e.id, e)));
    }
    results.addEntries(fallbackResults.map((e) => MapEntry(e.id, e)));
  }

  return results.values.toList();
}
