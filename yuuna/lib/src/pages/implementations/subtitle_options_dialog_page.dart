import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spaces/spaces.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing [SubtitleOptions].
class SubtitleOptionsDialogPage extends BasePage {
  /// Create an instance of this page.
  const SubtitleOptionsDialogPage({
    required this.notifier,
    super.key,
  });

  /// Notifier for the subtitle options.
  final ValueNotifier<SubtitleOptions> notifier;

  @override
  BasePageState createState() => _SubtitleOptionsDialogPage();
}

class _SubtitleOptionsDialogPage
    extends BasePageState<SubtitleOptionsDialogPage> {
  String get playerOptionSubtitleDelay =>
      appModel.translate('player_option_subtitle_delay');
  String get playerOptionAudioAllowance =>
      appModel.translate('player_option_audio_allowance');
  String get playerOptionFontName =>
      appModel.translate('player_option_font_name');
  String get playerOptionFontSize =>
      appModel.translate('player_option_font_size');
  String get playerOptionRegexFilter =>
      appModel.translate('player_option_regex_filter');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get dialogSaveLabel => appModel.translate('dialog_save');
  String get dialogSetLabel => appModel.translate('dialog_set');
  String get resetLabel => appModel.translate('reset');

  late SubtitleOptions _options;

  late final TextEditingController _allowanceController;
  late final TextEditingController _delayController;
  late final TextEditingController _fontSizeController;
  late final TextEditingController _fontNameController;
  late final TextEditingController _regexFilterController;

  @override
  void initState() {
    super.initState();
    _options = widget.notifier.value;

    _allowanceController =
        TextEditingController(text: _options.audioAllowance.toString());
    _delayController =
        TextEditingController(text: _options.subtitleDelay.toString());
    _fontSizeController =
        TextEditingController(text: _options.fontSize.toString());
    _fontNameController = TextEditingController(text: _options.fontName.trim());
    _regexFilterController =
        TextEditingController(text: _options.regexFilter.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.big,
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _delayController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
              ),
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: playerOptionSubtitleDelay,
                  suffixIcon: JidoujishoIconButton(
                    size: 18,
                    tooltip: resetLabel,
                    onTap: () async {
                      _delayController.text = '0';
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icons.undo,
                  ),
                  suffixText: ' ms'),
            ),
            TextField(
              controller: _allowanceController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
              ),
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: playerOptionAudioAllowance,
                  suffixIcon: JidoujishoIconButton(
                    size: 18,
                    tooltip: resetLabel,
                    onTap: () async {
                      _allowanceController.text = '0';
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icons.undo,
                  ),
                  suffixText: 'ms'),
            ),
            TextField(
              controller: _fontNameController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: playerOptionFontName,
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    JidoujishoIconButton(
                      size: 18,
                      tooltip: resetLabel,
                      onTap: () async {
                        if (appModel.targetLanguage is JapaneseLanguage) {
                          launchUrlString(
                              'https://fonts.google.com/?subset=japanese');
                        }
                        launchUrlString('https://fonts.google.com/');
                      },
                      icon: Icons.font_download,
                    ),
                    JidoujishoIconButton(
                      size: 18,
                      tooltip: resetLabel,
                      onTap: () async {
                        _fontNameController.text = '';
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _fontSizeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: playerOptionFontSize,
                suffixIcon: JidoujishoIconButton(
                  size: 18,
                  tooltip: resetLabel,
                  onTap: () async {
                    _fontSizeController.text = '24.0';
                    FocusScope.of(context).unfocus();
                  },
                  icon: Icons.undo,
                ),
                suffixText: 'px',
              ),
            ),
            TextField(
              controller: _regexFilterController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: playerOptionRegexFilter,
                suffixIcon: JidoujishoIconButton(
                  size: 18,
                  tooltip: resetLabel,
                  onTap: () async {
                    _regexFilterController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: Icons.undo,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> setValues({required bool saveOptions}) async {
    String allowanceText = _allowanceController.text;
    int? newAllowance = int.tryParse(allowanceText);

    String delayText = _delayController.text;
    int? newDelay = int.tryParse(delayText);

    String fontSizeText = _fontSizeController.text;
    double? newFontSize = double.tryParse(fontSizeText);

    String newFontName = _fontNameController.text.trim();
    String newRegexFilter = _regexFilterController.text.trim();

    if (newDelay != null && newAllowance != null && newFontSize != null) {
      RegExp(newRegexFilter);
      try {
        GoogleFonts.getFont(newFontName);
      } catch (e) {
        newFontName = '';
      }

      SubtitleOptions subtitleOptions = appModel.subtitleOptions;

      subtitleOptions.subtitleDelay = newDelay;
      subtitleOptions.audioAllowance = newAllowance;
      subtitleOptions.regexFilter = newRegexFilter;
      subtitleOptions.fontName = newFontName;
      subtitleOptions.fontSize = newFontSize;

      widget.notifier.value = subtitleOptions;

      if (saveOptions) {
        appModel.setSubtitleOptions(subtitleOptions);
      }

      Navigator.pop(context);
    }
  }

  List<Widget> get actions => [
        buildCancelButton(),
        buildSaveButton(),
        buildSetButton(),
      ];

  Widget buildCancelButton() {
    return TextButton(
      child: Text(
        dialogCancelLabel,
      ),
      onPressed: executeCancel,
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      child: Text(
        dialogSaveLabel,
      ),
      onPressed: executeSave,
    );
  }

  Widget buildSetButton() {
    return TextButton(
      child: Text(
        dialogSetLabel,
      ),
      onPressed: executeSet,
    );
  }

  void executeCancel() async {
    Navigator.pop(context);
  }

  void executeSave() async {
    await setValues(saveOptions: true);
  }

  void executeSet() async {
    await setValues(saveOptions: false);
  }
}
