import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/player.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';

typedef void ChannelCallback(String id, String name, bool isReversed);
typedef void CreatorCallback(DictionaryEntry entry, File file);
typedef void SearchCallback(String term);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await Permission.storage.request();
  requestAnkiDroidPermissions();

  gAppDirPath = (await getApplicationDocumentsDirectory()).path;
  gPackageInfo = await PackageInfo.fromPlatform();

  gMecabTagger = Mecab();
  await gMecabTagger.init("assets/ipadic", true);

  gSharedPrefs = await SharedPreferences.getInstance();
  gIsResumable = ValueNotifier<bool>(getResumeAvailable());
  gIsSelectMode = ValueNotifier<bool>(getSelectMode());

  gCustomDictionary = importCustomDictionary();
  gCustomDictionaryFuzzy =
      Fuzzy(getAllImportedWords(), options: FuzzyOptions());

  await AudioService.connect();
  await AudioService.start(
    backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
  );

  runApp(App());

  handleAppLifecycleState();
}

handleAppLifecycleState() {
  SystemChannels.lifecycle.setMessageHandler((msg) {
    print(msg);

    switch (msg) {
      case "AppLifecycleState.resumed":
        AudioService.start(
          backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        );
        break;
      default:
    }

    return null;
  });
}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayerTask();

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.sendCustomEvent("playPause");
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.sendCustomEvent("playPause");
  }

  @override
  Future<void> onFastForward() async {
    AudioServiceBackground.sendCustomEvent("rewindFastForward");
  }

  @override
  Future<void> onRewind() async {
    AudioServiceBackground.sendCustomEvent("rewindFastForward");
  }

  @override
  Future<void> onTaskRemoved() async {}
}

