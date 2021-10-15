import 'package:daijidoujisho/enums/reading_direction.dart';

abstract class Language {
  Language({
    required this.languageName,
    required this.languageCode,
    required this.countryCode,
    required this.readingDirection,
  });

  /// The name of the language, as known to native speakers.
  ///
  /// For example, in the case of Japanese, this is "日本語".
  /// In the case of American English, this is "English (US)".
  final String languageName;

  /// The ISO 639-1 code or the international standard language code.
  ///
  /// For example, in the case of Japanese, this is "ja".
  /// In the case of English, this is "en".
  final String languageCode;

  /// The ISO 3166-1 code or the international standard name of country.
  ///
  /// For example, in the case of Japanese, this is "JP".
  /// In the case of (American) English, this is "US".
  final String countryCode;

  /// The reading direction of the language, for which reading should be
  /// given a specific format by default.
  ///
  /// This is [ReadingDirection.verticalRTL] for Japanese.
  /// For English, this is [ReadingDirection.horizontalLTR].
  final ReadingDirection readingDirection;

  /// Initialise text segmentation and other tools necessary for this language
  /// to function.
  Future<void> initialiseLanguage();

  /// Given unsegmented [text], perform text segmentation particular to the
  /// language and return a list of parsed words.
  ///
  /// For example, in the case of Japanese, "日本語は難しいです。", this should
  /// ideally return a list containing "日本語", "は", "難しい", "です", "。".
  ///
  /// In the case of English, "This is a pen." should ideally return a list
  /// containing "This", " ", "is", " ", "a", " ", "pen", ".". Delimiters
  /// should stay intact for languages that feature such, such as spaces.
  List<String> textToWords(String text);

  /// Given an [index] or a character position in given [text], return a word
  /// such that it corresponds to a whole word from the parsed list of words
  /// from [textToWords].
  ///
  /// For example, in the case of Japanese, the parameters "日本語は難しいです。"
  /// and given index 2 (語), this should be "日本語".
  ///
  /// In the case of English, "This is a pen." at index 10 (p), should return
  /// the word "pen".
  String wordFromIndex(String text, int index);

  /// Given a word, lemmatise and get the root form of the word.
  ///
  /// For example, for Japanese, "見せる" should be "みる".
  /// For English, "running" should be "run".
  String getRootForm(String word);
}
