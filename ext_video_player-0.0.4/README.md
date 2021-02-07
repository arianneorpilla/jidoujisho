# [ext_video_player](https://pub.dartlang.org/packages/ext_video_player)

### Clone of [video_player](https://pub.dartlang.org/packages/video_player) plugin with support for Youtube & RTMP

[![pub package](https://img.shields.io/pub/v/ext_video_player.svg)](https://pub.dartlang.org/packages/ext_video_player)

# NOTICE

> This Plugin uses all its code from [video_player](https://pub.dartlang.org/packages/video_player) plugins which is the official video_player plugin
> Only few part of the code are modified.

# Note

> RTMP is only supported in Android (Working for iOS)

## Installation

First, add `ext_video_player` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Warning: The video player is not functional on iOS simulators. An iOS device must be used during development/testing.

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

This entry allows your app to access video files by URL.

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

The Flutter project template adds it, so it may already be there.

### Web

Please check readme file of [video_player](https://pub.dartlang.org/packages/video_player)

## Example

```dart
import 'package:ext_video_player/ext_video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
```

> For more code please check example project

## Buy Me a Coffee

<a href="https://www.buymeacoffee.com/karthikponnam" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>