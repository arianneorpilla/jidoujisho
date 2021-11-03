import 'dart:async';

import 'package:chaquopy/chaquopy.dart';

import 'package:chisa/util/reading_direction.dart';
import 'package:chisa/language/language.dart';
import 'package:flutter/widgets.dart';

class ChineseTraditionalLanguage extends Language {
  ChineseTraditionalLanguage()
      : super(
          languageName: "漢語",
          languageCode: "zh",
          countryCode: "TW",
          readingDirection: ReadingDirection.verticalRTL,
        );

  @override
  Future<void> initialiseLanguage() async {}

  @override
  String getRootForm(String word) {
    return word;
  }

  @override
  FutureOr<List<String>> textToWords(String text) async {
    String delimiterSanitisedText = text
        .replaceAll("﻿", "␝")
        .replaceAll("　", "␝")
        .replaceAll('\n', '␜')
        .replaceAll(' ', '␝');

    Map<String, dynamic> result = await Chaquopy.executeCode('''import jieba
seg_list = jieba.cut("""$delimiterSanitisedText""", cut_all=False)
for seg in seg_list:
  print(seg)
f''');

    String output = result['textOutputOrError']
            .replaceAll('␜', '\n')
            .replaceAll('␝', ' ') ??
        text;

    print((output.split("\n")));

    return output.split("\n");
  }

  @override
  FutureOr<List<String>> generateFallbackTerms(String searchTerm) async {
    List<String> fallbackTerms = [];

    if (searchTerm.length > 4) {
      fallbackTerms.add(searchTerm.substring(0, searchTerm.length - 2));
    }
    if (searchTerm.length > 2) {
      fallbackTerms.add(searchTerm.substring(0, searchTerm.length - 1));
    }

    return fallbackTerms;
  }
}
