import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/util/dictionary_widget_field.dart';

abstract class DictionaryWidgetEnhancement {
  DictionaryWidgetEnhancement(
      {required this.appModel,
      required this.enhancementName,
      required this.enhancementDescription,
      required this.enhancementIcon,
      required this.enhancementField});

  final AppModel appModel;

  /// Name of the enhancement that very shortly describes what it does. Should
  /// be unique and does not match any other enhancements.
  late String enhancementName;

  /// A longer description of what the enhancement can do, or details left
  /// by or regarding the developer.
  late String enhancementDescription;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  late IconData enhancementIcon;

  /// Which field this enhancement is for: word, reading or meaning.
  late DictionaryWidgetField enhancementField;

  /// Whether or not the enhancement is initialised. Do not override.
  bool isInitialised = false;

  /// Performed at startup if activated on startup or later when activated
  /// and not initialised.
  Future<void> initialiseEnhancement() async {}

  /// If this is not null and enhancement is active, this will show in place
  /// of a format's word widget.
  Widget? buildWord(DictionaryEntry entry) {
    return null;
  }

  /// If this is not null and enhancement is active, this will show in place
  /// of a format's reading widget.
  Widget? buildReading(DictionaryEntry entry) {
    return null;
  }

  /// If this is not null and enhancement is active, this will show in place
  /// of a format's meaning widget.
  Widget? buildMeaning(DictionaryEntry entry) {
    return null;
  }

  static String getFieldKey(DictionaryWidgetField field) {
    return "widgetPrefs/${field.toString()}";
  }

  Future<void> setEnabled(DictionaryWidgetField field) async {
    await appModel.sharedPreferences
        .setString(getFieldKey(field), enhancementName);
    await initialiseEnhancement();
  }

  Future<void> setDisabled(DictionaryWidgetField field) {
    return appModel.sharedPreferences.setString(getFieldKey(field), "");
  }
}
