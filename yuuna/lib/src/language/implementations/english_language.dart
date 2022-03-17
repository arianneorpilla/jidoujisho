import 'dart:async';
import 'dart:ui';

import 'package:yuuna/language.dart';

/// Language implementation of the English language.
class EnglishLanguage extends Language {
  EnglishLanguage._privateConstructor()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          preferVerticalReading: false,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
        );

  /// Get the singleton instance of this media type.
  static EnglishLanguage get instance => _instance;

  static final EnglishLanguage _instance =
      EnglishLanguage._privateConstructor();

  @override
  Future<void> prepareResources() async {}

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
