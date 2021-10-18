import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/busy_icon_button.dart';

abstract class AnkiExportEnhancement {
  AnkiExportEnhancement(
      {required this.appModel,
      required this.enhancementName,
      required this.enhancementDescription,
      required this.enhancementIcon,
      required this.enhancementField});

  final AppModel appModel;

  /// Name of the enhancement that very shortly describes what it does.
  late String enhancementName;

  /// A longer description of what the enhancement can do, or details left
  /// by or regarding the developer.
  late String enhancementDescription;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  late IconData enhancementIcon;

  /// Which field this enhancement is for.
  late AnkiExportField enhancementField;

  /// Whether or not the enhancement is initialised. Do not override.
  bool isInitialised = false;

  /// Performed at startup if activated on startup or later when activated
  /// and not initialised.
  Future<void> initialiseEnhancement() async {}

  /// A widget that is shown in the suffix icon area of the [TextFormField]
  /// making up the field in the [CreatorPage].
  Widget getButton({
    required BuildContext context,
    required AnkiExportParams Function() paramsCallback,
    required Function(AnkiExportParams, {AnkiExportField field}) updateCallback,
    required bool editMode,
    required bool autoMode,
    required int position,
  }) {
    return BusyIconButton(
      iconSize: 18,
      onPressed: () async {
        AnkiExportParams initialParams = paramsCallback();

        if (editMode) {
          await setDisabled(enhancementField, position);
          updateCallback(initialParams, field: enhancementField);
        } else if (autoMode) {
          await setNotAuto();
          updateCallback(initialParams, field: enhancementField);
        } else {
          AnkiExportParams newParams = await enhanceParams(initialParams);
          updateCallback(newParams, field: enhancementField);
        }
      },
      icon: Icon(
        enhancementIcon,
        color: editMode || autoMode
            ? Colors.red
            : Theme.of(context).iconTheme.color,
      ),
    );
  }

  /// Given an already defined set of parameters, enhance them and apply
  /// changes. These will be used to override a user's export parameters.
  FutureOr<AnkiExportParams> enhanceParams(AnkiExportParams params);

  static String getFieldAutoKey(AnkiExportField field) {
    return "enhancementPrefs/${field.toString()}/auto/";
  }

  static String getFieldEnabledPositionKey(
      AnkiExportField field, int position) {
    return "enhancementPrefs/${field.toString()}/$position/";
  }

  String getEnhancementFieldAutoKey() {
    return "enhancementPrefs/${enhancementField.toString()}/auto/";
  }

  String getEnhancementSettingKey() {
    return "enhancementPrefs/${enhancementField.toString()}/$enhancementName";
  }

  Future<void> setAuto() async {
    await appModel.sharedPreferences
        .setString(getEnhancementFieldAutoKey(), enhancementName);
    await initialiseEnhancement();
  }

  Future<void> setNotAuto() {
    return appModel.sharedPreferences
        .setString(getEnhancementFieldAutoKey(), "");
  }

  Future<void> setEnabled(AnkiExportField field, int position) async {
    await appModel.sharedPreferences.setString(
        getFieldEnabledPositionKey(field, position), enhancementName);
    await initialiseEnhancement();
  }

  Future<void> setDisabled(AnkiExportField field, int position) {
    return appModel.sharedPreferences
        .setString(getFieldEnabledPositionKey(field, position), "");
  }

  Map<String, dynamic> getSettings() {
    return jsonDecode(
        appModel.sharedPreferences.getString(getEnhancementSettingKey()) ??
            "{}");
  }

  Future<void> setSettings(Map<String, dynamic> settings) async {
    await appModel.sharedPreferences
        .setString(getEnhancementSettingKey(), jsonEncode(settings));
  }

  // bool isEnabled() {
  //   Map<String, dynamic> settings = getSettings();

  //   return settings["enabled"] != null && settings["enabled"];
  // }

  // Future<void> toggleEnabled() async {
  //   Map<String, dynamic> settings = getSettings();
  //   settings["enabled"] = true;
  //   await setSettings(settings);
  // }
}
