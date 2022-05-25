import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:collection/collection.dart';

/// Returns the formatted pitch accent diagram HTML of a [DictionaryTerm].
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

  /// Returns Furigana for a single [PitchData].
  static String getHtmlPitch(PitchData data) {
    StringBuffer html = StringBuffer();

    List<String> moras = [];
    for (int i = 0; i < data.reading.length; i++) {
      String current = data.reading[i];
      String? next;
      if (i + 1 < data.reading.length) {
        next = data.reading[i + 1];
      }

      if (next != null && 'ゃゅょぁぃぅぇぉャュョァィゥェォ'.contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (data.downstep == 0) {
      html.write(moras[0]);
      html.write('<span class="pitch">');
      for (int i = 1; i < moras.length; i++) {
        html.write(moras[i]);
      }
      html.write('</span>');
    } else {
      List<int> beforePitchNumbers = [];
      for (int i = 1; i < moras.length; i++) {
        if (i < data.downstep - 1) {
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
        } else if (i == data.downstep - 1) {
          html.write('<span class="pitch_end">');
        }
        html.write(moras[i]);
        if (i == lastBeforePitchNumber || i == data.downstep - 1) {
          html.write('</span>');
        }
      }
    }

    return html.toString();
  }

  /// Returns Furigana for multiple [PitchData].
  static String getAllHtmlPitch(List<PitchData> datas) {
    if (datas.isEmpty) {
      return '';
    }

    StringBuffer html = StringBuffer();

    datas.forEachIndexed((index, data) {
      html.write(getHtmlPitch(data));
      if (index != datas.length - 1) {
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
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
    required bool creatorJustLaunched,
  }) {
    List<DictionaryMetaEntry> pitchMetaEntries =
        metaEntries.where((metaEntry) => metaEntry.pitches != null).toList();

    List<PitchData> datas = [];
    for (DictionaryMetaEntry metaEntry in pitchMetaEntries) {
      datas.addAll(
        metaEntry.pitches!
            .where((pitch) => pitch.reading == dictionaryTerm.reading),
      );
    }

    return getAllHtmlPitch(datas);
  }
}