void unlockLandscape() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
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
      home: AudioServiceWidget(child: Home()),
    );
  }
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool _isChannelView = false;
  bool _isCreatorView = false;
  bool _isOldest = false;

  DictionaryEntry _creatorDictionaryEntry = DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  );
  File _creatorFile;

  String _searchQuery = "";
  int _selectedIndex = 0;
  String _selectedChannelName = "";
  ValueNotifier<List<String>> _searchSuggestions =
      ValueNotifier<List<String>>([]);
  YoutubeExplode yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();

    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      setCreatorView(DictionaryEntry(word: "", meaning: "", reading: ""),
          File(value.first.path));
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) {
        return;
      }

      setCreatorView(DictionaryEntry(word: "", meaning: "", reading: ""),
          File(value.first.path));
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      if (value == null) {
        return;
      }
      if (value.startsWith("https://")) {
        playYouTubeVideoLink(value);
      } else {
        setCreatorView(
            DictionaryEntry(word: value, meaning: "", reading: ""), null);
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value == null) {
        return;
      }

      if (value.startsWith("https://")) {
        playYouTubeVideoLink(value);
      } else {
        setCreatorView(
            DictionaryEntry(word: value, meaning: "", reading: ""), null);
      }
    });
  }

  void playYouTubeVideoLink(String link) {
    if (YoutubePlayer.convertUrlToId(link) != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Player(
            url: link,
          ),
        ),
      ).then((returnValue) {
        setState(() {
          unlockLandscape();
        });

        setLastPlayedPath(link);
        setLastPlayedPosition(0);
        gIsResumable.value = getResumeAvailable();
      });
    }
  }

  void setStateFromResult() {
    setState(() {});
  }

  void onItemTapped(int index) {
    setState(() {
      if (getNavigationBarItems()[index].label == "Library") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Player(),
          ),
        ).then((returnValue) {
          unlockLandscape();
        });
      } else {
        _selectedIndex = index;
        if (_isSearching || _isChannelView || _isCreatorView) {
          _isSearching = false;
          _isChannelView = false;
          _isCreatorView = false;
          _searchQuery = "";
        }
      }
    });
  }

  Widget getWidgetOptions(int index) {
    if (_isSearching) {
      return buildBody();
    } else if (_isChannelView) {
      return buildChannels();
    } else if (_isCreatorView) {
      return Creator(
        "",
        _creatorDictionaryEntry,
        _creatorFile,
      );
    }

    switch (getNavigationBarItems()[index].label) {
      case "Trending":
        return buildBody();
      case "Channels":
        return buildChannels();
      case "History":
        return History();
      case "Clipboard":
        return ClipboardMenu(setCreatorView);
      default:
        return Container();
    }
  }

  List<BottomNavigationBarItem> getNavigationBarItems() {
    List<BottomNavigationBarItem> items = [];

    if (gIsYouTubeAllowed) {
      items.addAll(
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot_sharp),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_sharp),
            label: 'Channels',
          ),
        ],
      );
    }

    items.addAll(
      [
        BottomNavigationBarItem(
          icon: Icon(Icons.history_sharp),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.paste_sharp),
          label: 'Clipboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_sharp),
          label: 'Library',
        ),
      ],
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    unlockLandscape();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: buildAppBarLeading(),
          title: buildAppBarTitleOrSearch(),
          actions: buildActions(),
        ),
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          unselectedLabelStyle: TextStyle(color: Colors.grey),
          selectedLabelStyle: TextStyle(color: Colors.red),
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
          items: getNavigationBarItems(),
        ),
        body: getWidgetOptions(_selectedIndex),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isSearching || _isChannelView || _isCreatorView) {
      setState(() {
        _isSearching = false;
        _isChannelView = false;
        _isCreatorView = false;
        _searchQuery = "";
        _searchSuggestions.value = [];
        _searchQueryController.clear();
      });
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    return false;
  }

  Widget buildAppBarLeading() {
    if (_isSearching || _isChannelView || _isCreatorView) {
      return BackButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
            _isChannelView = false;
            _isCreatorView = false;
            _searchQuery = "";
            _searchSuggestions.value = [];
            _searchQueryController.clear();
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

  Widget buildAppBarTitleOrSearch() {
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
        onChanged: (query) => updateSuggestions(query),
        onSubmitted: (query) => updateSearchQuery(query),
      );
    } else if (_isChannelView) {
      return Text(
        _selectedChannelName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (_isCreatorView) {
      return Text(
        "Card Creator",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("jidoujisho"),
          Text(
            " ${gPackageInfo.version} beta",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget buildChannels() {
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

    Widget queryMessage = centerMessage(
      "Listing channels...",
      Icons.subscriptions_sharp,
    );
    Widget errorMessage = centerMessage(
      "Error getting channels",
      Icons.error,
    );
    Widget emptyMessage = centerMessage(
      "No channels listed",
      Icons.subscriptions_sharp,
    );
    Widget videoMessage = centerMessage(
      _isOldest ? "Listing oldest videos..." : "Listing latest videos...",
      Icons.subscriptions_sharp,
    );

    if (_isChannelView && _searchQuery != null) {
      return FutureBuilder(
        future: fetchChannelVideoCache(_searchQuery),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          var results = snapshot.data;

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return videoMessage;
              break;
            default:
              if (!snapshot.hasData) {
                gChannelVideoCache[_searchQuery] = AsyncMemoizer();
                return errorMessage;
              }

              return LazyResults(results, _isOldest);
          }
        },
      );
    } else {
      return FutureBuilder(
        future: fetchChannelCache(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          var results = snapshot.data;

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return queryMessage;
            default:
              if (!snapshot.hasData) {
                gChannelCache = AsyncMemoizer();
                return errorMessage;
              }

              if (snapshot.data.isNotEmpty) {
                return ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return buildNewChannelRow();
                    }

                    Channel result = results[index - 1];
                    print("CHANNEL LISTED: $result");

                    return ChannelResult(
                      result,
                      setChannelVideoSearch,
                      setStateFromResult,
                      index,
                    );
                  },
                );
              } else {
                return Column(children: [
                  buildNewChannelRow(),
                  Expanded(child: emptyMessage),
                ]);
              }
          }
        },
      );
    }
  }

  Widget buildNewChannelRow() {
    String channelTitle = "List new channel";

    Widget displayThumbnail() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          alignment: Alignment.center,
          height: 36,
          width: 36,
          color: Colors.grey[900],
          child: Icon(
            Icons.add,
            color: Colors.grey,
            size: 16,
          ),
        ),
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
                channelTitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
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
                decoration: InputDecoration(
                    hintText: "Enter link to any video by channel"),
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
                  onPressed: () async {
                    String _input = _textFieldController.text;
                    await addNewChannel(_input);

                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        height: 48,
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

  void setChannelVideoSearch(
    String channelID,
    String channelName,
    bool isOldest,
  ) {
    setState(() {
      _isChannelView = true;
      _searchQuery = channelID;
      _selectedChannelName = channelName;
      _isOldest = isOldest;
    });
  }

  Future<void> setCreatorView(
    DictionaryEntry dictionaryEntry,
    File file,
  ) async {
    try {
      await getDecks();
      setState(() {
        _isCreatorView = true;
        _creatorDictionaryEntry = dictionaryEntry;
        _creatorFile = file;
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: Text(
                "The AnkiDroid background service must be active to use "
                "the card creator. Please launch AnkiDroid and return "
                "to continue.",
                textAlign: TextAlign.justify,
              ),
              actions: <Widget>[
                new TextButton(
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
                new TextButton(
                  child: Text(
                    'LAUNCH ANKIDROID',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'com.ichi2.anki',
                      openStore: true,
                    );
                    Navigator.pop(context);

                    try {
                      await getDecks();
                      setState(() {
                        _isCreatorView = true;
                        _creatorDictionaryEntry = dictionaryEntry;
                        _creatorFile = file;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            );
          });
    }
  }

  Widget generateSuggestions() {
    return ValueListenableBuilder(
      valueListenable: _searchSuggestions,
      builder: (BuildContext context, List<String> suggestions, ___) {
        return ListView.builder(
          key: UniqueKey(),
          itemCount: suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            String result = suggestions[index];

            return SearchResult(
              result,
              updateSearchQuery,
              null,
              index,
              Icons.search,
            );
          },
        );
      },
    );
  }

  Widget generateHistory() {
    List<String> searchHistory = getSearchHistory().reversed.toList();

    return ListView.builder(
      key: UniqueKey(),
      itemCount: searchHistory.length,
      itemBuilder: (BuildContext context, int index) {
        String result = searchHistory[index];

        return SearchResult(
          result,
          updateSearchQuery,
          setStateFromResult,
          index,
          Icons.history,
        );
      },
    );
  }

  Widget buildBody() {
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
      "Searching for \"$_searchQuery\"...",
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

    if (_isSearching &&
        _searchQuery == "" &&
        _searchSuggestions.value.isNotEmpty) {
      return generateSuggestions();
    } else if (_isSearching &&
        _searchQuery == "" &&
        getSearchHistory().isNotEmpty) {
      return generateHistory();
    } else if (_isSearching &&
        _searchQuery == "" &&
        getSearchHistory().isEmpty) {
      return searchMessage;
    }

    return FutureBuilder(
      future: _isSearching && _searchQuery != ""
          ? fetchSearchCache(_searchQuery)
          : fetchTrendingCache(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        var results = snapshot.data;

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            if (_isSearching && _searchQuery != "") {
              return searchingMessage;
            } else if (_isSearching && _searchQuery != "") {
              return searchMessage;
            } else {
              return queryMessage;
            }
            break;
          default:
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              if (_isSearching) {
                gSearchCache[_searchQuery] = AsyncMemoizer();
              } else {
                gTrendingCache = AsyncMemoizer();
              }
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
                  gCaptioningCache[result.id],
                  fetchCaptioningCache(result.id.value),
                  (_isSearching)
                      ? fetchMetadataCache(result.id.value, result)
                      : null,
                  index,
                  true,
                );
              },
            );
        }
      },
    );
  }

  showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String option = await showMenu(
      color: Colors.grey[900],
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
          child: const Text('Enter YouTube URL'),
          value: 'Enter YouTube URL',
          enabled: gIsYouTubeAllowed,
        ),
        PopupMenuItem<String>(
          child: const Text('Import/export channels'),
          value: 'Import/export channels',
          enabled: gIsYouTubeAllowed,
        ),
        PopupMenuItem<String>(
          child: const Text('View repository on GitHub'),
          value: 'View repository on GitHub',
        ),
        PopupMenuItem<String>(
          child: const Text('Report a bug or problem'),
          value: 'Report a bug or problem',
        ),
        PopupMenuItem<String>(
          child: const Text('Set AnkiDroid directory'),
          value: 'Set AnkiDroid directory',
        ),
        PopupMenuItem<String>(
          child: const Text('Set term bank directory'),
          value: 'Set term bank directory',
        ),
        PopupMenuItem<String>(
          child: const Text('About this app'),
          value: 'About this app',
        ),
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
                    String webURL = _textFieldController.text;

                    try {
                      if (YoutubePlayer.convertUrlToId(webURL) != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Player(
                              url: webURL,
                            ),
                          ),
                        ).then((returnValue) {
                          setState(() {
                            unlockLandscape();
                          });

                          setLastPlayedPath(webURL);
                          setLastPlayedPosition(0);
                          gIsResumable.value = getResumeAvailable();
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
      case "Import/export channels":
        String initialText = getChannelList().join("\n");
        TextEditingController _textFieldController = TextEditingController(
          text: initialText,
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: TextField(
                controller: _textFieldController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    hintText: "Paste channel IDs line by line to import here"),
                expands: true,
                maxLines: null,
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
                  onPressed: () async {
                    String currentText = _textFieldController.text;
                    if (initialText == currentText) {
                      Navigator.pop(context);
                    } else {
                      List<String> newChannelIDs = currentText.split("\n");
                      newChannelIDs.forEach((channelID) => channelID.trim());
                      newChannelIDs
                          .removeWhere((channelID) => channelID.isEmpty);
                      await setChannelList(newChannelIDs);
                      gChannelCache = AsyncMemoizer();
                      setChannelCache([]);

                      setStateFromResult();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
        break;
      case "View repository on GitHub":
        await launch("https://github.com/lrorpilla/jidoujisho");
        break;
      case "Report a bug or problem":
        await launch("https://github.com/lrorpilla/jidoujisho/issues/new");
        break;
      case "Set AnkiDroid directory":
        String currentDirectoryPath = getAnkiDroidDirectory().path;
        TextEditingController _textFieldController = TextEditingController(
          text: currentDirectoryPath,
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                    hintText: "storage/emulated/0/AnkiDroid",
                    labelText: 'AnkiDroid directory path'),
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
                  onPressed: () async {
                    String newDirectoryPath = _textFieldController.text;
                    Directory newDirectory = Directory(newDirectoryPath);

                    if (newDirectory.existsSync()) {
                      await setAnkiDroidDirectory(newDirectory);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
        break;
      case "Set term bank directory":
        String currentDirectoryPath = getTermBankDirectory().path;
        TextEditingController _textFieldController = TextEditingController(
          text: currentDirectoryPath,
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                    hintText: "storage/emulated/0/jidoujisho",
                    labelText: 'Term bank directory path'),
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
                  onPressed: () async {
                    String newDirectoryPath = _textFieldController.text;
                    Directory newDirectory = Directory(newDirectoryPath);

                    if (newDirectory.existsSync()) {
                      await setTermBankDirectory(newDirectory);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
        break;
      case "About this app":
        const String legalese = "A mobile video player for language learners.\n\n" +
            "Built for the Japanese language learning community by Leo Rafael Orpilla. " +
            "Bilingual definitions queried from Jisho.org. Monolingual definitions queried from Goo.ne.jp. Logo by Aaron Marbella.\n\n" +
            "jidoujisho is free and open source software. Liking the application? " +
            "Help out by providing feedback, making a donation, reporting issues or collaborating " +
            "for further improvements on GitHub.";

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
          applicationVersion: gPackageInfo.version,
          applicationLegalese: legalese,
        );
        break;
    }
  }

  Widget buildResume() {
    return ValueListenableBuilder(
      valueListenable: gIsResumable,
      builder: (_, __, ___) {
        if (gIsResumable.value) {
          return IconButton(
            icon: const Icon(Icons.update_sharp),
            onPressed: () async {
              int lastPlayedPosition = getLastPlayedPosition();
              String lastPlayedPath = getLastPlayedPath();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Player(
                    url: lastPlayedPath,
                    initialPosition: lastPlayedPosition,
                  ),
                ),
              ).then((returnValue) {
                unlockLandscape();
              });
            },
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.update_sharp,
              size: 24,
              color: Colors.grey[800],
            ),
          );
        }
      },
    );
  }

  List<Widget> buildActions() {
    return <Widget>[
      buildResume(),
      const SizedBox(width: 6),
      buildSearchButton(),
      const SizedBox(width: 12),
      GestureDetector(
        child: const Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) {
          showPopupMenu(details.globalPosition);
        },
      ),
      const SizedBox(width: 12),
    ];
  }

  Widget buildSearchButton() {
    if (gIsYouTubeAllowed) {
      if (_isSearching) {
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _clearSearchQuery();
          },
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.search),
          onPressed: startSearch,
        );
      }
    } else {
      return Container();
    }
  }

  void startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    _searchQuery = "";

    setState(() {
      _isSearching = true;
    });
  }

  void updateSuggestions(String newQuery) {
    if (newQuery == "") {
      setState(() {
        _searchSuggestions.value = [];
      });
    }

    yt.search.getQuerySuggestions(newQuery).then((results) {
      setState(() {
        _searchSuggestions.value = results;
      });
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      _searchQueryController.text = newQuery;
      _searchSuggestions.value = [];
      _searchQuery = newQuery;
      addSearchHistory(newQuery);
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
      _searchSuggestions.value = [];
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
  final metadataCallback;
  final int index;
  final bool trending;

  YouTubeResult(
    this.result,
    this.cache,
    this.cacheCallback,
    this.metadataCallback,
    this.index,
    this.trending,
  );

  _YouTubeResultState createState() => _YouTubeResultState(
        this.result,
        this.cache,
        this.cacheCallback,
        this.metadataCallback,
        this.index,
        this.trending,
      );
}

class _YouTubeResultState extends State<YouTubeResult>
    with AutomaticKeepAliveClientMixin {
  final Video result;
  final AsyncMemoizer cache;
  final cacheCallback;
  final metadataCallback;
  final int index;
  final bool trending;

  _YouTubeResultState(
    this.result,
    this.cache,
    this.cacheCallback,
    this.metadataCallback,
    this.index,
    this.trending,
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
              showVideoPublishStatus(
                context,
                result.id.value,
                index,
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

    void playVideo() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Player(
            url: videoStreamURL,
            video: result,
          ),
        ),
      ).then((returnValue) {
        unlockLandscape();

        setLastPlayedPath(videoStreamURL);
        setLastPlayedPosition(0);
        gIsResumable.value = getResumeAvailable();
      });
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              content: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage(
                  image: NetworkImage(result.thumbnails.highResUrl),
                  placeholder: MemoryImage(kTransparentImage),
                  width: 1280,
                  fit: BoxFit.fitWidth,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('LIST CHANNEL',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await addNewChannel(videoStreamURL);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    'PLAY VIDEO',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    print("doesnt work");
                    Navigator.pop(context);
                    playVideo();
                  },
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        playVideo();
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

  Widget showVideoPublishStatus(
    BuildContext context,
    String videoID,
    int index,
  ) {
    Widget metadataRow(String text, Color color) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      );
    }

    Widget trendingMessage = Text(
      "Trending #${index + 1} in Japan",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (metadataCallback == null) {
      if (trending) {
        return trendingMessage;
      } else {
        return Container();
      }
    }

    Widget queryMessage = metadataRow(
      "Getting engagement metrics...",
      Colors.grey,
    );
    Widget errorMessage = metadataRow(
      "Error querying engagement metrics",
      Colors.grey,
    );

    return FutureBuilder(
      future: metadataCallback,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String videoDetails = snapshot.data;
          if (!snapshot.hasData) {
            gMetadataCache[result.id.value] = AsyncMemoizer();
            return errorMessage;
          } else {
            return Text(
              videoDetails,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            );
          }
        } else {
          return queryMessage;
        }
      },
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
            gCaptioningCache[result.id.value] = AsyncMemoizer();
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

class ChannelResult extends StatefulWidget {
  final Channel result;
  final ChannelCallback callback;
  final VoidCallback stateCallback;
  final int index;

  ChannelResult(
    this.result,
    this.callback,
    this.stateCallback,
    this.index,
  );

  _ChannelResultState createState() => _ChannelResultState(
        this.result,
        this.callback,
        this.stateCallback,
        this.index,
      );
}

class _ChannelResultState extends State<ChannelResult>
    with AutomaticKeepAliveClientMixin {
  final Channel result;
  final ChannelCallback callback;
  final stateCallback;
  final int index;

  _ChannelResultState(
    this.result,
    this.callback,
    this.stateCallback,
    this.index,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String channelLogoURL = result.logoUrl;
    String channelTitle = result.title;

    Widget displayThumbnail() {
      return Stack(alignment: Alignment.bottomRight, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: FadeInImage(
            fit: BoxFit.cover,
            width: 36,
            height: 36,
            placeholder: MemoryImage(kTransparentImage),
            image: NetworkImage(channelLogoURL),
          ),
        ),
      ]);
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
                channelTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        callback(result.id.toString(), result.title, false);
      },
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                "${result.title}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 144,
                  width: 144,
                  color: Colors.transparent,
                  child: FadeInImage(
                    image: NetworkImage(result.logoUrl),
                    placeholder: MemoryImage(kTransparentImage),
                    width: 144,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('OLDEST VIDEOS',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                    callback(result.id.toString(), result.title, true);
                  },
                ),
                TextButton(
                  child: Text('LATEST VIDEOS',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                    callback(result.id.toString(), result.title, false);
                  },
                ),
                TextButton(
                  child: Text('UNLIST CHANNEL',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await removeChannel(result);

                    stateCallback();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        height: 48,
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
}

class SearchResult extends StatefulWidget {
  final String result;
  final SearchCallback callback;
  final VoidCallback stateCallback;
  final int index;
  final IconData icon;

  SearchResult(
    this.result,
    this.callback,
    this.stateCallback,
    this.index,
    this.icon,
  );

  _SearchResultState createState() => _SearchResultState(
        this.result,
        this.callback,
        this.stateCallback,
        this.index,
        this.icon,
      );
}

class _SearchResultState extends State<SearchResult>
    with AutomaticKeepAliveClientMixin {
  final String result;
  final SearchCallback callback;
  final VoidCallback stateCallback;
  final int index;
  final IconData icon;

  _SearchResultState(
    this.result,
    this.callback,
    this.stateCallback,
    this.index,
    this.icon,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget displayThumbnail() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          alignment: Alignment.center,
          height: 36,
          width: 36,
          color: Colors.transparent,
          child: Icon(
            icon,
            color: Colors.grey,
            size: 16,
          ),
        ),
      );
    }

    Widget displaySearchTerm() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 12, right: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        callback(result);
      },
      onLongPress: () {
        HapticFeedback.vibrate();
        if (icon == Icons.history) {
          removeSearchHistory(result);
          stateCallback();
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            displayThumbnail(),
            displaySearchTerm(),
          ],
        ),
      ),
    );
  }
}

