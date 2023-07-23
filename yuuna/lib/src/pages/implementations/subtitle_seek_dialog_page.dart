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
    required this.subtitleItem,
    required this.positionNotifier,
    required this.currentSubtitle,
    super.key,
  });

  /// Player controller for the volume control.
  final VlcPlayerController playerController;

  /// Notifier for the subtitle options.
  final ValueNotifier<SubtitleOptions> subtitleOptionsNotifier;

  /// Subtitle Item for current Video
  final SubtitleItem subtitleItem;

  /// Notifier for the current position of Video progress.
  final ValueNotifier<Duration> positionNotifier;

  /// Notifier for current subtitle of Video.
  final ValueNotifier<Subtitle?> currentSubtitle;

  @override
  BasePageState createState() => _PlayerVolumeBrightnessControlPage();
}

class _PlayerVolumeBrightnessControlPage
    extends BasePageState<SubtitleSeekDialogPage> {
  late VlcPlayerController _playerController;
  late SubtitleOptions _subtitleOptions;
  late SubtitleItem _subtitleItem;
  late ValueNotifier<Duration> _positionNotifier;
  late ValueNotifier<Subtitle?> _currentSubtitle;

  @override
  void initState() {
    super.initState();
    _playerController = widget.playerController;
    _subtitleOptions = widget.subtitleOptionsNotifier.value;
    _subtitleItem = widget.subtitleItem;
    _positionNotifier = widget.positionNotifier;
    _currentSubtitle = widget.currentSubtitle;
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
                        tooltip: t.prev_subtitle,
                        onTap: () async {
                          int prevIdx = _subtitleItem.controller.subtitles
                              .lastIndexWhere((element) =>
                                  _positionNotifier.value >
                                  (element.start +
                                      Duration(
                                          milliseconds:
                                              _subtitleOptions.subtitleDelay)));
                          if (prevIdx != -1) {
                            _playerController.seekTo(_subtitleItem
                                    .controller.subtitles[prevIdx].start -
                                Duration(
                                    milliseconds:
                                        _subtitleOptions.subtitleDelay));
                          }
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: JidoujishoIconButton(
                        size: 24,
                        icon: Icons.swipe_right,
                        tooltip: t.next_subtitle,
                        onTap: () async {
                          int nextIdx = _subtitleItem.controller.subtitles
                              .indexWhere((element) =>
                                  _positionNotifier.value <
                                  (element.start -
                                      Duration(
                                          milliseconds:
                                              _subtitleOptions.subtitleDelay)));
                          if (nextIdx != -1) {
                            _playerController.seekTo(_subtitleItem
                                    .controller.subtitles[nextIdx].start -
                                Duration(
                                    milliseconds:
                                        _subtitleOptions.subtitleDelay));
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
