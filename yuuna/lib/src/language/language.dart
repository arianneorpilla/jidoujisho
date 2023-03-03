import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Defines common characteristics required for tuning locale and text
/// segmentation behaviour for different languages. Override the variables
/// and functions of this abstract class in order to implement a target
/// language.
abstract class Language {
  /// Initialise the language with the required details.
  Language({
    required this.languageName,
    required this.languageCode,
    required this.countryCode,
    required this.textDirection,
    required this.preferVerticalReading,
    required this.isSpaceDelimited,
    required this.textBaseline,
    required this.helloWorld,
    required this.standardFormat,
    required this.defaultFontFamily,
    this.prepareSearchResults = prepareSearchResultsStandard,
  });

  /// The name of the language, as known to native speakers.
  ///
  /// For example, in the case of Japanese, this is '日本語'.
  /// In the case of American English, this is 'English (US)'.
  final String languageName;

  /// The ISO 639-1 code or the international standard language code.
  ///
  /// For example, in the case of Japanese, this is 'ja'.
  /// In the case of English, this is 'en'.
  final String languageCode;

  /// The ISO 3166-1 code or the international standard name of country.
  ///
  /// For example, in the case of Japanese, this is 'JP'.
  /// In the case of (American) English, this is 'US'.
  final String countryCode;

  /// The reading direction of the language, for which reading should be
  /// given a specific format by default. For example, Arabic is RTL, while
  /// English is LTR.
  final TextDirection textDirection;

  /// Whether or not this language should prefer vertical reading.
  final bool preferVerticalReading;

  /// Whether or not this language essentially relies on spaces to  commonly
  /// separate and discern words.
  final bool isSpaceDelimited;

  /// If this language uses an alphabetic or ideographic text baseline.
  final TextBaseline textBaseline;

  /// Testing text for the language's basic use. This is useful for testing
  /// and pre-loading the database for use.
  final String helloWorld;

  /// Overrides the base search function and implements search specific to
  /// a language.
  final Future<int?> Function(DictionarySearchParams params)
      prepareSearchResults;

  /// A standard format that dictionaries of this language can be found in.
  /// This is only to set this as the default last selected format on first
  /// time setup.
  final DictionaryFormat standardFormat;

  /// Default font for a language.
  final String defaultFontFamily;

  /// Whether or not [initialise] has been called for the language.
  bool _initialised = false;

  /// Some implementations of tap-to-select are very unoptimised for a high
  /// length of text. It is impractical to run text segmentation in some cases.
  /// This value sets a length from the center from which input text for
  /// [wordFromIndex] should be cut if longer. If null, the limit will not be
  /// used.
  int? indexMaxDistance;

  /// This function is run at startup or when changing languages. It is not
  /// called again if already run.
  Future<void> initialise() async {
    if (_initialised) {
      return;
    } else {
      await prepareResources();
      _initialised = true;
    }
  }

  /// Extract a [Locale] from the language code and country code.
  Locale get locale => Locale(languageCode, countryCode);

  /// Prepare text segmentation tools and other dependencies necessary for this
  /// langauge to function.
  Future<void> prepareResources();

  /// Given paragraph text and an index, yield the part of the text such that
  /// the result is a sentence. Different languages may decide to use different
  /// delimiters.
  String getSentenceFromParagraph({
    required String paragraph,
    required int index,
  }) {
    RegExp regex = RegExp(r'.{1,}?([。.」?？!！]+|\n)');

    Iterable<Match> matches = regex.allMatches(paragraph);
    int currentIndex = 0;
    String sentenceToReturn = paragraph;

    for (Match match in matches) {
      sentenceToReturn = match.group(0) ?? '';

      currentIndex += sentenceToReturn.length;
      if (currentIndex > index) {
        break;
      }
    }

    return sentenceToReturn.trim();
  }

  /// The language and country code separated by a dash.
  String get languageCountryCode => '$languageCode-$countryCode';

  /// Given unsegmented [text], perform text segmentation particular to the
  /// language and return a list of parsed words.
  ///
  /// For example, in the case of Japanese, '日本語は難しいです。', this should
  /// ideally return a list containing '日本語', 'は', '難しい', 'です', '。'.
  ///
  /// In the case of English, 'This is a pen.' should ideally return a list
  /// containing 'This', ' ', 'is', ' ', 'a', ' ', 'pen', '.'. Delimiters
  /// should stay intact for languages that feature such, such as spaces.
  List<String> textToWords(String text);

