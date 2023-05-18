import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for picking a specific contributor when
/// using the Forvo audio enhancement.
class ForvoAudioDialogPage extends BasePage {
  /// Create an instance of this page.
  const ForvoAudioDialogPage({
    required this.results,
    required this.onSelect,
    super.key,
  });

  /// List of recordings.
  final List<ForvoResult> results;

  /// The callback to be called when an example sentence has been picked.
  final Function(int) onSelect;

  @override
  BasePageState createState() => _ForvoAudioDialogPageState();
}

class _ForvoAudioDialogPageState extends BasePageState<ForvoAudioDialogPage> {
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<int> _notifier = ValueNotifier<int>(0);
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playCurrentAudio();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playCurrentAudio() async {
    if (widget.results.isEmpty) {
      return;
    }

    final AudioSession session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: true,
      ),
    );

    session.becomingNoisyEventStream.listen((event) async {
      await _audioPlayer.stop();
      session.setActive(false);
    });

    await _audioPlayer.stop();
    await _audioPlayer.setUrl(widget.results[_notifier.value].audioUrl);
    session.setActive(true);
    await _audioPlayer.play();
    session.setActive(false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
      actions: widget.results.isEmpty ? null : actions,
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: widget.results.isEmpty
              ? buildEmptyMessage()
              : Column(children: getTextWidgets()),
        ),
      ),
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: t.no_recordings_found,
      ),
    );
  }

  List<Widget> getTextWidgets() {
    List<Widget> widgets = [];

    widget.results.forEachIndexed((index, result) {
      Widget widget = GestureDetector(
        onTap: () {
          _notifier.value = index;
          playCurrentAudio();
        },
        child: ValueListenableBuilder<int>(
          valueListenable: _notifier,
          builder: (context, value, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.of(context).spaces.small,
                horizontal: Spacing.of(context).spaces.semiSmall,
              ),
              margin: EdgeInsets.only(
                top: Spacing.of(context).spaces.normal,
                right: Spacing.of(context).spaces.normal,
              ),
              color: _notifier.value == index
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.unselectedWidgetColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over),
                  const SizedBox(width: 10),
                  Text(
                    result.contributor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      widgets.add(widget);
    });

    return widgets;
  }

  List<Widget> get actions => [
        buildSelectButton(),
      ];

  Widget buildSelectButton() {
    return TextButton(
      onPressed: executeSelect,
      child: Text(t.dialog_select),
    );
  }

  void executeSelect() {
    Navigator.pop(context);
    widget.onSelect(_notifier.value);
  }
}
