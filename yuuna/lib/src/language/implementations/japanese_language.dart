import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';
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

  /// Used to cache furigana segments for already generated [DictionaryPair]
  /// items.
  final Map<DictionaryPair, List<RubyTextData>?> segmentsCache = {};

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

      if (word.startsWith('気に') && wordTokens.length >= 2) {
        return '気に${wordTokens[1].lemma}';
      }

      if (wordTokens.length >= 3 &&
          (wordTokens[0].word == wordTokens[0].lemma ||
              kanaKit.isKana(wordTokens[0].word!)) &&
          wordTokens[1].partOfSpeech == Pos.Postposition &&
          wordTokens[2].partOfSpeech == Pos.Verb) {
        return '${wordTokens[0]}${wordTokens[1].word}${wordTokens[2].lemma}';
      }

      if (wordTokens.first.word!.length == 1) {
        return word;
      }

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

  /// Some languages may want to display custom widgets rather than the built
  /// in word and reading text that is there by default. For example, Japanese
  /// may want to display a furigana widget instead.
  @override
  Widget? getWordReadingOverrideWidget({
    required BuildContext context,
    required String word,
    required String reading,
    required List<DictionaryEntry> meanings,
  }) {
    if (reading.isEmpty) {
      return null;
    }

    List<RubyTextData>? segments = fetchFurigana(word: word, reading: reading);
    return RubyText(
      segments ?? [RubyTextData(word, ruby: reading)],
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(fontWeight: FontWeight.bold),
      rubyStyle: Theme.of(context).textTheme.labelSmall,
    );
  }

  /// Fetch furigana for a certain word and reading. If already obtained,
  /// use the cache.
  List<RubyTextData>? fetchFurigana({
    required String word,
    required String reading,
  }) {
    DictionaryPair pair = DictionaryPair(word: word, reading: reading);
    if (segmentsCache.containsKey(pair)) {
      return segmentsCache[pair];
    }

    return LanguageUtils.distributeFurigana(term: word, reading: reading);
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<List<DictionaryEntry>> prepareSearchResultsJapaneseLanguage(
    DictionarySearchParams params) async {
  String searchTerm = params.searchTerm.trim();
  String fallbackTerm = params.fallbackTerm.trim();
  int limit = 30;

  if (searchTerm.isEmpty) {
    return [];
  }

  KanaKit kanaKit = const KanaKit();

  if (kanaKit.isRomaji(searchTerm)) {
    searchTerm = kanaKit.toHiragana(searchTerm);
    fallbackTerm = kanaKit.toKatakana(searchTerm);
  }

  List<String> searchTermPrefixes = JidoujishoCommon.allPrefixes(searchTerm);
  List<String> searchTermHiraganaPrefixes =
      JidoujishoCommon.allKanaPrefixes(searchTerm, kanaKit: kanaKit);

  bool searchTermStartsWithKana =
      searchTerm.isNotEmpty && kanaKit.isKana(searchTerm[0]);
  bool fallbackStartsWithKana =
      fallbackTerm.isNotEmpty && kanaKit.isKana(fallbackTerm[0]);

  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: globalSchemas,
  );

  Map<int?, DictionaryEntry> entries = {};

  List<DictionaryEntry> wordExactMatches = [];
  List<DictionaryEntry> wordStartsWithMatches = [];
  List<DictionaryEntry> readingExactMatches = [];
  List<DictionaryEntry> readingStartsWithMatches = [];

  List<DictionaryEntry> fallbackWordExactMatches = [];
  List<DictionaryEntry> fallbackWordStartsWithMatches = [];
  List<DictionaryEntry> fallbackReadingExactMatches = [];
  List<DictionaryEntry> fallbackReadingStartsWithMatches = [];

  wordExactMatches = database.dictionaryEntrys
      .filter()
      .repeat<String, QAfterFilterCondition>(
          searchTermPrefixes, (q, prefix) => q.wordEqualTo(prefix))
      .sortByWordLengthDesc()
      .thenByPopularityDesc()
      .limit(limit)
      .findAllSync();

  if (wordExactMatches.isNotEmpty &&
      wordExactMatches.first.wordLength == searchTerm.length) {
    wordStartsWithMatches = database.dictionaryEntrys
        .filter()
        .wordStartsWith(searchTerm)
        .sortByWordLength()
        .thenByPopularityDesc()
        .limit(limit)
        .findAllSync();
  }

  if (searchTermStartsWithKana) {
    readingExactMatches = database.dictionaryEntrys
        .filter()
        .repeat<String, QAfterFilterCondition>(
            searchTermHiraganaPrefixes, (q, prefix) => q.readingEqualTo(prefix))
        .sortByReadingLengthDesc()
        .thenByPopularityDesc()
        .limit(limit)
        .findAllSync();

    if (readingExactMatches.isNotEmpty &&
        readingExactMatches.first.wordLength == searchTerm.length) {
      readingStartsWithMatches = database.dictionaryEntrys
          .filter()
          .readingStartsWith(searchTerm)
          .sortByReadingLengthDesc()
          .thenByPopularityDesc()
          .limit(limit)
          .findAllSync();
    }
  }

  bool fallbackTermLessDesperateThanLongestExactWordPrefix =
      wordExactMatches.isEmpty ||
          (wordExactMatches.isNotEmpty &&
              wordExactMatches.first.wordLength <= fallbackTerm.length);
  bool fallbackTermLessDesperateThanLongestExactReadingPrefix =
      readingExactMatches.isEmpty ||
          (fallbackStartsWithKana &&
              readingExactMatches.isNotEmpty &&
              readingExactMatches.first.wordLength <= fallbackTerm.length);

  if (fallbackTermLessDesperateThanLongestExactWordPrefix) {
    fallbackWordExactMatches = database.dictionaryEntrys
        .filter()
        .wordEqualTo(fallbackTerm)
        .sortByWordLengthDesc()
        .thenByPopularityDesc()
        .limit(limit)
        .findAllSync();

    if (fallbackWordExactMatches.isNotEmpty &&
            fallbackWordExactMatches.first.wordLength == fallbackTerm.length ||
        fallbackWordExactMatches.isEmpty) {
      fallbackWordStartsWithMatches = database.dictionaryEntrys
          .filter()
          .wordStartsWith(fallbackTerm)
          .sortByWordLength()
          .thenByPopularityDesc()
          .limit(limit)
          .findAllSync();
    }
  }

  if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
    fallbackReadingExactMatches = database.dictionaryEntrys
        .filter()
        .readingEqualTo(fallbackTerm)
        .sortByPopularityDesc()
        .thenByReadingLengthDesc()
        .limit(limit)
        .findAllSync();

    if (readingExactMatches.isNotEmpty &&
        readingExactMatches.first.readingLength == searchTerm.length) {
      fallbackReadingStartsWithMatches = database.dictionaryEntrys
          .filter()
          .readingStartsWith(fallbackTerm)
          .sortByReadingLengthDesc()
          .thenByPopularityDesc()
          .limit(limit)
          .findAllSync();
    }
  }

  if (wordExactMatches.isNotEmpty &&
      wordExactMatches.first.word == searchTerm) {
    entries.addEntries(wordExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.word == searchTerm));
  }

  if (readingExactMatches.isNotEmpty &&
      readingExactMatches.first.reading == searchTerm) {
    entries.addEntries(readingExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.reading == searchTerm));
  }

  if (fallbackWordExactMatches.isNotEmpty &&
      fallbackWordExactMatches.first.word == fallbackTerm) {
    entries.addEntries(fallbackWordExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.word == fallbackTerm));
    entries.addEntries(
        fallbackWordStartsWithMatches.map((e) => MapEntry(e.id, e)));
  }

  if (searchTermStartsWithKana) {
    if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
      entries.addEntries(
          fallbackReadingExactMatches.map((e) => MapEntry(e.id, e)));
      entries.addEntries(
          fallbackReadingStartsWithMatches.map((e) => MapEntry(e.id, e)));
    }
    if (readingExactMatches.isNotEmpty &&
        (readingExactMatches.first.reading == searchTerm ||
            (wordExactMatches.isNotEmpty &&
                wordExactMatches.first.word.length <
                    readingExactMatches.first.reading.length))) {
      entries.addEntries(readingExactMatches.map((e) => MapEntry(e.id, e)));
      entries
          .addEntries(readingStartsWithMatches.map((e) => MapEntry(e.id, e)));
    }
  }
  if (searchTermStartsWithKana &&
      wordExactMatches.isNotEmpty &&
      wordExactMatches.first.word != searchTerm) {
    if (fallbackTermLessDesperateThanLongestExactWordPrefix) {
      entries
          .addEntries(fallbackWordExactMatches.map((e) => MapEntry(e.id, e)));
      entries.addEntries(
          fallbackWordStartsWithMatches.map((e) => MapEntry(e.id, e)));
    }
  }

  if (fallbackTermLessDesperateThanLongestExactWordPrefix) {
    entries.addEntries(fallbackWordExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackWordStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(wordExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(wordStartsWithMatches.map((e) => MapEntry(e.id, e)));
  } else {
    entries.addEntries(wordExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(wordStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(fallbackWordExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackWordStartsWithMatches.map((e) => MapEntry(e.id, e)));
  }

  if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
    entries
        .addEntries(fallbackReadingExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackReadingStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(readingExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(readingStartsWithMatches.map((e) => MapEntry(e.id, e)));
  } else {
    entries.addEntries(readingExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(readingStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries
        .addEntries(fallbackReadingExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackReadingStartsWithMatches.map((e) => MapEntry(e.id, e)));
  }

  // For debugging search results.
  // debugPrint('-' * 50);
  // debugPrint('SEARCH TERM: $searchTerm');
  // debugPrint('FALLBACK TERM: $fallbackTerm');
  // debugPrint(
  //     'WORD EXACT MATCH: ${wordExactMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'WORD STARTS WITH MATCH:  ${wordStartsWithMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'READING EXACT MATCH: ${readingExactMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'READING STARTS WITH MATCH: ${readingStartsWithMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'FALLBACK WORD EXACT MATCH: ${fallbackWordExactMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'FALLBACK WORD STARTS WITH MATCH: ${fallbackWordStartsWithMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'FALLBACK READING EXACT MATCH: ${fallbackReadingExactMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'FALLBACK READING STARTS WITH MATCH: ${fallbackReadingStartsWithMatches.map((e) => e.word).toList()}');
  // debugPrint(
  //     'FALLBACK TERM LESS DESPERATE THAN LONGEST EXACT WORD PREFIX: $fallbackTermLessDesperateThanLongestExactWordPrefix');
  // debugPrint(
  //     'FALLBACK TERM LESS DESPERATE THAN LONGEST EXACT READING PREFIX: $fallbackTermLessDesperateThanLongestExactReadingPrefix');
  // debugPrint('-' * 50);

  return entries.values.toList();
}
