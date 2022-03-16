import 'dart:async';
import 'dart:ui';

import 'package:yuuna/language.dart';

/// Language implementation of the English language.
class EnglishLanguage extends Language {
  /// Get a new instance of this language.
  EnglishLanguage()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          preferVerticalReading: false,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
        );

  @override
  Future<void> initialise() async {}

  @override
  FutureOr<String> getRootForm(String word) {
    /// Implement an actual lemmatiser here... Could use NLTK, but it should
    /// really be light to use...
    return word;
  }

  @override
  FutureOr<List<String>> textToWords(String text) {
    return text.splitWithDelim(RegExp(' '));
  }
}
