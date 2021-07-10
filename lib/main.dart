import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
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
import 'package:jidoujisho/reader.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/youtube.dart';

typedef void ChannelCallback(String id, String name, bool fromMenu);
typedef void CreatorCallback({
  String sentence,
  DictionaryEntry dictionaryEntry,
  File file,
  bool isShared,
  bool isReaderExport,
});
typedef void SearchCallback(String term);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await DefaultCacheManager().emptyCache();
  await Permission.storage.request();
  requestAnkiDroidPermissions();

  gAppDirPath = (await getApplicationDocumentsDirectory()).path;
  gPackageInfo = await PackageInfo.fromPlatform();
  gMecabTagger = Mecab();
  gMecabTagger.init("assets/ipadic", true);

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    int sdkInt = androidInfo.version.sdkInt;
    if (sdkInt <= 23) {
      gIsTapToSelectSupported = false;
    }
  }

  if (!getDCIMDirectory().existsSync()) {
    getDCIMDirectory().createSync(recursive: true);
  }

  gSharedPrefs = await SharedPreferences.getInstance();
  gIsSelectMode = ValueNotifier<bool>(getSelectMode());
  bool canResume;
  if (isLastSetVideo()) {
    canResume = getVideoHistory().isNotEmpty;
  } else {
    canResume = getBookHistory().isNotEmpty;
  }
  gIsResumable = ValueNotifier<bool>(canResume);

  maintainTrendingCache();
  maintainClosedCaptions();

  await AudioService.connect();
  await AudioService.start(
    backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
  );

  initializeCustomDictionaries();
  initializeKanjiumEntries().then((entries) {
    gKanjiumDictionary.value = entries;
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
    ThemeData theme = ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.black,
      focusColor: Colors.red,
      appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      canvasColor: Colors.grey[900],
      typography: kTypography,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale("ja", "JP"),
      theme: theme.copyWith(
        colorScheme: theme.colorScheme
            .copyWith(primary: Colors.red, secondary: Colors.red),
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
  bool _isChannelFromMenu = false;
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
  int _selectedIndex = getLastMenuSeen();
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
            );
            break;
          case SharedMediaType.VIDEO:
            Navigator.of(context).popUntil((route) => route.isFirst);
            playVideo(
              JidoujishoPlayerMode.localFile,
              value.first.path,
              pop: true,
            );
            break;
          case SharedMediaType.FILE:
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
            );
            break;
          case SharedMediaType.VIDEO:
            Navigator.of(context).popUntil((route) => route.isFirst);
            playVideo(
              JidoujishoPlayerMode.localFile,
              value.first.path,
              pop: true,
            );
            break;
          case SharedMediaType.FILE:
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

        if (value.startsWith("https://") || value.startsWith("http://")) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          if (YoutubePlayer.convertUrlToId(value) != null) {
            playVideo(JidoujishoPlayerMode.youtubeStream, value, pop: true);
          } else {
            playVideo(JidoujishoPlayerMode.networkStream, value, pop: true);
          }
        } else if (value.startsWith("content://")) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          String absolutePath =
              await FlutterAbsolutePath.getAbsolutePath(value);
          playVideo(JidoujishoPlayerMode.localFile, absolutePath, pop: true);
        } else {
          setCreatorView(
            sentence: value,
            dictionaryEntry:
                DictionaryEntry(word: "", meaning: "", reading: ""),
            file: null,
            isShared: true,
          );
        }
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

        if (value.startsWith("https://") || value.startsWith("http://")) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          if (YoutubePlayer.convertUrlToId(value) != null) {
            playVideo(JidoujishoPlayerMode.youtubeStream, value, pop: true);
          } else {
            playVideo(JidoujishoPlayerMode.networkStream, value, pop: true);
          }
        } else if (value.startsWith("content://")) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          String absolutePath =
              await FlutterAbsolutePath.getAbsolutePath(value);
          playVideo(JidoujishoPlayerMode.localFile, absolutePath, pop: true);
        } else {
          setCreatorView(
            sentence: value,
            dictionaryEntry:
                DictionaryEntry(word: "", meaning: "", reading: ""),
            file: null,
            isShared: true,
          );
        }
        ReceiveSharingIntent.reset();
      });
    }
  }

  void playVideo(
    JidoujishoPlayerMode playerMode,
    String link, {
    bool pop = false,
  }) {
    if (!gIsYouTubeAllowed &&
        playerMode == JidoujishoPlayerMode.youtubeStream) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JidoujishoPlayer(
          playerMode: playerMode,
          url: link,
        ),
      ),
    ).then((returnValue) {
      if (pop) {
        SystemNavigator.pop();
      }
    });
  }

  void setStateFromResult() {
    setState(() {
      unlockLandscape();
    });
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
        if (getNavigationBarItems()[index].label == "Player") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JidoujishoPlayer(
                playerMode: JidoujishoPlayerMode.localFile,
              ),
            ),
          ).then((result) {
            setState(() {
              unlockLandscape();
            });
          });
        } else {
          _selectedIndex = index;
          setLastMenuSeen(index);
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

    if (_isSearching) {
      return buildBody();
    } else if (_isChannelView) {
      return buildChannels();
    } else if (_isCreatorView) {
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
      case "Trending":
        return buildBody();
      case "Reader":
        return buildReader();
      case "History":
        return History(setChannelVideoSearch);
      case "Dictionary":
        return ClipboardMenu(setCreatorView, _dictionaryScrollOffset);
      default:
        return Container();
    }
  }

  void startReader(String initialURL, {int initialX}) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Reader(initialURL, initialX),
      ),
    ).then((result) {
      setState(() {
        bool canResume;
        if (isLastSetVideo()) {
          canResume = getVideoHistory().isNotEmpty;
        } else {
          canResume = getBookHistory().isNotEmpty;
        }
        gIsResumable.value = canResume;
        SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.bottom, SystemUiOverlay.top]);
      });
    });
  }

  Widget buildReader() {
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

    Widget openReaderButton() {
      String readerMessage;
      String initialURL;

      try {
        initialURL = getBookHistory().last.url;
        readerMessage = "Continue Reading";
      } catch (e) {
        initialURL = null;
        readerMessage = "Start Reading";
      }

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
                  Icon(Icons.chrome_reader_mode, size: 16),
                  SizedBox(width: 5),
                  Text(
                    readerMessage,
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
            startReader(initialURL);
          },
        ),
      );
    }

    Widget emptyMessage = centerMessage(
      "No books added to reader",
      Icons.chrome_reader_mode,
      false,
    );

    List<HistoryItem> bookHistory = getBookHistory().reversed.toList();

    if (bookHistory.isEmpty) {
      return Column(children: [
        openReaderButton(),
        Expanded(child: emptyMessage),
      ]);
    }

    ScrollController scrollController = ScrollController();
    gCurrentScrollbar = scrollController;

    return RawScrollbar(
      thumbColor: Colors.grey[600],
      controller: scrollController,
      child: ListView(
        shrinkWrap: true,
        controller: scrollController,
        key: UniqueKey(),
        children: [
          openReaderButton(),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: bookHistory.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 176 / 250,
            ),
            itemBuilder: (BuildContext context, int index) {
              HistoryItem book = bookHistory[index];
              print("BOOK LISTED: $book");

              return showBook(book);
            },
          ),
        ],
      ),
    );
  }

  Widget showBook(HistoryItem book) {
    ImageProvider imageProvider;

    try {
      UriData data = Uri.parse(book.thumbnail).data;
      imageProvider = MemoryImage(data.contentAsBytes());
    } catch (e) {
      imageProvider = MemoryImage(kTransparentImage);
    }

    double progress;
    if (book.subheading.isNotEmpty) {
      int currentWord = int.tryParse(book.subheading.split("/")[0]) ?? -1;
      int wordCount =
          int.tryParse(book.subheading.split("/")[1].split(" ")[0]) ?? -1;
      progress = (currentWord / wordCount) ?? 0;
      if ((wordCount - currentWord) < (wordCount * 0.01)) {
        progress = 1.0;
      }
    } else {
      progress = 0;
    }

    return InkWell(
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              color: Colors.grey[800].withOpacity(0.3),
              child: AspectRatio(
                aspectRatio: 176 / 250,
                child: FadeInImage(
                  image: imageProvider,
                  placeholder: MemoryImage(kTransparentImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.fromLTRB(2, 2, 2, 4),
              height: constraints.maxHeight * 0.175,
              width: double.maxFinite,
              color: Colors.black.withOpacity(0.6),
              child: Text(
                book.heading ?? "",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            );
          }),
          Container(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 2,
            ),
          ),
        ],
      ),
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                book.heading,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: AspectRatio(
                aspectRatio: 176 / 250,
                child: FadeInImage(
                  image: imageProvider,
                  placeholder: MemoryImage(kTransparentImage),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'REMOVE',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await removeBookHistory(book);

                    setState(() {
                      bool canResume;
                      if (isLastSetVideo()) {
                        canResume = getVideoHistory().isNotEmpty;
                      } else {
                        canResume = getBookHistory().isNotEmpty;
                      }
                      gIsResumable.value = canResume;
                    });
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    'READ',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    startReader(book.url);
                  },
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        startReader(book.url);
      },
    );
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
          icon: Icon(Icons.auto_stories),
          label: 'Dictionary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chrome_reader_mode),
          label: 'Reader',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_filled_sharp),
          label: 'Player',
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
        if (_isChannelFromMenu) {
          _isChannelView = true;
          _isChannelFromMenu = false;
        } else {
          _isChannelView = false;
          _isChannelFromMenu = false;
        }
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
      return BackButton(
        onPressed: () {
          if (_isCreatorShared) {
            MinimizeApp.minimizeApp();
            resetMenu();
          } else if (readerExport.isNotEmpty) {
            Navigator.pop(context);
          } else {
            setState(() {
              _isSearching = false;
              if (_isChannelFromMenu) {
                _isChannelView = true;
                _isChannelFromMenu = false;
              } else {
                _isChannelView = false;
                _isChannelFromMenu = false;
              }
              _isCreatorView = false;
              _searchQuery = "";
              _searchSuggestions.value = [];
              _searchQueryController.clear();
            });
          }
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
      return buildChannelNameRow();
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
            " ${gPackageInfo.version} beta",
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

  Widget buildChannelNameRow() {
    if (_searchQuery.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              "Channels",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      );
    }
    bool isListed = isChannelInList(_searchQuery);

    Widget buildListButton() {
      if (isListed) {
        return Container(
          padding: EdgeInsets.only(left: 10),
          child: GestureDetector(
            child: Icon(
              Icons.star,
              size: 18,
            ),
            onTap: () {
              setState(() {
                removeChannel(_searchQuery);
              });
            },
          ),
        );
      } else {
        return Container(
          padding: EdgeInsets.only(left: 10),
          child: GestureDetector(
            child: Icon(
              Icons.star_border,
              size: 18,
            ),
            onTap: () {
              setState(() {
                addNewChannelFromID(_searchQuery);
              });
            },
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Text(
            _selectedChannelName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
        buildListButton(),
      ],
    );
  }

  Widget buildChannels() {
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

    Widget queryMessage = centerMessage(
      "Listing channels",
      Icons.subscriptions_sharp,
      true,
    );
    Widget errorMessage = centerMessage(
      "Error getting channels",
      Icons.error,
      false,
    );
    Widget emptyMessage = centerMessage(
      "No channels listed",
      Icons.subscriptions_sharp,
      false,
    );

    if (_isChannelView && _searchQuery.isNotEmpty) {
      return LazyResults(
        _searchQuery,
        setChannelVideoSearch,
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
                ScrollController scrollController = ScrollController();
                gCurrentScrollbar = scrollController;

                return RawScrollbar(
                  thumbColor: Colors.grey[600],
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
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
                  ),
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
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
    bool fromMenu,
  ) {
    setState(() {
      _isChannelView = true;
      _isSearching = false;
      _searchQuery = channelID;
      _selectedChannelName = channelName;
      _isChannelFromMenu = fromMenu;
    });
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
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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

  Widget generateSuggestions() {
    return ValueListenableBuilder(
      valueListenable: _searchSuggestions,
      builder: (BuildContext context, List<String> suggestions, ___) {
        ScrollController scrollController = ScrollController();

        return RawScrollbar(
          thumbColor: Colors.grey[600],
          controller: scrollController,
          child: ListView.builder(
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
          ),
        );
      },
    );
  }

  Widget generateHistory() {
    List<String> searchHistory = getSearchHistory().reversed.toList();

    ScrollController scrollController = ScrollController();

    return RawScrollbar(
      thumbColor: Colors.grey[600],
      controller: scrollController,
      child: ListView.builder(
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
      ),
    );
  }

  Widget buildBody() {
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

    Widget searchMessage = centerMessage(
      "Enter keyword to search",
      Icons.youtube_searched_for,
      false,
    );
    Widget searchingMessage = centerMessage(
      "Searching for \"$_searchQuery\"",
      Icons.youtube_searched_for,
      true,
    );
    Widget queryMessage = centerMessage(
      "Querying trending videos",
      Icons.youtube_searched_for,
      true,
    );
    Widget errorMessage = centerMessage(
      "No videos could be queried",
      Icons.error,
      false,
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

            ScrollController scrollController = ScrollController();
            gCurrentScrollbar = scrollController;

            return RawScrollbar(
              thumbColor: Colors.grey[600],
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                addAutomaticKeepAlives: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    if (_isSearching) {
                      return SizedBox.shrink();
                    } else {
                      return showChannelCarousel(results);
                    }
                  }

                  Video result = results[index - 1];
                  print("VIDEO LISTED: $result");

                  return YouTubeResult(
                    result,
                    gCaptioningCache[result.id],
                    fetchCaptioningCache(result.id.value),
                    setChannelVideoSearch,
                    (_isSearching)
                        ? fetchMetadataCache(result.id.value, result)
                        : null,
                    index,
                    true,
                    false,
                  );
                },
              ),
            );
        }
      },
    );
  }

  Widget showChannelCarousel(List<Video> trendingVideos) {
    Widget buildNewChannelColumn() {
      String channelTitle = "Channels";

      Widget displayThumbnail() {
        return ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: Container(
            alignment: Alignment.center,
            height: 64,
            width: 64,
            color: Colors.grey[900],
            child: Icon(
              Icons.subscriptions_sharp,
              color: Colors.grey,
              size: 32,
            ),
          ),
        );
      }

      Widget displayVideoInformation() {
        return Expanded(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  channelTitle,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
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
        child: Container(
          width: 80,
          padding: EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              displayThumbnail(),
              displayVideoInformation(),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _isChannelView = true;
            _isSearching = false;
            _searchQuery = "";
            _selectedChannelName = "Channels";
          });
        },
      );
    }

    Widget queryMessage = Container(
      height: 100,
      child: Row(children: [buildNewChannelColumn()]),
    );
    Widget errorMessage = Container(
      height: 100,
      child: Row(children: [buildNewChannelColumn()]),
    );
    Widget emptyMessage = Container(
      height: 100,
      child: Row(children: [buildNewChannelColumn()]),
    );

    return FutureBuilder(
      future: gTrendingChannelCache.future,
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
              return Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  addAutomaticKeepAlives: true,
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return buildNewChannelColumn();
                    }

                    Channel result = results[index - 1];
                    print("CHANNEL LISTED: $result");

                    return ChannelHorizontalResult(
                      result,
                      setChannelVideoSearch,
                      setStateFromResult,
                      index,
                    );
                  },
                ),
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

  showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String option = await showMenu(
      color: Colors.grey[900],
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
          child: const Text('Enter network stream URL'),
          value: 'Enter network stream URL',
        ),
        if (gIsYouTubeAllowed)
          PopupMenuItem<String>(
            child: const Text('Import/export channels'),
            value: 'Import/export channels',
          ),
        PopupMenuItem<String>(
          child: const Text('Manage dictionaries'),
          value: 'Manage dictionaries',
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
          child: const Text('About this app'),
          value: 'About this app',
        ),
      ],
      elevation: 8.0,
    );

    switch (option) {
      case "Enter network stream URL":
        TextEditingController _textFieldController = TextEditingController();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: TextField(
                controller: _textFieldController,
                decoration:
                    InputDecoration(hintText: "Enter network stream URL"),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('PLAY', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    String webURL = _textFieldController.text;

                    if (webURL.isNotEmpty) {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JidoujishoPlayer(
                              playerMode: JidoujishoPlayerMode.networkStream,
                              url: webURL,
                            ),
                          ),
                        ).then((returnValue) {
                          setState(() {
                            unlockLandscape();
                          });
                        });
                      } on Exception {
                        Navigator.pop(context);
                        print("INVALID LINK");
                      } catch (error) {
                        Navigator.pop(context);
                        print("INVALID LINK");
                      }
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
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
      case "Manage dictionaries":
        openDictionaryMenu(context, true);
        break;
      case "View repository on GitHub":
        await launch("https://github.com/lrorpilla/jidoujisho");
        break;
      case "Report a bug or problem":
        await launch("https://github.com/lrorpilla/jidoujisho/issues/new");
        break;
      case "About this app":
        const String legalese = "A mobile video player, reader assistant and card creation toolkit tailored for language learners.\n\n" +
            "Built for the Japanese language learning community by Leo Rafael Orpilla. " +
            "Bilingual definitions queried from Jisho.org. Monolingual definitions queried from Sora. Pitch accent patterns from Kanjium. " +
            "Reader WebView linked to ッツ Ebook Reader. Video streaming via YouTube. Image search via Bing. Logo by Aaron Marbella.\n\n" +
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

  List<Widget> buildActions() {
    if (_isCreatorView || readerExport.isNotEmpty) {
      return [];
    }

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

  Widget buildResume() {
    return ValueListenableBuilder(
      valueListenable: gIsResumable,
      builder: (BuildContext context, bool value, Widget child) {
        if (value) {
          return IconButton(
            icon: const Icon(Icons.update_sharp),
            onPressed: () async {
              if (isLastSetVideo()) {
                int lastPlayedPosition = getLastPlayedPosition();
                String lastPlayedPath = getLastPlayedPath();

                JidoujishoPlayerMode playerMode;
                if (lastPlayedPath.startsWith("https://") ||
                    lastPlayedPath.startsWith("http://")) {
                  playerMode = JidoujishoPlayerMode.youtubeStream;
                } else {
                  playerMode = JidoujishoPlayerMode.localFile;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JidoujishoPlayer(
                      playerMode: playerMode,
                      url: lastPlayedPath,
                      initialPosition: lastPlayedPosition,
                    ),
                  ),
                ).then((returnValue) {
                  setState(() {
                    unlockLandscape();
                  });
                });
              } else {
                String initialURL;
                try {
                  initialURL = getBookHistory().last.url;
                } catch (e) {
                  initialURL = null;
                }
                startReader(initialURL);
              }
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
  final ChannelCallback channelCallback;
  final metadataCallback;
  final int index;
  final bool trending;
  final bool channelView;

  YouTubeResult(
    this.result,
    this.cache,
    this.cacheCallback,
    this.channelCallback,
    this.metadataCallback,
    this.index,
    this.trending,
    this.channelView,
  );

  _YouTubeResultState createState() => _YouTubeResultState(
        this.result,
        this.cache,
        this.cacheCallback,
        this.channelCallback,
        this.metadataCallback,
        this.index,
        this.trending,
        this.channelView,
      );
}

class _YouTubeResultState extends State<YouTubeResult>
    with AutomaticKeepAliveClientMixin {
  final Video result;
  final AsyncMemoizer cache;
  final cacheCallback;
  final ChannelCallback channelCallback;
  final metadataCallback;
  final int index;
  final bool trending;
  final bool channelView;

  _YouTubeResultState(
    this.result,
    this.cache,
    this.cacheCallback,
    this.channelCallback,
    this.metadataCallback,
    this.index,
    this.trending,
    this.channelView,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String videoStreamURL = result.url;
    String videoThumbnailURL = result.thumbnails.mediumResUrl;

    String videoTitle = result.title;
    String videoChannel = result.author;
    String videoDuration =
        result.duration == null ? "" : getYouTubeDuration(result.duration);

    Widget displayThumbnail() {
      return Padding(
        padding: EdgeInsets.only(left: 16),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: MediaQuery.of(context).size.shortestSide * (2 / 5),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: FadeInImage(
                    image: NetworkImage(videoThumbnailURL),
                    placeholder: MemoryImage(kTransparentImage),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5.0,
              bottom: 5.0,
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
                videoTitle,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                videoChannel,
                maxLines: 1,
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
          builder: (context) => JidoujishoPlayer(
            playerMode: JidoujishoPlayerMode.youtubeStream,
            url: videoStreamURL,
            video: result,
          ),
        ),
      ).then((returnValue) {
        setState(() {
          unlockLandscape();
        });
      });
    }

    return InkWell(
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                result.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage(
                  image: NetworkImage(result.thumbnails.mediumResUrl),
                  placeholder: MemoryImage(kTransparentImage),
                  width: 1280,
                  fit: BoxFit.fitWidth,
                ),
              ),
              actions: <Widget>[
                if (!channelView)
                  TextButton(
                    child:
                        Text('CHANNEL', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      channelCallback(
                          result.channelId.value, result.author, false);
                      Navigator.pop(context);
                    },
                  ),
                TextButton(
                  child: Text(
                    'PLAY',
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
        padding: EdgeInsets.only(top: 16, bottom: 16),
        height:
            MediaQuery.of(context).size.shortestSide * (2 / 5) * (9 / 16) + 32,
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
    Widget metadataRow(String text, Color color, bool dots) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          (dots)
              ? SizedBox(
                  width: 12,
                  height: 14,
                  child: JumpingDotsProgressIndicator(
                    color: Colors.grey,
                  ),
                )
              : SizedBox.shrink()
        ],
      );
    }

    Widget trendingMessage = Text(
      "Trending #$index in Japan",
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
      "Getting engagement metrics",
      Colors.grey,
      true,
    );
    Widget errorMessage = metadataRow(
      "Error querying engagement metrics",
      Colors.grey,
      false,
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

  Widget showClosedCaptionStatus(
    BuildContext context,
    String videoID,
    int index,
  ) {
    Widget closedCaptionRow(
        String text, Color color, IconData icon, bool dots) {
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
            overflow: TextOverflow.ellipsis,
          ),
          (dots)
              ? SizedBox(
                  width: 12,
                  height: 14,
                  child: JumpingDotsProgressIndicator(color: color),
                )
              : SizedBox.shrink()
        ],
      );
    }

    Widget queryMessage = closedCaptionRow(
      "Querying for closed captions",
      Colors.grey,
      Icons.youtube_searched_for,
      true,
    );
    Widget errorMessage = closedCaptionRow(
      "Error querying closed captions",
      Colors.grey,
      Icons.error,
      false,
    );
    Widget availableMessage = closedCaptionRow(
      "Closed captioning available",
      Colors.green[200],
      Icons.closed_caption,
      false,
    );
    Widget unavailableMessage = closedCaptionRow(
      "No closed captioning",
      Colors.red[200],
      Icons.closed_caption_disabled,
      false,
    );

    try {
      if (getHasClosedCaptions(result.id.value)) {
        return availableMessage;
      } else {
        return unavailableMessage;
      }
    } catch (e) {
      return FutureBuilder(
        future: cacheCallback,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) {
              gCaptioningCache[result.id.value] = AsyncMemoizer();
              return errorMessage;
            } else {
              bool hasClosedCaptions = snapshot.data;
              setHasClosedCaptions(result.id.value, hasClosedCaptions);
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
        callback(result.id.toString(), result.title, true);
      },
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                "${result.title}",
                maxLines: 3,
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
                  child: Text('REMOVE', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await removeChannel(result.id.value);

                    stateCallback();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('CHANNEL', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                    callback(result.id.toString(), result.title, true);
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

class ChannelHorizontalResult extends StatefulWidget {
  final Channel result;
  final ChannelCallback callback;
  final VoidCallback stateCallback;
  final int index;

  ChannelHorizontalResult(
    this.result,
    this.callback,
    this.stateCallback,
    this.index,
  );

  _ChannelHorizontalResultState createState() => _ChannelHorizontalResultState(
        this.result,
        this.callback,
        this.stateCallback,
        this.index,
      );
}

class _ChannelHorizontalResultState extends State<ChannelHorizontalResult>
    with AutomaticKeepAliveClientMixin {
  final Channel result;
  final ChannelCallback callback;
  final stateCallback;
  final int index;

  _ChannelHorizontalResultState(
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: FadeInImage(
          fit: BoxFit.cover,
          width: 64,
          height: 64,
          placeholder: MemoryImage(kTransparentImage),
          image: NetworkImage(channelLogoURL),
        ),
      );
    }

    Widget displayVideoInformation() {
      return Expanded(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      channelTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      child: Container(
        width: 80,
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            displayThumbnail(),
            displayVideoInformation(),
          ],
        ),
      ),
      onTap: () {
        callback(result.id.toString(), result.title, false);
      },
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
            size: 20,
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
        if (icon == Icons.history) {
          HapticFeedback.vibrate();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  result,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'REMOVE',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      removeSearchHistory(result);
                      stateCallback();
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child:
                        Text('SEARCH', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      callback(result);
                    },
                  ),
                ],
              );
            },
          );
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
  final HistoryItem history;
  final HistoryItemPosition historyPosition;
  final stateCallback;
  final channelCallback;
  final int index;

  HistoryResult(
    this.history,
    this.historyPosition,
    this.stateCallback,
    this.channelCallback,
    this.index,
  );

  _HistoryResultState createState() => _HistoryResultState(
        this.history,
        this.historyPosition,
        this.stateCallback,
        this.channelCallback,
        this.index,
      );
}

class _HistoryResultState extends State<HistoryResult>
    with AutomaticKeepAliveClientMixin {
  final HistoryItem history;
  final HistoryItemPosition historyPosition;
  final stateCallback;
  final channelCallback;
  final int index;

  _HistoryResultState(
    this.history,
    this.historyPosition,
    this.stateCallback,
    this.channelCallback,
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

    bool isScopedStorage() {
      return history.subheading.startsWith("/data/");
    }

    bool isReader() {
      return history.url.startsWith("https://ttu-ebook.web.app/");
    }

    ImageProvider getImage() {
      if (isNetwork()) {
        return NetworkImage(history.thumbnail);
      } else if (isReader()) {
        UriData data = Uri.parse(history.thumbnail).data;
        return MemoryImage(data.contentAsBytes());
      } else {
        return FileImage(File(history.thumbnail));
      }
    }

    Widget displayThumbnail() {
      return Padding(
        padding: EdgeInsets.only(left: 16),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: MediaQuery.of(context).size.shortestSide * (2 / 5),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: FadeInImage(
                    image: getImage(),
                    placeholder: MemoryImage(kTransparentImage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5.0,
              bottom: 5.0,
              child: Container(
                height: 20,
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  getYouTubeDuration(Duration(seconds: history.duration)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            Positioned(
              child: Container(
                height: MediaQuery.of(context).size.shortestSide *
                    (2 / 5) *
                    (9 / 16),
                width: MediaQuery.of(context).size.shortestSide * (2 / 5),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.shortestSide * (2 / 5),
                  child: LinearProgressIndicator(
                    value: historyPosition.position / history.duration,
                    backgroundColor: Colors.white.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    minHeight: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
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
              if (isNetwork())
                closedCaptionRow(
                    "YouTube", Colors.grey, Icons.ondemand_video_sharp)
              else if (isScopedStorage())
                closedCaptionRow(
                    "Scoped Storage", Colors.grey, Icons.cached_sharp)
              else if (isReader())
                closedCaptionRow(
                    "ッツ Ebook Reader", Colors.grey, Icons.auto_stories)
              else
                closedCaptionRow(
                    "Local Storage", Colors.grey, Icons.storage_sharp)
            ],
          ),
        ),
      );
    }

    void playVideo() {
      JidoujishoPlayerMode playerMode;
      if (history.url.startsWith("https://") ||
          history.url.startsWith("http://")) {
        playerMode = JidoujishoPlayerMode.youtubeStream;
      } else {
        playerMode = JidoujishoPlayerMode.localFile;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JidoujishoPlayer(
            playerMode: playerMode,
            url: history.url,
            initialPosition: historyPosition.position,
          ),
        ),
      ).then((result) {
        stateCallback();
      });
    }

    return InkWell(
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
                  child: Text(
                    'REMOVE',
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
                        child: Text('CHANNEL',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          channelCallback(
                              history.channelId, history.subheading, false);
                          Navigator.pop(context);
                          print(history.channelId);
                        },
                      )
                    : Container(),
                TextButton(
                  child: Text(
                    'PLAY',
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
        padding: EdgeInsets.only(
          top: 16,
          bottom: 16,
        ),
        height:
            MediaQuery.of(context).size.shortestSide * (2 / 5) * (9 / 16) + 32,
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
  final ChannelCallback channelCallback;
  History(this.channelCallback);

  _HistoryState createState() => _HistoryState(this.channelCallback);
}

class _HistoryState extends State<History> {
  final ChannelCallback channelCallback;
  _HistoryState(this.channelCallback);

  void setStateFromResult() {
    setState(() {
      unlockLandscape();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<HistoryItem> histories = getVideoHistory().reversed.toList();
    List<HistoryItemPosition> historyPositions =
        getVideoHistoryPosition().reversed.toList();

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
      "No videos in history",
      Icons.history_sharp,
      false,
    );

    if (histories.isEmpty) {
      return emptyMessage;
    }

    ScrollController scrollController = ScrollController();
    gCurrentScrollbar = scrollController;

    return RawScrollbar(
      thumbColor: Colors.grey[600],
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        key: UniqueKey(),
        itemCount: histories.length,
        itemBuilder: (BuildContext context, int index) {
          HistoryItem history = histories[index];
          HistoryItemPosition position = historyPositions[index];

          print("HISTORY $history");
          print("POSITION $position");

          print("HISTORY LISTED: $history");

          return HistoryResult(
            history,
            position,
            setStateFromResult,
            channelCallback,
            index,
          );
        },
      ),
    );
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

  ValueNotifier<DictionaryHistoryEntry> _currentInstantSearch =
      ValueNotifier<DictionaryHistoryEntry>(null);
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

    Widget loadingMessage = centerMessage(
      "Preparing dictionary",
      Icons.auto_stories,
      true,
    );

    Widget buildCardCreatorButton() {
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

    void wordFieldSearch() async {
      String searchTerm = _wordController.text;
      if (!_isSearching.value && searchTerm.isNotEmpty) {
        _wordController.clear();
        _isSearching.value = true;

        try {
          var results;
          switch (getCurrentDictionary()) {
            case "Jisho.org API":
              results = await fetchBilingualSearchCache(
                searchTerm: searchTerm,
              );
              break;
            case "Sora Dictionary API":
              results = await fetchMonolingualSearchCache(
                searchTerm: searchTerm,
                recursive: false,
              );
              break;
            default:
              results = await fetchCustomDictionarySearchCache(
                dictionaryName: getCurrentDictionary(),
                searchTerm: searchTerm,
              );
              break;
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

    Widget wordSearchButton() {
      return ValueListenableBuilder(
        valueListenable: _isSearching,
        builder: (BuildContext context, bool isSearching, Widget widget) {
          return IconButton(
            iconSize: 18,
            onPressed: () async {
              wordFieldSearch();
            },
            icon: Icon(Icons.search,
                color: (isSearching) ? Colors.grey : Colors.white),
          );
        },
      );
    }

    List<DictionaryHistoryEntry> entries =
        getDictionaryHistory().reversed.toList();

    Widget buildSearchField() {
      return Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
        child: TextFormField(
          keyboardType: TextInputType.text,
          maxLines: 1,
          controller: _wordController,
          onFieldSubmitted: (result) {
            wordFieldSearch();
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
                wordSearchButton(),
                IconButton(
                  iconSize: 18,
                  onPressed: () => openDictionaryMenu(context, false),
                  icon: Icon(Icons.auto_stories, color: Colors.white),
                ),
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
        ),
      );
    }

    if (entries.isEmpty) {
      return Column(children: [
        buildSearchField(),
        buildCardCreatorButton(),
        Expanded(child: emptyMessage),
      ]);
    }
    return ValueListenableBuilder(
      valueListenable: gKanjiumDictionary,
      builder: (BuildContext context, List<DictionaryEntry> pitchAccents,
          Widget child) {
        if (pitchAccents.isEmpty) {
          return Column(children: [
            buildSearchField(),
            buildCardCreatorButton(),
            Expanded(child: loadingMessage),
          ]);
        }

        return RawScrollbar(
          thumbColor: Colors.grey[600],
          controller: _dictionaryScroller,
          child: ListView.builder(
            controller: _dictionaryScroller,
            addAutomaticKeepAlives: true,
            key: UniqueKey(),
            itemCount: entries.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return buildSearchField();
              }
              if (index == 1) {
                return buildCardCreatorButton();
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
      },
    );
  }

  void setStateFromResult() {
    setState(() {
      unlockLandscape();
    });
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
                  if (entry
                      .entries[entry.swipeIndex].yomichanTermTags.isNotEmpty)
                    SizedBox(height: 5),
                  if (entry
                      .entries[entry.swipeIndex].yomichanTermTags.isNotEmpty)
                    Wrap(
                      children: entry.entries[entry.swipeIndex]
                          .generateTagWidgets(context),
                    ),
                  entry.entries[entry.swipeIndex]
                      .generateMeaningWidgetsMenu(context),
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Search result ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "${entry.swipeIndex + 1} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "out of ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "${entry.entries.length} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (entry.contextDataSource != "-1")
                          if (entry.contextDataSource
                              .startsWith("https://ttu-ebook.web.app/"))
                            TextSpan(
                              text: "from book ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          else
                            TextSpan(
                              text: "from video ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        TextSpan(
                          text: "found for",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "『",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "${entry.searchTerm}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "』",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
                        if (results.entries[_dialogIndex.value].yomichanTermTags
                            .isNotEmpty)
                          SizedBox(height: 5),
                        if (results.entries[_dialogIndex.value].yomichanTermTags
                            .isNotEmpty)
                          Wrap(
                            children: results.entries[_dialogIndex.value]
                                .generateTagWidgets(context),
                          ),
                        results.entries[_dialogIndex.value]
                            .generateMeaningWidgetsDialog(dialogContext),
                        Text.rich(
                          TextSpan(
                            text: '',
                            children: <InlineSpan>[
                              TextSpan(
                                text: "Search result ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: "${_dialogIndex.value + 1} ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "out of ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: "${results.entries.length} ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              if (entry.contextDataSource != "-1")
                                if (entry.contextDataSource
                                    .startsWith("https://ttu-ebook.web.app/"))
                                  TextSpan(
                                    text: "from book ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  TextSpan(
                                    text: "from video ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              TextSpan(
                                text: "found for",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: "『",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: "${results.searchTerm}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "』",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
            if (results.contextDataSource != "-1")
              TextButton(
                child: Text(
                  'CONTEXT',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (entry.contextDataSource
                      .startsWith("https://ttu-ebook.web.app/")) {
                    SystemChrome.setEnabledSystemUIOverlays([]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Reader(
                            entry.contextDataSource, results.contextPosition),
                      ),
                    ).then((result) {
                      setState(() {
                        bool canResume;
                        if (isLastSetVideo()) {
                          canResume = getVideoHistory().isNotEmpty;
                        } else {
                          canResume = getBookHistory().isNotEmpty;
                        }
                        gIsResumable.value = canResume;
                      });
                    });
                  } else {
                    JidoujishoPlayerMode playerMode;
                    if (results.contextDataSource.startsWith("https://") ||
                        results.contextDataSource.startsWith("http://")) {
                      playerMode = JidoujishoPlayerMode.youtubeStream;
                    } else {
                      playerMode = JidoujishoPlayerMode.localFile;
                    }

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JidoujishoPlayer(
                          playerMode: playerMode,
                          url: results.contextDataSource,
                          initialPosition: results.contextPosition,
                        ),
                      ),
                    ).then((returnValue) {
                      stateCallback();
                    });
                  }
                },
              ),
            TextButton(
              child: Text(
                'CREATOR',
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

class LazyResults extends StatefulWidget {
  final channelID;
  final ChannelCallback channelCallback;

  LazyResults(
    this.channelID,
    this.channelCallback,
  );

  @override
  _LazyResultsState createState() =>
      new _LazyResultsState(this.channelID, this.channelCallback);
}

class _LazyResultsState extends State<LazyResults> {
  final String channelID;
  final ChannelCallback channelCallback;

  bool isLoading = false;
  ScrollController scrollController;

  _LazyResultsState(
    this.channelID,
    this.channelCallback,
  );

  List<Video> verticalData;
  final int increment = 10;

  Future _loadMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List<Video> channelVideos = [];
      try {
        channelVideos = await getChannelUploadsStream(channelID)
            .skip(verticalData.length)
            .take(increment)
            .toList();
      } finally {
        setState(() {
          channelVideos.forEach((video) => verticalData.add(video));
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    verticalData = fetchChannelVideoCache(channelID);
    _loadMore();
  }

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

  @override
  Widget build(BuildContext context) {
    if (verticalData.length == 0) {
      return centerMessage(
        "Listing channel videos",
        Icons.subscriptions_sharp,
        true,
      );
    }

    return LazyLoadScrollView(
      onEndOfPage: () => _loadMore(),
      child: Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          addAutomaticKeepAlives: true,
          itemCount: verticalData.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == verticalData.length) {
              if (isLoading) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
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
              channelCallback,
              null,
              index,
              false,
              true,
            );
          },
        ),
      ),
    );
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
      if (!gIsTapToSelectSupported ||
          parseVe(gMecabTagger, initialSentence).length != 1) {
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
              )
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
          contentPadding:
              EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: ValueListenableBuilder(
            valueListenable: _dialogIndex,
            builder: (BuildContext dialogContext, int _, Widget widget) {
              _dialogEntry.value = results.entries[_dialogIndex.value];
              addDictionaryEntryToHistory(
                DictionaryHistoryEntry(
                  entries: results.entries,
                  searchTerm: results.searchTerm,
                  swipeIndex: _dialogIndex.value,
                  contextDataSource: results.contextDataSource,
                  contextPosition: results.contextPosition,
                  dictionarySource: results.dictionarySource,
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
                        if (results.entries[_dialogIndex.value].yomichanTermTags
                            .isNotEmpty)
                          SizedBox(height: 5),
                        if (results.entries[_dialogIndex.value].yomichanTermTags
                            .isNotEmpty)
                          Wrap(
                            children: results.entries[_dialogIndex.value]
                                .generateTagWidgets(context),
                          ),
                        results.entries[_dialogIndex.value]
                            .generateMeaningWidgetsDialog(dialogContext),
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
          contentPadding:
              EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
              if (gIsTapToSelectSupported)
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

    void wordFieldSearch() async {
      String searchTerm = _wordController.text;
      if (!_isSearching.value && searchTerm.isNotEmpty) {
        _wordController.clear();
        _isSearching.value = true;

        try {
          var results;
          switch (getCurrentDictionary()) {
            case "Jisho.org API":
              results = await fetchBilingualSearchCache(
                searchTerm: searchTerm,
              );
              break;
            case "Sora Dictionary API":
              results = await fetchMonolingualSearchCache(
                searchTerm: searchTerm,
                recursive: false,
              );
              break;
            default:
              results = await fetchCustomDictionarySearchCache(
                dictionaryName: getCurrentDictionary(),
                searchTerm: searchTerm,
              );
              break;
          }

          if (results != null && results.entries.isNotEmpty) {
            showDictionaryDialog(results);
          }
        } finally {
          _isSearching.value = false;
        }
      }
    }

    Widget wordSearchButton() {
      return ValueListenableBuilder(
        valueListenable: _isSearching,
        builder: (BuildContext context, bool isSearching, Widget widget) {
          return IconButton(
            iconSize: 18,
            onPressed: () async {
              wordFieldSearch();
            },
            icon: Icon(Icons.search,
                color: (isSearching) ? Colors.grey : Colors.white),
          );
        },
      );
    }

    Widget wordField = TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      controller: _wordController,
      onFieldSubmitted: (result) {
        wordFieldSearch();
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.speaker_notes_outlined,
        ),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            wordSearchButton(),
            IconButton(
              iconSize: 18,
              onPressed: () => openDictionaryMenu(context, false),
              icon: Icon(Icons.auto_stories, color: Colors.white),
            ),
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
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${searchTerm.trim()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
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
