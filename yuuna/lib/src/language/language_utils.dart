import 'package:kana_kit/kana_kit.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:yuuna/dictionary.dart';

/// Extra methods for [RegExp].

extension RegExpExtension on RegExp {
  /// Given text, get all instances of the text split according to this
  /// [RegExp].
  List<String> allMatchesWithSep(String text, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(text, start)) {
      result.add(text.substring(start, match.start));
      result.add(match[0] ?? '');
      start = match.end;
    }
    result.add(text.substring(start));
    return result;
  }
}

/// Extra methods for [String].
extension StringExtension on String {
  /// Split a String with a certain pattern, but keep the delimiters.
  List<String> splitWithDelim(RegExp pattern) =>
      pattern.allMatchesWithSep(this);
}

/// A class utilized in the process of distributing furigana.
class FuriganaDistributionGroup {
  /// Define a Furigana distribution group.
  FuriganaDistributionGroup({
    required this.isKana,
    required this.text,
    required this.textNormalized,
  });

  /// The original text.
  String text;

  /// The text after conversion to kana.
  String? textNormalized;

  /// Whether or not this group pertains to kana.
  bool isKana;
}

/// A class for general language utility functions. A majority of these
/// functions are direct adaptations of Yomichan's Japanese utility functions
/// from JavaScript to Dart.
class LanguageUtils {
  static const _hiraganaRange = [0x3040, 0x309f];
  static const _katakanaRange = [0x30a0, 0x30ff];

  static const _kanaRanges = [_hiraganaRange, _katakanaRange];

  static const KanaKit _kanaKit = KanaKit();

  static const Map<DictionaryPair, List<RubyTextData>> _furiganaCache = {};

  /// Get whether or not a code point is within the ranges. Assumes [ranges]
  /// is a two element list of integers.
  static bool isCodePointInRange(int codePoint, List<int> ranges) {
    return codePoint >= ranges.first && codePoint <= ranges.last;
  }

  /// Multiple ranges version of [isCodePointInRange].  Assumes
  /// [multipleRanges] only contains lists that are two element list of
  /// integers.
  static bool isCodePointInRanges(
      int codePoint, List<List<int>> multipleRanges) {
    for (List<int> ranges in multipleRanges) {
      if (isCodePointInRange(codePoint, ranges)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a given code point is hiragana or katakana.
  static bool isCodePointKana(int codePoint) {
    return isCodePointInRanges(codePoint, _kanaRanges);
  }

  /// Generate Furigana for a [term] given its [reading].
  static List<RubyTextData> distributeFurigana(
      {required String term, required String reading}) {
    DictionaryPair pair = DictionaryPair(term: term, reading: reading);
    if (_furiganaCache[pair] != null) {
      return _furiganaCache[pair]!;
    }

    if (reading == term) {
      // The term and reading are the same. No Furigana required.
      return [RubyTextData(term)];
    }

    List<FuriganaDistributionGroup> groups = [];

    FuriganaDistributionGroup? groupPre;
    bool? isKanaPre;

    for (int codePoint in term.runes) {
      String character = String.fromCharCode(codePoint);

      bool isKana = isCodePointKana(codePoint);
      if (isKanaPre == isKana) {
        groupPre!.text += character;
      } else {
        groupPre = FuriganaDistributionGroup(
          isKana: isKana,
          text: character,
          textNormalized: null,
        );
        groups.add(groupPre);
        isKanaPre = isKana;
      }
    }

    for (FuriganaDistributionGroup group in groups) {
      if (group.isKana) {
        group.textNormalized = _kanaKit.toHiragana(group.text);
      }
    }

    String readingNormalized = _kanaKit.toHiragana(reading);
    List<RubyTextData>? segments = segmentizeFurigana(
      reading: reading,
      readingNormalized: readingNormalized,
      groups: groups,
      groupsStart: 0,
    );
    if (segments != null) {
      return segments;
    }

    /// This is the fallback upon failure.
    return [RubyTextData(term, ruby: reading)];
  }

  /// Given the groups generated from [distributeFurigana], segment the
  /// furigana.
  static List<RubyTextData>? segmentizeFurigana({
    required String reading,
    required String readingNormalized,
    required List<FuriganaDistributionGroup> groups,
    required int groupsStart,
  }) {
    int groupCount = groups.length - groupsStart;

    if (groupCount <= 0) {
      return reading.isEmpty ? [] : null;
    }

    FuriganaDistributionGroup group = groups[groupsStart];
    bool isKana = group.isKana;
    String text = group.text;

    if (isKana) {
      String? textNormalized = group.textNormalized;
      if (readingNormalized.startsWith(textNormalized!)) {
        List<RubyTextData>? segments = segmentizeFurigana(
          reading: reading.substring(text.length),
          readingNormalized: readingNormalized.substring(text.length),
          groups: groups,
          groupsStart: groupsStart + 1,
        );

        if (segments != null) {
          if (reading.startsWith(text)) {
            segments.insert(0, RubyTextData(text));
          } else {
            segments.insertAll(
                0, getFuriganaKanaSegments(text: text, reading: reading));
          }

          return segments;
        }
      }

      return null;
    } else {
      List<RubyTextData>? result;

      for (int i = reading.length; i >= text.length; --i) {
        List<RubyTextData>? segments = segmentizeFurigana(
          reading: reading.substring(i),
          readingNormalized: readingNormalized.substring(i),
          groups: groups,
          groupsStart: groupsStart + 1,
        );

        if (segments != null) {
          if (result != null) {
            return null;
          }

          String segmentReading = reading.substring(0, i);
          segments.insert(0, RubyTextData(text, ruby: segmentReading));
          result = segments;
        }

        if (groupCount == 1) {
          break;
        }
      }

      return result;
    }
  }

  /// Generate a list of [RubyTextData] for kana given a text and its reading.
  static List<RubyTextData> getFuriganaKanaSegments({
    required String text,
    required String reading,
  }) {
    List<RubyTextData> newSegments = [];
    int start = 0;
    bool state = text[0] == reading[0];

    for (int i = 0; i < text.length; i++) {
      bool newState = text[i] == reading[i];
      if (state == newState) {
        continue;
      }
      newSegments.add(
        RubyTextData(
          text.substring(start, i),
          ruby: state ? '' : reading.substring(start, i),
        ),
      );
      state = newState;
      start = i;
    }

    newSegments.add(
      RubyTextData(
        text.substring(start, text.length),
        ruby: state ? '' : reading.substring(start, text.length),
      ),
    );

    return newSegments;
  }
}
