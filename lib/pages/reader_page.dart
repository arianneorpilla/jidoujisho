import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  final ReaderLaunchParams params;

  @override
  State<StatefulWidget> createState() => ReaderPageState();
}

class ReaderPageState extends State<ReaderPage> {
  late AppModel appModel;
  Color dictionaryColor = Colors.grey.shade800.withOpacity(0.97);

  late InAppWebViewController webViewController;

  DictionarySearchResult? latestResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<String> searchMessage = ValueNotifier<String>("");

  final ValueNotifier<int> latestResultEntryIndex = ValueNotifier<int>(0);

  /// Public for a [MediaSource] to edit and store session-specific details
  /// for its source button.
  Map<dynamic, dynamic> sourceOptions = {};

  late ReaderMediaSource source;

  late int currentProgress;
  late int completeProgress;
  late dynamic scrollX;
  late dynamic scrollY;
  late String url;
  late dynamic thumbnail;
  late String title;
  late String author;

  ThemeData? themeData;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    Wakelock.enable();

    ClipboardListener.addListener(copyClipboardAction);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    source = widget.params.mediaSource;

    currentProgress = widget.params.mediaHistoryItem.currentProgress;
    completeProgress = widget.params.mediaHistoryItem.completeProgress;
    url = widget.params.mediaHistoryItem.key;
    scrollX = widget.params.mediaHistoryItem.extra["scrollX"] ?? -1;
    scrollY = widget.params.mediaHistoryItem.extra["scrollY"] ?? -1;
    thumbnail = widget.params.mediaHistoryItem.extra["thumbnail"] ?? "";
    author = widget.params.mediaHistoryItem.author;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.params.mediaSource.getHorizontalHack(context)) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
        ]);
      }

      setIsDarkMode(appModel.getIsDarkMode());
      setState(() {});
    });
  }

  @override
  void dispose() async {
    ClipboardListener.removeListener(copyClipboardAction);
    super.dispose();
  }

  Future<void> updateHistory() async {
    MediaHistory history =
        widget.params.mediaSource.mediaType.getMediaHistory(appModel);

    widget.params.mediaHistoryItem.currentProgress = currentProgress;

    MediaHistoryItem item = MediaHistoryItem(
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      key: url,
      extra: {
        "thumbnail": thumbnail,
        "scrollX": -1,
        "scrollY": -1,
      },
      thumbnailPath: widget.params.mediaHistoryItem.thumbnailPath,
      alias: widget.params.mediaHistoryItem.alias,
      title: title,
      author: author,
      sourceName: source.sourceName,
      mediaTypePrefs: MediaType.reader.prefsDirectory(),
    );

    if (completeProgress != 0 && thumbnail.isNotEmpty && title.isNotEmpty) {
      if (widget.params.saveHistoryItem) {
        if (!appModel.getIncognitoMode()) {
          await history.addItem(item);
        }
      }
    }
  }

  Future<void> copyClipboardAction() async {
    setSearchTerm((await Clipboard.getData(Clipboard.kTextPlain))!
        .text!
        .replaceAll("￼", ""));
  }

  void setCurrentProgress(int value) {
    currentProgress = value;
  }

  void setCompleteProgress(int value) {
    completeProgress = value;
  }

  void setScrollX(int value) {
    scrollX = value;
  }

  void setScrollY(int value) {
    scrollY = value;
  }

  void setUrl(String value) {
    url = value;
  }

  void setThumbnail(String value) {
    thumbnail = value;
  }

  void setTitle(String value) {
    title = value;
  }

  void setAuthor(String value) {
    author = value;
  }

  void setIsDarkMode(bool value) {
    isDarkMode = value;

    dictionaryColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.97)
        : Colors.grey.shade200.withOpacity(0.97);
    themeData = isDarkMode
        ? appModel.getDarkTheme(context)
        : appModel.getLightTheme(context);
    setState(() {});
  }

  Future<bool> onWillPop() async {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        appModel.translate("dialog_exit_reader"),
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              appModel.translate("dialog_yes"),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, true);
              appModel.dictionaryUpdateFlipflop.value =
                  !appModel.dictionaryUpdateFlipflop.value;
              appModel.readerUpdateFlipflop.value =
                  !appModel.readerUpdateFlipflop.value;
            }),
        TextButton(
          child: Text(
            appModel.translate("dialog_no"),
          ),
          onPressed: () async {
            Navigator.pop(context, false);
          },
        ),
      ],
    );

    return await showDialog(
          context: context,
          builder: (context) => (source.getHorizontalHack(context))
              ? RotatedBox(quarterTurns: 1, child: alertDialog)
              : alertDialog,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    themeData ??= Theme.of(context);
    appModel = Provider.of<AppModel>(context);

    return Theme(
      data: themeData!,
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildReaderArea(),
              (source.getHorizontalHack(context))
                  ? RotatedBox(
                      quarterTurns: 1,
                      child: buildDictionary(),
                    )
                  : buildDictionary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReaderArea() {
    return source.buildReaderArea(context, this);
  }

  void refreshDictionaryWidget() {
    String holder = searchTerm.value;
    searchTerm.value = "";
    searchTerm.value = holder;
  }

  void setSearchTerm(String newTerm) {
    searchTerm.value = newTerm.trim();
    latestResult = null;
  }

  MediaHistoryItem? generateContextHistoryItem() {
    if (!widget.params.saveHistoryItem) {
      return null;
    }

    MediaHistoryItem item = MediaHistoryItem(
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      key: url,
      extra: {
        "thumbnail": thumbnail,
        "scrollX": scrollX,
        "scrollY": scrollY,
      },
      title: title,
      author: author,
      sourceName: source.sourceName,
      mediaTypePrefs: MediaType.reader.prefsDirectory(),
    );

    return item;
  }

  Widget buildDictionary() {
    return MultiValueListenableBuider(
      valueListenables: [
        searchTerm,
        searchMessage,
      ],
      builder: (context, values, _) {
        String searchTerm = values.elementAt(0);
        String searchMessage = values.elementAt(1);

        if (searchMessage.isNotEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.of(context).size.height * 0.075,
                bottom: MediaQuery.of(context).size.height * 0.075,
              ),
              child: GestureDetector(
                onTap: () {
                  setSearchTerm("");
                },
                child: Container(
                  color: dictionaryColor,
                  padding: const EdgeInsets.all(16),
                  child: buildDictionaryMessage(searchMessage),
                ),
              ),
            ),
          );
        }

        if (searchTerm.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).size.height * 0.075,
              bottom: MediaQuery.of(context).size.height * 0.075,
            ),
            child: GestureDetector(
              onTap: () {
                setSearchTerm("");
              },
              onLongPress: () async {
                await appModel.showDictionaryMenu(
                  context,
                  onDictionaryChange: () {
                    refreshDictionaryWidget();
                  },
                  horizontalHack: source.getHorizontalHack(context),
                  themeData: themeData,
                );
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == 0) return;

                if (details.primaryVelocity!.compareTo(0) == -1) {
                  appModel.setPrevDictionary();
                } else {
                  appModel.setNextDictionary();
                }
                refreshDictionaryWidget();
              },
              child: Container(
                color: dictionaryColor,
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DictionarySearchResult>(
                  future: appModel.searchDictionary(
                    searchTerm,
                    mediaHistoryItem: generateContextHistoryItem(),
                  ), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<DictionarySearchResult> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildDictionarySearching();
                    }

                    latestResult = snapshot.data;

                    if (!snapshot.hasData || latestResult!.entries.isEmpty) {
                      return buildDictionaryNoMatch();
                    } else {
                      return buildDictionaryMatch();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDictionaryMatch() {
    latestResultEntryIndex.value = 0;

    return DictionaryScrollableWidget.fromLatestResult(
      appModel: appModel,
      result: latestResult!,
      indexNotifier: latestResultEntryIndex,
      selectable: true,
    );
  }

  Widget buildDictionarySearching() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("searching_before"),
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("searching_after"),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildDictionaryMessage1Argument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessageArgument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessage(String messageText) {
    // Handle special cases with certain reserved patterns.
    if (messageText.startsWith("deckExport://")) {
      String deckName = messageText.replaceAll("deckExport://", "");
      return buildDictionaryMessageArgument(
        appModel.translate("deck_label_before"),
        deckName,
        appModel.translate("deck_label_after"),
        false,
      );
    }

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: messageText.replaceAll("...", ""),
          ),
          if (messageText.endsWith("..."))
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryNoMatch() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("dictionary_nomatch_before"),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeData!.unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_nomatch_after"),
            style: const TextStyle(),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void setDictionaryMessage(String messageText, {Duration? duration}) {
    searchMessage.value = messageText;
    if (duration != null) {
      Future.delayed(duration, () {
        clearDictionaryMessage();
      });
    }
  }

  void clearDictionaryMessage() {
    searchMessage.value = "";
  }

  Future<void> openCardCreator(String selection) async {
    MediaHistoryItem? contextItem = generateContextHistoryItem();
    String? contextJson = "";
    if (contextItem != null) {
      contextJson = Uri.encodeFull(
          "https://jidoujisho.context/${generateContextHistoryItem()!.toJson()}");
    }

    AnkiExportParams initialParams = AnkiExportParams(
      sentence: selection,
      context: contextJson,
    );

    if (latestResult != null) {
      DictionaryEntry entry =
          latestResult!.entries[latestResultEntryIndex.value];
      initialParams.word = entry.word;
      initialParams.meaning = entry.meaning;
      initialParams.reading = entry.reading;
    }

    searchTerm.value = "";

    ClipboardListener.removeListener(copyClipboardAction);

    clearDictionaryMessage();

    await navigateToCreator(
      context: context,
      appModel: appModel,
      initialParams: initialParams,
      popOnExport: true,
      hideActions: true,
      themeData: themeData,
      exportCallback: () {
        Navigator.of(context).pop();
        String lastDeck = appModel.getLastAnkiDroidDeck();
        setDictionaryMessage(
          "deckExport://$lastDeck",
          duration: const Duration(seconds: 3),
        );
      },
    );

    await Clipboard.setData(const ClipboardData(text: ""));
    ClipboardListener.addListener(copyClipboardAction);
  }
}
