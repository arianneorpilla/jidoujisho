import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/utils/misc/jidoujisho_time_format.dart';

/// The content of the dialog used for selecting segmented units of a source
/// text.
class AudioRecorderDialogPage extends BasePage {
  /// Create an instance of this page.
  const AudioRecorderDialogPage({
    required this.filePath,
    required this.onSave,
    super.key,
  });

  /// Path to save audio file to.
  final String filePath;

  /// The callback to be called when a new audio file has been recorded.
  final Function(File) onSave;

  @override
  BasePageState createState() => _AudioRecorderDialogPageState();
}

class _AudioRecorderDialogPageState
    extends BasePageState<AudioRecorderDialogPage> {
  final ScrollController _scrollController = ScrollController();

  File? _audioFile;

  bool _isRecording = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.small,
      content: buildContent(),
      actions: [
        if (_isRecording) buildStopButton() else buildRecordButton(),
        buildSaveButton(),
      ],
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: _scrollController,
        child: _audioFile == null || _isRecording
            ? buildDisabledPlayer()
            : buildAudioPlayer(),
      ),
    );
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  final ValueNotifier<Duration> _positionNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration?> _durationNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<PlayerState?> _playerStateNotifier =
      ValueNotifier<PlayerState?>(null);

  /// Build the audio player.
  Widget buildAudioPlayer() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          buildPlayButton(),
          buildDurationAndPosition(),
          Expanded(
            child: buildSlider(),
          ),
        ],
      ),
    );
  }

  /// Build the play/pause button
  Widget buildPlayButton() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _playerStateNotifier,
      ],
      builder: (context, values, _) {
        PlayerState? playerState = values.elementAt(0);

        IconData iconData = Icons.play_arrow;

        if (playerState == null ||
            playerState.processingState == ProcessingState.completed) {
          iconData = Icons.play_arrow;
        } else if (playerState.playing) {
          iconData = Icons.pause;
        } else {
          iconData = Icons.play_arrow;
        }

        return IconButton(
          icon: Icon(iconData, size: 24),
          onPressed: () async {
            final AudioSession session = await AudioSession.instance;
            await session.configure(
              const AudioSessionConfiguration(
                avAudioSessionCategory: AVAudioSessionCategory.playback,
                avAudioSessionCategoryOptions:
                    AVAudioSessionCategoryOptions.duckOthers,
                avAudioSessionMode: AVAudioSessionMode.defaultMode,
                avAudioSessionRouteSharingPolicy:
                    AVAudioSessionRouteSharingPolicy.defaultPolicy,
                avAudioSessionSetActiveOptions:
                    AVAudioSessionSetActiveOptions.none,
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
              await _audioPlayer.pause();
              session.setActive(false);
            });

            if (playerState == null ||
                playerState.processingState == ProcessingState.completed) {
              await _audioPlayer.seek(Duration.zero);

              session.setActive(true);
              await _audioPlayer.play();
              session.setActive(false);
            } else if (playerState.playing) {
              await _audioPlayer.pause();
              session.setActive(false);
            } else {
              session.setActive(true);
              await _audioPlayer.play();
              session.setActive(false);
            }
          },
        );
      },
    );
  }

  /// Build the player duration label.
  Widget buildDurationAndPosition() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _durationNotifier,
        _positionNotifier,
        _playerStateNotifier,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        PlayerState? playerState = values.elementAt(2);

        if (duration == Duration.zero) {
          return const SizedBox.shrink();
        }

        String getPositionText() {
          if (playerState == null ||
              playerState.processingState == ProcessingState.completed) {
            position = Duration.zero;
          }

          return JidoujishoTimeFormat.getVideoDurationText(position).trim();
        }

        String getDurationText() {
          return JidoujishoTimeFormat.getVideoDurationText(duration).trim();
        }

        return Text(
          '${getPositionText()} / ${getDurationText()}',
        );
      },
    );
  }

  /// Build the duration slider.
  Widget buildSlider() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _durationNotifier,
        _positionNotifier,
        _playerStateNotifier,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        PlayerState? playerState = values.elementAt(2);

        double sliderValue = position.inMilliseconds.toDouble();

        if (playerState == null ||
            playerState.processingState == ProcessingState.completed) {
          sliderValue = 0;
        }

        return Expanded(
          child: Slider(
              value: sliderValue,
              max: (playerState == null ||
                      playerState.processingState == ProcessingState.completed)
                  ? 1.0
                  : duration.inMilliseconds.toDouble(),
              onChanged: (progress) {
                if (playerState == null ||
                    playerState.processingState == ProcessingState.completed) {
                  sliderValue = progress.floor().toDouble();
                  _audioPlayer.seek(Duration(
                    milliseconds: sliderValue.toInt(),
                  ));
                } else {
                  sliderValue = progress.floor().toDouble();
                  _audioPlayer
                      .seek(Duration(milliseconds: sliderValue.toInt()));
                }
              }),
        );
      },
    );
  }

  /// Set up audio for new file.
  Future<void> initialiseAudio(File file) async {
    await _audioPlayer.setFilePath(file.path);
    await _audioPlayer.pause();
    _positionNotifier.value = _audioPlayer.position;
    _durationNotifier.value = _audioPlayer.duration ?? Duration.zero;

    if (!_initialised) {
      _audioPlayer.durationStream.listen((duration) {
        _durationNotifier.value = duration;
      });
      _audioPlayer.positionStream.listen((position) {
        _positionNotifier.value = position;
      });
      _audioPlayer.playerStateStream.listen((playerState) {
        _playerStateNotifier.value = playerState;
      });
      _initialised = true;
    }
  }

  /// Buiid the audio player.
  Widget buildDisabledPlayer() {
    return SizedBox(
      height: 48,
      child: IgnorePointer(
        child: Row(
          children: [
            if (_isRecording)
              Container(
                height: 48,
                width: 48,
                padding: const EdgeInsets.all(16),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                ),
              )
            else
              Opacity(
                opacity: 0.5,
                child: IconButton(
                  icon: Icon(
                    Icons.play_arrow_outlined,
                    size: 24,
                    color: theme.unselectedWidgetColor,
                  ),
                  onPressed: null,
                ),
              ),
            const Opacity(
              opacity: 0.5,
              child: Text(
                '--:-- / --:--',
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: 0.5,
                child: Slider(
                  value: 0,
                  thumbColor: Theme.of(context).unselectedWidgetColor,
                  onChanged: (value) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStopButton() {
    return TextButton(
      child: Text(
        t.dialog_stop,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        RecordMp3.instance.stop();
        _audioFile = File(widget.filePath);

        initialiseAudio(_audioFile!);
        setState(() {
          _isRecording = false;
        });
      },
    );
  }

  Widget buildRecordButton() {
    return TextButton(
      child: Text(t.dialog_record),
      onPressed: () async {
        await _audioPlayer.stop();
        setState(() {
          _isRecording = true;
        });
        RecordMp3.instance.start(widget.filePath, (error) {
          setState(() {
            _isRecording = false;
          });
        });
      },
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(t.dialog_save),
    );
  }

  void executeSave() {
    if (_audioFile == null) {
      Fluttertoast.showToast(msg: t.no_audio_file);
      return;
    }

    widget.onSave(_audioFile!);
    Navigator.pop(context);
  }
}
