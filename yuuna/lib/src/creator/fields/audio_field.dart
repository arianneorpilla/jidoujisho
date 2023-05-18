import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// Returns audio information from context.
class AudioField extends AudioExportField {
  /// Initialise this field with the predetermined and hardset values.
  AudioField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Term Audio',
          description: 'Audio pertaining to the term. Text field can be used'
              ' to enter search terms for audio sources.',
          icon: Icons.audiotrack,
        );

  /// Get the singleton instance of this field.
  static AudioField get instance => _instance;

  static final AudioField _instance = AudioField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'audio';

  final AudioPlayer _audioPlayer = AudioPlayer();

  final ValueNotifier<Duration> _positionNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration?> _durationNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<PlayerState?> _playerStateNotifier =
      ValueNotifier<PlayerState?>(null);

  /// Buiid the audio player.
  Widget buildAudioPlayer() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          buildPlayButton(),
          buildDurationAndPosition(),
          buildSlider(),
        ],
      ),
    );
  }

  /// Buiid the audio player.
  Widget buildDisabledPlayer(BuildContext context) {
    return SizedBox(
      height: 48,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.5,
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).unselectedWidgetColor),
                ),
              ),
              const Text(
                '--:-- / --:--',
              ),
              Expanded(
                child: Slider(
                  value: 0,
                  thumbColor: Theme.of(context).unselectedWidgetColor,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void setAudioFile({
    required AppModel appModel,
    required CreatorModel creatorModel,
    required File file,
    String? searchTermUsed,
  }) {
    initialiseAudio(file);
    super.setAudioFile(
      appModel: appModel,
      creatorModel: creatorModel,
      file: file,
    );
  }

  bool _initialised = false;

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

  /// Clears this field's data. The state refresh afterwards is not performed
  /// here and should be performed by the invocation of the clear field button.
  @override
  void clearFieldState({
    required CreatorModel creatorModel,
  }) {
    _audioPlayer.stop();
    super.clearFieldState(creatorModel: creatorModel);
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

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    return null;
  }

  @override
  Widget buildTopWidget({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required Orientation orientation,
  }) {
    if (isSearching) {
      return buildDisabledPlayer(context);
    }

    if (!showWidget) {
      if (orientation == Orientation.landscape) {
        return const SizedBox(height: 24);
      } else {
        return const SizedBox.shrink();
      }
    }

    return buildAudioPlayer();
  }

  // Executed on close of the creator screen.
  @override
  void onCreatorClose() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }
}
