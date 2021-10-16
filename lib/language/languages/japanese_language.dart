import 'package:chisachan/util/reading_direction.dart';
import 'package:chisachan/language/language.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:ve_dart/ve_dart.dart';

class JapaneseLanguage extends Language {
  JapaneseLanguage()
      : super(
          languageName: "日本語",
          languageCode: "ja",
          countryCode: "JP",
          readingDirection: ReadingDirection.verticalRTL,
        );

  Mecab mecab = Mecab();

  @override
  Future<void> initialiseLanguage() async {
    await mecab.init("assets/ipadic", true);
  }

  @override
  String getRootForm(String word) {
    List<Word> wordTokens = parseVe(mecab, word);
    return wordTokens.first.lemma ?? "";
  }

  @override
  List<String> textToWords(String text) {
    String delimiterSanitisedText = text
        .replaceAll("﻿", "␝")
        .replaceAll("　", "␝")
        .replaceAll('\n', '␜')
        .replaceAll(' ', '␝');

    List<Word> tokens = parseVe(mecab, delimiterSanitisedText);

    List<String> words = [];
    for (Word token in tokens) {
      String word = token.word!.replaceAll('␜', '\n').replaceAll('␝', ' ');
      words.add(word);
    }

    return words;
  }

  @override
  String wordFromIndex(String text, int index) {
    List<String> words = textToWords(text);

    List<String> wordTape = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      for (int j = 0; j < word.length; j++) {
        wordTape.add(word);
      }
    }

    String word = wordTape[index];
    word = word.replaceAll('␜', '\n').replaceAll('␝', ' ').trim();

    return word;
  }
}
