import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  /// A widget that is shown in the suffix icon area of the [TextFormField]
  /// making up the field in the [CreatorPage].
  Widget getButton({
    required BuildContext context,
    required TextEditingController controller,
    required ValueNotifier<File?> imageNotifier,
    required ValueNotifier<File?> audioNotifier,
    required bool editMode,
    required bool autoMode,
    required int position,
    required VoidCallback refreshCallback,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);

    return IconButton(
      iconSize: 18,
      onPressed: () async {
        if (editMode) {
          await setDisabled(enhancementField, position);
          refreshCallback();
        } else if (autoMode) {
          await setNotAuto();
          refreshCallback();
        } else {
          AnkiExportParams params =
              await enhanceParams(appModel.ankiExportParams);
          switch (enhancementField) {
            case AnkiExportField.sentence:
              controller.text = params.sentence;
              break;
            case AnkiExportField.word:
              controller.text = params.word;
              break;
            case AnkiExportField.reading:
              controller.text = params.reading;
              break;
            case AnkiExportField.meaning:
              controller.text = params.meaning;
              break;
            case AnkiExportField.extra:
              controller.text = params.extra;
              break;
            case AnkiExportField.image:
              imageNotifier.value = params.imageFile;
              controller.clear();
              break;
            case AnkiExportField.audio:
              audioNotifier.value = params.audioFile;
              controller.clear();
              break;
          }
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

  Future<void> setAuto() {
    return appModel.sharedPreferences
        .setString(getEnhancementFieldAutoKey(), enhancementName);
  }

  Future<void> setNotAuto() {
    return appModel.sharedPreferences
        .setString(getEnhancementFieldAutoKey(), "");
  }

  Future<void> setEnabled(AnkiExportField field, int position) {
    return appModel.sharedPreferences.setString(
        getFieldEnabledPositionKey(field, position), enhancementName);
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
