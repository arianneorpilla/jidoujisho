import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/player.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/youtube.dart';

typedef void ChannelCallback(String id, String name);
typedef void CreatorCallback({
  String sentence,
  DictionaryEntry dictionaryEntry,
  File file,
  bool isShared,
});
typedef void SearchCallback(String term);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await DefaultCacheManager().emptyCache();
  await Permission.storage.request();
  requestAnkiDroidPermissions();

  gMecabTagger = Mecab();
  await gMecabTagger.init("assets/ipadic", true);

  gAppDirPath = (await getApplicationDocumentsDirectory()).path;
  gPackageInfo = await PackageInfo.fromPlatform();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    int sdkInt = androidInfo.version.sdkInt;
    if (sdkInt <= 23) {
      gIsTapToSelectSupported = false;
    }
  }

  gSharedPrefs = await SharedPreferences.getInstance();
  gIsResumable = ValueNotifier<bool>(getVideoHistory().isNotEmpty);
  gIsSelectMode = ValueNotifier<bool>(getSelectMode());
  maintainClosedCaptions();

  await AudioService.connect();
  await AudioService.start(
    backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
  );

  await initializeKanjiumEntries().then((entries) {
    gKanjiumDictionary = entries;
  });

  runApp(App());

  handleAppLifecycleState();
}

