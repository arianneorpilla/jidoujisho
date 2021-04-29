import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';

import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

typedef void ChannelCallback(String id, String name);
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
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool _isChannelView = false;

  String _searchQuery = "";
  int _selectedIndex = 0;
  String _selectedChannelName = "";
  ValueNotifier<List<String>> _searchSuggestions =
      ValueNotifier<List<String>>([]);
  YoutubeExplode yt = YoutubeExplode();

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
        if (_isSearching || _isChannelView) {
          _isSearching = false;
          _isChannelView = false;
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
    }

    switch (getNavigationBarItems()[index].label) {
      case "Trending":
        return buildBody();
      case "Channels":
        return buildChannels();
      case "History":
        return History();
      case "Clipboard":
        return ClipboardMenu();
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
        body: Center(
          child: getWidgetOptions(_selectedIndex),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isSearching || _isChannelView) {
      setState(() {
        _isSearching = false;
        _isChannelView = false;
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
    if (_isSearching || _isChannelView) {
      return BackButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
            _isChannelView = false;
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
    Widget videoMessage = centerMessage(
      "Listing recent videos...",
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
                return errorMessage;
              }

              return LazyResults(results);
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
                return errorMessage;
              }
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

  void setChannelVideoSearch(String channelID, String channelName) {
    setState(() {
      _isChannelView = true;
      _searchQuery = channelID;
      _selectedChannelName = channelName;
    });
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
              gTrendingCache = AsyncMemoizer();
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
          child: const Text('View on GitHub'),
          value: 'View project on GitHub',
        ),
        PopupMenuItem<String>(
          child: const Text('Report a bug'),
          value: 'Report a bug',
        ),
        PopupMenuItem<String>(
          child: const Text('Set AnkiDroid directory'),
          value: 'Set AnkiDroid directory',
        ),
        PopupMenuItem<String>(
          child: const Text('Manage term banks'),
          value: 'Manage term banks',
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
      case "View project on GitHub":
        await launch("https://github.com/lrorpilla/jidoujisho");
        break;
      case "Report a bug":
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
      case "Manage term banks":
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
    if (_isSearching) {
      return <Widget>[
        buildResume(),
        const SizedBox(width: 6),
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
            showPopupMenu(details.globalPosition);
          },
        ),
        const SizedBox(width: 12),
      ];
    }

    return <Widget>[
      buildResume(),
      const SizedBox(width: 6),
      gIsYouTubeAllowed
          ? IconButton(
              icon: const Icon(Icons.search),
              onPressed: startSearch,
            )
          : Container(),
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
        callback(result.id.toString(), result.title);
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
  _ClipboardState createState() => _ClipboardState();
}

class _ClipboardState extends State<ClipboardMenu> {
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

    if (entries.isEmpty) {
      return emptyMessage;
    }

    return ListView.builder(
      key: UniqueKey(),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        DictionaryEntry entry = entries[index];
        print("ENTRY LISTED: $entry");

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          color: Colors.grey[800].withOpacity(0.2),
          child: InkWell(
            onTap: () {
              Clipboard.setData(new ClipboardData(text: entry.word));
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      entry.word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SelectableText(entry.reading),
                    SelectableText("\n${entry.meaning}\n"),
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

  LazyResults(this.results);

  @override
  _LazyResultsState createState() => new _LazyResultsState(this.results);
}

class _LazyResultsState extends State<LazyResults> {
  final results;

  _LazyResultsState(this.results);

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
