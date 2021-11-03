import 'dart:async';

import 'package:chisa/util/reading_direction.dart';
import 'package:chisa/language/language.dart';
import 'package:chisa/util/reg_exp.dart';

class EnglishLanguage extends Language {
  EnglishLanguage()
      : super(
          languageName: "English",
          languageCode: "en",
          countryCode: "US",
          readingDirection: ReadingDirection.horizontalLTR,
        );

  @override
  Future<void> initialiseLanguage() async {}

  @override
  FutureOr<String> getRootForm(String word) {
    return word;
  }

  @override
  FutureOr<List<String>> textToWords(String text) {
    return text.splitWithDelim(RegExp(r" "));
  }
}
