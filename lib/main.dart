import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/player.dart';
import 'package:jidoujisho/util.dart';

String appDirPath;
String previewImageDir;
String previewAudioDir;

String appName;
String packageName;
String version;
String buildNumber;

int sdkInt;

List<DictionaryEntry> customDictionary;
Fuzzy customDictionaryFuzzy;

bool isGooglePlayLimited = false;

final AsyncMemoizer trendingCache = AsyncMemoizer();
Map<String, AsyncMemoizer> searchCache = {};
Map<String, AsyncMemoizer> captioningCache = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

  await Permission.storage.request();
  Directory appDirDoc = await getApplicationDocumentsDirectory();
  appDirPath = appDirDoc.path;
  previewImageDir = appDirPath + "/exportImage.jpg";
  previewAudioDir = appDirPath + "/exportAudio.mp3";

  customDictionary = importCustomDictionary();
  customDictionaryFuzzy = Fuzzy(getAllImportedWords());

  runApp(App());
}

fetchTrendingCache() {
  return trendingCache.runOnce(() async {
    return searchYouTubeTrendingVideos();
  });
}

fetchSearchCache(String searchQuery) {
  if (searchCache[searchQuery] == null) {
    searchCache[searchQuery] = AsyncMemoizer();
  }
  return searchCache[searchQuery].runOnce(() async {
    return searchYouTubeVideos(searchQuery);
  });
}

