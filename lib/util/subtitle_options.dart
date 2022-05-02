import 'package:chisa/language/language.dart';
import 'package:chisa/language/languages/chinese_simplified_language.dart';
import 'package:chisa/language/languages/chinese_traditional_language.dart';
import 'package:chisa/language/languages/japanese_language.dart';
import 'package:chisa/language/languages/korean_language.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SubtitleOptions {
  SubtitleOptions(
    this.audioAllowance,
    this.subtitleDelay,
    this.fontSize,
    this.fontName,
    this.regexFilter,
  );

  int audioAllowance;
  int subtitleDelay;
  double fontSize;
  String fontName;
  String regexFilter;
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
  TextEditingController fontNameController =
      TextEditingController(text: subtitleOptions.fontName.trim());
  TextEditingController regexFilterController =
      TextEditingController(text: subtitleOptions.regexFilter.trim());

  Future<void> setValues(bool remember) async {
    String allowanceText = allowanceController.text;
    int? newAllowance = int.tryParse(allowanceText);

    String delayText = delayController.text;
    int? newDelay = int.tryParse(delayText);

    String fontSizeText = fontSizeController.text;
    double? newFontSize = double.tryParse(fontSizeText);

    String newFontName = fontNameController.text.trim();
    String newRegexFilter = regexFilterController.text.trim();

    try {
      if (newDelay != null && newAllowance != null && newFontSize != null) {
        RegExp(newRegexFilter);
        GoogleFonts.getFont(newFontName);

        SubtitleOptions subtitleOptions = appModel.getSubtitleOptions();

        subtitleOptions.subtitleDelay = newDelay;
        subtitleOptions.audioAllowance = newAllowance;
        subtitleOptions.regexFilter = newRegexFilter;
        subtitleOptions.fontName = newFontName;
        subtitleOptions.fontSize = newFontSize;

        optionsNotifier.value = subtitleOptions;

        if (remember) {
          await appModel.setSubtitleOptions(subtitleOptions);
        }

        Navigator.pop(context);
      }
    } finally {}
  }

  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(),
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
                    ),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .unselectedWidgetColor
                                  .withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).focusColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText:
                            appModel.translate('player_option_subtitle_delay'),
                        suffixIcon: IconButton(
                          iconSize: 18,
                          color: appModel.getIsDarkMode()
                              ? Colors.white
                              : Colors.black,
                          onPressed: () async {
                            delayController.text = '0';
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.undo),
                        ),
                        suffixText: ' ms'),
                  ),
                  TextField(
                    controller: allowanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .unselectedWidgetColor
                                  .withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).focusColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText:
                            appModel.translate('player_option_audio_allowance'),
                        suffixIcon: IconButton(
                          iconSize: 18,
                          color: appModel.getIsDarkMode()
                              ? Colors.white
                              : Colors.black,
                          onPressed: () async {
                            allowanceController.text = '0';
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.undo),
                        ),
                        suffixText: ' ms'),
                  ),
                  TextField(
                    controller: fontNameController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).focusColor),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: appModel.translate('player_option_font_name'),
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18,
                            color: appModel.getIsDarkMode()
                                ? Colors.white
                                : Colors.black,
                            onPressed: () async {
                              Language language = appModel.getCurrentLanguage();

                              if (language is JapaneseLanguage) {
                                launch(
                                    'https://fonts.google.com/?subset=japanese');
                              } else if (language
                                  is ChineseSimplifiedLanguage) {
                                launch(
                                    'https://fonts.google.com/?subset=chinese-simplified');
                              } else if (language
                                  is ChineseTraditionalLanguage) {
                                launch(
                                    'https://fonts.google.com/?subset=chinese-traditional');
                              } else if (language is KoreanLanguage) {
                                launch(
                                    'https://fonts.google.com/?subset=korean');
                              } else {
                                launch('https://fonts.google.com/');
                              }
                            },
                            icon: const Icon(Icons.font_download),
                          ),
                          IconButton(
                            iconSize: 18,
                            color: appModel.getIsDarkMode()
                                ? Colors.white
                                : Colors.black,
                            onPressed: () async {
                              fontNameController.text = 'Roboto';
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(Icons.undo),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: fontSizeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .unselectedWidgetColor
                                  .withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).focusColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText:
                            appModel.translate('player_option_font_size'),
                        suffixIcon: IconButton(
                          iconSize: 18,
                          color: appModel.getIsDarkMode()
                              ? Colors.white
                              : Colors.black,
                          onPressed: () async {
                            fontSizeController.text = '24.0';
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.undo),
                        ),
                        suffixText: ' px'),
                  ),
                  TextField(
                    controller: regexFilterController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).focusColor),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText:
                          appModel.translate('player_option_regex_filter'),
                      suffixIcon: IconButton(
                        iconSize: 18,
                        color: appModel.getIsDarkMode()
                            ? Colors.white
                            : Colors.black,
                        onPressed: () async {
                          regexFilterController.clear();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.undo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate('dialog_close'),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                appModel.translate('dialog_set_remember'),
              ),
              onPressed: () {
                setValues(true);
              },
            ),
            TextButton(
              child: Text(
                appModel.translate('dialog_set'),
              ),
              onPressed: () {
                setValues(false);
              },
            ),
          ],
        );
      });
}
