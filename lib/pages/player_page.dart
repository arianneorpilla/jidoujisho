import 'dart:async';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

class PlayerPage extends StatefulWidget {
  final PlayerLaunchParams params;

  const PlayerPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage>
    with AutomaticKeepAliveClientMixin {
  late AppModel appModel;

  late VlcPlayerController playerController;
  SubtitleController? subtitleController;

  List<SubtitleController> allSubtitleControllers = [];

  Subtitle? subtitle;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  Color menuColor = const Color(0xcc424242);
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);
  Timer? menuHideTimer;

  double sliderValue = 0.0;
  bool validPosition = false;
  bool isPlayerReady = false;

  bool tapToSelectMode = false;

  DictionarySearchResult? searchResult;
  String searchTerm = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    playerController = preparePlayerController(widget.params);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      allSubtitleControllers = await prepareSubtitleControllers(widget.params);
      for (SubtitleController controller in allSubtitleControllers) {
        await controller.initial();
      }

      if (allSubtitleControllers.isNotEmpty) {
        subtitleController = allSubtitleControllers.first;
      }

      playerController.addListener(listener);
      isPlayerReady = true;

      setState(() {});

      startHideTimer();
    });
  }

  void cancelHideTimer() {
    menuHideTimer!.cancel();
    isMenuHidden.value = false;
  }

  void startHideTimer() {
    menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  VlcPlayerController preparePlayerController(PlayerLaunchParams params) {
    List<String> audioParams = ["--audio-track=0", "--sub-track=99999"];
    if (params.audioPath != null) {
      audioParams.add("--input-slave=${params.audioPath}");
    }

    VlcAudioOptions audio = VlcAudioOptions(audioParams);
    VlcPlayerOptions options = VlcPlayerOptions(audio: audio);

    switch (params.getMode()) {
      case MediaLaunchMode.file:
        return VlcPlayerController.file(
          params.videoFile!,
          options: options,
        );
      case MediaLaunchMode.network:
        return VlcPlayerController.network(
          params.networkPath!,
          options: options,
        );
    }
  }

  Future<List<SubtitleController>> prepareSubtitleControllers(
      PlayerLaunchParams params) async {
    return await params.mediaSource.provideSubtitles(params);
  }

  @override
  void dispose() {
    playerController.removeListener(listener);
    super.dispose();
  }

  String getPositionText() {
    if (position.inHours == 0) {
      var strPosition = position.toString().split('.')[0];
      return "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
    } else {
      return position.toString().split('.')[0];
    }
  }

  String getDurationText() {
    if (duration.inHours == 0) {
      var strDuration = duration.toString().split('.')[0];
      return "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
    } else {
      return duration.toString().split('.')[0];
    }
  }

  void listener() async {
    if (!mounted) return;

    if (playerController.value.isInitialized) {
      position = playerController.value.position;
      duration = playerController.value.duration;

      if (subtitleController != null) {
        Subtitle? newSubtitle = subtitleController!.durationSearch(position);
        subtitle = newSubtitle;
      }

      validPosition = duration.compareTo(position) >= 0;
      sliderValue = validPosition ? position.inSeconds.toDouble() : 0;
      setState(() {});
    }
  }

  Widget buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }

  Widget buildPlayer() {
    return Center(
      child: VlcPlayer(
        controller: playerController,
        aspectRatio: 16 / 9,
        placeholder: buildPlaceholder(),
      ),
    );
  }

  Widget buildPlayerArea() {
    return GestureDetector(
      onTap: () {
        toggleMenuVisibility();
      },
      child: Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: double.maxFinite,
        color: Colors.black,
        child: buildPlayer(),
      ),
    );
  }

  Widget buildSubtitleArea() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: menuHeight + 24),
        child: buildSubtitles(),
      ),
    );
  }

  Widget buildSubtitles() {
    return SelectableText.rich(
      TextSpan(text: subtitle!.data),
    );
  }

  void toggleMenuVisibility() async {
    menuHideTimer!.cancel();
    isMenuHidden.value = !isMenuHidden.value;
    if (!isMenuHidden.value) {
      startHideTimer();
    }
  }

  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: isMenuHidden,
        builder: (BuildContext context, bool value, _) {
          return GestureDetector(
            onTap: () {
              toggleMenuVisibility();
            },
            child: AbsorbPointer(
              absorbing: value,
              child: AnimatedOpacity(
                opacity: value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: buildMenuContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMenuContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: menuHeight,
        color: menuColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              color: Colors.white,
              icon: playerController.value.isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              onPressed: _togglePlaying,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "${getPositionText()} / ${getDurationText()}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      activeColor: Theme.of(context).focusColor,
                      inactiveColor: Theme.of(context).unselectedWidgetColor,
                      value: sliderValue,
                      min: 0.0,
                      max: (!validPosition)
                          ? 1.0
                          : playerController.value.duration.inSeconds
                              .toDouble(),
                      onChangeStart: (value) {
                        cancelHideTimer();
                      },
                      onChangeEnd: (value) {
                        startHideTimer();
                      },
                      onChanged:
                          validPosition ? _onSliderPositionChanged : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    super.build(context);

    if (!isPlayerReady) {
      return buildPlaceholder();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildPlayerArea(),
          buildMenuArea(),
          if (subtitle != null)
            Positioned.fill(
              child: buildSubtitleArea(),
            ),
        ],
      ),
    );
  }

  bool isPlaying() {
    return playerController.value.isPlaying;
  }

  void _togglePlaying() async {
    cancelHideTimer();

    if (isPlaying()) {
      cancelHideTimer();
      await playerController.pause();
    } else {
      startHideTimer();
      await playerController.play();
    }
  }

  void _onSliderPositionChanged(double progress) {
    cancelHideTimer();

    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    playerController.setTime(sliderValue.toInt() * 1000);
  }
}