fetchCaptioningCache(String videoID) {
  if (captioningCache[videoID] == null) {
    captioningCache[videoID] = AsyncMemoizer();
  }
  return captioningCache[videoID].runOnce(() async {
    return checkYouTubeClosedCaptionAvailable(videoID);
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.red,
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        cardColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        canvasColor: Colors.grey[900],
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: _buildAppBarLeading(),
          title: _buildAppBarTitleOrSearch(),
          actions: _buildActions(),
        ),
        backgroundColor: Colors.black,
        body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Player()))
                .then((returnValue) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            });
          },
          child: Icon(Icons.video_collection_sharp),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
      });
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    return false;
  }

  Widget _buildAppBarLeading() {
    if (_isSearching) {
      return BackButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
          });
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 0, 9),
        child: FadeInImage(
          image: AssetImage('assets/icon/icon.png'),
          placeholder: MemoryImage(kTransparentImage),
        ),
      );
    }
  }

  Widget _buildAppBarTitleOrSearch() {
    if (_isSearching) {
      return TextField(
        cursorColor: Colors.red,
        controller: _searchQueryController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search YouTube...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white30),
        ),
        textInputAction: TextInputAction.go,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
        onSubmitted: (query) => updateSearchQuery(query),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("jidoujisho"),
          Text(
            " $version beta",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    Widget centerMessage(String text, IconData icon) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 72,
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            )
          ],
        ),
      );
    }

    Widget searchMessage = centerMessage(
      "Enter keyword to search",
      Icons.youtube_searched_for,
    );
    Widget searchingMessage = centerMessage(
      "Searching for \"$searchQuery\"...",
      Icons.youtube_searched_for,
    );
    Widget queryMessage = centerMessage(
      "Querying trending videos...",
      Icons.youtube_searched_for,
    );
    Widget errorMessage = centerMessage(
      "Error getting videos",
      Icons.error,
    );
    Widget featureLockedMessage = ColorFiltered(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInImage(
                image: AssetImage("assets/icon/icon.png"),
                placeholder: MemoryImage(kTransparentImage),
                height: 72,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(height: 6),
              Text(
                "A video player for language learners",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "GETTING STARTED\n📲 Play a local media file with the lower right button to get started\n" +
                    "⏯️  Select subtitles by simply holding and drag to change selection\n" +
                    "📋 When the dictionary definition for the text shows up, the text is the current context\n" +
                    "📔 Closing the dictionary prompt will clear the clipboard\n" +
                    "🗑️ The current context may be used to open browser links to third-party websites\n" +
                    "🌐 You may swipe vertically to open the transcript, and you can pick a time or read subtitles\n" +
                    "↔️ Swipe horizontally to repeat the current subtitle audio\n\n" +
                    "EXPORTING TO ANKIDROID\n📤 You may also export the current context to an AnkiDroid card, including the current frame and audio\n" +
                    "🔤 Having a word in the clipboard will include the sentence, word, meaning and reading in the export\n" +
                    "📝 You may edit the sentence, word, meaning and reading text fields before sharing to AnkiDroid\n" +
                    "🔗 To finalise the export, share the exported text to AnkiDroid\n" +
                    "🃏 The front of the card will include the audio, video and sentence\n" +
                    "🎴 The back of the card will include the reading, word and meaning\n" +
                    "📑 You may apply text formatting to the card with the AnkiDroid editor once shared\n"
                        "⚛️ Extensive customisation of the Anki export is planned",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      colorFilter: ColorFilter.mode(Colors.black, BlendMode.saturation),
    );

    if (_isSearching && searchQuery == "") {
      return searchMessage;
    }

    if (isGooglePlayLimited) {
      return featureLockedMessage;
    }

    return FutureBuilder(
      future: _isSearching && searchQuery != ""
          ? fetchSearchCache(searchQuery)
          : fetchTrendingCache(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        List<Video> results = snapshot.data;

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            if (_isSearching && searchQuery != "") {
              return searchingMessage;
            } else if (_isSearching && searchQuery != "") {
              return searchMessage;
            } else {
              return queryMessage;
            }
            break;
          default:
            if (!snapshot.hasData) {
              return errorMessage;
            }
            return ListView.builder(
              addAutomaticKeepAlives: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Video result = results[index];
                print("VIDEO LISTED: $result");

                return YouTubeResult(
                  result,
                  captioningCache[result.id],
                  fetchCaptioningCache(result.id.value),
                  index,
                );
              },
            );
        }
      },
    );
  }

  _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String option = await showMenu(
      color: Colors.grey[900],
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: isGooglePlayLimited
          ? [
              PopupMenuItem<String>(
                  child: const Text('View on GitHub'), value: 'View on GitHub'),
              PopupMenuItem<String>(
                  child: const Text('Report a bug'), value: 'Report a bug'),
              PopupMenuItem<String>(
                  child: const Text('About this app'), value: 'About this app'),
            ]
          : [
              PopupMenuItem<String>(
                  child: const Text('Enter YouTube URL'),
                  value: 'Enter YouTube URL'),
              PopupMenuItem<String>(
                  child: const Text('View on GitHub'), value: 'View on GitHub'),
              PopupMenuItem<String>(
                  child: const Text('Report a bug'), value: 'Report a bug'),
              PopupMenuItem<String>(
                  child: const Text('About this app'), value: 'About this app'),
            ],
      elevation: 8.0,
    );

    switch (option) {
      case "Enter YouTube URL":
        TextEditingController _textFieldController = TextEditingController();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Enter YouTube URL"),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    String _webURL = _textFieldController.text;

                    try {
                      if (YoutubePlayer.convertUrlToId(_webURL) != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Player(streamURL: _webURL),
                          ),
                        ).then((returnValue) {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitDown,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                        });
                      }
                    } on Exception {
                      Navigator.pop(context);
                      print("INVALID LINK");
                    } catch (error) {
                      Navigator.pop(context);
                      print("INVALID LINK");
                    }
                  },
                ),
              ],
            );
          },
        );
        break;
      case "View on GitHub":
        await launch("https://github.com/lrorpilla/jidoujisho");
        break;
      case "Report a bug":
        await launch("https://github.com/lrorpilla/jidoujisho/issues/new");
        break;
      case "About this app":
        const String legalese = "A video player for language learners.\n\n" +
            "Built for the Japanese language learning community by Leo " +
            "Rafael Orpilla. Word definitions queried from Jisho.org. Logo " +
            "by Aaron Marbella.\n\nIf you like my work, you can help me out " +
            "by providing feedback, making a donation, reporting issues or " +
            "collaborating with me on further improvements on GitHub.";

        showLicensePage(
          context: context,
          applicationName: "jidoujisho",
          applicationIcon: Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Image(
              image: AssetImage("assets/icon/icon.png"),
              height: 48,
              width: 48,
            ),
          ),
          applicationVersion: version,
          applicationLegalese: legalese,
        );
        break;
    }
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _clearSearchQuery();
          },
        ),
        const SizedBox(width: 12),
        GestureDetector(
          child: const Icon(Icons.more_vert),
          onTapDown: (TapDownDetails details) {
            _showPopupMenu(details.globalPosition);
          },
        ),
        const SizedBox(width: 12),
      ];
    }

    return <Widget>[
      isGooglePlayLimited
          ? Container()
          : IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
      const SizedBox(width: 12),
      GestureDetector(
        child: const Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) {
          _showPopupMenu(details.globalPosition);
        },
      ),
      const SizedBox(width: 12),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    searchQuery = "";

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}

