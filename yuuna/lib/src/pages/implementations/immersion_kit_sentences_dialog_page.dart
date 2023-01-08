import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for selecting example sentences.
class ImmersionKitSentencesDialogPage extends BasePage {
  /// Create an instance of this page.
  const ImmersionKitSentencesDialogPage({
    required this.exampleSentences,
    required this.onSelect,
    super.key,
  });

  /// The example sentences to be shown in the dialog.
  final List<ImmersionKitResult> exampleSentences;

  /// The callback to be called when an example sentence has been picked.
  final Function(ImmersionKitResult) onSelect;

  @override
  BasePageState createState() => _ImmersionKitSentencesDialogPageState();
}

class _ImmersionKitSentencesDialogPageState
    extends BasePageState<ImmersionKitSentencesDialogPage> {
  final ScrollController _scrollController = ScrollController();

  String get dialogSelectLabel => appModel.translate('dialog_select');
  String get dialogStashLabel => appModel.translate('dialog_stash');
  String get noSentencesFound => appModel.translate('no_sentences_found');

  int _selectedIndex = 0;
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
    if (widget.exampleSentences.isEmpty) {
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

    await _audioPlayer.stop();
    await _audioPlayer.setUrl(widget.exampleSentences[_selectedIndex].audioUrl);
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
      actions: widget.exampleSentences.isEmpty ? null : actions,
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: widget.exampleSentences.isEmpty
            ? SingleChildScrollView(
                controller: _scrollController, child: buildEmptyMessage())
            : buildTextWidgets(),
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
        message: noSentencesFound,
      ),
    );
  }

  Widget buildTextWidgets() {
    return ListView.builder(
      itemCount: widget.exampleSentences.length,
      itemBuilder: (context, index) {
        ImmersionKitResult result = widget.exampleSentences[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            playCurrentAudio();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Spacing.of(context).spaces.small,
              horizontal: Spacing.of(context).spaces.semiSmall,
            ),
            margin: EdgeInsets.only(
              top: Spacing.of(context).spaces.normal,
              right: Spacing.of(context).spaces.normal,
            ),
            color: _selectedIndex == index
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.unselectedWidgetColor.withOpacity(0.1),
            child: buildTextWidget(result),
          ),
        );
      },
    );
  }

  Widget buildTextWidget(ImmersionKitResult result) {
    List<InlineSpan> spans = [];
    result.wordList.forEachIndexed((index, word) {
      if (result.wordIndices.contains(index)) {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.grey.shade900.withOpacity(0.3),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              imageErrorBuilder: (_, __, ___) => const SizedBox.shrink(),
              image: CachedNetworkImageProvider(result.imageUrl),
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        const Space.small(),
        Text.rich(
          TextSpan(children: spans),
        ),
        Text(
          result.source,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
      ],
    );
  }

  List<Widget> get actions => [
        buildStashButton(),
        buildSelectButton(),
      ];

  Widget buildStashButton() {
    return TextButton(
      child: Text(dialogStashLabel),
      onPressed: executeStash,
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      child: Text(dialogSelectLabel),
      onPressed: executeSelect,
    );
  }

  ImmersionKitResult get selection {
    return widget.exampleSentences[_selectedIndex];
  }

  void executeStash() {
    appModel.addToStash(terms: [selection.text]);
  }

  void executeSelect() {
    Navigator.pop(context);
    widget.onSelect(selection);
  }
}
