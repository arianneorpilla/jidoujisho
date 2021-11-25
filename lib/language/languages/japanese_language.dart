import 'dart:async';

import 'package:kana_kit/kana_kit.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';

import 'package:chisa/util/reading_direction.dart';
import 'package:chisa/language/language.dart';

class JapaneseLanguage extends Language {
  JapaneseLanguage()
      : super(
          languageName: "日本語",
          languageCode: "ja",
          countryCode: "JP",
          readingDirection: ReadingDirection.verticalRTL,
          isSpaceDelimited: false,
        );

  Mecab mecab = Mecab();
  KanaKit kanaKit = const KanaKit();

  @override
  Future<void> initialiseLanguage() async {
    await mecab.init("assets/ipadic", true);
  }

  @override
  FutureOr<String> getRootForm(String word) {
    if (kanaKit.isRomaji(word)) {
      return kanaKit.toHiragana(word);
    }

    List<Word> wordTokens = parseVe(mecab, word);
    return wordTokens.first.lemma ?? "";
  }

  @override
  FutureOr<List<String>> textToWords(String text) {
    String delimiterSanitisedText = text
        .replaceAll("﻿", "␝")
        .replaceAll("　", "␝")
        .replaceAll('\n', '␜')
        .replaceAll(' ', '␝');

    List<Word> tokens = parseVe(mecab, delimiterSanitisedText);

    List<String> words = [];

    for (Word token in tokens) {
      String word = "";
      for (TokenNode token in token.tokens) {
        word += token.surface;
      }
      word = word.replaceAll('␜', '\n').replaceAll('␝', ' ');
      words.add(word);
    }

    return words;
  }

  @override
  FutureOr<List<String>> generateFallbackTerms(String searchTerm) async {
    List<String> fallbackTerms = [];

    String rootForm = await getRootForm(searchTerm);
    if (rootForm != searchTerm) {
      fallbackTerms.add(rootForm);
    }

    if (kanaKit.isRomaji(searchTerm)) {
      String hiragana = kanaKit.toHiragana(searchTerm);
      String katakana = kanaKit.toKatakana(searchTerm);
      String hiraganaFallback = await getRootForm(hiragana);
      String katakanaFallback = await getRootForm(katakana);

      fallbackTerms.add(hiragana);
      if (hiraganaFallback != hiragana) {
        fallbackTerms.add(hiraganaFallback);
      }
      fallbackTerms.add(katakana);
      if (katakanaFallback != katakana) {
        fallbackTerms.add(katakanaFallback);
      }
    } else {
      if (kanaKit.isHiragana(searchTerm)) {
        fallbackTerms.add(kanaKit.toKatakana(searchTerm));
      }
      if (kanaKit.isKatakana(searchTerm)) {
        fallbackTerms.add(kanaKit.toHiragana(searchTerm));
      }

      if (searchTerm.length > 4) {
        if (searchTerm.endsWith("そうに")) {
          fallbackTerms.add(searchTerm.substring(0, searchTerm.length - 3));
        }
        fallbackTerms.add(searchTerm.substring(0, searchTerm.length - 2));
      }
    }

    return fallbackTerms;
  }
}
