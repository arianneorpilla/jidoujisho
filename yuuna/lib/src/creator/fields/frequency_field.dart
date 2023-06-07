import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Returns the frequency of a [DictionaryHeading] (uses harmonic mean for
/// multiple entries, idea taken from @MarvNC).
class FrequencyField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  FrequencyField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Frequency',
          description: 'Adds frequency of headword for sorting purposes,'
              ' calculated using the harmonic mean.',
          icon: Icons.insert_chart,
        );

  /// Get the singleton instance of this field.
  static FrequencyField get instance => _instance;

  static final FrequencyField _instance = FrequencyField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'frequency';

  /// Returns the frequency, set [useMinInDictionary] to true to only use the
  /// lower value if one dictionary provides multiple values.
  static String getFrequency({
    required AppModel appModel,
    required DictionaryHeading heading,
    required SortingMethod sortBy,
    required bool useMinInDictionary,
  }) {
    List<Dictionary> dictionaries = appModel.dictionaries;

    List<String> unhiddenDictionaries = dictionaries
        .where((d) => !d.isHidden(appModel.targetLanguage))
        .map((d) => d.name)
        .toList();

    List<(double, String)> unhiddenFrequencies = heading.frequencies
        .where((entry) =>
            unhiddenDictionaries.contains(entry.dictionary.value!.name))
        .map((freq) => (freq.value, freq.dictionary.value!.name))
        .toList();

    List<double> frequencies = useMinInDictionary
        ? []
        : unhiddenFrequencies.map((tup) => tup.$1).toList();

    if (useMinInDictionary) {
      Map<String, double> dictionariesPlusFreq = {};
      for (var tup in unhiddenFrequencies) {
        var entry = dictionariesPlusFreq[tup.$2];
        dictionariesPlusFreq[tup.$2] =
            entry == null ? tup.$1 : min(entry, tup.$1);
      }
      frequencies = dictionariesPlusFreq.values.toList();
    }

    unhiddenFrequencies.map((tup) => tup.$1).toList();

    if (frequencies.isEmpty) {
      return '';
    }

    double ret;

    switch (sortBy) {
      case SortingMethod.harmonic:
        ret = frequencies.length /
            frequencies.fold(0, (prev, freq) => (1 / freq) + prev);
        break;
      case SortingMethod.min:
        ret = frequencies.reduce((f1, f2) => f1 < f2 ? f1 : f2);
        break;
      case SortingMethod.avg:
        ret = frequencies.fold(0, (prev, freq) => prev + freq.toInt()) /
            frequencies.length;
        break;
    }

    return ret.round().toString();
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
    return getFrequency(
      appModel: appModel,
      heading: heading,
      sortBy: SortingMethod.harmonic,
      useMinInDictionary: true,
    );
  }
}

/// The method by which the frequency value is calculated.
enum SortingMethod {
  /// DEFAULT: The harmonic mean of frequencies.
  harmonic,

  /// The smallest frequency value
  min,

  /// The average frequency value
  avg
}
