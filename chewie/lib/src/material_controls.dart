import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/youtube.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls>
    with SingleTickerProviderStateMixin {
  VlcPlayerValue _latestValue;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VlcPlayerController controller;
  ChewieController chewieController;
  AnimationController playPauseIconAnimationController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : const Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Column(
            children: <Widget>[
              if (_latestValue != null && _latestValue.isBuffering ||
                  !_latestValue.isPlaying && _latestValue.duration == null)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                )
              else
                _buildHitArea(),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    playPauseIconAnimationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
        child: Row(
          children: <Widget>[
            _buildPlayPause(controller),
            if (chewieController.isLive)
              const Expanded(child: Text('LIVE'))
            else
              _buildPosition(iconColor),
            if (chewieController.isLive)
              const SizedBox()
            else
              _buildProgressBar(),
            // if (chewieController.allowPlaybackSpeedChanging)
            //   _buildSpeedButton(controller),
            if (controller.dataSourceType == DataSourceType.network)
              _buildQualityButton(controller),
            _buildToolsButton(controller),
            _buildMoreButton(controller),
            if (chewieController.allowFullScreen) _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    Widget getIcon() {
      if (_latestValue.isEnded) {
        return const Icon(Icons.replay, size: 32.0);
      } else {
        if (!_latestValue.isInitialized) {
          return const Icon(Icons.play_arrow, color: Colors.transparent);
        }

        return AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: playPauseIconAnimationController,
          size: 32.0,
        );
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else {
              _cancelAndRestartTimer();
            }
          } else {
            // _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: (_latestValue.isInitialized)
                        ? Theme.of(context).dialogBackgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                        icon: getIcon(),
                        onPressed: () {
                          _playPause();
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openExtraShare() async {
    final bool isYouTube = chewieController.streamData != null;

    final chosenOption = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _MoreOptionsDialog(
        const [
          "Search Current Subtitle with Jisho.org",
          "Translate Current Subtitle with DeepL",
          "Translate Current Subtitle with Google Translate",
          "Share Current Subtitle with Menu",
          "Share YouTube Video Link",
        ],
        const [
          Icons.menu_book_rounded,
          Icons.translate_rounded,
          Icons.g_translate_rounded,
          Icons.share_outlined,
          Icons.link_sharp,
        ],
        const [],
        count: isYouTube ? 5 : 4,
      ),
    );

    final String subtitleText = chewieController.currentSubtitle.value.text;

    switch (chosenOption) {
      case 0:
        await launch("https://jisho.org/search/$subtitleText");
        break;
      case 1:
        await launch("https://www.deepl.com/translator#ja/en/$subtitleText");
        break;
      case 2:
        await launch(
            "https://translate.google.com/?sl=ja&tl=en&text=$subtitleText&op=translate");
        break;
      case 3:
        Share.share(subtitleText);
        break;
      case 4:
        Share.share(chewieController.streamData.videoURL);
        break;
    }
  }

  Widget _buildMoreButton(VlcPlayerController controller) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        List<int> highlightedIndexes = [];
        if (chewieController.shadowingSubtitle.value != null) {
          highlightedIndexes.add(0);
        }
        if (getFocusMode()) {
          highlightedIndexes.add(1);
        }
        if (getListeningComprehensionMode()) {
          highlightedIndexes.add(2);
        }

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _MoreOptionsDialog(
            [
              "Shadowing Mode",
              "Definition Focus Mode",
              "Listening Comprehension Mode",
              if (getSelectMode())
                "Use Tap to Select Subtitle Selection"
              else
                "Use Drag to Select Subtitle Selection",
              if (getMonolingualMode())
                "Use Bilingual Definitions from Jisho.org"
              else
                "Use Monolingual Definitions from Goo.ne.jp",
              "Share Links to Applications",
              "Export Current Context to Anki",
            ],
            [
              Icons.loop_sharp,
              if (getFocusMode())
                Icons.lightbulb
              else
                Icons.lightbulb_outline_rounded,
              if (getListeningComprehensionMode())
                Icons.hearing_sharp
              else
                Icons.hearing_disabled,
              if (getSelectMode())
                Icons.touch_app_sharp
              else
                Icons.select_all_sharp,
              Icons.translate_sharp,
              Icons.share_outlined,
              Icons.mobile_screen_share_rounded,
            ],
            highlightedIndexes,
          ),
        );

        switch (chosenOption) {
          case 0:
            chewieController.toggleShadowingMode();
            break;
          case 1:
            toggleFocusMode();
            break;
          case 2:
            toggleListeningComprehensionMode();
            break;
          case 3:
            toggleSelectMode();
            gIsSelectMode.value = getSelectMode();
            break;
          case 4:
            toggleMonolingualMode();
            final String clipboardMemory = chewieController.clipboard.value;
            chewieController.clipboard.value = "";
            chewieController.setNoPush();
            chewieController.clipboard.value = clipboardMemory;
            break;
          case 5:
            openExtraShare();
            break;
          case 6:
            chewieController.exportSingleCallback();
            break;
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: const Icon(Icons.more_vert),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityButton(
    VlcPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final List<String> qualityTags = [];

        for (final YouTubeQualityOption quality
            in chewieController.streamData.videoQualities) {
          String muxTag;

          if (quality.muxed) {
            muxTag = " (seek friendly)";
          } else {
            muxTag = "";
          }

          qualityTags.add("${quality.videoResolution}$muxTag");
        }

        qualityTags.add("Set Preferred Video Quality");

        String currentMuxTag;
        if (chewieController.currentVideoQuality.muxed) {
          currentMuxTag = " (seek friendly)";
        } else {
          currentMuxTag = "";
        }

        final currentQuality =
            "${chewieController.currentVideoQuality.videoResolution}$currentMuxTag";
        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) =>
              _SelectQualityDialog(qualityTags, currentQuality),
        );

        if (chosenOption != null) {
          if (chosenOption != qualityTags.length - 1) {
            chewieController.clipboard.value = "";

            await gSharedPrefs.setString(
                "lastPlayedQuality", qualityTags[chosenOption]);
            final Duration position = await controller.getPosition();

            final YouTubeQualityOption chosenQuality =
                chewieController.streamData.videoQualities[chosenOption];

            chewieController.currentVideoQuality = chosenQuality;

            await controller.setMediaFromNetwork(chewieController
                .streamData.videoQualities[chosenOption].videoURL);
            if (!chosenQuality.muxed) {
              await controller
                  .addAudioFromNetwork(chewieController.streamData.audioURL);
            }

            await controller.seekTo(position);
          } else {
            final preferredQualityOption = await showModalBottomSheet<int>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => _MoreOptionsDialog(
                const [
                  "Prefer Last Selected Quality",
                  "Prefer Lowest Quality (all streams)",
                  "Prefer Lowest Quality (seek friendly)",
                  "Prefer Highest Quality (seek friendly)",
                  "Prefer Highest Quality (all streams)",
                ],
                const [
                  Icons.history,
                  Icons.sd,
                  Icons.sd,
                  Icons.hd,
                  Icons.hd,
                ],
                [getPreferredQuality()],
              ),
            );

            if (preferredQualityOption != null) {
              setPreferredQuality(preferredQualityOption);

              final YouTubeQualityOption chosenQuality =
                  getPreferredYouTubeQuality(
                      chewieController.streamData.videoQualities);

              chewieController.currentVideoQuality = chosenQuality;

              await controller.setMediaFromNetwork(chosenQuality.videoURL);
              if (!chosenQuality.muxed) {
                await controller
                    .addAudioFromNetwork(chewieController.streamData.audioURL);
              }
            }
          }
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: const Icon(Icons.video_settings_sharp),
          ),
        ),
      ),
    );
  }

  Widget _buildToolsButton(
    VlcPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final List<String> audioTrackNames = [];
        final List<String> subtitleTrackNames = [];
        final List<String> autoSubtitleTrackNames = [];

        if (controller.dataSourceType == DataSourceType.file) {
          final audioTracks = await controller.getAudioTracks();
          final subtitleTracks = await controller.getSpuTracks();

          audioTracks.forEach((index, name) => audioTrackNames.add(name));
          subtitleTracks.forEach((index, name) => subtitleTrackNames.add(name));
        } else {
          if (chewieController.internalSubs.isNotEmpty) {
            subtitleTrackNames.add("YouTube - [CC] - [Japanese]");
          } else {
            autoSubtitleTrackNames.add("YouTube - [Automatic] - [Japanese]");
          }
          audioTrackNames
              .add("YouTube - ${chewieController.streamData.audioMetadata}");
        }

        final List<SubtitleAudioMenuOption> options = [];
        for (int i = 0; i < audioTrackNames.length; i++) {
          options.add(
            SubtitleAudioMenuOption(
              type: SubtitleAudioMenuOptionType.audioTrack,
              callbackIndex: i,
              metadata: audioTrackNames[i],
            ),
          );
        }
        for (int i = 0; i < subtitleTrackNames.length; i++) {
          options.add(
            SubtitleAudioMenuOption(
              type: SubtitleAudioMenuOptionType.embeddedSubtitle,
              callbackIndex: i,
              metadata: subtitleTrackNames[i],
            ),
          );
        }
        for (int i = 0; i < autoSubtitleTrackNames.length; i++) {
          options.add(
            SubtitleAudioMenuOption(
              type: SubtitleAudioMenuOptionType.autoSubtitle,
              callbackIndex: -50,
              metadata: audioTrackNames[i],
            ),
          );
        }
        options.add(
          SubtitleAudioMenuOption(
            type: SubtitleAudioMenuOptionType.noneSubtitle,
            callbackIndex: 99999,
          ),
        );
        options.add(
          SubtitleAudioMenuOption(
            type: SubtitleAudioMenuOptionType.adjustDelayAndAllowance,
          ),
        );
        options.add(
          SubtitleAudioMenuOption(
            type: SubtitleAudioMenuOptionType.externalSubtitle,
          ),
        );

        final chosenOption =
            await showModalBottomSheet<SubtitleAudioMenuOption>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _SelectAudioDialog(
            options,
            chewieController,
          ),
        );

        if (chosenOption == null) {
          return;
        }

        switch (chosenOption.type) {
          case SubtitleAudioMenuOptionType.audioTrack:
            chewieController.currentAudioTrack.value =
                chosenOption.callbackIndex;
            await controller.setAudioTrack(chosenOption.callbackIndex + 1);
            break;
          case SubtitleAudioMenuOptionType.embeddedSubtitle:
          case SubtitleAudioMenuOptionType.autoSubtitle:
          case SubtitleAudioMenuOptionType.noneSubtitle:
            chewieController.currentSubTrack.value = chosenOption.callbackIndex;
            break;
          case SubtitleAudioMenuOptionType.externalSubtitle:
            chewieController.playExternalSubtitles();
            break;
          case SubtitleAudioMenuOptionType.adjustDelayAndAllowance:
            controller.pause();
            chewieController.retimeSubtitles();
            break;
          default:
            break;
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: const Icon(Icons.queue_music_outlined),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VlcPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 8.0, right: 4.0),
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    if (chewieController.shadowingSubtitle.value != null) {
      final shadowDuration = Duration(
          milliseconds:
              chewieController.shadowingSubtitle.value.endTime.inMilliseconds +
                  chewieController.audioAllowance.value);

      return GestureDetector(
        onTap: () {
          chewieController.toggleShadowingMode();
        },
        child: Padding(
          padding: const EdgeInsets.only(
            right: 24.0,
          ),
          child: Row(
            children: [
              Text(
                duration != Duration.zero
                    ? '${formatDuration(position)} / ${formatDuration(shadowDuration)}'
                    : '',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          chewieController.toggleShadowingMode();
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Row(
            children: [
              Text(
                duration != Duration.zero
                    ? '${formatDuration(position)} / ${formatDuration(duration)}'
                    : '',
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _cancelAndRestartTimer() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final isFinished = controller.value.isEnded;
    chewieController.wasPlaying.value = false;

    setState(() {
      if (controller.value.isPlaying) {
        playPauseIconAnimationController.reverse();
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
            playPauseIconAnimationController.forward();
          });
        } else {
          if (isFinished) {
            chewieController.clipboard.value = "";
            controller.stop();
          }
          playPauseIconAnimationController.forward();
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}

class _MoreOptionsDialog extends StatelessWidget {
  const _MoreOptionsDialog(
    this.options,
    this.icons,
    this.highlights, {
    this.count = -1,
  });

  final List<String> options;
  final List<IconData> icons;
  final List<int> highlights;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final _option = options[index];
        final _icon = icons[index];

        return ListTile(
          dense: true,
          title: Row(
            children: [
              Icon(
                _icon,
                size: 20.0,
                color: Colors.red,
              ),
              const SizedBox(width: 16.0),
              Text(
                _option,
                style: TextStyle(
                  color:
                      (highlights.contains(index)) ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(index);
          },
        );
      },
      itemCount: (count == -1) ? options.length : count,
    );
  }
}

IconData getIconFromQualityTag(String qualityTag) {
  switch (qualityTag) {
    case "144p":
    case "144p (seek friendly)":
    case "240p":
    case "240p (seek friendly)":
    case "360p":
    case "360p (seek friendly)":
    case "480p":
    case "480p (seek friendly)":
    case "720p":
    case "720p (seek friendly)":
      return Icons.sd;
    case "1080p":
    case "1080p (seek friendly)":
    case "1440p":
    case "1440p (seek friendly)":
      return Icons.hd;
    case "2160p":
    case "2160p (seek friendly)":
      return Icons.four_k;
    default:
      return Icons.settings_applications_outlined;
  }
}

class _SelectQualityDialog extends StatelessWidget {
  const _SelectQualityDialog(this.qualityTags, this.currentQuality);

  final List<String> qualityTags;
  final String currentQuality;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final String qualityTag = qualityTags[index];
        return ListTile(
          dense: true,
          title: Row(
            children: [
              Icon(
                getIconFromQualityTag(qualityTag),
                size: 20.0,
                color: Colors.red,
              ),
              const SizedBox(width: 16.0),
              Text(
                qualityTag,
                style: TextStyle(
                  color: (currentQuality == qualityTag)
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(index);
          },
        );
      },
      itemCount: qualityTags.length,
    );
  }
}

class _SelectAudioDialog extends StatelessWidget {
  const _SelectAudioDialog(
    this.options,
    this.chewieController,
  );

  final List<SubtitleAudioMenuOption> options;
  final ChewieController chewieController;

  Widget buildRow(int index) {
    final SubtitleAudioMenuOption option = options[index];

    return Row(
      children: [
        Icon(
          option.getIcon(),
          size: 20.0,
          color: Colors.red,
        ),
        const SizedBox(width: 16.0),
        Text(
          option.getLabel(),
          style: TextStyle(
            color: option.getColor(chewieController),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          title: buildRow(index),
          onTap: () {
            Navigator.of(context).pop(options[index]);
          },
        );
      },
      itemCount: options.length,
    );
  }
}

class SubtitleAudioMenuOption {
  SubtitleAudioMenuOption({
    this.type,
    this.callbackIndex,
    this.metadata = "",
  });

  final SubtitleAudioMenuOptionType type;
  final int callbackIndex;
  final String metadata;

  Color getColor(ChewieController chewie) {
    switch (type) {
      case SubtitleAudioMenuOptionType.audioTrack:
        if (chewie.currentAudioTrack.value == callbackIndex) {
          return Colors.red;
        }
        break;
      case SubtitleAudioMenuOptionType.embeddedSubtitle:
        if (chewie.currentSubTrack.value == callbackIndex ||
            chewie.currentSubTrack.value == -1) {
          return Colors.red;
        }
        break;
      case SubtitleAudioMenuOptionType.autoSubtitle:
        if (chewie.currentSubTrack.value == -51) {
          return Colors.red;
        }
        break;
      case SubtitleAudioMenuOptionType.noneSubtitle:
        if (chewie.currentSubTrack.value == 99999) {
          return Colors.red;
        }
        break;
      case SubtitleAudioMenuOptionType.externalSubtitle:
        return Colors.white;
        break;
      case SubtitleAudioMenuOptionType.adjustDelayAndAllowance:
        return Colors.white;
        break;
      default:
        return Colors.white;
    }

    return Colors.white;
  }

  IconData getIcon() {
    switch (type) {
      case SubtitleAudioMenuOptionType.audioTrack:
        return Icons.audiotrack_outlined;
        break;
      case SubtitleAudioMenuOptionType.embeddedSubtitle:
      case SubtitleAudioMenuOptionType.autoSubtitle:
        return Icons.subtitles_outlined;
        break;
      case SubtitleAudioMenuOptionType.noneSubtitle:
        return Icons.subtitles_off_outlined;
        break;
      case SubtitleAudioMenuOptionType.externalSubtitle:
        return Icons.upload_file;
        break;
      case SubtitleAudioMenuOptionType.adjustDelayAndAllowance:
        return Icons.timer_sharp;
        break;
      default:
        return Icons.error;
    }
  }

  String getLabel() {
    switch (type) {
      case SubtitleAudioMenuOptionType.audioTrack:
        return "Audio - $metadata";
        break;
      case SubtitleAudioMenuOptionType.embeddedSubtitle:
        return "Subtitle - $metadata";
        break;
      case SubtitleAudioMenuOptionType.autoSubtitle:
        return "Subtitle - YouTube - [Automatic] - [Japanese]";
        break;
      case SubtitleAudioMenuOptionType.noneSubtitle:
        return "Subtitle - None";
        break;
      case SubtitleAudioMenuOptionType.externalSubtitle:
        return "Load External Subtitles";
        break;
      case SubtitleAudioMenuOptionType.adjustDelayAndAllowance:
        return "Adjust Delay and Allowance";
        break;

      default:
        return "Undefined";
    }
  }
}

enum SubtitleAudioMenuOptionType {
  audioTrack,
  embeddedSubtitle,
  autoSubtitle,
  noneSubtitle,
  externalSubtitle,
  adjustDelayAndAllowance,
}
