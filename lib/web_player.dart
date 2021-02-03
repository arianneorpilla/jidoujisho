// import 'dart:convert';

// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:jidoujisho/main.dart';
// import 'package:subtitle_wrapper_package/subtitle_controller.dart';
// import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
// import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:unofficial_jisho_api/api.dart' as jisho;
// import 'package:ext_video_player/ext_video_player.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml2json/xml2json.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import 'package:jidoujisho/main.dart';
// import 'package:jidoujisho/util.dart';

// class WebPlayer extends StatelessWidget {
//   WebPlayer({this.webURL});

//   final String webURL;

//   @override
//   Widget build(BuildContext context) {
//     String videoID = "";

//     try {
//       videoID = YoutubePlayer.convertUrlToId(webURL);
//       print(videoID);
//     } catch (error) {
//       print("Invalid link");
//       return Container();
//     }

//     return new FutureBuilder(
//       future: http.read(
//         "https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID,
//       ),
//       builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Scaffold(
//               backgroundColor: Colors.black,
//               body: Center(
//                 child: Container(
//                   height: 30,
//                   width: 30,
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//             );
//           default:
//             print("https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID);

//             if (!snapshot.hasData || snapshot.data.isEmpty) {
//               subtitles = "";
//             } else {
//               subtitles = timedTextToSRT(snapshot.data);
//             }

//             return WebVideoPlayer(webURL: webURL);
//         }
//       },
//     );
//   }
// }

// class WebVideoPlayer extends StatefulWidget {
//   WebVideoPlayer({
//     this.webURL,
//     this.webSubtitles,
//     Key key,
//   }) : super(key: key);

//   final String webURL;
//   final String webSubtitles;

//   @override
//   _WebVideoPlayerState createState() =>
//       _WebVideoPlayerState(this.webURL, this.webSubtitles);
// }

// class _WebVideoPlayerState extends State<WebVideoPlayer> {
//   _WebVideoPlayerState(String webURL, String webSubtitles) {
//     _webURL = webURL;
//     _webSubtitles = webSubtitles;
//   }

//   VideoPlayerController _videoPlayerController;
//   ChewieController _chewieController;
//   SubTitleWrapper _subTitleWrapper;

//   String _webURL;
//   String _webSubtitles;

//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//             title: new Text('End Playback?'),
//             actions: <Widget>[
//               new FlatButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: new Text('NO'),
//               ),
//               new FlatButton(
//                 onPressed: () async {
//                   Phoenix.rebirth(context);
//                 },
//                 child: new Text('YES'),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//       onWillPop: _onWillPop,
//       child: new Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             GestureDetector(
//               onHorizontalDragUpdate: (details) {
//                 if (details.delta.dx > 20) {
//                   getVideoPlayerController().seekTo(currentSubtitle.endTime);
//                 } else if (details.delta.dx < -20) {
//                   getVideoPlayerController().seekTo(currentSubtitle.startTime);
//                 }
//               },
//               child: getSubtitleWrapper(),
//             ),
//             buildDictionary(),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (_videoPlayerController != null && _chewieController != null) {
//       _videoPlayerController?.dispose();
//       _chewieController?.dispose();
//     }
//   }

//   VideoPlayerController getVideoPlayerController() {
//     _videoPlayerController ??=
//         VideoPlayerController.network(_webURL, _subTitleWrapper);
//     return _videoPlayerController;
//   }

//   ChewieController getChewieController() {
//     _chewieController ??= ChewieController(
//       videoPlayerController: getVideoPlayerController(),
//       aspectRatio: getVideoPlayerController().value.aspectRatio,
//       autoPlay: true,
//       autoInitialize: true,
//       allowFullScreen: false,
//       allowMuting: false,
//       materialProgressColors: ChewieProgressColors(
//         playedColor: Colors.redAccent,
//         handleColor: Colors.redAccent,
//         backgroundColor: Colors.grey,
//         bufferedColor: Colors.redAccent[100],
//       ),
//       fullScreenByDefault: false,
//       allowedScreenSleep: false,
//     );
//     return _chewieController;
//   }

//   SubTitleWrapper getSubtitleWrapper() {
//     _subTitleWrapper ??= SubTitleWrapper(
//       videoPlayerController: getVideoPlayerController(),
//       subtitleController: SubtitleController(
//         subtitlesContent: _webSubtitles,
//         showSubtitles: true,
//         subtitleDecoder: SubtitleDecoder.utf8,
//         subtitleType: SubtitleType.srt,
//       ),
//       subtitleStyle: SubtitleStyle(
//         textColor: Colors.white,
//         hasBorder: true,
//         fontSize: 24,
//       ),
//       videoChild: FutureBuilder(
//         future: getVideoPlayerController().initialize(),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Container();
//             default:
//               _chewieController = getChewieController();
//               return FutureBuilder(
//                 future: getVideoPlayerController().setAudioByIndex(0),
//                 builder: (BuildContext context, AsyncSnapshot snapshot) {
//                   switch (snapshot.connectionState) {
//                     case ConnectionState.waiting:
//                       return Container();
//                     default:
//                       return Chewie(
//                         controller: _chewieController,
//                       );
//                   }
//                 },
//               );
//           }
//         },
//       ),
//     );

//     return _subTitleWrapper;
//   }

//   Widget buildDictionaryLoading(String clipboard) {
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             color: Theme.of(context).backgroundColor.withOpacity(0.6),
//             child: Column(
//               children: [
//                 Text("Looking up \"" + clipboard + "\" on Jisho.org...")
//               ],
//             ),
//           ),
//         ),
//         Expanded(child: Container()),
//       ],
//     );
//   }

//   Widget buildDictionaryNoMatch(String clipboard) {
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: InkWell(
//             onTap: () {
//               globalClipboard.value = "";
//               currentDefinition = "";
//             },
//             child: Container(
//               padding: EdgeInsets.all(16.0),
//               color: Theme.of(context).backgroundColor.withOpacity(0.6),
//               child:
//                   Text("No matches for \"" + clipboard + "\" could be queried"),
//             ),
//           ),
//         ),
//         Expanded(child: Container()),
//       ],
//     );
//   }

//   Widget buildDictionaryMatch(List<String> results) {
//     String slug = results[0];
//     String readings = results[1];
//     String definitions = results[2];

//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: GestureDetector(
//             onTap: () {
//               globalClipboard.value = "";
//               currentDefinition = "";
//             },
//             child: Container(
//               padding: EdgeInsets.all(16.0),
//               color: Theme.of(context).backgroundColor.withOpacity(0.6),
//               child: Column(
//                 children: [
//                   Text(
//                     slug,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//                   Text(readings),
//                   Text("\n$definitions\n"),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Expanded(child: Container()),
//       ],
//     );
//   }

//   Widget buildDictionary() {
//     return ValueListenableBuilder(
//       valueListenable: globalClipboard,
//       builder: (context, clipboard, widget) {
//         return FutureBuilder(
//           future: getWordDetails(clipboard),
//           builder:
//               (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
//             if (globalClipboard.value == "") {
//               return Container();
//             }
//             switch (snapshot.connectionState) {
//               case ConnectionState.waiting:
//                 return buildDictionaryLoading(clipboard);
//               default:
//                 List<String> results = snapshot.data;

//                 if (snapshot.hasData) {
//                   return buildDictionaryMatch(results);
//                 } else {
//                   return buildDictionaryNoMatch(clipboard);
//                 }
//             }
//           },
//         );
//       },
//     );
//   }
// }