handleAppLifecycleState() {
  SystemChannels.lifecycle.setMessageHandler((msg) async {
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

class App extends StatelessWidget {
  static const Locale kLocale = const Locale("ja", "JP");
  static const String kFontFamilyAndroid = null;
  static const String kFontFamilyCupertino = "Hiragino Sans";

  static final bool _android = defaultTargetPlatform == TargetPlatform.android;
  static final String _kFontFamily =
      _android ? kFontFamilyAndroid : kFontFamilyCupertino;
  static final TextTheme _whiteTextTheme =
      _android ? Typography.whiteMountainView : Typography.whiteCupertino;
  static final TextTheme _blackTextTheme = _android
      ? Typography.blackMountainView
      : Typography.blackCupertino; // This is it!

  static TextStyle _textStyle(TextStyle base) {
    return base.copyWith(
      fontFamily: _kFontFamily,
      locale: kLocale,
      textBaseline: TextBaseline.ideographic,
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headline1: _textStyle(base.headline1),
      headline2: _textStyle(base.headline2),
      headline3: _textStyle(base.headline3),
      headline4: _textStyle(base.headline4),
      headline5: _textStyle(base.headline5),
      headline6: _textStyle(base.headline6),
      subtitle1: _textStyle(base.subtitle1),
      bodyText1: _textStyle(base.bodyText1),
      bodyText2: _textStyle(base.bodyText2),
      caption: _textStyle(base.caption),
      button: _textStyle(base.button),
      overline: _textStyle(base.overline),
    );
  }

  static final Typography kTypography = Typography.material2018(
    platform: defaultTargetPlatform,
    white: _textTheme(_whiteTextTheme),
    black: _textTheme(_blackTextTheme),
    englishLike: _textTheme(Typography.englishLike2018),
    dense: _textTheme(Typography.dense2018),
    tall: _textTheme(Typography.tall2018),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale("ja", "JP"),
      theme: ThemeData(
        accentColor: Colors.red,
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        cardColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        canvasColor: Colors.grey[900],
        typography: kTypography,
      ),
      home: AudioServiceWidget(child: Home()),
    );
  }
}

class Home extends StatefulWidget {
  Home({this.readerExport = ""});
  final String readerExport;

  _HomeState createState() => _HomeState(readerExport: this.readerExport);
}

class _HomeState extends State<Home> {
  _HomeState({this.readerExport = ""});
  final String readerExport;

  TextEditingController _searchQueryController = TextEditingController();
  ValueNotifier<double> _dictionaryScrollOffset = ValueNotifier<double>(0);
  bool _isSearching = false;
  bool _isChannelView = false;
  bool _isCreatorView = false;
  bool _isCreatorShared = false;
  bool _isCreatorReaderExport = false;

  DictionaryEntry _creatorDictionaryEntry = DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  );
  String _creatorSentence = "";
  File _creatorFile;

  String _searchQuery = "";
  int _selectedIndex = 0;
  String _selectedChannelName = "";
  ValueNotifier<List<String>> _searchSuggestions =
      ValueNotifier<List<String>>([]);
  YoutubeExplode yt = YoutubeExplode();
  ValueNotifier<bool> _readerFlipflop = ValueNotifier<bool>(false);

  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    if (readerExport.isEmpty) {
      _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
          .listen((List<SharedMediaFile> value) {
        SharedMediaType type = value.first.type;

        if (value == null) {
          return;
        }

        switch (type) {
          case SharedMediaType.IMAGE:
            setCreatorView(
              sentence: "",
              dictionaryEntry:
                  DictionaryEntry(word: "", meaning: "", reading: ""),
              file: File(value.first.path),
              isShared: true,
              isReaderExport: false,
            );
            break;
          default:
            break;
        }
        ReceiveSharingIntent.reset();
      }, onError: (err) {
        print("getIntentDataStream error: $err");
        ReceiveSharingIntent.reset();
      });

      // For sharing images coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> value) {
        SharedMediaType type = value.first.type;

        if (value == null) {
          return;
        }

        switch (type) {
          case SharedMediaType.IMAGE:
            setCreatorView(
              sentence: "",
              dictionaryEntry:
                  DictionaryEntry(word: "", meaning: "", reading: ""),
              file: File(value.first.path),
              isShared: true,
              isReaderExport: false,
            );
            break;
          default:
            break;
        }

        ReceiveSharingIntent.reset();
      });

      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen((String value) async {
        if (value == null) {
          return;
        }

        setCreatorView(
          sentence: value,
          dictionaryEntry: DictionaryEntry(word: "", meaning: "", reading: ""),
          file: null,
          isShared: true,
          isReaderExport: false,
        );
        ReceiveSharingIntent.reset();
      }, onError: (err) {
        print("getLinkStream error: $err");
        ReceiveSharingIntent.reset();
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((String value) async {
        if (value == null) {
          return;
        }

        setCreatorView(
          sentence: value,
          dictionaryEntry: DictionaryEntry(word: "", meaning: "", reading: ""),
          file: null,
          isShared: true,
          isReaderExport: false,
        );
        ReceiveSharingIntent.reset();
      });
    }
  }

  void setStateFromResult() {
    setState(() {});
  }

  void onItemTapped(int index) {
    if (getNavigationBarItems()[index].label ==
        getNavigationBarItems()[_selectedIndex].label) {
      if (_isSearching || _isChannelView || _isCreatorView) {
        setState(() {
          _isSearching = false;
          _isChannelView = false;
          _isCreatorView = false;
          _searchQuery = "";
        });
      } else {
        gCurrentScrollbar.animateTo(0,
            duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
      }
    } else {
      setState(() {
        if (getNavigationBarItems()[index].label == "Reader") {
          SystemChrome.setEnabledSystemUIOverlays([]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Reader(),
            ),
          ).then((result) {
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            setState(() {});
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
  }

  Widget getWidgetOptions(int index) {
    if (readerExport.isNotEmpty) {
      return Creator(
        readerExport,
        DictionaryEntry(word: "", reading: "", meaning: ""),
        null,
        false,
        true,
        resetMenu,
        _readerFlipflop,
      );
    }

    if (_isCreatorView) {
      return Creator(
        _creatorSentence,
        _creatorDictionaryEntry,
        _creatorFile,
        _isCreatorShared,
        _isCreatorReaderExport,
        resetMenu,
        _readerFlipflop,
      );
    }

    switch (getNavigationBarItems()[index].label) {
      case "Dictionary":
        return ClipboardMenu(setCreatorView, _dictionaryScrollOffset);
      default:
        return Container();
    }
  }

  List<BottomNavigationBarItem> getNavigationBarItems() {
    List<BottomNavigationBarItem> items = [];

    items.addAll(
      [
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories),
          label: 'Dictionary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chrome_reader_mode),
          label: 'Reader',
        ),
      ],
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: buildAppBarLeading(),
              title: buildAppBarTitleOrSearch(),
              actions: buildActions(),
            ),
            backgroundColor: Colors.black,
            bottomNavigationBar: (!_isCreatorView && !readerExport.isNotEmpty)
                ? buildNavigationBar()
                : SizedBox.shrink(),
            body: getWidgetOptions(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationBar() {
    return BottomNavigationBar(
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
    );
  }

  Future<bool> _onWillPop() async {
    if (_isSearching ||
        _isChannelView ||
        (_isCreatorView && !_isCreatorShared)) {
      setState(() {
        _isSearching = false;
        _isChannelView = false;
        _isCreatorView = false;
        _searchQuery = "";
        _searchSuggestions.value = [];
        _searchQueryController.clear();
      });
    } else {
      if (readerExport.isEmpty) {
        MinimizeApp.minimizeApp();
        resetMenu();
      } else {
        Navigator.pop(context);
      }
    }
    return false;
  }

  void resetMenu() {
    setState(() {
      _isSearching = false;
      _isChannelView = false;
      _isCreatorView = false;
      _searchQuery = "";
      _searchSuggestions.value = [];
      _searchQueryController.clear();
    });
  }

  Widget buildAppBarLeading() {
    if (_isSearching ||
        _isChannelView ||
        _isCreatorView ||
        readerExport.isNotEmpty) {
      return BackButton(onPressed: () {
        if (_isCreatorShared) {
          MinimizeApp.minimizeApp();
          resetMenu();
        } else if (readerExport.isNotEmpty) {
          Navigator.pop(context);
        }
        setState(() {
          _isSearching = false;
          _isChannelView = false;
          _isCreatorView = false;
          _searchQuery = "";
          _searchSuggestions.value = [];
          _searchQueryController.clear();
        });
      });
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
    } else if (_isCreatorView || readerExport.isNotEmpty) {
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
            " reader assistant",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 12,
            ),
            overflow: TextOverflow.fade,
          ),
        ],
      );
    }
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
          child: const Text('About this app'),
          value: 'About this app',
        ),
      ],
      elevation: 8.0,
    );

    switch (option) {
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
      case "About this app":
        const String legalese =
            "A mobile web reader assistant tailored for language learners.\n\n" +
                "Built for the Japanese language learning community by Leo Rafael Orpilla. " +
                "Bilingual definitions queried from Jisho.org. Monolingual definitions queried from Sora. Pitch accent patterns from Kanjium. Reader WebView linked to Ttu-Ebook. Logo by Aaron Marbella.\n\n" +
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

  Future<void> setCreatorView({
    String sentence,
    DictionaryEntry dictionaryEntry,
    File file,
    bool isShared,
    bool isReaderExport,
  }) async {
    try {
      setState(() {
        _isCreatorView = false;
      });
      if (isShared) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      await getDecks();
      setState(() {
        _isCreatorView = true;
        _isCreatorShared = isShared;
        _isCreatorReaderExport = isReaderExport;
        _creatorSentence = sentence;
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
                        _isCreatorShared = isShared;
                        _isCreatorReaderExport = isReaderExport;
                        _creatorSentence = sentence;
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

  List<Widget> buildActions() {
    if (_isCreatorView || readerExport.isNotEmpty) {
      return [];
    }

    return <Widget>[
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

class ClipboardMenu extends StatefulWidget {
  final CreatorCallback creatorCallback;
  final ValueNotifier<double> dictionaryScrollOffset;

  ClipboardMenu(this.creatorCallback, this.dictionaryScrollOffset);

  _ClipboardState createState() =>
      _ClipboardState(this.creatorCallback, this.dictionaryScrollOffset);
}

class _ClipboardState extends State<ClipboardMenu> {
  final CreatorCallback creatorCallback;
  final ValueNotifier<double> dictionaryScrollOffset;

  ScrollController _dictionaryScroller;
  final _wordController = TextEditingController(text: "");
  ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  _ClipboardState(this.creatorCallback, this.dictionaryScrollOffset);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dictionaryScroller =
        ScrollController(initialScrollOffset: dictionaryScrollOffset.value);
    gCurrentScrollbar = _dictionaryScroller;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _dictionaryScroller.addListener(() {
        dictionaryScrollOffset.value = _dictionaryScroller.offset;
      });
      _dictionaryScroller.position.isScrollingNotifier.addListener(() {
        if (!_dictionaryScroller.position.isScrollingNotifier.value) {
          dictionaryScrollOffset.value = _dictionaryScroller.offset;
        } else {
          dictionaryScrollOffset.value = _dictionaryScroller.offset;
        }
      });
    });

    List<DictionaryHistoryEntry> entries =
        getDictionaryHistory().reversed.toList();

    Widget centerMessage(String text, IconData icon, bool dots) {
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
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                (dots)
                    ? SizedBox(
                        width: 12,
                        height: 16,
                        child: JumpingDotsProgressIndicator(
                          color: Colors.grey,
                        ),
                      )
                    : SizedBox.shrink()
              ],
            )
          ],
        ),
      );
    }

    Widget emptyMessage = centerMessage(
      "No entries in dictionary",
      Icons.auto_stories,
      false,
    );

    Widget cardCreatorButton() {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12),
        color: Colors.grey[800].withOpacity(0.2),
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(12),
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
              sentence: "",
              dictionaryEntry: DictionaryEntry(
                word: "",
                reading: "",
                meaning: "",
              ),
              file: null,
              isShared: false,
            );
          },
        ),
      );
    }

    void wordFieldSearch(bool monolingual) async {
      String searchTerm = _wordController.text;
      if (!_isSearching.value && searchTerm.isNotEmpty) {
        _wordController.clear();
        _isSearching.value = true;

        try {
          var results;
          if (monolingual) {
            results = await fetchMonolingualSearchCache(
              searchTerm: searchTerm,
              recursive: false,
            );
          } else {
            results = await fetchBilingualSearchCache(
              searchTerm: searchTerm,
            );
          }

          if (results != null && results.entries.isNotEmpty) {
            addDictionaryEntryToHistory(results);
          }
        } finally {
          dictionaryScrollOffset.value = 0;
          _isSearching.value = false;
          setStateFromResult();
        }
      }
    }

    Widget wordSearchButton({bool monolingual}) {
      return ValueListenableBuilder(
        valueListenable: _isSearching,
        builder: (BuildContext context, bool isSearching, Widget widget) {
          return IconButton(
            iconSize: 18,
            onPressed: () async {
              wordFieldSearch(monolingual);
            },
            icon: Text(
              (monolingual) ? "あ⌕" : "A⌕",
              style:
                  TextStyle(color: (isSearching) ? Colors.grey : Colors.white),
            ),
          );
        },
      );
    }

    Widget wordField = TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      controller: _wordController,
      onFieldSubmitted: (result) {
        wordFieldSearch(getMonolingualMode());
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        prefixIcon: Icon(
          Icons.search,
        ),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            wordSearchButton(monolingual: false),
            wordSearchButton(monolingual: true),
            IconButton(
              iconSize: 18,
              onPressed: () => _wordController.clear(),
              icon: Icon(Icons.clear, color: Colors.white),
            ),
          ],
        ),
        labelText: "Search",
        hintText: "Enter search term here",
      ),
    );

    if (entries.isEmpty) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: wordField,
        ),
        cardCreatorButton(),
        Expanded(child: emptyMessage),
      ]);
    }

    return Scrollbar(
      controller: _dictionaryScroller,
      child: ListView.builder(
        controller: _dictionaryScroller,
        addAutomaticKeepAlives: true,
        key: UniqueKey(),
        itemCount: entries.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: wordField,
            );
          }
          if (index == 1) {
            return cardCreatorButton();
          }

          DictionaryHistoryEntry entry = entries[index - 2];
          print("ENTRY LISTED: $entry");

          return ClipboardHistoryItem(
            entry,
            creatorCallback,
            setStateFromResult,
            _dictionaryScroller,
            dictionaryScrollOffset,
          );
        },
      ),
    );
  }

  void setStateFromResult() {
    setState(() {});
  }
}

