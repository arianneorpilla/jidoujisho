import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// The content of the dialog when editing [SubtitleOptions].
class PlayerVolumeBrightnessControlPage extends BasePage {
  /// Create an instance of this page.
  const PlayerVolumeBrightnessControlPage({
    required this.notifier,
    required this.playerController,
    super.key,
  });

  /// Notifier for the subtitle options.
  final ValueNotifier<PlayerBasicOptions> notifier;

  /// Player controller for the volume control.
  final VlcPlayerController playerController;

  @override
  BasePageState createState() => _PlayerVolumeBrightnessControlPage();
}

class _PlayerVolumeBrightnessControlPage
    extends BasePageState<PlayerVolumeBrightnessControlPage> {
  late PlayerBasicOptions _options;
  late VlcPlayerController playerController;
  final ValueNotifier<int> _volume = ValueNotifier<int>(60);
  final ValueNotifier<double> _brightness = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    _options = widget.notifier.value;
    _volume.value = _options.volume;
    _brightness.value = _options.brightness;
    ScreenBrightness().setScreenBrightness(_options.brightness);
    playerController = widget.playerController;
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
      thumbVisibility: false,
      controller: scrollController,
      child: Padding(
        padding: Spacing.of(context).insets.onlyRight.normal,
        child: SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * (1 / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.volume_down,
                        tooltip: t.player_option_volume_down,
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _volume,
                        builder: (context, value, _) {
                          return Slider(
                            activeColor: Colors.red,
                            max: 100,
                            inactiveColor:
                                Theme.of(context).unselectedWidgetColor,
                            value: value.toDouble(),
                            onChanged: (value) {
                              playerController.setVolume(value.toInt());
                              _volume.value = value.toInt();
                            },
                          );
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.volume_up,
                        tooltip: t.player_option_volume_up,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.brightness_2,
                        tooltip: t.player_option_brightness_down,
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<double>(
                        valueListenable: _brightness,
                        builder: (context, value, _) {
                          return Slider(
                            activeColor: Colors.red,
                            inactiveColor:
                                Theme.of(context).unselectedWidgetColor,
                            value: value,
                            onChanged: (value) {
                              _brightness.value = value;
                              ScreenBrightness().setScreenBrightness(value);
                            },
                          );
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.brightness_7,
                        tooltip: t.player_option_brightness_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setValues({required bool saveOptions}) async {
    PlayerBasicOptions playerBasicOptions = appModel.playerBasicOptions;

    playerBasicOptions.keepShown = _options.keepShown;
    playerBasicOptions.volume = _volume.value;
    playerBasicOptions.brightness = _brightness.value;

    widget.notifier.value = playerBasicOptions;

    if (saveOptions) {
      appModel.setPlayerBasicOptions(playerBasicOptions);
    }
    Navigator.pop(context);
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
