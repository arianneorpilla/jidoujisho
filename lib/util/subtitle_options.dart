import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleOptions {
  int audioAllowance;
  int subtitleDelay;
  double fontSize;
  String regexFilter;

  SubtitleOptions(
    this.audioAllowance,
    this.subtitleDelay,
    this.fontSize,
    this.regexFilter,
  );
}

Future<void> showSubtitleOptionsDialog(
  BuildContext context,
  ValueNotifier<SubtitleOptions> optionsNotifier,
) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);
  SubtitleOptions subtitleOptions = optionsNotifier.value;

  TextEditingController allowanceController =
      TextEditingController(text: subtitleOptions.audioAllowance.toString());
  TextEditingController delayController =
      TextEditingController(text: subtitleOptions.subtitleDelay.toString());
  TextEditingController fontSizeController =
      TextEditingController(text: subtitleOptions.fontSize.toString());
  TextEditingController regexFilterController =
      TextEditingController(text: subtitleOptions.regexFilter.trim());

  Future<void> setValues(bool remember) async {
    String allowanceText = allowanceController.text;
    int? newAllowance = int.tryParse(allowanceText);

    String delayText = delayController.text;
    int? newDelay = int.tryParse(delayText);

    String fontSizeText = fontSizeController.text;
    double? newFontSize = double.tryParse(fontSizeText);

    String newRegexFilter = regexFilterController.text.trim();

    try {
      if (newDelay != null && newAllowance != null && newFontSize != null) {
        RegExp(newRegexFilter);
        SubtitleOptions subtitleOptions = appModel.getSubtitleOptions();

        subtitleOptions.subtitleDelay = newDelay;
        subtitleOptions.audioAllowance = newAllowance;
        subtitleOptions.regexFilter = newRegexFilter;
        subtitleOptions.fontSize = newFontSize;

        optionsNotifier.value = subtitleOptions;

        if (remember) {
          await appModel.setSubtitleOptions(subtitleOptions);
        }

        Navigator.pop(context);
      }
    } finally {}
  }

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (1 / 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: delayController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText:
                            appModel.translate("player_option_subtitle_delay"),
                        suffixText: " ms"),
                  ),
                  TextField(
                    controller: allowanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText:
                            appModel.translate("player_option_audio_allowance"),
                        suffixText: " ms"),
                  ),
                  TextField(
                    controller: fontSizeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText:
                            appModel.translate("player_option_font_size"),
                        suffixText: " px"),
                  ),
                  TextField(
                    controller: regexFilterController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText:
                          appModel.translate("player_option_regex_filter"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(appModel.translate("dialog_close"),
                  style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(appModel.translate("dialog_set_remember"),
                  style: const TextStyle(color: Colors.white)),
              onPressed: () {
                setValues(true);
              },
            ),
            TextButton(
              child: Text(appModel.translate("dialog_set"),
                  style: const TextStyle(color: Colors.white)),
              onPressed: () {
                setValues(false);
              },
            ),
          ],
        );
      });
}