  /// Given an [index] or a character position in given [text], return a word
  /// such that it corresponds to a whole word from the parsed list of words
  /// from [textToWords].
  ///
  /// For example, in the case of Japanese, the parameters '日本語は難しいです。'
  /// and given index 2 (語), this should be '日本語'.
  ///
  /// In the case of English, 'This is a pen.' at index 10 (p), should return
  /// the word 'pen'.
  String wordFromIndex({
    required String text,
    required int index,
  }) {
    /// See [indexMaxDistance] above.
    /// If the [indexMaxDistance] is not defined...
    if (indexMaxDistance != null) {
      /// If the length of text cut into two, incrmeented by one exceeds the
      /// [indexMaxDistance] multiplied into two and incremented by one...
      if (((text.length / 2) + 1) > ((indexMaxDistance! * 2) + 1)) {
        /// Then get a substring of text, with the original index character
        /// being the center and to its left and right, a maximum number of
        /// [indexMaxDistance] characters...
        ///
        /// Of course, the indexes of those values will have to be in the range
        /// of (0, length - 1)...
        List<int> originalIndexTape = [];
        List<int> indexTape = [];

        int rangeStart = max(0, index - indexMaxDistance!);
        int rangeEnd = min(text.length - 1, index + indexMaxDistance! + 1);

        for (int i = 0; i < text.length; i++) {
          originalIndexTape.add(i);
        }

        StringBuffer buffer = StringBuffer();
        int newIndex = -1;

        for (int i = 0; i < text.runes.length; i++) {
          if (i >= rangeStart && i < rangeEnd) {
            final String character =
                String.fromCharCode(text.runes.elementAt(i));
            buffer.write(character);

            indexTape.add(i);
            if (index == i) {
              newIndex = indexTape.indexOf(i);
            }
          }
        }

        final String newText = buffer.toString();

        return wordFromIndex(text: newText, index: newIndex);
      }
    }

    List<String> words = textToWords(text);

    List<String> wordTape = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      for (int j = 0; j < word.length; j++) {
        wordTape.add(word);
      }
    }

    String word = wordTape[index];

    return word;
  }

  /// Gets a search term and for a space-delimited language, assumes the index
  /// is within the range of the first word, with remainder words included.
  /// For a language that is not space-delimited, this is simply the substring
  /// function.
  String getSearchTermFromIndex({
    required String text,
    required int index,
  }) {
    if (isSpaceDelimited) {
      final workingBuffer = StringBuffer();
      final termBuffer = StringBuffer();
      List<String> words = textToWords(text.replaceAll('\n', ' '));

      for (String word in words) {
        workingBuffer.write(word);
        if (workingBuffer.length > index) {
          termBuffer.write(word);
        }
      }

      return termBuffer.toString();
    } else {
      return text.substring(index);
    }
  }

  /// Returns the starting index from which the search term should be chopped
  /// from, given a clicked index and full text. For a space-delimited language,
  /// this will return the starting index of a clicked word. Otherwise, this
  /// returns the clicked index itself.
  int getStartingIndex({
    required String text,
    required int index,
  }) {
    if (isSpaceDelimited) {
      final workingBuffer = StringBuffer();

      List<String> words = textToWords(text.replaceAll('\n', ' '));

      for (String word in words) {
        workingBuffer.write(word);
        if (workingBuffer.length > index) {
          return workingBuffer.length - word.length;
        }
      }

      return index;
    } else {
      return index;
    }
  }

  /// Some languages may want to display custom widgets rather than the built
  /// in word and reading text that is there by default. For example, Japanese
  /// may want to display a furigana widget instead.
  Widget getTermReadingOverrideWidget({
    required BuildContext context,
    required AppModel appModel,
    required DictionaryHeading heading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading.term,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          heading.reading,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  /// Some languages may have custom widgets for generating pronunciation
  /// diagrams.
  Widget getPitchWidget({
    required AppModel appModel,
    required BuildContext context,
    required String reading,
    required int downstep,
  }) {
    return const SizedBox.shrink();
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<int?> prepareSearchResultsStandard(DictionarySearchParams params) {
  throw UnimplementedError();
}
