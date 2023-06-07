import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';
import 'package:collection/collection.dart';

/// Returns the formatted pitch accent diagram HTML of a [DictionaryHeading].
class PitchAccentField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  PitchAccentField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Pitch Accent',
          description: 'Pre-fills text to export for pitch accent diagrams.',
          icon: Icons.swap_vert,
        );

  /// Get the singleton instance of this field.
  static PitchAccentField get instance => _instance;

  static final PitchAccentField _instance =
      PitchAccentField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'pitch_accent';

  /// Returns Furigana for multiple [DictionaryPitch].
  static String getAllHtmlPitch(
      {required AppModel appModel, required DictionaryHeading heading}) {
    List<Dictionary> dictionaries = appModel.dictionaries;

    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    List<DictionaryPitch> pitches = heading.pitches
        .where(
            (entry) => !dictionaryNamesByHidden[entry.dictionary.value!.name]!)
        .toList();
    pitches.sort((a, b) => dictionaryNamesByOrder[a.dictionary.value!.name]!
        .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    if (pitches.isEmpty) {
      return '';
    }

    StringBuffer html = StringBuffer();

    pitches.forEachIndexed((index, pitch) {
      html.write(
        PitchSvg._pitchSvg(
          heading.reading,
          PitchSvg._pitchValueToPatt(heading.reading, pitch.downstep),
        ),
      );
      if (index != pitches.length - 1) {
        html.write('<br>');
      }
    });

    return html.toString();
  }

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    if (appModel.targetLanguage is! JapaneseLanguage) {
      return null;
    }

    return getAllHtmlPitch(
      appModel: appModel,
      heading: heading,
    );
  }
}

/// Pitch utilities courtesy of Matthew Chan.
/// https://github.com/mathewthe2/immersion_reader/blob/main/lib/japanese/pitch.dart
class PitchSvg {
  static String _pitchSvg(String word, String patt, {bool silent = false}) {
    /* Draw pitch accent patterns in SVG

    Examples:
        はし HLL (箸)
        はし LHL (橋)
        はし LHH (端)
        */
    List<String> mora = _hiraToMora(word);
    if ((patt.length - mora.length != 1) && !silent) {
      debugPrint('pattern should be number of morae + 1. got $word, $patt');
    }
    int positions = max(mora.length, patt.length);
    const int stepWidth = 35;
    const int marginLr = 16;
    int svgWidth = max(0, ((positions - 1) * stepWidth) + (marginLr * 2));
    final svg = StringBuffer(
        '<svg xmlns="http://www.w3.org/2000/svg" width="${svgWidth * (3 / 5)}px" height="45px" viewBox="0 0 $svgWidth 75">');
    final chars = StringBuffer();
    for (int i = 0; i < mora.length; i++) {
      int xCenter = marginLr + (i * stepWidth);
      chars.write(_text(xCenter - 11, mora[i]));
    }
    final circles = StringBuffer();

    final paths = StringBuffer();
    String pathTyp = '';

    List<int> prevCenter = [-1, -1];
    for (int i = 0; i < patt.length; i++) {
      int xCenter = marginLr + (i * stepWidth);
      String accent = patt[i];
      int yCenter = 0;
      if (['H', 'h', '1', '2'].contains(accent)) {
        yCenter = 5;
      } else if (['L', 'l', '0'].contains(accent)) {
        yCenter = 30;
      }
      circles.write(_circle(xCenter, yCenter, o: i >= mora.length));
      if (i > 0) {
        if (prevCenter[1] == yCenter) {
          pathTyp = 's';
        } else if (prevCenter[1] < yCenter) {
          pathTyp = 'd';
        } else if (prevCenter[1] > yCenter) {
          pathTyp = 'u';
        }
        paths.write(_path(prevCenter[0], prevCenter[1], pathTyp, stepWidth));
      }
      prevCenter = [xCenter, yCenter];
    }
    svg.write(chars);
    svg.write(paths);
    svg.write(circles);
    svg.write('</svg>');

    return svg.toString();
  }

  static String _circle(int x, int y, {bool o = false}) {
    if (o) {
      return '<circle r="4" cx="${x + 4}" cy="$y" stroke="currentColor" stroke-width="2" fill="none" />';
    } else {
      return '<circle r="5" cx="$x" cy="$y" style="opacity:1;fill:currentColor;" />';
    }
  }

  static String _text(int x, String mora) {
    if (mora.length == 1) {
      return '<text x="$x" y="67.5" style="font-size:20px;font-family:sans-serif;fill:currentColor;">$mora</text>';
    } else {
      return '<text x="${x - 5}" y="67.5" style="font-size:20px;font-family:sans-serif;fill:currentColor;">${mora[0]}</text><text x="${x + 12}" y="67.5" style="font-size:14px;font-family:sans-serif;fill:currentColor;">${mora[1]}</text>';
    }
  }

  static String _path(int x, int y, String typ, int stepWidth) {
    String delta = '';
    switch (typ) {
      case 's':
        delta = '$stepWidth,0';
        break;
      case 'u':
        delta = '$stepWidth,-25';
        break;
      case 'd':
        delta = '$stepWidth,25';
        break;
    }
    return '<path d="m $x,$y $delta" style="fill:none;stroke:currentColor;stroke-width:1.5;" />';
  }

  static String _pitchValueToPatt(String word, int pitchValue) {
    int numberOfMora = _hiraToMora(word).length;
    if (numberOfMora >= 1) {
      if (pitchValue == 0) {
        // heiban
        return 'L${'H' * numberOfMora}';
      } else if (pitchValue == 1) {
        // atamadaka
        return 'H${'L' * numberOfMora}';
      } else if (pitchValue >= 2) {
        int stepdown = pitchValue - 2;
        return 'LH${'H' * stepdown}${'L' * (numberOfMora - pitchValue + 1)}';
      }
    }
    return '';
  }

  static List<String> _hiraToMora(String hira) {
    /* Example:
          in:  'しゅんかしゅうとう'
         out: ['しゅ', 'ん', 'か', 'しゅ', 'う', 'と', 'う']
    */

    List<String> moraArr = [];
    const List<String> combiners = [
      'ゃ',
      'ゅ',
      'ょ',
      'ぁ',
      'ぃ',
      'ぅ',
      'ぇ',
      'ぉ',
      'ャ',
      'ュ',
      'ョ',
      'ァ',
      'ィ',
      'ゥ',
      'ェ',
      'ォ'
    ];

    int i = 0;
    while (i < hira.length) {
      if (i + 1 < hira.length && combiners.contains(hira[i + 1])) {
        moraArr.add('${hira[i]}${hira[i + 1]}');
        i += 2;
      } else {
        moraArr.add(hira[i]);
        i += 1;
      }
    }
    return moraArr;
  }
}