class HistoryResult extends StatefulWidget {
  final VideoHistory history;
  final stateCallback;
  final int index;

  HistoryResult(
    this.history,
    this.stateCallback,
    this.index,
  );

  _HistoryResultState createState() => _HistoryResultState(
        this.history,
        this.stateCallback,
        this.index,
      );
}

class _HistoryResultState extends State<HistoryResult>
    with AutomaticKeepAliveClientMixin {
  final VideoHistory history;
  final stateCallback;
  final int index;

  _HistoryResultState(
    this.history,
    this.stateCallback,
    this.index,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isNetwork() {
      return (history.thumbnail.startsWith("https://"));
    }

    Widget displayThumbnail() {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: FadeInImage(
              image: isNetwork()
                  ? NetworkImage(history.thumbnail)
                  : FileImage(File(history.thumbnail)),
              placeholder: MemoryImage(kTransparentImage),
              height: 480,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

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

    Widget displayVideoInformation() {
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 12, right: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                history.heading,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                history.subheading,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              isNetwork()
                  ? closedCaptionRow(
                      "YouTube", Colors.grey, Icons.ondemand_video_sharp)
                  : closedCaptionRow(
                      "Local Storage", Colors.grey, Icons.storage_sharp)
            ],
          ),
        ),
      );
    }

    void playVideo() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Player(
            url: history.url,
          ),
        ),
      ).then((returnValue) {
        unlockLandscape();

        setLastPlayedPath(history.url);
        setLastPlayedPosition(0);
        gIsResumable.value = getResumeAvailable();

        stateCallback();
      });
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                history.heading,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage(
                  image: isNetwork()
                      ? NetworkImage(history.thumbnail)
                      : FileImage(File(history.thumbnail)),
                  placeholder: MemoryImage(kTransparentImage),
                  height: 1280,
                  fit: BoxFit.fitWidth,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    'REMOVE FROM HISTORY',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await removeVideoHistory(history);
                    stateCallback();
                    Navigator.pop(context);
                  },
                ),
                (isNetwork())
                    ? TextButton(
                        child: Text(
                          'LIST CHANNEL',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          await addNewChannel(history.url);
                          Navigator.pop(context);
                        },
                      )
                    : Container(),
                TextButton(
                  child: Text(
                    'PLAY VIDEO',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    playVideo();
                  },
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        playVideo();
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
}

