import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:share/share.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/dictionary.dart';
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
    final chosenOption = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _MoreOptionsDialog(options: [
        "Search Current Subtitle with Jisho.org",
        "Translate Current Subtitle with DeepL",
        "Translate Current Subtitle with Google Translate",
        "Share Current Subtitle with Menu",
      ], icons: [
        Icons.menu_book_rounded,
        Icons.translate_rounded,
        Icons.g_translate_rounded,
        Icons.share_outlined,
      ]),
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
    }
  }

  Widget _buildMoreButton(VlcPlayerController controller) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _MoreOptionsDialog(options: [
            "Share Current Subtitle to Applications",
            "Adjust Subtitle Delay and Audio Allowance",
            if (getSelectMode())
              "Use Tap to Select Subtitle Selection"
            else
              "Use Drag to Select Subtitle Selection",
            if (getFocusMode())
              "Turn Off Definition Focus Mode"
            else
              "Turn On Definition Focus Mode",
            "Load External Subtitles",
            "Export Current Context to Anki",
          ], icons: [
            Icons.share_outlined,
            Icons.timer_rounded,
            if (getSelectMode())
              Icons.touch_app_rounded
            else
              Icons.select_all_rounded,
            if (getFocusMode())
              Icons.lightbulb_outline_rounded
            else
              Icons.lightbulb,
            Icons.subtitles_outlined,
            Icons.mobile_screen_share_rounded,
          ]),
        );

        switch (chosenOption) {
          case 0:
            openExtraShare();
            break;
          case 1:
            controller.pause();
            chewieController.retimeSubtitles();
            break;
          case 2:
            toggleSelectMode();
            gIsSelectMode.value = getSelectMode();
            break;
          case 3:
            toggleFocusMode();
            break;
          case 4:
            chewieController.playExternalSubtitles();
            break;
          case 5:
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

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _SelectQualityDialog(qualityTags),
        );

        if (chosenOption != null) {
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

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _SelectAudioDialog(
            audioTrackNames,
            subtitleTrackNames,
            autoSubtitleTrackNames,
          ),
        );

        if (chosenOption != null) {
          if (chosenOption ==
              audioTrackNames.length +
                  subtitleTrackNames.length +
                  autoSubtitleTrackNames.length) {
            chewieController.currentSubTrack.value =
                chosenOption - audioTrackNames.length;
          }
          if (chosenOption < audioTrackNames.length) {
            await controller.setAudioTrack(chosenOption + 1);
          } else if (chosenOption <
              audioTrackNames.length + subtitleTrackNames.length) {
            chewieController.currentSubTrack.value =
                chosenOption - audioTrackNames.length;
          } else if (chosenOption <
              audioTrackNames.length +
                  subtitleTrackNames.length +
                  autoSubtitleTrackNames.length) {
            chewieController.currentSubTrack.value = -50;
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

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Text(
          duration != Duration.zero
              ? '${formatDuration(position)} / ${formatDuration(duration)}'
              : '',
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
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
  const _MoreOptionsDialog({
    Key key,
    @required List<String> options,
    @required List<IconData> icons,
  })  : _options = options,
        _icons = icons,
        super(key: key);

  final List<String> _options;
  final List<IconData> _icons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final _option = _options[index];
        final _icon = _icons[index];
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
              Text(_option),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(index);
          },
        );
      },
      itemCount: _options.length,
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
    default:
      return Icons.four_k;
  }
}

class _SelectQualityDialog extends StatelessWidget {
  const _SelectQualityDialog(this.qualityTags);

  final List<String> qualityTags;

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
              Text(qualityTag),
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
  const _SelectAudioDialog(this.options, this.subtitles, this.autoSubtitles);

  final List<String> options;
  final List<String> subtitles;
  final List<String> autoSubtitles;

  Widget buildRow(int index) {
    if (index < options.length) {
      final String _text = options[index];
      return Row(
        children: [
          const Icon(
            Icons.audiotrack_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Audio - $_text"),
        ],
      );
    } else if (index < options.length + subtitles.length) {
      final String _text = subtitles[index - options.length];
      return Row(
        children: [
          const Icon(
            Icons.subtitles_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Subtitle - $_text"),
        ],
      );
    } else if (index <
        options.length + subtitles.length + autoSubtitles.length) {
      final String _text =
          autoSubtitles[index - options.length - subtitles.length];
      return Row(
        children: [
          const Icon(
            Icons.subtitles_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Subtitle - $_text"),
        ],
      );
    } else {
      return Row(
        children: const [
          Icon(
            Icons.subtitles_off_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          SizedBox(width: 16.0),
          Text("Subtitle - None"),
        ],
      );
    }
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
            Navigator.of(context).pop(index);
          },
        );
      },
      itemCount: options.length + subtitles.length + autoSubtitles.length + 1,
    );
  }
}
