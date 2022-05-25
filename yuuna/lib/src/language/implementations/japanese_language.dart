import 'dart:async';

import 'package:collection/collection.dart';
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
  FutureOr<String> getRootForm(String term) {
    try {
      if (kanaKit.isRomaji(term)) {
        return kanaKit.toHiragana(term);
      }

      List<Word> termTokens = parseVe(mecab, term);

      if (term.startsWith('気に') && termTokens.length >= 2) {
        return '気に${termTokens[1].lemma}';
      }

      if (termTokens.length >= 3 &&
          (termTokens[0].word == termTokens[0].lemma ||
              kanaKit.isKana(termTokens[0].word!)) &&
          termTokens[1].partOfSpeech == Pos.Postposition &&
          termTokens[2].partOfSpeech == Pos.Verb) {
        return '${termTokens[0]}${termTokens[1].word}${termTokens[2].lemma}';
      }

      if (termTokens.first.word!.length == 1) {
        return term;
      }

      if (termTokens.first.lemma == '*') {
        return term[0];
      }
      return termTokens.first.lemma ?? '';
    } catch (e) {
      return term[0];
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

    List<String> terms = [];

    for (Word token in tokens) {
      final buffer = StringBuffer();
      for (TokenNode token in token.tokens) {
        buffer.write(token.surface);
      }

      String term = buffer.toString();
      term = term.replaceAll('␜', '\n').replaceAll('␝', ' ');
      terms.add(term);
    }

    return terms;
  }

  /// Some languages may want to display custom widgets rather than the built
  /// in term and reading text that is there by default. For example, Japanese
  /// may want to display a furigana widget instead.
  @override
  Widget getTermReadingOverrideWidget({
    required BuildContext context,
    required AppModel appModel,
    required DictionaryTerm dictionaryTerm,
  }) {
    if (dictionaryTerm.reading.isEmpty) {
      return super.getTermReadingOverrideWidget(
        context: context,
        appModel: appModel,
        dictionaryTerm: dictionaryTerm,
      );
    }

    List<RubyTextData>? segments = fetchFurigana(
        term: dictionaryTerm.term, reading: dictionaryTerm.reading);
    return RubyText(
      segments ??
          [RubyTextData(dictionaryTerm.term, ruby: dictionaryTerm.reading)],
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(fontWeight: FontWeight.bold),
      rubyStyle: Theme.of(context).textTheme.labelSmall,
    );
  }

  /// Fetch furigana for a certain term and reading. If already obtained,
  /// use the cache.
  List<RubyTextData>? fetchFurigana({
    required String term,
    required String reading,
  }) {
    DictionaryPair pair = DictionaryPair(term: term, reading: reading);
    if (segmentsCache.containsKey(pair)) {
      return segmentsCache[pair];
    }

    return LanguageUtils.distributeFurigana(term: term, reading: reading);
  }

  @override
  Widget getPitchWidget({
    required BuildContext context,
    required String reading,
    required int downstep,
  }) {
    List<Widget> listWidgets = [];

    Color foregroundColor = Theme.of(context).appBarTheme.foregroundColor!;
    TextStyle style = TextStyle(
      fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
    );

    Widget getAccentTop(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: foregroundColor),
          ),
        ),
        child: Text(text, style: style),
      );
    }

    Widget getAccentEnd(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: foregroundColor),
            right: BorderSide(color: foregroundColor),
          ),
        ),
        child: Text(text, style: style),
      );
    }

    Widget getAccentNone(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        child: Text(text, style: style),
      );
    }

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && 'ゃゅょぁぃぅぇぉャュョァィゥェォ'.contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (downstep == 0) {
      for (int i = 0; i < moras.length; i++) {
        if (i == 0) {
          listWidgets.add(getAccentNone(moras[i]));
        } else {
          listWidgets.add(getAccentTop(moras[i]));
        }
      }
    } else {
      for (int i = 0; i < moras.length; i++) {
        if (i == 0 && i != downstep - 1) {
          listWidgets.add(getAccentNone(moras[i]));
        } else if (i < downstep - 1) {
          listWidgets.add(getAccentTop(moras[i]));
        } else if (i == downstep - 1) {
          listWidgets.add(getAccentEnd(moras[i]));
        } else {
          listWidgets.add(getAccentNone(moras[i]));
        }
      }
    }

    listWidgets.add(Text(' [$downstep]  ', style: style));

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: listWidgets,
    );
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<List<DictionaryTerm>> prepareSearchResultsJapaneseLanguage(
    DictionarySearchParams params) async {
  String searchTerm = params.searchTerm.trim();
  String fallbackTerm = params.fallbackTerm.trim();
  int limit = params.maximumDictionaryEntrySearchMatch;

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

  List<DictionaryEntry> termExactMatches = [];
  List<DictionaryEntry> termStartsWithMatches = [];
  List<DictionaryEntry> readingExactMatches = [];
  List<DictionaryEntry> readingStartsWithMatches = [];

  List<DictionaryEntry> fallbackTermExactMatches = [];
  List<DictionaryEntry> fallbackTermStartsWithMatches = [];
  List<DictionaryEntry> fallbackReadingExactMatches = [];
  List<DictionaryEntry> fallbackReadingStartsWithMatches = [];

  /// Index for the first character of this term.
  String? searchTermFirstChar;
  String? searchTermSecondChar;
  String? fallbackFirstChar;
  String? fallbackSecondChar;

  if (searchTerm.isEmpty) {
    searchTermFirstChar = null;
  } else {
    searchTermFirstChar = searchTerm[0];
  }
  if (fallbackTerm.isEmpty) {
    fallbackFirstChar = null;
  } else {
    fallbackFirstChar = fallbackTerm[0];
  }
  if (searchTerm.length < 2) {
    searchTermSecondChar = null;
  } else {
    searchTermSecondChar = searchTerm[1];
  }
  if (fallbackTerm.length < 2) {
    fallbackSecondChar = null;
  } else {
    fallbackSecondChar = fallbackTerm[1];
  }

  termExactMatches = database.dictionaryEntrys
      .filter()
      .repeat<String, QAfterFilterCondition>(
          searchTermPrefixes, (q, prefix) => q.termEqualTo(prefix))
      .sortByTermLengthDesc()
      .thenByPopularityDesc()
      .limit(limit)
      .findAllSync();

  if (termExactMatches.isNotEmpty &&
      termExactMatches.first.termLength == searchTerm.length) {
    termStartsWithMatches = database.dictionaryEntrys
        .where()
        .termFirstCharTermSecondCharEqualToTermLengthGreaterThan(
          searchTermFirstChar,
          searchTermSecondChar,
          searchTerm.length - 1,
        )
        .filter()
        .termStartsWith(searchTerm)
        .sortByTermLengthDesc()
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
        readingExactMatches.first.termLength == searchTerm.length) {
      readingStartsWithMatches = database.dictionaryEntrys
          .where()
          .readingFirstCharReadingSecondCharEqualToReadingLengthGreaterThan(
            searchTermFirstChar,
            searchTermSecondChar,
            searchTerm.length - 1,
          )
          .filter()
          .readingStartsWith(searchTerm)
          .sortByReadingLengthDesc()
          .thenByPopularityDesc()
          .limit(limit)
          .findAllSync();
    }
  }

  bool fallbackTermLessDesperateThanLongestExactTermPrefix =
      termExactMatches.isEmpty ||
          (termExactMatches.isNotEmpty &&
              termExactMatches.first.termLength <= fallbackTerm.length);
  bool fallbackTermLessDesperateThanLongestExactReadingPrefix =
      readingExactMatches.isEmpty ||
          (fallbackStartsWithKana &&
              readingExactMatches.isNotEmpty &&
              readingExactMatches.first.termLength <= fallbackTerm.length);

  if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
    fallbackTermExactMatches = database.dictionaryEntrys
        .filter()
        .termEqualTo(fallbackTerm)
        .sortByTermLengthDesc()
        .thenByPopularityDesc()
        .limit(limit)
        .findAllSync();

    if (fallbackTermExactMatches.isNotEmpty &&
        fallbackTermExactMatches.first.termLength == fallbackTerm.length) {
      fallbackTermStartsWithMatches = database.dictionaryEntrys
          .where()
          .termFirstCharTermSecondCharEqualToTermLengthGreaterThan(
            fallbackFirstChar,
            fallbackSecondChar,
            fallbackTerm.length - 1,
          )
          .filter()
          .termStartsWith(fallbackTerm)
          .sortByTermLength()
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
          .where()
          .readingFirstCharReadingSecondCharEqualToReadingLengthGreaterThan(
            fallbackFirstChar,
            fallbackSecondChar,
            fallbackTerm.length - 1,
          )
          .filter()
          .readingStartsWith(fallbackTerm)
          .sortByReadingLengthDesc()
          .thenByPopularityDesc()
          .limit(limit)
          .findAllSync();
    }
  }

  if (termExactMatches.isNotEmpty &&
      termExactMatches.first.term == searchTerm) {
    entries.addEntries(termExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.term == searchTerm));
  }

  if (readingExactMatches.isNotEmpty &&
      readingExactMatches.first.reading == searchTerm) {
    entries.addEntries(readingExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.reading == searchTerm));
  }

  if (fallbackTermExactMatches.isNotEmpty &&
      fallbackTermExactMatches.first.term == fallbackTerm) {
    entries.addEntries(fallbackTermExactMatches
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.term == fallbackTerm));
    entries.addEntries(
        fallbackTermStartsWithMatches.map((e) => MapEntry(e.id, e)));
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
            (termExactMatches.isNotEmpty &&
                termExactMatches.first.term.length <
                    readingExactMatches.first.reading.length))) {
      entries.addEntries(readingExactMatches.map((e) => MapEntry(e.id, e)));
      entries
          .addEntries(readingStartsWithMatches.map((e) => MapEntry(e.id, e)));
    }
  }
  if (searchTermStartsWithKana &&
      termExactMatches.isNotEmpty &&
      termExactMatches.first.term != searchTerm) {
    if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
      entries
          .addEntries(fallbackTermExactMatches.map((e) => MapEntry(e.id, e)));
      entries.addEntries(
          fallbackTermStartsWithMatches.map((e) => MapEntry(e.id, e)));
    }
  }

  if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
    entries.addEntries(fallbackTermExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackTermStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(termExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(termStartsWithMatches.map((e) => MapEntry(e.id, e)));
  } else {
    entries.addEntries(termExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(termStartsWithMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(fallbackTermExactMatches.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        fallbackTermStartsWithMatches.map((e) => MapEntry(e.id, e)));
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

  Map<DictionaryPair, List<DictionaryEntry>> entriesByPair =
      groupBy<DictionaryEntry, DictionaryPair>(
    entries.values,
    (entry) => DictionaryPair(term: entry.term, reading: entry.reading),
  );

  List<DictionaryTerm> terms = entriesByPair.entries
      .map((entry) => DictionaryTerm(
            term: entry.key.term,
            reading: entry.key.reading,
            entries: entry.value,
          ))
      .toList();

  if (terms.length >= params.maximumDictionaryTermsInResult) {
    terms = terms.sublist(0, params.maximumDictionaryTermsInResult);
  }

  // For debugging search results.
  // debugPrint('-' * 50);
  // debugPrint('SEARCH TERM: $searchTerm');
  // debugPrint('FALLBACK TERM: $fallbackTerm');
  // debugPrint(
  //     'TERM EXACT MATCH: ${termExactMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'TERM STARTS WITH MATCH:  ${termStartsWithMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'READING EXACT MATCH: ${readingExactMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'READING STARTS WITH MATCH: ${readingStartsWithMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'FALLBACK TERM EXACT MATCH: ${fallbackTermExactMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'FALLBACK TERM STARTS WITH MATCH: ${fallbackTermStartsWithMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'FALLBACK READING EXACT MATCH: ${fallbackReadingExactMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'FALLBACK READING STARTS WITH MATCH: ${fallbackReadingStartsWithMatches.map((e) => e.term).toList()}');
  // debugPrint(
  //     'FALLBACK TERM LESS DESPERATE THAN LONGEST EXACT TERM PREFIX: $fallbackTermLessDesperateThanLongestExactTermPrefix');
  // debugPrint(
  //     'FALLBACK TERM LESS DESPERATE THAN LONGEST EXACT READING PREFIX: $fallbackTermLessDesperateThanLongestExactReadingPrefix');
  // debugPrint('-' * 50);

  return terms;
}
