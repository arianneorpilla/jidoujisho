import 'dart:io';
import 'package:async/async.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart' as ph;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:jidoujisho/player.dart';
import 'package:jidoujisho/util.dart';

List<DictionaryEntry> customDictionary;
Fuzzy customDictionaryFuzzy;

String appDirPath;
String previewImageDir;
String previewAudioDir;

String appName;
String packageName;
String version;
String buildNumber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  await FilePicker.platform.clearTemporaryFiles();

  Directory appDirDoc = await ph.getApplicationDocumentsDirectory();
  appDirPath = appDirDoc.path;

  previewImageDir = appDirPath + "/exportImage.jpg";
  previewAudioDir = appDirPath + "/exportAudio.mp3";

  await Permission.storage.request();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

  customDictionary = importCustomDictionary();
  customDictionaryFuzzy = Fuzzy(getAllImportedWords());

  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        cardColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        canvasColor: Colors.grey[900],
        /* light theme settings */
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  YoutubeAPI ytApi =
      new YoutubeAPI("ENTER API KEY HERE", maxResults: 10, type: "video");
  final AsyncMemoizer _trendingCache = AsyncMemoizer();
  Map<String, AsyncMemoizer> _captioningCache = {};

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  Widget _buildTitle(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("jidoujisho"),
        Text(
          " " + version + " beta",
          style: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
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
  }

  _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String option = await showMenu(
      color: Colors.grey[900],
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            child: const Text('View on GitHub'), value: 'View on GitHub'),
        PopupMenuItem<String>(
            child: const Text('Report a bug'), value: 'Report a bug'),
        PopupMenuItem<String>(
            child: const Text('About this app'), value: 'About this app'),
      ],
      elevation: 8.0,
    );

    const String legalese = "A video player for language learners.\n\n" +
        "Built for the Japanese language learning community by Leo Rafael " +
        "Orpilla. Word definitions queried " +
        "from Jisho.org. Logo by Aaron Marbella.\n\nIf you like my work, you can help me out " +
        "by providing feedback, making a donation, reporting issues or collaborating with me " +
        "on further improvements on GitHub.";

    switch (option) {
      case "About this app":
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
      case "View on GitHub":
        await launch("https://github.com/lrorpilla/jidoujisho");
        break;
      case "Report a bug":
        await launch("https://github.com/lrorpilla/jidoujisho/issues/new");
        break;
      default:
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
        SizedBox(width: 12),
        GestureDetector(
          child: const Icon(Icons.more_vert),
          onTapDown: (TapDownDetails details) {
            _showPopupMenu(details.globalPosition);
          },
        ),
        SizedBox(width: 12),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      SizedBox(width: 12),
      GestureDetector(
        child: const Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) {
          _showPopupMenu(details.globalPosition);
        },
      ),
      SizedBox(width: 12),
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
    if (YoutubePlayer.convertUrlToId(newQuery) != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Player(newQuery),
        ),
      );
    } else {
      setState(() {
        searchQuery = newQuery;
      });
    }
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

  _fetchTrendingCache() {
    return this._trendingCache.runOnce(() async {
      return ytApi.getTrends(regionCode: "JP");
    });
  }

  _fetchCaptioningCache(String videoID) {
    if (_captioningCache[videoID] == null) {
      _captioningCache[videoID] = AsyncMemoizer();
    }
    return this._captioningCache[videoID].runOnce(() async {
      return doesYouTubeIDHaveSubtitles(videoID);
    });
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

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: _isSearching
              ? BackButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 9, 0, 9),
                  child: FadeInImage(
                    image: AssetImage('assets/icon/icon.png'),
                    placeholder: MemoryImage(kTransparentImage),
                  ),
                ),
          title: _isSearching ? _buildSearchField() : _buildTitle(context),
          actions: _buildActions(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Player("")));
          },
          child: Icon(Icons.video_collection_sharp),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Container(
          // use LayoutBuilder to fetch the parent widget's constraints
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  buildResults(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildResults(BuildContext context) {
    if (_isSearching && searchQuery == "") {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.youtube_searched_for, color: Colors.grey, size: 72),
              SizedBox(height: 6),
              Text(
                "Enter keyword to search or use video ID",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder(
        future: _isSearching && searchQuery != ""
            ? ytApi.search(searchQuery)
            : _fetchTrendingCache(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          List<YT_API> results = snapshot.data;

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.youtube_searched_for,
                          color: Colors.grey, size: 72),
                      SizedBox(height: 6),
                      Text(
                        _isSearching && searchQuery != ""
                            ? "Searching for \"$searchQuery\"..."
                            : "Querying trending videos...",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            default:
              if (!snapshot.hasData) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.grey, size: 72),
                        SizedBox(height: 6),
                        Text(
                          "Error getting videos",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    YT_API result = results[index];
                    return YouTubeResult(
                      result,
                      _captioningCache[result.id],
                      _fetchCaptioningCache(result.id),
                    );
                  },
                ),
              );
          }
        });
  }
}

class YouTubeResult extends StatefulWidget {
  final YT_API result;
  final AsyncMemoizer cache;
  final callback;
  YouTubeResult(
    this.result,
    this.cache,
    this.callback,
  );
  _YouTubeResultState createState() => _YouTubeResultState(
        this.result,
        this.cache,
        this.callback,
      );
}

class _YouTubeResultState extends State<YouTubeResult>
    with AutomaticKeepAliveClientMixin {
  final YT_API result;
  final AsyncMemoizer cache;
  final callback;

  _YouTubeResultState(this.result, this.cache, this.callback);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String thumbnailURL = result.thumbnail["high"]["url"];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Player(result.url),
          ),
        );
      },
      child: Container(
        height: 128,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                FadeInImage(
                  image: NetworkImage(thumbnailURL),
                  placeholder: MemoryImage(kTransparentImage),
                  height: 480,
                ),
                Positioned(
                  right: 5.0,
                  bottom: 20.0,
                  child: Container(
                    height: 20,
                    color: Colors.black.withOpacity(0.8),
                    alignment: Alignment.center,
                    child: Text(
                      (result.duration.contains(":"))
                          ? "  " + result.duration + "  "
                          : "  0:" + result.duration + "  ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 12, right: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 6),
                    Text(
                      result.channelTitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    Text(
                      displayTimeAgoFromTimestamp(result.publishedAt) +
                          " · " +
                          getViewCountFormatted(int.parse(result.viewCount)) +
                          " views",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    showHasSubtitlesText(context, result.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder showHasSubtitlesText(BuildContext context, String videoID) {
    return FutureBuilder(
        future: callback,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Row(
                children: [
                  Icon(Icons.youtube_searched_for,
                      color: Colors.grey, size: 12),
                  SizedBox(width: 3),
                  Text(
                    "Querying for subtitles...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  )
                ],
              );
              break;
            default:
              if (snapshot.data == null) {
                return Row(
                  children: [
                    Icon(Icons.youtube_searched_for,
                        color: Colors.grey, size: 12),
                    SizedBox(width: 3),
                    Text(
                      "Querying for subtitles...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    )
                  ],
                );
              }
              return Row(
                children: [
                  Icon(
                      snapshot.data
                          ? Icons.closed_caption
                          : Icons.closed_caption_disabled,
                      color:
                          snapshot.data ? Colors.green[200] : Colors.red[200],
                      size: 12),
                  SizedBox(width: 3),
                  Text(
                    snapshot.data
                        ? "Closed captioning available"
                        : "No closed captioning" ?? "No closed captioning",
                    style: TextStyle(
                      color:
                          snapshot.data ? Colors.green[200] : Colors.red[200],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  )
                ],
              );
          }
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
