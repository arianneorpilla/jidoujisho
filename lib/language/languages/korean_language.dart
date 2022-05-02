import 'dart:async';
import 'dart:ui';

import 'package:chisa/util/reading_direction.dart';
import 'package:chisa/language/language.dart';
import 'package:collection/collection.dart';
import 'package:mecab_dart/mecab_dart.dart';

class KoreanLanguage extends Language {
  KoreanLanguage()
      : super(
          languageName: '한국어',
          languageCode: 'ko',
          countryCode: 'KR',
          readingDirection: ReadingDirection.horizontalLTR,
          isSpaceDelimited: false,
          textBaseline: TextBaseline.ideographic,
        );

  Mecab mecab = Mecab();

  @override
  Future<void> initialiseLanguage() async {
    await mecab.init('assets/ipadic_korean', true);
  }

  @override
  String getRootForm(String word) {
    return word;
  }

  @override
  FutureOr<List<String>> textToWords(String text) async {
    List<int> spaceIndexes = [];

    for (int i = 0; i < text.length; i++) {
      if (text[i] == ' ' || text[i] == ' ') {
        spaceIndexes.add(i);
      }
    }

    List<dynamic> tokens = mecab.parse(text);
    tokens.removeLast();

    List<String> tokenTape = [];
    int currentLength = 0;

    tokens.forEachIndexed((index, token) {
      tokenTape.add(token.surface.trim());
      currentLength += token.surface.trim().length as int;
      if (spaceIndexes.contains(currentLength)) {
        tokenTape.add(' ');
        currentLength += 1;
      }
    });

    return tokenTape;
  }

  @override
  FutureOr<List<String>> generateFallbackTerms(String searchTerm) async {
    return [];
  }

  @override
  int get indexMaxDistance => 5;
}