class History extends StatefulWidget {
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  void setStateFromResult() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<VideoHistory> histories = getVideoHistory().reversed.toList();

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

    Widget emptyMessage = centerMessage(
      "No videos in history",
      Icons.history_sharp,
    );

    if (histories.isEmpty) {
      return emptyMessage;
    }

    return ListView.builder(
      key: UniqueKey(),
      itemCount: histories.length,
      itemBuilder: (BuildContext context, int index) {
        VideoHistory history = histories[index];
        print("HISTORY LISTED: $history");

        return HistoryResult(
          history,
          setStateFromResult,
          index,
        );
      },
    );
  }
}

class ClipboardMenu extends StatefulWidget {
  final CreatorCallback creatorCallback;

  ClipboardMenu(this.creatorCallback);

  _ClipboardState createState() => _ClipboardState(this.creatorCallback);
}

class _ClipboardState extends State<ClipboardMenu> {
  final CreatorCallback creatorCallback;
  _ClipboardState(this.creatorCallback);

  @override
  Widget build(BuildContext context) {
    List<DictionaryEntry> entries = getDictionaryHistory().reversed.toList();

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

    Widget emptyMessage = centerMessage(
      "No entries in clipboard history",
      Icons.paste_sharp,
    );

    Widget cardCreatorButton() {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12),
        color: Colors.grey[800].withOpacity(0.2),
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_add_sharp, size: 16),
                  SizedBox(width: 5),
                  Text(
                    "Card Creator",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () async {
            creatorCallback(
              DictionaryEntry(
                word: "",
                reading: "",
                meaning: "",
              ),
              null,
            );
          },
        ),
      );
    }

    if (entries.isEmpty) {
      return Column(children: [
        cardCreatorButton(),
        Expanded(child: emptyMessage),
      ]);
    }

    return ListView.builder(
      key: UniqueKey(),
      itemCount: entries.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return cardCreatorButton();
        }

        DictionaryEntry entry = entries[index - 1];
        print("ENTRY LISTED: $entry");

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          color: Colors.grey[800].withOpacity(0.2),
          child: InkWell(
            onTap: () {
              creatorCallback(entry, null);
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(entry.reading),
                    Text("\n${entry.meaning}\n"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void setStateFromResult() {
    setState(() {});
  }
}

class LazyResults extends StatefulWidget {
  final results;
  bool isOldest;

  LazyResults(this.results, this.isOldest);

  @override
  _LazyResultsState createState() =>
      new _LazyResultsState(this.results, this.isOldest);
}

class _LazyResultsState extends State<LazyResults> {
  List<Video> results;
  bool isOldest;

  _LazyResultsState(this.results, this.isOldest);

  List<Video> verticalData = [];
  final int increment = 10;

  Future _loadMore() async {
    await new Future.delayed(const Duration(milliseconds: 1000));

    int next;
    if (verticalData.length + increment >= results.length) {
      next = results.length;
    } else {
      next = verticalData.length + increment;
    }
    setState(() {
      verticalData.addAll(results.sublist(verticalData.length, next));
    });
  }

  @override
  void initState() {
    super.initState();
    if (isOldest) {
      results = results.reversed.toList();
    }

    int next;
    if (verticalData.length + 20 >= results.length) {
      next = results.length;
    } else {
      next = verticalData.length + 20;
    }
    verticalData.addAll(results.sublist(verticalData.length, next));
  }

  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      onEndOfPage: () => _loadMore(),
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        itemCount: verticalData.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == verticalData.length) {
            if (verticalData.length != results.length) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          }

          Video result = verticalData[index];
          print("VIDEO LISTED: $result");

          return YouTubeResult(
            result,
            gCaptioningCache[result.id],
            fetchCaptioningCache(result.id.value),
            null,
            index,
            false,
          );
        },
      ),
    );
  }
}

