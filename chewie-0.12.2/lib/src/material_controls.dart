import 'dart:async';
import 'dart:io';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:share/share.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:jidoujisho/util.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls>
    with SingleTickerProviderStateMixin {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
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
              if (_latestValue != null &&
                      !_latestValue.isPlaying &&
                      _latestValue.duration == null ||
                  _latestValue.isBuffering)
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
            _buildToolsButton(controller),
            _buildMoreButton(controller),
            if (chewieController.allowMuting) _buildMuteButton(controller),
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
    final bool isFinished = _latestValue.position >= _latestValue.duration;

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
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                        icon: isFinished
                            ? const Icon(Icons.replay, size: 32.0)
                            : AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: playPauseIconAnimationController,
                                size: 32.0,
                              ),
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

  Widget _buildMoreButton(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _MoreOptionsDialog(options: [
            "Call Jisho.org Instant Dictionary",
            "Jisho.org Lookup Clipboard",
            "Translate Clipboard with DeepL",
            "Translate Clipboard with Google Translate",
            "Share Clipboard to App",
            "Load External Subtitles",
            "Export Current Context to Anki",
          ], icons: [
            Icons.book_rounded,
            Icons.menu_book_rounded,
            Icons.translate_rounded,
            Icons.g_translate_rounded,
            Icons.share_outlined,
            Icons.subtitles_outlined,
            Icons.mobile_screen_share_rounded,
          ]),
        );

        String clip = controller.clipboard.value;

        switch (chosenOption) {
          case 0:
            controller.clipboard.value = "@usejisho@$clip";
            break;
          case 1:
            await launch("https://jisho.org/search/" + clip);
            break;
          case 2:
            await launch("https://www.deepl.com/translator#ja/en/" + clip);
            break;
          case 3:
            await launch("https://translate.google.com/?sl=ja&tl=en&text=" +
                clip +
                "&op=translate");
            break;
          case 4:
            if (controller.clipboard.value.isNotEmpty) {
              Share.share(controller.clipboard.value);
            }
            break;
          case 5:
            controller.callback();
            break;
          case 6:
            controller.pause();
            await exportToAnki(
              context,
              controller,
              controller.currentSubtitle.value,
              controller.currentWord.value,
              controller.currentDefinition.value,
              controller.currentReading.value,
            );
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

  Widget _buildToolsButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        List<dynamic> audioTracks = await controller.getAudios();

        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _SelectAudioDialog(
            options: audioTracks,
            subtitles: controller.internalSubs,
          ),
        );

        if (chosenOption != null) {
          if (chosenOption < audioTracks.length) {
            await controller.setAudioByIndex(chosenOption);
            controller.setCurrentAudioIndex(chosenOption);
          } else {
            controller.currentSubTrack.value =
                chosenOption - audioTracks.length;
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

  // Widget _buildSpeedButton(
  //   VideoPlayerController controller,
  // ) {
  //   return GestureDetector(
  //     onTap: () async {
  //       _hideTimer?.cancel();

  //       final chosenSpeed = await showModalBottomSheet<double>(
  //         context: context,
  //         isScrollControlled: true,
  //         useRootNavigator: true,
  //         builder: (context) => _PlaybackSpeedDialog(
  //           speeds: chewieController.videoPlayerController,
  //           selected: _latestValue.playbackSpeed,
  //         ),
  //       );

  //       if (chosenSpeed != null) {
  //         controller.setPlaybackSpeed(chosenSpeed);
  //       }

  //       if (_latestValue.isPlaying) {
  //         _startHideTimer();
  //       }
  //     },
  //     child: AnimatedOpacity(
  //       opacity: _hideStuff ? 0.0 : 1.0,
  //       duration: const Duration(milliseconds: 300),
  //       child: ClipRect(
  //         child: Container(
  //           height: barHeight,
  //           padding: const EdgeInsets.only(
  //             left: 8.0,
  //             right: 8.0,
  //           ),
  //           child: const Icon(Icons.speed),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
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
            child: Icon(
              (_latestValue != null && _latestValue.volume > 0)
                  ? Icons.volume_up
                  : Icons.volume_off,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
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

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: const TextStyle(
          fontSize: 14.0,
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
    bool isFinished;
    if (_latestValue.duration != null) {
      isFinished = _latestValue.position >= _latestValue.duration;
    } else {
      isFinished = false;
    }

    setState(() {
      if (controller.value.isPlaying) {
        playPauseIconAnimationController.reverse();
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
            playPauseIconAnimationController.forward();
          });
        } else {
          if (isFinished) {
            controller.seekTo(const Duration());
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
    final Color selectedColor = Theme.of(context).primaryColor;

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

class _SelectAudioDialog extends StatelessWidget {
  const _SelectAudioDialog({
    Key key,
    @required List<dynamic> options,
    @required List<File> subtitles,
  })  : _options = options,
        _subtitles = subtitles,
        super(key: key);

  final List<dynamic> _options;
  final List<File> _subtitles;

  Widget buildRow(int index) {
    String _option;
    int _subIndex = 0;

    if (index < _options.length) {
      _option = _options[index].toString();
    } else {
      _subIndex = index - _options.length;
    }

    if (index < _options.length) {
      return Row(
        children: [
          Icon(
            Icons.audiotrack_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Audio - $_option"),
        ],
      );
    } else if (index < _options.length + _subtitles.length) {
      return Row(
        children: [
          Icon(
            Icons.subtitles_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Subtitle - Track $_subIndex"),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.subtitles_off_outlined,
            size: 20.0,
            color: Colors.red,
          ),
          const SizedBox(width: 16.0),
          Text("Subtitle - None"),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).primaryColor;

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
      itemCount: (_subtitles.isEmpty)
          ? _options.length
          : _options.length + _subtitles.length + 1,
    );
  }
}
