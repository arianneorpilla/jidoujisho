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
  late SubtitleOptions _options;

  late final TextEditingController _allowanceController;
  late final TextEditingController _delayController;
  late final TextEditingController _fontSizeController;
  late final TextEditingController _fontNameController;
  late final TextEditingController _regexFilterController;
  late final TextEditingController _opacityController;
  late final TextEditingController _widthController;
  late final TextEditingController _blurController;

  late ValueNotifier<bool> _aboveBottomBarNotifier;

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
    _opacityController = TextEditingController(
        text: _options.subtitleBackgroundOpacity.toString());
    _widthController =
        TextEditingController(text: _options.subtitleOutlineWidth.toString());
    _blurController = TextEditingController(
        text: _options.subtitleBackgroundBlurRadius.toString());
    _aboveBottomBarNotifier =
        ValueNotifier<bool>(_options.alwaysAboveBottomBar);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildContent() {
    ScrollController scrollController = ScrollController();
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: scrollController,
      child: Padding(
        padding: Spacing.of(context).insets.onlyRight.normal,
        child: SingleChildScrollView(
          controller: scrollController,
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
                      labelText: t.player_option_subtitle_delay,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Space.normal(),
                          JidoujishoIconButton(
                            size: 18,
                            tooltip: t.decrease,
                            onTap: () async {
                              _delayController.text =
                                  ((int.tryParse(_delayController.text) ??
                                              _options.subtitleDelay) -
                                          100)
                                      .toString();
                              FocusScope.of(context).unfocus();
                            },
                            icon: Icons.remove,
                          ),
                          JidoujishoIconButton(
                            size: 18,
                            tooltip: t.increase,
                            onTap: () async {
                              _delayController.text =
                                  ((int.tryParse(_delayController.text) ??
                                              _options.subtitleDelay) +
                                          100)
                                      .toString();
                              FocusScope.of(context).unfocus();
                            },
                            icon: Icons.add,
                          ),
                          JidoujishoIconButton(
                            size: 18,
                            tooltip: t.reset,
                            onTap: () async {
                              _delayController.text = '0';
                              FocusScope.of(context).unfocus();
                            },
                            icon: Icons.undo,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      suffixText: t.unit_milliseconds),
                ),
                TextField(
                  controller: _allowanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_audio_allowance,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Space.normal(),
                        JidoujishoIconButton(
                          size: 18,
                          tooltip: t.decrease,
                          onTap: () async {
                            _allowanceController.text =
                                ((int.tryParse(_allowanceController.text) ??
                                            _options.audioAllowance) -
                                        100)
                                    .toString();
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icons.remove,
                        ),
                        JidoujishoIconButton(
                          size: 18,
                          tooltip: t.increase,
                          onTap: () async {
                            _allowanceController.text =
                                ((int.tryParse(_allowanceController.text) ??
                                            _options.audioAllowance) +
                                        100)
                                    .toString();
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icons.add,
                        ),
                        JidoujishoIconButton(
                          size: 18,
                          tooltip: t.reset,
                          onTap: () async {
                            _allowanceController.text = '0';
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icons.undo,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    suffixText: t.unit_milliseconds,
                  ),
                ),
                TextField(
                  controller: _fontSizeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_font_size,
                    suffixIcon: JidoujishoIconButton(
                      size: 18,
                      tooltip: t.reset,
                      onTap: () async {
                        _fontSizeController.text = '20.0';
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                    suffixText: t.unit_pixels,
                  ),
                ),
                TextField(
                  controller: _widthController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_outline_width,
                    suffixText: t.unit_pixels,
                    suffixIcon: JidoujishoIconButton(
                      size: 18,
                      tooltip: t.reset,
                      onTap: () async {
                        _widthController.text = '3.0';
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                  ),
                ),
                TextField(
                  controller: _blurController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_subtitle_background_blur_radius,
                    suffixText: t.unit_pixels,
                    suffixIcon: JidoujishoIconButton(
                      size: 18,
                      tooltip: t.reset,
                      onTap: () async {
                        _blurController.text = '0.0';
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                  ),
                ),
                TextField(
                  controller: _opacityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_subtitle_background_opacity,
                    suffixIcon: JidoujishoIconButton(
                      size: 18,
                      tooltip: t.reset,
                      onTap: () async {
                        _opacityController.text = '0.0';
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                  ),
                ),
                TextField(
                  controller: _fontNameController,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_font_name,
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        JidoujishoIconButton(
                          size: 18,
                          tooltip: t.google_fonts,
                          onTap: () async {
                            /// Language Customizable
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
                          tooltip: t.reset,
                          onTap: () async {
                            _fontNameController.text = '';
                            FocusScope.of(context).unfocus();
                          },
                          icon: Icons.undo,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: _regexFilterController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.player_option_regex_filter,
                    suffixIcon: JidoujishoIconButton(
                      size: 18,
                      tooltip: t.reset,
                      onTap: () async {
                        _regexFilterController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icons.undo,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                buildAlwaysAboveBottomBar(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAlwaysAboveBottomBar() {
    return Row(
      children: [
        Expanded(child: Text(t.player_option_subtitle_always_above_bottom_bar)),
        ValueListenableBuilder<bool>(
          valueListenable: _aboveBottomBarNotifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                _aboveBottomBarNotifier.value = value;
              },
            );
          },
        )
      ],
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

    String opacityText = _opacityController.text;
    double? newOpacity = double.tryParse(opacityText);

    String widthText = _widthController.text;
    double? newWidth = double.tryParse(widthText);

    String blurText = _blurController.text;
    double? newBlur = double.tryParse(blurText);

    bool newAlwaysAboveBottomBar = _aboveBottomBarNotifier.value;

    if (newDelay != null &&
        newAllowance != null &&
        newFontSize != null &&
        newOpacity != null &&
        newWidth != null &&
        newBlur != null &&
        (newOpacity <= 1 && newOpacity >= 0) &&
        newFontSize >= 0 &&
        newWidth >= 0 &&
        newBlur >= 0) {
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
      subtitleOptions.subtitleBackgroundOpacity = newOpacity;
      subtitleOptions.subtitleOutlineWidth = newWidth;
      subtitleOptions.subtitleBackgroundBlurRadius = newBlur;
      subtitleOptions.alwaysAboveBottomBar = newAlwaysAboveBottomBar;

      widget.notifier.value = subtitleOptions;

      if (saveOptions) {
        appModel.setSubtitleOptions(subtitleOptions);
      }

      Navigator.pop(context);
    }
  }

  List<Widget> get actions => [
        buildSaveButton(),
        buildSetButton(),
      ];

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(
        t.dialog_save,
      ),
    );
  }

  Widget buildSetButton() {
    return TextButton(
      onPressed: executeSet,
      child: Text(
        t.dialog_set,
      ),
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