class Creator extends StatefulWidget {
  final String initialSentence;
  final DictionaryEntry initialDictionaryEntry;
  final File initialFile;

  Creator(
    this.initialSentence,
    this.initialDictionaryEntry,
    this.initialFile,
  );

  _CreatorState createState() => _CreatorState(
        this.initialSentence,
        this.initialDictionaryEntry,
        this.initialFile,
      );
}

class _CreatorState extends State<Creator> {
  final String initialSentence;
  final DictionaryEntry initialDictionaryEntry;
  final File initialFile;

  List<String> decks;
  List<String> imageURLs;
  String searchTerm;
  TextEditingController _imageSearchController;

  TextEditingController _sentenceController;
  TextEditingController _wordController;
  TextEditingController _readingController;
  TextEditingController _meaningController;
  ValueNotifier<String> _selectedDeck;

  String lastDeck = getLastDeck();

  ValueNotifier<DictionaryEntry> _selectedEntry;
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  ValueNotifier<bool> _justExported = ValueNotifier<bool>(false);
  bool _isFileImage = false;
  File _fileImage;
  String _networkImageURL;

  _CreatorState(
    this.initialSentence,
    this.initialDictionaryEntry,
    this.initialFile,
  );

  @override
  initState() {
    super.initState();
    _imageSearchController = TextEditingController(text: searchTerm);
    _sentenceController = TextEditingController(text: initialSentence);
    _wordController = TextEditingController(text: initialDictionaryEntry.word);
    _readingController =
        TextEditingController(text: initialDictionaryEntry.reading);
    _meaningController =
        TextEditingController(text: initialDictionaryEntry.meaning);

    _selectedEntry = new ValueNotifier<DictionaryEntry>(initialDictionaryEntry);
    _selectedDeck = new ValueNotifier<String>(lastDeck);

    if (initialDictionaryEntry.word == "") {
      _isFileImage = true;
    }
    if (initialFile != null) {
      _isFileImage = true;
      _fileImage = initialFile;
    }

    if (searchTerm == null) {
      if (initialDictionaryEntry.word.contains(";")) {
        searchTerm = initialDictionaryEntry.word.split(";").first;
      } else if (initialDictionaryEntry.word.contains("／")) {
        searchTerm = initialDictionaryEntry.word.split("／").first;
      } else {
        searchTerm = initialDictionaryEntry.word;
      }
    }
  }

