import 'dart:async';
import 'dart:math';

import 'package:chisa/util/reading_direction.dart';
import 'package:flutter/material.dart';

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

  /// Whether or not the language is initialised. Do not override.
  bool isInitialised = false;

  /// Some implementations of tap-to-select are very unoptimised for a high
  /// length of text. It is impractical to run text segmentation in some cases.
  /// This value sets a length from the center from which input text for
  /// [wordFromIndex] should be cut if longer. If -1, the limit will not be
  /// used.
  int indexMaxDistance = -1;

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
  FutureOr<List<String>> textToWords(String text);

  /// Given an [index] or a character position in given [text], return a word
  /// such that it corresponds to a whole word from the parsed list of words
  /// from [textToWords].
  ///
  /// For example, in the case of Japanese, the parameters "日本語は難しいです。"
  /// and given index 2 (語), this should be "日本語".
  ///
  /// In the case of English, "This is a pen." at index 10 (p), should return
  /// the word "pen".
  FutureOr<String> wordFromIndex(String text, int index) async {
    /// See [indexMaxDistance] above.
    /// If the [indexMaxDistance] is not defined (-1)...
    if (indexMaxDistance != -1) {
      /// If the length of text cut into two, incrmeented by one exceeds the
      /// [indexMaxDistance] multiplied into two and incremented by one...
      if (((text.length / 2) + 1) > ((indexMaxDistance * 2) + 1)) {
        /// Then get a substring of text, with the original index character
        /// being the center and to its left and right, a maximum number of
        /// [indexMaxDistance] characters...
        ///
        /// Of course, the indexes of those values will have to be in the range
        /// of (0, length - 1)...
        List<int> originalIndexTape = [];
        List<int> indexTape = [];

        int rangeStart = max(0, index - indexMaxDistance);
        int rangeEnd = min(text.length - 1, index + indexMaxDistance + 1);

        for (int i = 0; i < text.length; i++) {
          originalIndexTape.add(i);
        }

        String newText = "";
        int newIndex = -1;

        for (int i = 0; i < text.runes.length; i++) {
          if (i >= rangeStart && i < rangeEnd) {
            String character = String.fromCharCode(text.runes.elementAt(i));
            newText += character;

            indexTape.add(i);
            if (index == i) {
              newIndex = indexTape.indexOf(i);
            }
          }
        }

        text = newText;
        index = newIndex;
      }
    }

    List<String> words = await textToWords(text);

    List<String> wordTape = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      for (int j = 0; j < word.length; j++) {
        wordTape.add(word);
      }
    }

    String word = wordTape[index];

    // debugPrint("---");
    // debugPrint(text);
    // debugPrint(index.toString());
    // debugPrint(text[index]);
    // debugPrint(word);
    // debugPrint("---");

    return word;
  }

  /// Given a word, lemmatise and get the root form of the word.
  ///
  /// For example, for Japanese, "しました" should be "する".
  /// For English, "running" should be "run".
  FutureOr<String> getRootForm(String word);

  /// Generate extra fallback terms for a word for use in [searchDictionary].
  /// Some custom formats may decide to perform operations after an original
  /// search term and a fallback search term have both failed in finding
  /// results. By default, the [searchDatabase] function will exhaust all
  /// fallback terms until a match is found.
  FutureOr<List<String>> generateFallbackTerms(String searchTerm) async {
    List<String> fallbackTerms = [];

    String rootForm = await getRootForm(searchTerm);
    if (rootForm != searchTerm) {
      fallbackTerms.add(rootForm);
    }

    return fallbackTerms;
  }
}
