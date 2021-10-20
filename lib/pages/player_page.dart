import 'dart:typed_data';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class VlcPlayerWithControls extends StatefulWidget {
  final VlcPlayerController controller;
  final bool showControls;

  const VlcPlayerWithControls({
    Key? key,
    required this.controller,
    this.showControls = true,
  }) : super(key: key);

  @override
  VlcPlayerWithControlsState createState() => VlcPlayerWithControlsState();
}

class VlcPlayerWithControlsState extends State<VlcPlayerWithControls>
    with AutomaticKeepAliveClientMixin {
  static const _playerControlsBgColor = Colors.black87;

  late VlcPlayerController _controller;

  //
  final double initSnapshotRightPosition = 10;
  final double initSnapshotBottomPosition = 10;
  OverlayEntry? _overlayEntry;

  //
  double sliderValue = 0.0;
  double volumeValue = 50;
  String position = '';
  String duration = '';
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;
  bool validPosition = false;

  double recordingTextOpacity = 0;
  DateTime lastRecordingShowTime = DateTime.now();
  bool isRecording = false;

  //
  List<double> playbackSpeeds = [0.5, 1.0, 2.0];
  int playbackSpeedIndex = 1;

  late AppModel appModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void listener() async {
    if (!mounted) return;
    //
    if (_controller.value.isInitialized) {
      var oPosition = _controller.value.position;
      var oDuration = _controller.value.duration;
      if (oDuration.inHours == 0) {
        var strPosition = oPosition.toString().split('.')[0];
        var strDuration = oDuration.toString().split('.')[0];
        position = "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
        duration = "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
      } else {
        position = oPosition.toString().split('.')[0];
        duration = oDuration.toString().split('.')[0];
      }
      validPosition = oDuration.compareTo(oPosition) >= 0;
      sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      numberOfCaptions = _controller.value.spuTracksCount;
      numberOfAudioTracks = _controller.value.audioTracksCount;
      // update recording blink widget
      if (_controller.value.isRecording && _controller.value.isPlaying) {
        if (DateTime.now().difference(lastRecordingShowTime).inSeconds >= 1) {
          lastRecordingShowTime = DateTime.now();
          recordingTextOpacity = 1 - recordingTextOpacity;
        }
      } else {
        recordingTextOpacity = 0;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    super.build(context);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: widget.showControls,
            child: Container(
              width: double.infinity,
              color: _playerControlsBgColor,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            tooltip: 'Get Subtitle Tracks',
                            icon: Icon(Icons.closed_caption),
                            color: Colors.white,
                            onPressed: _getSubtitleTracks,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 1,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  '$numberOfCaptions',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            tooltip: 'Get Audio Tracks',
                            icon: Icon(Icons.audiotrack),
                            color: Colors.white,
                            onPressed: _getAudioTracks,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 1,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  '$numberOfAudioTracks',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.timer),
                            color: Colors.white,
                            onPressed: _cyclePlaybackSpeed,
                          ),
                          Positioned(
                            bottom: 7,
                            right: 3,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 1,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  '${playbackSpeeds.elementAt(playbackSpeedIndex)}x',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Get Snapshot',
                        icon: Icon(Icons.camera),
                        color: Colors.white,
                        onPressed: _createCameraImage,
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: _controller.value.isRecording
                            ? const Icon(Icons.videocam_off_outlined)
                            : const Icon(Icons.videocam_outlined),
                        onPressed: _toggleRecording,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cast),
                        color: Colors.white,
                        onPressed: _getRendererDevices,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Size: ' +
                              (_controller.value.size.width.toInt())
                                  .toString() +
                              'x' +
                              (_controller.value.size.height.toInt())
                                  .toString(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Status: ' +
                              _controller.value.playingState
                                  .toString()
                                  .split('.')[1],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Center(
                    child: VlcPlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                      placeholder: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: AnimatedOpacity(
                      opacity: recordingTextOpacity,
                      duration: Duration(seconds: 1),
                      child: Container(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.circle, color: Colors.red),
                            SizedBox(width: 5),
                            Text(
                              'REC',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget.showControls,
            child: Container(
              color: _playerControlsBgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: _controller.value.isPlaying
                        ? Icon(Icons.pause_circle_outline)
                        : Icon(Icons.play_circle_outline),
                    onPressed: _togglePlaying,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          position,
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.redAccent,
                            inactiveColor: Colors.white70,
                            value: sliderValue,
                            min: 0.0,
                            max: (!validPosition &&
                                    _controller.value.duration == null)
                                ? 1.0
                                : _controller.value.duration.inSeconds
                                    .toDouble(),
                            onChanged:
                                validPosition ? _onSliderPositionChanged : null,
                          ),
                        ),
                        Text(
                          duration,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.fullscreen),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget.showControls,
            child: Container(
              color: _playerControlsBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.volume_down,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 100,
                      value: volumeValue,
                      onChanged: _setSoundVolume,
                    ),
                  ),
                  Icon(
                    Icons.volume_up,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cyclePlaybackSpeed() async {
    playbackSpeedIndex++;
    if (playbackSpeedIndex >= playbackSpeeds.length) {
      playbackSpeedIndex = 0;
    }
    return await _controller
        .setPlaybackSpeed(playbackSpeeds.elementAt(playbackSpeedIndex));
  }

  void _setSoundVolume(value) {
    setState(() {
      volumeValue = value;
    });
    _controller.setVolume(volumeValue.toInt());
  }

  void _togglePlaying() async {
    appModel.showDictionaryMenu(context);
    _controller.value.isPlaying
        ? await _controller.pause()
        : await _controller.play();
  }

  void _toggleRecording() async {
    if (!_controller.value.isRecording) {
      var saveDirectory = await getTemporaryDirectory();
      await _controller.startRecording(saveDirectory.path);
    } else {
      await _controller.stopRecording();
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    _controller.setTime(sliderValue.toInt() * 1000);
  }

  void _getSubtitleTracks() async {
    if (!_controller.value.isPlaying) return;

    var subtitleTracks = await _controller.getSpuTracks();
    //
    if (subtitleTracks != null && subtitleTracks.isNotEmpty) {
      var selectedSubId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Subtitle'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: subtitleTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < subtitleTracks.keys.length
                          ? subtitleTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < subtitleTracks.keys.length
                            ? subtitleTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedSubId != null) await _controller.setSpuTrack(selectedSubId);
    }
  }

  void _getAudioTracks() async {
    if (!_controller.value.isPlaying) return;

    var audioTracks = await _controller.getAudioTracks();
    //
    if (audioTracks != null && audioTracks.isNotEmpty) {
      var selectedAudioTrackId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Audio'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: audioTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < audioTracks.keys.length
                          ? audioTracks.values.elementAt(index).toString()
                          : 'Disable',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < audioTracks.keys.length
                            ? audioTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      if (selectedAudioTrackId != null) {
        await _controller.setAudioTrack(selectedAudioTrackId);
      }
    }
  }

  void _getRendererDevices() async {
    var castDevices = await _controller.getRendererDevices();
    //
    if (castDevices != null && castDevices.isNotEmpty) {
      var selectedCastDeviceName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Display Devices'),
            content: Container(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: castDevices.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < castDevices.keys.length
                          ? castDevices.values.elementAt(index).toString()
                          : 'Disconnect',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < castDevices.keys.length
                            ? castDevices.keys.elementAt(index)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      await _controller.castToRenderer(selectedCastDeviceName);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No Display Device Found!')));
    }
  }

  void _createCameraImage() async {
    var snapshot = await _controller.takeSnapshot();
    _overlayEntry?.remove();
    _overlayEntry = _createSnapshotThumbnail(snapshot);
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  OverlayEntry _createSnapshotThumbnail(Uint8List snapshot) {
    var right = initSnapshotRightPosition;
    var bottom = initSnapshotBottomPosition;
    return OverlayEntry(
      builder: (context) => Positioned(
        right: right,
        bottom: bottom,
        width: 100,
        child: Material(
          elevation: 4.0,
          child: GestureDetector(
            onTap: () async {
              _overlayEntry?.remove();
              _overlayEntry = null;
              await showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.all(0),
                    content: Container(
                      child: Image.memory(snapshot),
                    ),
                  );
                },
              );
            },
            onVerticalDragUpdate: (dragUpdateDetails) {
              bottom -= dragUpdateDetails.delta.dy;
              _overlayEntry!.markNeedsBuild();
            },
            onHorizontalDragUpdate: (dragUpdateDetails) {
              right -= dragUpdateDetails.delta.dx;
              _overlayEntry!.markNeedsBuild();
            },
            onHorizontalDragEnd: (dragEndDetails) {
              if ((initSnapshotRightPosition - right).abs() >= 100) {
                _overlayEntry?.remove();
                _overlayEntry = null;
              } else {
                right = initSnapshotRightPosition;
                _overlayEntry!.markNeedsBuild();
              }
            },
            onVerticalDragEnd: (dragEndDetails) {
              if ((initSnapshotBottomPosition - bottom).abs() >= 100) {
                _overlayEntry?.remove();
                _overlayEntry = null;
              } else {
                bottom = initSnapshotBottomPosition;
                _overlayEntry!.markNeedsBuild();
              }
            },
            child: Container(
              child: Image.memory(snapshot),
            ),
          ),
        ),
      ),
    );
  }
}