class YouTubeResult extends StatefulWidget {
  final Video result;
  final AsyncMemoizer cache;
  final cacheCallback;
  final int index;

  YouTubeResult(
    this.result,
    this.cache,
    this.cacheCallback,
    this.index,
  );

  _YouTubeResultState createState() => _YouTubeResultState(
        this.result,
        this.cache,
        this.cacheCallback,
        this.index,
      );
}

class _YouTubeResultState extends State<YouTubeResult>
    with AutomaticKeepAliveClientMixin {
  final Video result;
  final AsyncMemoizer cache;
  final cacheCallback;
  final int index;

  _YouTubeResultState(
    this.result,
    this.cache,
    this.cacheCallback,
    this.index,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String videoStreamURL = result.url;
    String videoThumbnailURL = result.thumbnails.highResUrl;

    String videoTitle = result.title;
    String videoChannel = result.author;
    String videoPublishTime =
        result.uploadDate == null ? "" : getTimeAgoFormatted(result.uploadDate);
    String videoViewCount = getViewCountFormatted(result.engagement.viewCount);
    String videoDetails = "$videoPublishTime · $videoViewCount views";
    String videoDuration =
        result.duration == null ? "" : getYouTubeDuration(result.duration);

    Widget displayThumbnail() {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: FadeInImage(
              image: NetworkImage(videoThumbnailURL),
              placeholder: MemoryImage(kTransparentImage),
              height: 480,
              fit: BoxFit.fitHeight,
            ),
          ),
          Positioned(
            right: 5.0,
            bottom: 20.0,
            child: Container(
              height: 20,
              color: Colors.black.withOpacity(0.8),
              alignment: Alignment.center,
              child: Text(
                videoDuration,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget displayVideoInformation() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 12, right: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                videoTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                videoChannel,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                videoDetails == "$videoPublishTime · 0 views"
                    ? "Trending #${index + 1} in Japan"
                    : videoDetails,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              showClosedCaptionStatus(
                context,
                result.id.value,
                index,
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Player(streamURL: videoStreamURL),
          ),
        ).then((returnValue) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        });
      },
      child: Container(
        height: 128,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            displayThumbnail(),
            displayVideoInformation(),
          ],
        ),
      ),
    );
  }

  FutureBuilder showClosedCaptionStatus(
    BuildContext context,
    String videoID,
    int index,
  ) {
    Widget closedCaptionRow(String text, Color color, IconData icon) {
      return Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          )
        ],
      );
    }

    Widget queryMessage = closedCaptionRow(
      "Querying for closed captions...",
      Colors.grey,
      Icons.youtube_searched_for,
    );
    Widget errorMessage = closedCaptionRow(
      "Error querying closed captions",
      Colors.grey,
      Icons.error,
    );
    Widget availableMessage = closedCaptionRow(
      "Closed captioning available",
      Colors.green[200],
      Icons.closed_caption,
    );
    Widget unavailableMessage = closedCaptionRow(
      "No closed captioning",
      Colors.red[200],
      Icons.closed_caption_disabled,
    );

    return FutureBuilder(
      future: cacheCallback,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return errorMessage;
          } else {
            bool hasClosedCaptions = snapshot.data;
            if (hasClosedCaptions) {
              return availableMessage;
            } else {
              return unavailableMessage;
            }
          }
        } else {
          return queryMessage;
        }
      },
    );
  }
}
