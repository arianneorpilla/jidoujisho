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
          helloWorld: 'こんにちは世界',
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

  /// Used to cache furigana segments for already generated [PitchData]
  /// items.
  final Map<String, Map<int, Widget>?> pitchCache = {};

  @override
  Future<void> prepareResources() async {
    await mecab.init('assets/language/japanese/ipadic', true);
  }

  @override
  FutureOr<String> getRootForm(String term) {
    /// This function is supposed to just return the lemma for the starting
    /// word of a sentence but it also attempts to repair some problems with
    /// some search results.
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

      if (termTokens.first.word!.length < termTokens.first.lemma!.length) {
        return termTokens.first.lemma ?? termTokens.first.word!;
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
    List<RubyTextData> furigana =
        LanguageUtils.distributeFurigana(term: term, reading: reading);

    segmentsCache[pair] = furigana;

    return furigana;
  }

  @override
  Widget getPitchWidget({
    required BuildContext context,
    required String reading,
    required int downstep,
  }) {
    pitchCache[reading] ??= {};
    if (pitchCache[reading]![downstep] != null) {
      return pitchCache[reading]![downstep]!;
    }

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

    Widget widget = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: listWidgets,
    );

    pitchCache[reading]![downstep] = widget;
    return widget;
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<List<DictionaryTerm>> prepareSearchResultsJapaneseLanguage(
    DictionarySearchParams params) async {
  String searchTerm = params.searchTerm.trim();
  String fallbackTerm = params.fallbackTerm.trim();

  int maxEntries = 50;
  int limit = params.maximumDictionaryEntrySearchMatch;

  if (searchTerm.isEmpty) {
    return [];
  }

  KanaKit kanaKit = const KanaKit();

  if (kanaKit.isRomaji(searchTerm)) {
    searchTerm = kanaKit.toHiragana(searchTerm);
    fallbackTerm = kanaKit.toKatakana(searchTerm);
  }

  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.isarDirectoryPath,
    maxSizeMiB: 10240,
  );

  bool searchTermStartsWithKana =
      searchTerm.isNotEmpty && kanaKit.isKana(searchTerm[0]);
  bool fallbackTermStartsWithKana =
      fallbackTerm.isNotEmpty && kanaKit.isKana(fallbackTerm[0]);

  Map<int?, DictionaryEntry> entries = {};

  int maxExactMatchLength = 0;
  int maxExactMatchFallbackLength = 0;
  int maxExactMatchReadingLength = 0;

  bool capturingSearchTermKana = true;
  bool capturingFallbackTermKana = true;

  StringBuffer searchBuffer = StringBuffer();
  for (int rune in searchTerm.runes) {
    if (!LanguageUtils.isCodePointKana(rune)) {
      capturingSearchTermKana = false;
    }

    String character = String.fromCharCode(rune);

    searchBuffer.write(character);

    String partialTerm = searchBuffer.toString();

    if (capturingSearchTermKana) {
      DictionaryEntry? partialTermMatch = database.dictionaryEntrys
          .where()
          .readingEqualTo(partialTerm)
          .or()
          .optional(kanaKit.isHiragana(partialTerm),
              (q) => q.readingEqualTo(kanaKit.toKatakana(partialTerm)))
          .findFirstSync();

      if (partialTermMatch != null) {
        maxExactMatchReadingLength = partialTerm.length;
      }
    }

    DictionaryEntry? partialTermMatch = database.dictionaryEntrys
        .where()
        .termEqualTo(partialTerm)
        .or()
        .optional(kanaKit.isHiragana(partialTerm),
            (q) => q.termEqualTo(kanaKit.toKatakana(partialTerm)))
        .findFirstSync();

    if (partialTermMatch != null) {
      maxExactMatchLength = partialTerm.length;
    }
  }

  StringBuffer fallbackBuffer = StringBuffer();
  if (fallbackTerm.length >= maxExactMatchLength) {
    for (int rune in fallbackTerm.runes) {
      if (!LanguageUtils.isCodePointKana(rune)) {
        capturingFallbackTermKana = false;
      }

      String character = String.fromCharCode(rune);

      fallbackBuffer.write(character);
      String partialTerm = fallbackBuffer.toString();

      if (capturingFallbackTermKana) {
        DictionaryEntry? partialTermMatch = database.dictionaryEntrys
            .where()
            .readingEqualTo(partialTerm)
            .or()
            .optional(kanaKit.isHiragana(partialTerm),
                (q) => q.readingEqualTo(kanaKit.toKatakana(partialTerm)))
            .findFirstSync();

        if (partialTermMatch != null) {
          maxExactMatchFallbackLength = partialTerm.length;
        }
      }

      DictionaryEntry? partialTermMatch = database.dictionaryEntrys
          .where()
          .termEqualTo(partialTerm)
          .or()
          .optional(kanaKit.isHiragana(partialTerm),
              (q) => q.termEqualTo(kanaKit.toKatakana(partialTerm)))
          .findFirstSync();

      if (partialTermMatch != null) {
        maxExactMatchFallbackLength = partialTerm.length;
      }
    }
  }

  List<DictionaryEntry> exactTermResults = [];
  List<DictionaryEntry> exactReadingResults = [];
  List<DictionaryEntry> startsWithTermResults = [];
  List<DictionaryEntry> startsWithReadingResults = [];
  List<DictionaryEntry> fallbackTermResults = [];
  List<DictionaryEntry> fallbackReadingResults = [];
  List<DictionaryEntry> startsWithFallbackTermResults = [];
  List<DictionaryEntry> startsWithFallbackReadingResults = [];

  while (maxEntries >= entries.length &&
      (maxExactMatchLength != 0 || maxExactMatchReadingLength != 0)) {
    String partialTerm = searchTerm.substring(0, maxExactMatchLength);
    String partialReadingTerm =
        searchTerm.substring(0, maxExactMatchReadingLength);

    if (partialTerm.length >= partialReadingTerm.length) {
      if (partialTerm.isNotEmpty) {
        List<DictionaryEntry> results = database.dictionaryEntrys
            .where(sort: Sort.desc)
            .termEqualToAnyPopularity(partialTerm)
            .or()
            .optional(
                kanaKit.isHiragana(partialTerm),
                (q) =>
                    q.termEqualToAnyPopularity(kanaKit.toKatakana(partialTerm)))
            .limit(limit)
            .findAllSync();
        exactTermResults.addAll(results);

        maxExactMatchLength -= 1;
      }

      if (partialReadingTerm.isNotEmpty) {
        List<DictionaryEntry> results = database.dictionaryEntrys
            .where(sort: Sort.desc)
            .readingEqualToAnyPopularity(partialReadingTerm)
            .or()
            .optional(
                kanaKit.isHiragana(partialReadingTerm),
                (q) => q.readingEqualToAnyPopularity(
                    kanaKit.toKatakana(partialReadingTerm)))
            .limit(limit)
            .findAllSync();
        exactReadingResults.addAll(results);

        maxExactMatchReadingLength -= 1;
      }
    } else {
      if (partialReadingTerm.isNotEmpty) {
        List<DictionaryEntry> results = database.dictionaryEntrys
            .where(sort: Sort.desc)
            .readingEqualToAnyPopularity(partialReadingTerm)
            .or()
            .optional(
                kanaKit.isHiragana(partialReadingTerm),
                (q) => q.readingEqualToAnyPopularity(
                    kanaKit.toKatakana(partialReadingTerm)))
            .limit(limit)
            .findAllSync();
        exactReadingResults.addAll(results);

        maxExactMatchReadingLength -= 1;
      }

      if (partialTerm.isNotEmpty) {
        List<DictionaryEntry> results = database.dictionaryEntrys
            .where(sort: Sort.desc)
            .termEqualToAnyPopularity(partialTerm)
            .or()
            .optional(
                kanaKit.isHiragana(partialTerm),
                (q) =>
                    q.termEqualToAnyPopularity(kanaKit.toKatakana(partialTerm)))
            .limit(limit)
            .findAllSync();
        exactTermResults.addAll(results);

        maxExactMatchLength -= 1;
      }
    }
  }

  bool fallbackTermLessDesperateThanLongestExactTermPrefix =
      maxExactMatchFallbackLength > maxExactMatchLength;
  bool fallbackTermLessDesperateThanLongestExactReadingPrefix =
      maxExactMatchFallbackLength > maxExactMatchReadingLength;

  while (fallbackTermLessDesperateThanLongestExactTermPrefix ||
      fallbackTermLessDesperateThanLongestExactReadingPrefix) {
    String partialTerm = fallbackTerm.substring(0, maxExactMatchFallbackLength);

    if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
      List<DictionaryEntry> results = database.dictionaryEntrys
          .where(sort: Sort.desc)
          .termEqualToAnyPopularity(partialTerm)
          .or()
          .optional(
              kanaKit.isHiragana(partialTerm),
              (q) =>
                  q.termEqualToAnyPopularity(kanaKit.toKatakana(partialTerm)))
          .limit(limit)
          .findAllSync();
      fallbackTermResults.addAll(results);
    }
    if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
      List<DictionaryEntry> results = database.dictionaryEntrys
          .where(sort: Sort.desc)
          .readingEqualToAnyPopularity(partialTerm)
          .or()
          .optional(
              kanaKit.isHiragana(partialTerm),
              (q) => q
                  .readingEqualToAnyPopularity(kanaKit.toKatakana(partialTerm)))
          .limit(limit)
          .findAllSync();
      fallbackReadingResults.addAll(results);
    }

    maxExactMatchFallbackLength -= 1;

    fallbackTermLessDesperateThanLongestExactTermPrefix =
        maxExactMatchFallbackLength > maxExactMatchLength;
    fallbackTermLessDesperateThanLongestExactReadingPrefix =
        maxExactMatchFallbackLength > maxExactMatchReadingLength;
  }

  startsWithTermResults = database.dictionaryEntrys
      .where()
      .termStartsWith(searchTerm)
      .sortByPopularityDesc()
      .limit(limit)
      .findAllSync();

  if (searchTermStartsWithKana) {
    startsWithReadingResults = database.dictionaryEntrys
        .where()
        .readingStartsWith(searchTerm)
        .sortByPopularityDesc()
        .limit(limit)
        .findAllSync();
  }

  startsWithFallbackTermResults = database.dictionaryEntrys
      .where()
      .termStartsWith(fallbackTerm)
      .sortByPopularityDesc()
      .limit(limit)
      .findAllSync();

  if (fallbackTermStartsWithKana) {
    startsWithFallbackReadingResults = database.dictionaryEntrys
        .where()
        .readingStartsWith(fallbackTerm)
        .sortByPopularityDesc()
        .limit(limit)
        .findAllSync();
  }

  if (exactTermResults.isNotEmpty &&
      (exactTermResults.first.term == searchTerm)) {
    entries.addEntries(exactTermResults
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.term == searchTerm));
  }

  if (exactReadingResults.isNotEmpty &&
      (exactReadingResults.first.reading == searchTerm)) {
    entries.addEntries(exactReadingResults
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.reading == searchTerm));
  }

  if (exactTermResults.isNotEmpty &&
      (kanaKit.isHiragana(searchTerm) &&
          exactTermResults.first.term == kanaKit.toKatakana(searchTerm))) {
    entries.addEntries(exactTermResults
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.term == kanaKit.toKatakana(searchTerm)));
  }

  if (exactReadingResults.isNotEmpty &&
      (kanaKit.isHiragana(searchTerm) &&
          exactReadingResults.first.reading ==
              kanaKit.toKatakana(searchTerm))) {
    entries.addEntries(exactReadingResults
        .map((e) => MapEntry(e.id, e))
        .where((e) => e.value.reading == kanaKit.toKatakana(searchTerm)));
  }

  entries.addEntries(startsWithTermResults.map((e) => MapEntry(e.id, e)));

  if (fallbackTermResults.isNotEmpty &&
      (fallbackTermResults.first.term == fallbackTerm ||
          (kanaKit.isHiragana(fallbackTerm) &&
              fallbackTermResults.first.term ==
                  kanaKit.toKatakana(fallbackTerm)))) {
    entries.addEntries(fallbackTermResults.map((e) => MapEntry(e.id, e)).where(
        (e) =>
            e.value.term == fallbackTerm ||
            e.value.term == kanaKit.toKatakana(fallbackTerm)));
  }

  if (searchTermStartsWithKana) {
    if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
      entries.addEntries(fallbackTermResults.map((e) => MapEntry(e.id, e)));
    }
    if (exactReadingResults.isNotEmpty &&
        (exactReadingResults.first.reading == searchTerm ||
            (exactTermResults.isNotEmpty &&
                exactTermResults.first.term.length <
                    exactReadingResults.first.reading.length))) {
      entries.addEntries(exactReadingResults.map((e) => MapEntry(e.id, e)));
    }
  }
  if (searchTermStartsWithKana &&
      exactTermResults.isNotEmpty &&
      exactTermResults.first.term != searchTerm) {
    if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
      entries.addEntries(fallbackTermResults.map((e) => MapEntry(e.id, e)));
    }
  }

  if (fallbackTermLessDesperateThanLongestExactTermPrefix) {
    entries.addEntries(
        startsWithFallbackTermResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(fallbackTermResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(exactTermResults.map((e) => MapEntry(e.id, e)));
  } else {
    entries.addEntries(exactTermResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(startsWithTermResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(fallbackTermResults.map((e) => MapEntry(e.id, e)));
  }

  if (fallbackTermLessDesperateThanLongestExactReadingPrefix) {
    entries.addEntries(fallbackReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        startsWithFallbackReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(exactReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(startsWithReadingResults.map((e) => MapEntry(e.id, e)));
  } else {
    entries.addEntries(exactReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(startsWithReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(fallbackReadingResults.map((e) => MapEntry(e.id, e)));
    entries.addEntries(
        startsWithFallbackReadingResults.map((e) => MapEntry(e.id, e)));
  }

  Map<DictionaryPair, List<DictionaryEntry>> entriesByPair =
      groupBy<DictionaryEntry, DictionaryPair>(
    entries.values,
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
        .map((e) => e!)
        .toList();
    List<DictionaryMetaEntry> metaEntries = database.dictionaryMetaEntrys
        .where()
        .termEqualTo(pair.term)
        .findAllSync();
    List<List<DictionaryTag>> meaningTagsGroups = meaningTagKeysByEntry
        .map((meaningTagKeys) => database.dictionaryTags
            .getAllByUniqueKeySync(meaningTagKeys)
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

  return terms;
}
