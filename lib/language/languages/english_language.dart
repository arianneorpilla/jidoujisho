import 'dart:async';
import 'dart:ui';

import 'package:chisa/util/reading_direction.dart';
import 'package:chisa/language/language.dart';
import 'package:chisa/util/reg_exp.dart';

class EnglishLanguage extends Language {
  EnglishLanguage()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          readingDirection: ReadingDirection.horizontalLTR,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
        );

  @override
  Future<void> initialiseLanguage() async {}

  @override
  FutureOr<String> getRootForm(String word) {
    // Implement an actual lemmatiser here... Could use NLTK, but it should
    // really be light to use...
    return word;
  }

  @override
  FutureOr<List<String>> textToWords(String text) {
    return text.splitWithDelim(RegExp(' '));
  }
}
