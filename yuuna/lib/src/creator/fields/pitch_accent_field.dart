import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:collection/collection.dart';

/// Returns the formatted pitch accent diagram HTML of a [DictionaryHeading].
class PitchAccentField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  PitchAccentField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Pitch Accent',
          description: 'Pre-fills HTML to export for pitch accent diagrams. '
              ' See documentation for required CSS.',
          icon: Icons.swap_vert,
        );

  /// Get the singleton instance of this field.
  static PitchAccentField get instance => _instance;

  static final PitchAccentField _instance =
      PitchAccentField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'pitch_accent';

  /// Returns Furigana for a single [DictionaryHeading].
  static String getHtmlPitch({
    required String reading,
    required int downstep,
  }) {
    StringBuffer html = StringBuffer();

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && 'ゃゅょぁぃぅぇぉャュョァィゥェォ'.contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (downstep == 0) {
      html.write(moras[0]);
      html.write('<span class="pitch">');
      for (int i = 1; i < moras.length; i++) {
        html.write(moras[i]);
      }
      html.write('</span>');
    } else {
      List<int> beforePitchNumbers = [];
      for (int i = 1; i < moras.length; i++) {
        if (i < downstep - 1) {
          beforePitchNumbers.add(i);
        }
      }

      int firstBeforePitchNumber = -1;
      int lastBeforePitchNumber = -1;
      if (beforePitchNumbers.isNotEmpty) {
        firstBeforePitchNumber = beforePitchNumbers.first;
        lastBeforePitchNumber = beforePitchNumbers.last;
      }

      for (int i = 0; i < moras.length; i++) {
        if (i == firstBeforePitchNumber) {
          html.write('<span class="pitch">');
        } else if (i == downstep - 1) {
          html.write('<span class="pitch_end">');
        }
        html.write(moras[i]);
        if (i == lastBeforePitchNumber || i == downstep - 1) {
          html.write('</span>');
        }
      }
    }

    return html.toString();
  }

  /// Returns Furigana for multiple [DictionaryPitch].
  static String getAllHtmlPitch({required DictionaryHeading heading}) {
    if (heading.pitches.isEmpty) {
      return '';
    }

    StringBuffer html = StringBuffer();

    heading.pitches.forEachIndexed((index, pitch) {
      html.write(
        getHtmlPitch(
          reading: heading.reading,
          downstep: pitch.downstep,
        ),
      );
      if (index != heading.pitches.length - 1) {
        html.write('<br>');
      }
    });

    return html.toString();
  }

  @override
  String? onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
  }) {
    return getAllHtmlPitch(heading: heading);
  }
}