class ClipboardHistoryItem extends StatefulWidget {
  final DictionaryHistoryEntry entry;
  final CreatorCallback creatorCallback;
  final VoidCallback stateCallback;

  final ScrollController dictionaryScroller;
  final ValueNotifier<double> dictionaryScrollOffset;

  ClipboardHistoryItem(
    this.entry,
    this.creatorCallback,
    this.stateCallback,
    this.dictionaryScroller,
    this.dictionaryScrollOffset,
  );

  @override
  _ClipboardHistoryItemState createState() => new _ClipboardHistoryItemState(
        this.entry,
        this.creatorCallback,
        this.stateCallback,
        this.dictionaryScroller,
        this.dictionaryScrollOffset,
      );
}

class _ClipboardHistoryItemState extends State<ClipboardHistoryItem>
    with AutomaticKeepAliveClientMixin {
  _ClipboardHistoryItemState(
    this.entry,
    this.creatorCallback,
    this.stateCallback,
    this.dictionaryScroller,
    this.dictionaryScrollOffset,
  );

  @override
  bool get wantKeepAlive => true;

  final DictionaryHistoryEntry entry;
  final CreatorCallback creatorCallback;
  final VoidCallback stateCallback;

  final ScrollController dictionaryScroller;
  final ValueNotifier<double> dictionaryScrollOffset;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    DictionaryEntry pitchEntry =
        getClosestPitchEntry(entry.entries[entry.swipeIndex]);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.grey[800].withOpacity(0.2),
      child: InkWell(
        onTap: () {
          creatorCallback(
            sentence: "",
            dictionaryEntry: entry.entries[entry.swipeIndex],
            file: null,
            isShared: false,
          );
        },
        onLongPress: () {
          HapticFeedback.vibrate();
          showDictionaryDialog(entry, entry.swipeIndex);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: InkWell(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == 0) return;

                if (details.primaryVelocity.compareTo(0) == -1) {
                  if (entry.swipeIndex == entry.entries.length - 1) {
                    entry.swipeIndex = 0;
                  } else {
                    entry.swipeIndex += 1;
                  }
                } else {
                  if (entry.swipeIndex == 0) {
                    entry.swipeIndex = entry.entries.length - 1;
                  } else {
                    entry.swipeIndex -= 1;
                  }
                }

                updateDictionaryHistorySwipeIndex(entry, entry.swipeIndex);
                setState(() {});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.entries[entry.swipeIndex].word,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),
                  (pitchEntry != null)
                      ? getAllPitchWidgets(pitchEntry)
                      : Text(entry.entries[entry.swipeIndex].reading),
                  Text(
                    "\n${entry.entries[entry.swipeIndex].meaning}\n",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        "Search result ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${entry.swipeIndex + 1} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "out of ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${entry.entries.length} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (entry.contextDataSource != "-1")
                        Text(
                          "from video ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      Text(
                        "found for",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            "『",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${entry.searchTerm}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "』",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showDictionaryDialog(
      DictionaryHistoryEntry results, int swipeIndex) async {
    ValueNotifier<int> _dialogIndex = ValueNotifier<int>(swipeIndex);
    ValueNotifier<DictionaryEntry> _dialogEntry =
        ValueNotifier<DictionaryEntry>(results.entries[swipeIndex]);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: ValueListenableBuilder(
            valueListenable: _dialogIndex,
            builder: (BuildContext context, int _, Widget widget) {
              _dialogEntry.value = results.entries[_dialogIndex.value];

              DictionaryEntry pitchEntry =
                  getClosestPitchEntry(results.entries[_dialogIndex.value]);
              // if (pitchEntry != null) {
              //   print(getAllHtmlPitch(pitchEntry));
              // }

              return Container(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == 0) return;

                    if (details.primaryVelocity.compareTo(0) == -1) {
                      if (_dialogIndex.value == results.entries.length - 1) {
                        _dialogIndex.value = 0;
                      } else {
                        _dialogIndex.value += 1;
                      }
                    } else {
                      if (_dialogIndex.value == 0) {
                        _dialogIndex.value = results.entries.length - 1;
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
                          results.entries[_dialogIndex.value].word,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        (pitchEntry != null)
                            ? getAllPitchWidgets(pitchEntry)
                            : Text(results.entries[_dialogIndex.value].reading),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              "\n${results.entries[_dialogIndex.value].meaning}\n",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              "Selecting search result ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${_dialogIndex.value + 1} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "out of ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${results.entries.length} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (entry.contextDataSource != "-1")
                              Text(
                                "from video ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            Text(
                              "found for",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Text(
                                  "『",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${results.searchTerm}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "』",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'REMOVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.pop(context);
                removeDictionaryEntryFromHistory(results);
                stateCallback();
              },
            ),
            TextButton(
              child: Text(
                'CREATE CARD',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                creatorCallback(
                  sentence: "",
                  dictionaryEntry: results.entries[_dialogIndex.value],
                  file: null,
                  isShared: false,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    updateDictionaryHistorySwipeIndex(results, _dialogIndex.value);
    setState(() {});
  }
}

class Creator extends StatefulWidget {
  final String initialSentence;
  final DictionaryEntry initialDictionaryEntry;
  final File initialFile;
  final bool isShared;
  final bool isReaderExport;
  final VoidCallback resetMenu;
  final ValueNotifier<bool> readerFlipflop;

  Creator(
    this.initialSentence,
    this.initialDictionaryEntry,
    this.initialFile,
    this.isShared,
    this.isReaderExport,
    this.resetMenu,
    this.readerFlipflop,
  );

  _CreatorState createState() => _CreatorState(
        this.initialSentence,
        this.initialDictionaryEntry,
        this.initialFile,
        this.isShared,
        this.isReaderExport,
        this.resetMenu,
        this.readerFlipflop,
      );
}

class _CreatorState extends State<Creator> {
  final String initialSentence;
  final DictionaryEntry initialDictionaryEntry;
  final File initialFile;
  final bool isShared;
  final bool isReaderExport;
  final VoidCallback resetMenu;
  final ValueNotifier<bool> readerFlipflop;

  List<String> decks;
  List<String> imageURLs;
  String searchTerm = "";
  TextEditingController _imageSearchController;

  TextEditingController _sentenceController;
  TextEditingController _wordController;
  TextEditingController _readingController;
  TextEditingController _meaningController;
  ValueNotifier<String> _selectedDeck;

  String lastDeck = getLastDeck();
  ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  ValueNotifier<DictionaryEntry> _selectedEntry;
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  ValueNotifier<bool> _justExported = ValueNotifier<bool>(false);
  bool _isFileImage = false;
  File _fileImage;
  String _networkImageURL;

  ValueNotifier<bool> _isReader;

  _CreatorState(
    this.initialSentence,
    this.initialDictionaryEntry,
    this.initialFile,
    this.isShared,
    this.isReaderExport,
    this.resetMenu,
    this.readerFlipflop,
  );

  @override
  initState() {
    super.initState();
    _imageSearchController = TextEditingController(text: searchTerm);
    _wordController = TextEditingController(text: initialDictionaryEntry.word);
    _sentenceController = TextEditingController(text: "");

    _selectedEntry = new ValueNotifier<DictionaryEntry>(initialDictionaryEntry);
    _selectedDeck = new ValueNotifier<String>(lastDeck);
    _isReader = ValueNotifier<bool>(false);

    DictionaryEntry pitchEntry = getClosestPitchEntry(initialDictionaryEntry);
    if (pitchEntry != null) {
      _readingController =
          TextEditingController(text: getAllHtmlPitch(pitchEntry));
    } else {
      _readingController =
          TextEditingController(text: initialDictionaryEntry.reading);
    }

    _meaningController =
        TextEditingController(text: initialDictionaryEntry.meaning);

    if (initialDictionaryEntry.word == "") {
      _isFileImage = true;
    }
    if (initialFile != null) {
      _isFileImage = true;
      _fileImage = initialFile;
    }

    if (initialSentence.isNotEmpty) {
      if (parseVe(gMecabTagger, initialSentence).length != 1) {
        _sentenceController = TextEditingController(text: initialSentence);
        _wordController = TextEditingController(text: "");
        _isReader = ValueNotifier<bool>(true);
      } else {
        _sentenceController = TextEditingController(text: "");
        _wordController = TextEditingController(text: initialSentence);
      }
    }

    if (_fileImage == null) {
      _isFileImage = false;

      if (_selectedEntry.value.word.contains(";")) {
        searchTerm = _selectedEntry.value.word.split(";").first;
      } else if (_selectedEntry.value.word.contains("／")) {
        searchTerm = _selectedEntry.value.word.split("／").first;
      } else {
        searchTerm = _selectedEntry.value.word;
      }
      _selectedIndex.value = 0;
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
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                "Preparing card creator",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 12,
                height: 16,
                child: JumpingDotsProgressIndicator(
                  color: Colors.grey,
                ),
              ),
            ],
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
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              "Searching for images",
              style: TextStyle(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 12,
              height: 14,
              child: JumpingDotsProgressIndicator(
                color: Colors.white,
              ),
            )
          ],
        ),
      ],
    );
  }

  void showDictionaryDialog(DictionaryHistoryEntry results) {
    ValueNotifier<int> _dialogIndex = ValueNotifier<int>(0);
    ValueNotifier<DictionaryEntry> _dialogEntry =
        ValueNotifier<DictionaryEntry>(results.entries[0]);

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
              _dialogEntry.value = results.entries[_dialogIndex.value];
              addDictionaryEntryToHistory(
                DictionaryHistoryEntry(
                  entries: results.entries,
                  searchTerm: results.searchTerm,
                  swipeIndex: _dialogIndex.value,
                  contextDataSource: results.contextDataSource,
                  contextPosition: results.contextPosition,
                ),
              );

              DictionaryEntry pitchEntry =
                  getClosestPitchEntry(results.entries[_dialogIndex.value]);
              // if (pitchEntry != null) {
              //   print(getAllHtmlPitch(pitchEntry));
              // }

              return Container(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == 0) return;

                    if (details.primaryVelocity.compareTo(0) == -1) {
                      if (_dialogIndex.value == results.entries.length - 1) {
                        _dialogIndex.value = 0;
                      } else {
                        _dialogIndex.value += 1;
                      }
                    } else {
                      if (_dialogIndex.value == 0) {
                        _dialogIndex.value = results.entries.length - 1;
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
                          results.entries[_dialogIndex.value].word,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        (pitchEntry != null)
                            ? getAllPitchWidgets(pitchEntry)
                            : Text(results.entries[_dialogIndex.value].reading),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              "\n${results.entries[_dialogIndex.value].meaning}\n",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(
                              "Selecting search result ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${_dialogIndex.value + 1} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "out of ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${results.entries.length} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "found for",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Text(
                                  "『",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${results.searchTerm}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "』",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
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

                DictionaryEntry pitchEntry =
                    getClosestPitchEntry(_selectedEntry.value);
                if (pitchEntry != null) {
                  _readingController =
                      TextEditingController(text: getAllHtmlPitch(pitchEntry));
                } else {
                  _readingController =
                      TextEditingController(text: _selectedEntry.value.reading);
                }

                _meaningController =
                    TextEditingController(text: _selectedEntry.value.meaning);

                if (_fileImage == null) {
                  _isFileImage = false;
                  if (_selectedEntry.value.word.contains(";")) {
                    searchTerm = _selectedEntry.value.word.split(";").first;
                  } else if (_selectedEntry.value.word.contains("／")) {
                    searchTerm = _selectedEntry.value.word.split("／").first;
                  } else {
                    searchTerm = _selectedEntry.value.word;
                  }
                  _selectedIndex.value = 0;
                }

                print(searchTerm);

                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> getTextWidgetsFromWords(
      List<String> words, ValueNotifier<int> notifier) {
    List<Widget> widgets = [];
    for (int i = 0; i < words.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            notifier.value = i;
          },
          child: ValueListenableBuilder(
              valueListenable: notifier,
              builder: (BuildContext context, int value, Widget child) {
                return Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(top: 10, right: 10),
                    color: (notifier.value == i)
                        ? Colors.red.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    child: Text(
                      words[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ));
              }),
        ),
      );
    }

    return widgets;
  }

  void showSentenceDialog(String sentence) {
    sentence = sentence.trim();

    ValueNotifier<int> selectedWordIndex = ValueNotifier<int>(-1);
    List<Word> segments = parseVe(gMecabTagger, sentence);
    List<String> words = [];
    segments.forEach((segment) => words.add(segment.word));
    List<Widget> textWidgets =
        getTextWidgetsFromWords(words, selectedWordIndex);

    ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder: (BuildContext context, int _, Widget widget) {
              return Container(
                child: Container(
                  color: Colors.grey[800].withOpacity(0.6),
                  child: Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Wrap(children: textWidgets),
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
                setState(() {
                  _wordController.text = words[selectedWordIndex.value];
                  // if (_fileImage == null) {
                  //   setState(() {
                  //     _isFileImage = false;
                  //     _fileImage = null;
                  //     searchTerm = _wordController.text;
                  //     _selectedIndex.value = 0;
                  //   });
                  // }
                });
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
      keyboardType: TextInputType.text,
      maxLines: 1,
      controller: _imageSearchController,
      onFieldSubmitted: (result) {
        setState(() {
          _isFileImage = false;
          _fileImage = null;
          searchTerm = _imageSearchController.text;
          _selectedIndex.value = 0;
        });
      },
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
                  if (_imageSearchController.text.trim().isEmpty) {
                    _imageSearchController.clear();

                    if (_wordController.text.contains(";")) {
                      searchTerm = _wordController.text.split(";").first;
                    } else if (_selectedEntry.value.word.contains("／")) {
                      searchTerm = _wordController.text.split("／").first;
                    } else {
                      searchTerm = _wordController.text;
                    }
                  } else {
                    searchTerm = _imageSearchController.text;
                  }
                  _selectedIndex.value = 0;
                });
              },
              icon: Icon(Icons.image_search_sharp, color: Colors.white),
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
        hintText: "Searches word if blank",
      ),
    );

    Widget sentenceField = TextFormField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: _sentenceController,
        onFieldSubmitted: (result) {
          if (_sentenceController.text.trim().isNotEmpty) {
            showSentenceDialog(_sentenceController.text);
          }
        },
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.format_align_center_rounded, color: Colors.white),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 18,
                onPressed: () {
                  if (_sentenceController.text.trim().isNotEmpty) {
                    showSentenceDialog(_sentenceController.text);
                  }
                },
                icon: Icon(Icons.account_tree_outlined, color: Colors.white),
              ),
              IconButton(
                iconSize: 18,
                onPressed: () {
                  setState(() {
                    _sentenceController.clear();
                    _isReader.value = false;
                  });
                },
                icon: Icon(Icons.clear, color: Colors.white),
              ),
            ],
          ),
          labelText: "Sentence",
          hintText: "Enter sentence here",
        ),
        onChanged: (value) {
          _isReader.value = value.isNotEmpty;
        });

    void wordFieldSearch(bool monolingual) async {
      if (!_isSearching.value) {
        _isSearching.value = true;
        String searchTerm = _wordController.text;
        try {
          var results;
          if (monolingual) {
            results = await fetchMonolingualSearchCache(
              searchTerm: searchTerm,
              recursive: false,
            );
          } else {
            results = await fetchBilingualSearchCache(
              searchTerm: searchTerm,
            );
          }

          showDictionaryDialog(results);
        } finally {
          _isSearching.value = false;
        }
      }
    }

    Widget wordSearchButton({bool monolingual}) {
      return ValueListenableBuilder(
        valueListenable: _isSearching,
        builder: (BuildContext context, bool isSearching, Widget widget) {
          return IconButton(
            iconSize: 18,
            onPressed: () async {
              wordFieldSearch(monolingual);
            },
            icon: Text(
              (monolingual) ? "あ⌕" : "A⌕",
              style:
                  TextStyle(color: (isSearching) ? Colors.grey : Colors.white),
            ),
          );
        },
      );
    }

    Widget wordField = TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      controller: _wordController,
      onFieldSubmitted: (result) {
        wordFieldSearch(getMonolingualMode());
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.speaker_notes_outlined,
        ),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            wordSearchButton(monolingual: false),
            wordSearchButton(monolingual: true),
            IconButton(
              iconSize: 18,
              onPressed: () => _wordController.clear(),
              icon: Icon(Icons.clear, color: Colors.white),
            ),
          ],
        ),
        labelText: "Word",
        hintText: "Enter search term here",
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
      "Enter the meaning of the word here",
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
                    maxScale: PhotoViewComputedScale.contained * 4,
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
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      );
    }

    Widget showNetworkImage() {
      if (searchTerm.trim().isEmpty) {
        return Container();
      }

      return FutureBuilder(
        future: scrapeBingImages(context, searchTerm),
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
                              maxScale: PhotoViewComputedScale.contained * 4,
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
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Selecting image ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${_selectedIndex.value + 1} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "out of ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${imageURLs.length} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "found for",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                "『",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${searchTerm.trim()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "』",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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

    String isReaderText() {
      if (_isReader.value) {
        return "Reader";
      } else {
        return "Creator";
      }
    }

    Widget showExportButton() {
      return ValueListenableBuilder(
          valueListenable: _isReader,
          builder: (BuildContext context, bool exported, ___) {
            return ValueListenableBuilder(
              valueListenable: _justExported,
              builder: (BuildContext context, bool exported, ___) {
                return Container(
                  width: double.infinity,
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
                              exported
                                  ? "Card Exported"
                                  : isShared
                                      ? "Export ${isReaderText()} Card and Return"
                                      : "Export ${isReaderText()} Card",
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
                      bool isReader = _isReader.value;

                      if (_wordController.text == "" &&
                          _sentenceController.text == "" &&
                          _readingController.text == "" &&
                          _meaningController.text == "" &&
                          _fileImage == null) {
                        return;
                      }

                      if (_fileImage == null && _networkImageURL != null) {
                        var response =
                            await http.get(Uri.tryParse(_networkImageURL));

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
                          isReader,
                        );

                        setState(() {
                          _isFileImage = true;
                          _fileImage = null;
                          _networkImageURL = null;

                          _imageSearchController.clear();
                          _sentenceController.clear();
                          _wordController.clear();
                          _readingController.clear();
                          _meaningController.clear();
                        });

                        _isReader.value = false;
                        _justExported.value = true;
                        if (isShared) {
                          MinimizeApp.minimizeApp();
                          resetMenu();
                        } else if (isReaderExport) {
                          Navigator.pop(context);
                        } else {
                          Future.delayed(Duration(seconds: 2), () {
                            _justExported.value = false;
                          });
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                );
              },
            );
          });
    }

    ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
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
                      wordField,
                      sentenceField,
                      readingField,
                      meaningField,
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          showExportButton(),
        ],
      ),
    );
  }
}