  @override
  build(BuildContext context) {
    if (decks == null) {
      return FutureBuilder(
        future: getDecks(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return buildWaitingMessage();
              break;
            default:
              decks = snapshot.data;
              return buildEditor();
          }
        },
      );
    } else {
      return buildEditor();
    }
  }

  Widget buildWaitingMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_sharp,
            color: Colors.grey,
            size: 72,
          ),
          const SizedBox(height: 6),
          Text(
            "Preparing card creator...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          )
        ],
      ),
    );
  }

  Widget buildSearchingMessage() {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 5,
        ),
        SizedBox(height: 13),
        Text(
          "Searching for image...",
          style: TextStyle(
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void showDictionaryDialog(List<DictionaryEntry> results) {
    ValueNotifier<int> _dialogIndex = ValueNotifier<int>(0);
    ValueNotifier<DictionaryEntry> _dialogEntry =
        ValueNotifier<DictionaryEntry>(results[0]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: ValueListenableBuilder(
            valueListenable: _dialogIndex,
            builder: (BuildContext context, int _, Widget widget) {
              _dialogEntry.value = results[_dialogIndex.value];
              addDictionaryEntryToHistory(_dialogEntry.value);

              return Container(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == 0) return;

                    if (details.primaryVelocity.compareTo(0) == -1) {
                      if (_dialogIndex.value == results.length - 1) {
                        _dialogIndex.value = 0;
                      } else {
                        _dialogIndex.value += 1;
                      }
                    } else {
                      if (_dialogIndex.value == 0) {
                        _dialogIndex.value = results.length - 1;
                      } else {
                        _dialogIndex.value -= 1;
                      }
                    }
                  },
                  child: Container(
                    color: Colors.grey[800].withOpacity(0.6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          results[_dialogIndex.value].word,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(results[_dialogIndex.value].reading),
                        Flexible(
                          child: SingleChildScrollView(
                            child: gCustomDictionary.isNotEmpty ||
                                    getMonolingualMode()
                                ? SelectableText(
                                    "\n${results[_dialogIndex.value].meaning}\n")
                                : Text(
                                    "\n${results[_dialogIndex.value].meaning}\n"),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Showing search result ",
                              style: TextStyle(
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${_dialogIndex.value + 1} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "out of ",
                              style: TextStyle(
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${results.length} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "found for",
                              style: TextStyle(
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "『${results[_dialogIndex.value].searchTerm}』",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('SELECT', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                _selectedEntry.value = _dialogEntry.value;
                _wordController =
                    TextEditingController(text: _selectedEntry.value.word);
                _readingController =
                    TextEditingController(text: _selectedEntry.value.reading);
                _meaningController =
                    TextEditingController(text: _selectedEntry.value.meaning);

                if (!_isFileImage) {
                  if (_selectedEntry.value.word.contains(";")) {
                    searchTerm = _selectedEntry.value.word.split(";").first;
                  } else if (_selectedEntry.value.word.contains("／")) {
                    searchTerm = _selectedEntry.value.word.split("／").first;
                  } else {
                    searchTerm = _selectedEntry.value.word;
                  }
                  _selectedIndex.value = 0;
                }

                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildEditor() {
    Widget displayField(
      String labelText,
      String hintText,
      IconData icon,
      TextEditingController controller,
    ) {
      return TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            iconSize: 18,
            onPressed: () => controller.clear(),
            icon: Icon(Icons.clear, color: Colors.white),
          ),
          labelText: labelText,
          hintText: hintText,
        ),
      );
    }

    Widget imageSearchField = TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: _imageSearchController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.image, color: Colors.white),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 18,
              onPressed: () {
                setState(() {
                  _isFileImage = false;
                  _fileImage = null;
                  searchTerm = _imageSearchController.text;
                  _selectedIndex.value = 0;
                });
              },
              icon: Icon(Icons.search, color: Colors.white),
            ),
            IconButton(
              iconSize: 18,
              onPressed: () async {
                final _picker = ImagePicker();
                final pickedFile =
                    await _picker.getImage(source: ImageSource.camera);

                setState(() {
                  _fileImage = File(pickedFile.path);
                  _isFileImage = true;
                  _networkImageURL = null;
                });
              },
              icon: Icon(Icons.add_a_photo, color: Colors.white),
            ),
            IconButton(
              iconSize: 18,
              onPressed: () async {
                final _picker = ImagePicker();
                final pickedFile =
                    await _picker.getImage(source: ImageSource.gallery);

                setState(() {
                  _fileImage = File(pickedFile.path);
                  _isFileImage = true;
                  _networkImageURL = null;
                });
              },
              icon: Icon(Icons.file_upload, color: Colors.white),
            ),
            IconButton(
              iconSize: 18,
              onPressed: () {
                setState(() {
                  _isFileImage = true;
                  _fileImage = null;
                  _networkImageURL = null;
                  _imageSearchController.clear();
                });
              },
              icon: Icon(Icons.clear, color: Colors.white),
            ),
          ],
        ),
        labelText: "Image",
        hintText: "Enter search term here",
      ),
    );
    Widget sentenceField = displayField(
      "Sentence",
      "Enter front of card or sentence here",
      Icons.format_align_center_rounded,
      _sentenceController,
    );

    Widget wordField = displayField(
      "Word",
      "Enter the word in the back here",
      Icons.speaker_notes_outlined,
      _wordController,
    );

    wordField = TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: _wordController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.speaker_notes_outlined,
        ),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 18,
              onPressed: () async {
                String searchTerm = _wordController.text;
                showDictionaryDialog(await getWordDetails(searchTerm));
              },
              icon: Text("A⌕", style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              iconSize: 18,
              onPressed: () async {
                String searchTerm = _wordController.text;
                showDictionaryDialog(
                    await getMonolingualWordDetails(searchTerm, false));
              },
              icon: Text("あ⌕", style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              iconSize: 18,
              onPressed: () => _wordController.clear(),
              icon: Icon(Icons.clear, color: Colors.white),
            ),
          ],
        ),
        labelText: "Word",
        hintText: "Enter the word in the back here",
      ),
    );

    Widget readingField = displayField(
      "Reading",
      "Enter the reading of the word here",
      Icons.surround_sound_outlined,
      _readingController,
    );
    Widget meaningField = displayField(
      "Meaning",
      "Enter the meaning in the back here",
      Icons.translate_rounded,
      _meaningController,
    );

    Widget showFileImage() {
      if (_fileImage == null) {
        return Container();
      }

      return ListView(
        shrinkWrap: true,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoView(
                    initialScale: PhotoViewComputedScale.contained * 1,
                    minScale: PhotoViewComputedScale.contained * 1,
                    imageProvider: FileImage(_fileImage),
                  ),
                ),
              );
            },
            child: FadeInImage(
              fadeOutDuration: Duration(milliseconds: 10),
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(_fileImage),
              fit: BoxFit.fitHeight,
              height: MediaQuery.of(context).size.height / 5,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Showing local image",
                style: TextStyle(
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      );
    }

    Widget showNetworkImage() {
      return FutureBuilder(
        future: scrapeBingImages(searchTerm),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return buildSearchingMessage();
              break;
            default:
              if (snapshot.data == null || snapshot.data.isEmpty) {
                _fileImage = null;
                return showFileImage();
              }

              imageURLs = snapshot.data;
              return ListView(
                shrinkWrap: true,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoView(
                              initialScale:
                                  PhotoViewComputedScale.contained * 1,
                              minScale: PhotoViewComputedScale.contained * 1,
                              imageProvider: NetworkImage(
                                imageURLs[_selectedIndex.value],
                              ),
                            ),
                          ),
                        );
                      },
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == 0) return;

                        if (details.primaryVelocity.compareTo(0) == -1) {
                          if (_selectedIndex.value == imageURLs.length - 1) {
                            _selectedIndex.value = 0;
                          } else {
                            _selectedIndex.value += 1;
                          }
                        } else {
                          if (_selectedIndex.value == 0) {
                            _selectedIndex.value = imageURLs.length - 1;
                          } else {
                            _selectedIndex.value -= 1;
                          }
                        }
                      },
                      child: ValueListenableBuilder(
                        valueListenable: _selectedIndex,
                        builder: (BuildContext context, value, Widget child) {
                          _networkImageURL = imageURLs[_selectedIndex.value];

                          return FadeInImage(
                            fadeOutDuration: Duration(milliseconds: 10),
                            fadeInDuration: Duration(milliseconds: 50),
                            placeholder: MemoryImage(kTransparentImage),
                            image: NetworkImage(_networkImageURL),
                            fit: BoxFit.fitHeight,
                            height: MediaQuery.of(context).size.height / 5,
                          );
                        },
                      )),
                  SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: _selectedIndex,
                    builder: (BuildContext context, value, Widget child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Selecting image ",
                            style: TextStyle(
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${_selectedIndex.value + 1} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "out of ",
                            style: TextStyle(
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${imageURLs.length} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "found for",
                            style: TextStyle(
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "『$searchTerm』",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
          }
        },
      );
    }

    Widget showImagePreview() {
      if (_isFileImage) {
        return showFileImage();
      } else {
        return showNetworkImage();
      }
    }

    Widget showExportButton() {
      return ValueListenableBuilder(
        valueListenable: _justExported,
        builder: (BuildContext context, bool exported, ___) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12),
            color: Colors.grey[800].withOpacity(0.2),
            child: InkWell(
              enableFeedback: !exported,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.note_add_sharp,
                          size: 16,
                          color: exported ? Colors.grey : Colors.white),
                      SizedBox(width: 5),
                      Text(
                        exported ? "Card Exported" : "Export Card",
                        style: TextStyle(
                          color: exported ? Colors.grey : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () async {
                if (_sentenceController.text == "" &&
                    _wordController.text == "" &&
                    _readingController.text == "" &&
                    _meaningController.text == "" &&
                    _fileImage == null) {
                  return;
                }

                if (_fileImage == null && _networkImageURL != null) {
                  var response = await http.get(Uri.tryParse(_networkImageURL));

                  File previewImageFile = File(getPreviewImagePath());
                  if (previewImageFile.existsSync()) {
                    previewImageFile.deleteSync();
                  }

                  previewImageFile.writeAsBytesSync(response.bodyBytes);
                  _fileImage = previewImageFile;
                }

                try {
                  exportCreatorAnkiCard(
                    _selectedDeck.value,
                    _sentenceController.text,
                    _wordController.text,
                    _readingController.text,
                    _meaningController.text,
                    _fileImage,
                  );

                  setState(() {
                    _isFileImage = true;
                    _fileImage = null;

                    _sentenceController.clear();
                    _wordController.clear();
                    _readingController.clear();
                    _meaningController.clear();
                  });

                  _justExported.value = true;
                  Future.delayed(Duration(seconds: 2), () {
                    _justExported.value = false;
                  });
                } catch (e) {
                  print(e);
                }
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  showImagePreview(),
                  DeckDropDown(
                    decks: decks,
                    selectedDeck: _selectedDeck,
                  ),
                  imageSearchField,
                  sentenceField,
                  wordField,
                  readingField,
                  meaningField,
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          showExportButton(),
        ],
      ),
    );
  }
}
