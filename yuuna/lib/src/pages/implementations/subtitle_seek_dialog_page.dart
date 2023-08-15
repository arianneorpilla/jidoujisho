import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:subtitle/subtitle.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

/// The content of the dialog when editing [SubtitleOptions].
class SubtitleSeekDialogPage extends BasePage {
  /// Create an instance of this page.
  const SubtitleSeekDialogPage({
    required this.playerController,
    required this.subtitleOptionsNotifier,
    required this.positionNotifier,
    required this.durationNotifier,
    required this.endedNotifier,
    required this.currentSubtitle,
    required this.autoPauseNotifier,
    super.key,
  });

  /// Player controller for the volume control.
  final VlcPlayerController playerController;

  /// Notifier for the subtitle options.
  final ValueNotifier<SubtitleOptions> subtitleOptionsNotifier;

  /// Notifier for the current position of Video progress.
  final ValueNotifier<Duration> positionNotifier;

  /// Notifier for the duration of Video progress.
  final ValueNotifier<Duration> durationNotifier;

  /// Notifier to check the video is finished.
  final ValueNotifier<bool> endedNotifier;

  /// Notifier for current subtitle of Video.
  final ValueNotifier<Subtitle?> currentSubtitle;

  /// Notifier for auto pause of Video.
  final ValueNotifier<Subtitle?> autoPauseNotifier;

  @override
  BasePageState createState() => _PlayerVolumeBrightnessControlPage();
}

class _PlayerVolumeBrightnessControlPage
    extends BasePageState<SubtitleSeekDialogPage> {
  late VlcPlayerController _playerController;
  late SubtitleOptions _subtitleOptions;
  late ValueNotifier<Duration> _positionNotifier;
  late ValueNotifier<Duration> _durationNotifier;
  late ValueNotifier<bool> _endedNotifier;
  late ValueNotifier<Subtitle?> _currentSubtitle;
  late ValueNotifier<Subtitle?> _autoPauseNotifier;

  @override
  void initState() {
    super.initState();
    _playerController = widget.playerController;
    _subtitleOptions = widget.subtitleOptionsNotifier.value;
    _positionNotifier = widget.positionNotifier;
    _durationNotifier = widget.durationNotifier;
    _endedNotifier = widget.endedNotifier;
    _currentSubtitle = widget.currentSubtitle;
    _autoPauseNotifier = widget.autoPauseNotifier;
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
      // actions: actions,
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
            width: MediaQuery.of(context).size.width * (2 / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<Subtitle?>(
                  valueListenable: _currentSubtitle,
                  builder: (context, value, _) {
                    return Padding(
                      padding: Spacing.of(context).insets.all.normal,
                      child: Text(
                        value?.data ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _subtitleOptions.fontName,
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                ),
                const Space.normal(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.swipe_left,
                        tooltip: t.seek_control,
                        onTap: () async {
                          Duration duration = _durationNotifier.value;
                          Duration position = _positionNotifier.value;
                          bool isEnded = _endedNotifier.value;
                          bool validPosition =
                              duration.compareTo(position) >= 0;
                          double sliderValue =
                              validPosition ? position.inSeconds.toDouble() : 0;
                          if (isEnded) {
                            sliderValue = 1;
                          }
                          if (validPosition) {
                            _playerController
                                .setTime((sliderValue.toInt() - 5) * 1000);
                            _autoPauseNotifier.value = null;
                          }
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.swipe_right,
                        tooltip: t.seek_control,
                        onTap: () async {
                          Duration duration = _durationNotifier.value;
                          Duration position = _positionNotifier.value;
                          bool isEnded = _endedNotifier.value;
                          bool validPosition =
                              duration.compareTo(position) >= 0;
                          double sliderValue =
                              validPosition ? position.inSeconds.toDouble() : 0;
                          if (isEnded) {
                            sliderValue = 1;
                          }
                          if (validPosition) {
                            _playerController
                                .setTime((sliderValue.toInt() + 5) * 1000);
                            _autoPauseNotifier.value = null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setValues({required bool saveOptions}) async {
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
