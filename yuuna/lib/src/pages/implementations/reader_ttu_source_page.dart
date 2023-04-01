import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/src/creator/creator_field_values.dart';
import 'package:yuuna/src/creator/fields/sentence_field.dart';
import 'package:yuuna/src/pages/base_source_page.dart';
import 'package:yuuna/utils.dart';

/// The media page used for the [ReaderTtuSource].
class ReaderTtuSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const ReaderTtuSourcePage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderTtuSourcePageState();
}

class _ReaderTtuSourcePageState extends BaseSourcePageState<ReaderTtuSourcePage>
    with WidgetsBindingObserver {
  /// The media source pertaining to this page.
  ReaderTtuSource get mediaSource => ReaderTtuSource.instance;
  bool _controllerInitialised = false;
  late InAppWebViewController _controller;

  DateTime? lastMessageTime;
  Orientation? lastOrientation;

  Duration get consoleMessageDebounce => const Duration(milliseconds: 50);

  final FocusNode _focusNode = FocusNode();
  bool _isRecursiveSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _focusNode.requestFocus();
    }
  }

  @override
  void onSearch(String searchTerm) async {
    _isRecursiveSearching = true;
    if (appModel.isMediaOpen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await Future.delayed(const Duration(milliseconds: 5), () {});
    }
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
    if (appModel.isMediaOpen) {
      await Future.delayed(const Duration(milliseconds: 5), () {});
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _isRecursiveSearching = false;

    _focusNode.requestFocus();
  }

  /// Hide the dictionary and dispose of the current result.
  @override
  void clearDictionaryResult() async {
    super.clearDictionaryResult();
    unselectWebViewTextSelection(_controller);
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != lastOrientation) {
      if (_controllerInitialised) {
        clearDictionaryResult();
      }
      lastOrientation = orientation;
    }

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onFocusChange: (value) {
        if (mediaSource.volumePageTurningEnabled &&
            !(ModalRoute.of(context)?.isCurrent ?? false) &&
            !appModel.isCreatorOpen &&
            !_isRecursiveSearching) {
          _focusNode.requestFocus();
        }
      },
      canRequestFocus: true,
      onKey: (data, event) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (mediaSource.volumePageTurningEnabled) {
            if (isDictionaryShown) {
              clearDictionaryResult();
              unselectWebViewTextSelection(_controller);
              mediaSource.clearCurrentSentence();

              return KeyEventResult.handled;
            }

            if (event.isKeyPressed(LogicalKeyboardKey.audioVolumeUp)) {
              unselectWebViewTextSelection(_controller);
              _controller.evaluateJavascript(source: leftArrowSimulateJs);

              return KeyEventResult.handled;
            }
            if (event.isKeyPressed(LogicalKeyboardKey.audioVolumeDown)) {
              unselectWebViewTextSelection(_controller);
              _controller.evaluateJavascript(source: rightArrowSimulateJs);

              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        } else {
          return KeyEventResult.ignored;
        }
      },
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            top: !mediaSource.extendPageBeyondNavigationBar,
            bottom: false,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: <Widget>[
                buildBody(),
                buildDictionary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    AsyncValue<LocalAssetsServer> server =
        ref.watch(ttuServerProvider(appModel.targetLanguage));

    return server.when(
      data: buildReaderArea,
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(ttuServerProvider(appModel.targetLanguage));
        },
      ),
    );
  }

  void setDictionaryColors() async {
    String currentTheme = (await _controller.evaluateJavascript(
            source: 'window.localStorage.getItem("theme")'))
        .toString();
    switch (currentTheme) {
      case 'light-theme':
        appModel.setOverrideDictionaryTheme(appModel.theme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(249, 249, 249, dictionaryEntryOpacity),
        );
        break;
      case 'ecru-theme':
        appModel.setOverrideDictionaryTheme(appModel.theme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(247, 246, 235, dictionaryEntryOpacity),
        );
        break;
      case 'water-theme':
        appModel.setOverrideDictionaryTheme(appModel.theme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(223, 236, 244, dictionaryEntryOpacity),
        );
        break;
      case 'gray-theme':
        appModel.setOverrideDictionaryTheme(appModel.darkTheme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(35, 39, 42, dictionaryEntryOpacity),
        );
        break;
      case 'dark-theme':
        appModel.setOverrideDictionaryTheme(appModel.darkTheme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(18, 18, 18, dictionaryEntryOpacity),
        );
        break;
      case 'black-theme':
        appModel.setOverrideDictionaryTheme(appModel.darkTheme);
        appModel.setOverrideDictionaryColor(
          Color.fromRGBO(16, 16, 16, dictionaryEntryOpacity),
        );
        break;
    }

    if (mounted) {
      clearDictionaryResult();
      setState(() {});
    }
  }

  String sanitizeWebViewTextSelection(String? text) {
    if (text == null) {
      return '';
    }

    text = text.replaceAll('\\n', '\n');
    text = text.trim();
    return text;
  }

  Future<String> getWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String? selectedText = await webViewController.getSelectedText();
    selectedText = sanitizeWebViewTextSelection(selectedText);
    return selectedText;
  }

  AndroidCacheMode get cacheMode {
    if (mediaSource.currentTtuInternalVersion ==
        ReaderTtuSource.ttuInternalVersion) {
      return AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK;
    } else {
      mediaSource.setTtuInternalVersion();
      return AndroidCacheMode.LOAD_NO_CACHE;
    }
  }

  createFileFromBase64(String base64Content) async {
    var bytes = base64Decode(base64Content.replaceAll('\n', ''));
    DocumentFileSavePlus().saveFile(
      bytes.buffer.asUint8List(),
      _suggestedFilename,
      _mimeType,
    );
    Fluttertoast.showToast(msg: t.file_downloaded(name: _suggestedFilename));
  }

  Widget buildReaderArea(LocalAssetsServer server) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(
          widget.item?.mediaIdentifier ??
              'http://localhost:${server.boundPort}/manage.html',
        ),
      ),
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
          resources: resources,
          action: PermissionRequestResponseAction.GRANT,
        );
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          mediaPlaybackRequiresUserGesture: false,
          verticalScrollBarEnabled: false,
          horizontalScrollBarEnabled: false,
          javaScriptCanOpenWindowsAutomatically: true,
          useOnDownloadStart: true,
        ),
        android: AndroidInAppWebViewOptions(
          forceDark: appModel.isDarkMode
              ? AndroidForceDark.FORCE_DARK_ON
              : AndroidForceDark.FORCE_DARK_OFF,
          verticalScrollbarThumbColor: Colors.transparent,
          verticalScrollbarTrackColor: Colors.transparent,
          horizontalScrollbarThumbColor: Colors.transparent,
          horizontalScrollbarTrackColor: Colors.transparent,
          scrollbarFadingEnabled: false,
          appCachePath: appModel.browserDirectory.path,
          cacheMode: cacheMode,
          supportMultipleWindows: true,
        ),
      ),
      contextMenu: contextMenu,
      onConsoleMessage: onConsoleMessage,
      onWebViewCreated: (controller) {
        _controller = controller;
        _controllerInitialised = true;

        controller.addJavaScriptHandler(
          handlerName: 'blobToBase64Handler',
          callback: (data) async {
            if (data.isNotEmpty) {
              final String base64Content = data[0];
              createFileFromBase64(base64Content);
            }
          },
        );
      },
      onCreateWindow: (controller, createWindowRequest) async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              insetPadding: Spacing.of(context).insets.all.big,
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * (3 / 4),
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      supportZoom: false,
                      disableContextMenu: true,
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true,
                      mediaPlaybackRequiresUserGesture: false,
                      verticalScrollBarEnabled: false,
                      horizontalScrollBarEnabled: false,
                      javaScriptCanOpenWindowsAutomatically: true,
                      userAgent: 'random',
                      useOnDownloadStart: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                      verticalScrollbarThumbColor: Colors.transparent,
                      verticalScrollbarTrackColor: Colors.transparent,
                      horizontalScrollbarThumbColor: Colors.transparent,
                      horizontalScrollbarTrackColor: Colors.transparent,
                      scrollbarFadingEnabled: false,
                      appCachePath: appModel.browserDirectory.path,
                      cacheMode: cacheMode,
                      supportMultipleWindows: true,
                    ),
                  ),
                  windowId: createWindowRequest.windowId,
                  onDownloadStartRequest: onDownloadStartRequest,
                  onCloseWindow: (controller) {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            );
          },
        );
        return true;
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      onLoadStart: (controller, url) async {
        if (mediaSource.getPreference<bool>(
          key: mediaSource.getFirstTimeKey(appModel.targetLanguage),
          defaultValue: true,
        )) {
          if (appModel.isDarkMode) {
            await controller.evaluateJavascript(
                source:
                    'javascript:window.localStorage.setItem("theme", "black-theme")');
          }

          if (!appModel.targetLanguage.preferVerticalReading) {
            await controller.evaluateJavascript(
                source:
                    'javascript:window.localStorage.setItem("writingMode", "horizontal-tb")');
            await controller.evaluateJavascript(
                source:
                    'javascript:window.localStorage.setItem("fontSize", 16)');
            await controller.evaluateJavascript(
                source:
                    'javascript:window.localStorage.setItem("firstDimensionMargin", 24)');
          } else {
            await controller.evaluateJavascript(
                source:
                    'javascript:window.localStorage.setItem("fontSize", 24)');
          }
        }
      },
      onLoadStop: (controller, uri) async {
        await mediaSource.setPreference(
          key: mediaSource.getFirstTimeKey(appModel.targetLanguage),
          value: false,
        );

        setDictionaryColors();

        await controller.evaluateJavascript(source: javascriptToExecute);
        Future.delayed(const Duration(seconds: 1), _focusNode.requestFocus);
      },
      onTitleChanged: (controller, title) async {
        await controller.evaluateJavascript(source: javascriptToExecute);

        setDictionaryColors();
      },
      onDownloadStartRequest: onDownloadStartRequest,
    );
  }

  String _suggestedFilename = '';
  String _mimeType = '';

  void onDownloadStartRequest(
      InAppWebViewController controller, DownloadStartRequest request) async {
    _mimeType = request.mimeType ?? _mimeType;

    _suggestedFilename = request.suggestedFilename ?? _suggestedFilename;

    await controller.evaluateJavascript(
        source: downloadFileJs.replaceAll(
            'blobUrlPlaceholder', request.url.toString()));
  }

  Future<void> selectTextOnwards({
    required int cursorX,
    required int cursorY,
    required int offsetIndex,
    required int length,
    required int whitespaceOffset,
    required bool isSpaceDelimited,
  }) async {
    await _controller.setContextMenu(emptyContextMenu);
    await _controller.evaluateJavascript(
      source:
          'selectTextForTextLength($cursorX, $cursorY, $offsetIndex, $length, $whitespaceOffset, $isSpaceDelimited);',
    );
    await _controller.setContextMenu(contextMenu);
  }

  void onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage message,
  ) async {
    DateTime now = DateTime.now();
    if (lastMessageTime != null &&
        now.difference(lastMessageTime!) < consoleMessageDebounce) {
      return;
    }

    lastMessageTime = now;

    late Map<String, dynamic> messageJson;
    try {
      messageJson = jsonDecode(message.message);
    } catch (e) {
      debugPrint(prettyJson(message.toJson()));

      return;
    }

    switch (messageJson['jidoujisho-message-type']) {
      case 'lookup':
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

        int index = messageJson['index'];
        String text = messageJson['text'];
        int x = messageJson['x'];
        int y = messageJson['y'];

        late JidoujishoPopupPosition position;
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          if (y < MediaQuery.of(context).size.height / 2) {
            position = JidoujishoPopupPosition.bottomHalf;
          } else {
            position = JidoujishoPopupPosition.topHalf;
          }
        } else {
          if (x < MediaQuery.of(context).size.width / 2) {
            position = JidoujishoPopupPosition.rightHalf;
          } else {
            position = JidoujishoPopupPosition.leftHalf;
          }
        }

        if (text.isEmpty || index == -1) {
          clearDictionaryResult();
          mediaSource.clearCurrentSentence();
          return;
        }

        try {
          bool isSpaceDelimited = appModel.targetLanguage.isSpaceDelimited;

          String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
            text: text,
            index: index,
          );
          int whitespaceOffset =
              searchTerm.length - searchTerm.trimLeft().length;

          int offsetIndex = appModel.targetLanguage
                  .getStartingIndex(text: text, index: index) +
              whitespaceOffset;

          int length = appModel.targetLanguage
              .textToWords(searchTerm)
              .firstWhere((e) => e.trim().isNotEmpty)
              .length;

          if (mediaSource.highlightOnTap) {
            await selectTextOnwards(
              cursorX: x,
              cursorY: y,
              offsetIndex: offsetIndex,
              length: length,
              whitespaceOffset: whitespaceOffset,
              isSpaceDelimited: isSpaceDelimited,
            );
          }

          searchDictionaryResult(
            searchTerm: searchTerm,
            position: position,
          ).then((_) {
            int length = isSpaceDelimited
                ? appModel.targetLanguage
                    .textToWords(searchTerm)
                    .firstWhere((e) => e.trim().isNotEmpty)
                    .length
                : max(1, currentResult?.bestLength ?? 0);

            if (mediaSource.highlightOnTap) {
              selectTextOnwards(
                cursorX: x,
                cursorY: y,
                offsetIndex: offsetIndex,
                length: length,
                whitespaceOffset: whitespaceOffset,
                isSpaceDelimited: isSpaceDelimited,
              );
            }
          });
          String sentence = appModel.targetLanguage.getSentenceFromParagraph(
            paragraph: text,
            index: index,
          );
          mediaSource.setCurrentSentence(sentence.replaceAll('\\n', '\n'));
        } catch (e) {
          clearDictionaryResult();
        } finally {
          FocusScope.of(context).unfocus();
          _focusNode.requestFocus();
        }

        break;
    }
  }

  Future<void> unselectWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String source = 'window.getSelection().removeAllRanges();';
    await webViewController.evaluateJavascript(source: source);
  }

  /// Get the default context menu for sources that make use of embedded web
  /// views.
  ContextMenu get contextMenu => ContextMenu(
        options: ContextMenuOptions(
          hideDefaultSystemContextMenuItems: true,
        ),
        menuItems: [
          searchMenuItem(),
          stashMenuItem(),
          creatorMenuItem(),
          copyMenuItem(),
        ],
      );

  /// Get the default context menu for sources that make use of embedded web
  /// views.
  ContextMenu get emptyContextMenu => ContextMenu(
        options: ContextMenuOptions(
          hideDefaultSystemContextMenuItems: true,
        ),
        menuItems: [],
      );

  ContextMenuItem searchMenuItem() {
    return ContextMenuItem(
      iosId: '1',
      androidId: 1,
      title: t.search,
      action: searchMenuAction,
    );
  }

  ContextMenuItem stashMenuItem() {
    return ContextMenuItem(
      iosId: '2',
      androidId: 2,
      title: t.stash,
      action: stashMenuAction,
    );
  }

  ContextMenuItem creatorMenuItem() {
    return ContextMenuItem(
      iosId: '3',
      androidId: 3,
      title: t.creator,
      action: creatorMenuAction,
    );
  }

  ContextMenuItem copyMenuItem() {
    return ContextMenuItem(
      iosId: '4',
      androidId: 4,
      title: t.copy,
      action: copyMenuAction,
    );
  }

  void searchMenuAction() async {
    String searchTerm = await getSelectedText();
    _isRecursiveSearching = true;

    await unselectWebViewTextSelection(_controller);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
    await Future.delayed(const Duration(milliseconds: 5), () {});
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _isRecursiveSearching = false;
    _focusNode.requestFocus();
  }

  void stashMenuAction() async {
    String searchTerm = await getSelectedText();

    appModel.addToStash(terms: [searchTerm]);
  }

  void creatorMenuAction() async {
    String searchTerm = await getSelectedText();

    await unselectWebViewTextSelection(_controller);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});

    await appModel.openCreator(
      ref: ref,
      killOnPop: false,
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: searchTerm.replaceAll('\\n', '\n'),
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 5), () {});
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _focusNode.requestFocus();
  }

  void copyMenuAction() async {
    String searchTerm = await getSelectedText();
    Clipboard.setData(ClipboardData(text: searchTerm));
    await unselectWebViewTextSelection(_controller);
  }

  Future<String> getSelectedText() async {
    return (await _controller.getSelectedText() ?? '')
        .replaceAll('\\n', '\n')
        .trim();
  }

  String downloadFileJs = '''
var xhr = new XMLHttpRequest();
var blobUrl = "blobUrlPlaceholder";
console.log(blobUrl);
xhr.open('GET', blobUrl, true);
xhr.responseType = 'blob';
xhr.onload = function(e) {
  if (this.status == 200) {
    var blob = this.response;
    var reader = new FileReader();
    reader.readAsDataURL(blob);
    reader.onloadend = function() {
      var base64data = reader.result;
      var base64ContentArray = base64data.split(",")     ;
      var mimeType = base64ContentArray[0].match(/[^:\\s*]\\w+\\/[\\w-+\\d.]+(?=[;| ])/)[0];
      var decodedFile = base64ContentArray[1];
      console.log(mimeType);
      window.flutter_inappwebview.callHandler('blobToBase64Handler', decodedFile, mimeType);
    };
  };
};
xhr.send();
''';

  /// This is executed upon page load and change.
  /// More accurate readability courtesy of
  /// https://github.com/birchill/10ten-ja-reader/blob/fbbbde5c429f1467a7b5a938e9d67597d7bd5ffa/src/content/get-text.ts#L314
  String javascriptToExecute = """
/*jshint esversion: 6 */

function tapToSelect(e) {
  if (getSelectionText()) {
    console.log(JSON.stringify({
				"index": -1,
				"text": getSelectionText(),
				"jidoujisho-message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
        "isCreator": "no",
			}));
  }

  var result = document.caretRangeFromPoint(e.clientX, e.clientY);

  if (e.target.classList.contains('book-content')) {
    console.log(JSON.stringify({
      "index": -1,
      "text": getSelectionText(),
      "jidoujisho-message-type": "lookup",
      "x": e.clientX,
      "y": e.clientY,
      "isCreator": "no",
    }));
    return;
  }

  var selectedElement = result.startContainer;
  var paragraph = result.startContainer;
  var offsetNode = result.startContainer;
  var offset = result.startOffset;

  var adjustIndex = false;

  if (!!offsetNode && offsetNode.nodeType === Node.TEXT_NODE && offset) {
      const range = new Range();
      range.setStart(offsetNode, offset - 1);
      range.setEnd(offsetNode, offset);

      const bbox = range.getBoundingClientRect();
      if (bbox.left <= e.x && bbox.right >= e.x &&
          bbox.top <= e.y && bbox.bottom >= e.y) {
          
          result.startOffset = result.startOffset - 1;
          adjustIndex = true;
      }
    }
  
  
  while (paragraph && paragraph.nodeName !== 'P') {
    paragraph = paragraph.parentNode;
  }
  if (paragraph === null) {
    paragraph = result.startContainer.parentNode;
  }
  var noFuriganaText = [];
  var noFuriganaNodes = [];
  var selectedFound = false;
  var index = 0;
  for (var value of paragraph.childNodes.values()) {
    if (value.nodeName === "#text") {
      noFuriganaText.push(value.textContent);
      noFuriganaNodes.push(value);
      if (selectedFound === false) {
        if (selectedElement !== value) {
          index = index + value.textContent.length;
        } else {
          index = index + result.startOffset;
          selectedFound = true;
        }
      }
    } else {
      for (var node of value.childNodes.values()) {
        if (node.nodeName === "#text") {
          noFuriganaText.push(node.textContent);
          noFuriganaNodes.push(node);
          if (selectedFound === false) {
            if (selectedElement !== node) {
              index = index + node.textContent.length;
            } else {
              index = index + result.startOffset;
              selectedFound = true;
            }
          }
        } else if (node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
          noFuriganaText.push(node.firstChild.textContent);
          noFuriganaNodes.push(node.firstChild);
          if (selectedFound === false) {
            if (selectedElement !== node.firstChild) {
              index = index + node.firstChild.textContent.length;
            } else {
              index = index + result.startOffset;
              selectedFound = true;
            }
          }
        }
      }
    }
  }
  var text = noFuriganaText.join("");
  var offset = index;
  if (adjustIndex) {
    index = index - 1;
  }

  var character = text[index];
  if (character) {
    console.log(JSON.stringify({
      "index": index,
      "text": text,
      "jidoujisho-message-type": "lookup",
      "x": e.clientX,
      "y": e.clientY,
    }));
    console.log(character);
  } else {
    console.log(JSON.stringify({
      "index": -1,
      "text": getSelectionText(),
      "jidoujisho-message-type": "lookup",
      "x": e.clientX,
      "y": e.clientY,
      "isCreator": "no",
    }));
  }
}
function getSelectionText() {
    function getRangeSelectedNodes(range) {
      var node = range.startContainer;
      var endNode = range.endContainer;
      if (node == endNode) return [node];
      var rangeNodes = [];
      while (node && node != endNode) rangeNodes.push(node = nextNode(node));
      node = range.startContainer;
      while (node && node != range.commonAncestorContainer) {
        rangeNodes.unshift(node);
        node = node.parentNode;
      }
      return rangeNodes;
      function nextNode(node) {
        if (node.hasChildNodes()) return node.firstChild;
        else {
          while (node && !node.nextSibling) node = node.parentNode;
          if (!node) return null;
          return node.nextSibling;
        }
      }
    }
    var txt = "";
    var nodesInRange;
    var selection;
    if (window.getSelection) {
      selection = window.getSelection();
      nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));
      nodes = nodesInRange.filter((node) => node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
      if (selection.anchorNode === selection.focusNode) {
          txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));
      } else {
          for (var i = 0; i < nodes.length; i++) {
              var node = nodes[i];
              if (i === 0) {
                  txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));
              } else if (i === nodes.length - 1) {
                  txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));
              } else {
                  txt = txt.concat(node.textContent);
              }
          }
      }
    } else if (window.document.getSelection) {
      selection = window.document.getSelection();
      nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));
      nodes = nodesInRange.filter((node) => node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
      if (selection.anchorNode === selection.focusNode) {
          txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));
      } else {
          for (var i = 0; i < nodes.length; i++) {
              var node = nodes[i];
              if (i === 0) {
                  txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));
              } else if (i === nodes.length - 1) {
                  txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));
              } else {
                  txt = txt.concat(node.textContent);
              }
          }
      }
    } else if (window.document.selection) {
      txt = window.document.selection.createRange().text;
    }
    return txt;
};
var reader = document.getElementsByClassName('book-content');
if (reader.length != 0) {
  reader[0].addEventListener('click', tapToSelect, true);
}
document.head.insertAdjacentHTML('beforebegin', `
<style>
rt {
  -webkit-touch-callout:none; /* iOS Safari */
  -webkit-user-select:none;   /* Chrome/Safari/Opera */
  -khtml-user-select:none;    /* Konqueror */
  -moz-user-select:none;      /* Firefox */
  -ms-user-select:none;       /* Internet Explorer/Edge */
  user-select:none;           /* Non-prefixed version */
}
rp {
  -webkit-touch-callout:none; /* iOS Safari */
  -webkit-user-select:none;   /* Chrome/Safari/Opera */
  -khtml-user-select:none;    /* Konqueror */
  -moz-user-select:none;      /* Firefox */
  -ms-user-select:none;       /* Internet Explorer/Edge */
  user-select:none;           /* Non-prefixed version */
}

::selection {
  color: white;
  background: rgba(255, 0, 0, 0.6);
}
</style>
`);


function selectTextForTextLength(x, y, index, length, whitespaceOffset, isSpaceDelimited) {
  var result = document.caretRangeFromPoint(x, y);

  var selectedElement = result.startContainer;
  var paragraph = result.startContainer;
  var offsetNode = result.startContainer;
  var offset = result.startOffset;

  var adjustIndex = false;

  if (isSpaceDelimited) {
    const range = new Range();
    range.setStart(offsetNode, index);
    range.setEnd(offsetNode, index);
    range.expand("word")

    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    return;
  } 

  if (!!offsetNode && offsetNode.nodeType === Node.TEXT_NODE && offset) {
      const range = new Range();
      range.setStart(offsetNode, offset - 1);
      range.setEnd(offsetNode, offset);

      const bbox = range.getBoundingClientRect();
      if (bbox.left <= x && bbox.right >= x &&
          bbox.top <= y && bbox.bottom >= y) {
          if (length == 1) {
            const range = new Range();
            range.setStart(offsetNode, result.startOffset - 1);
            range.setEnd(offsetNode, result.startOffset);

            var selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(range);
            return;
          }

          result.startOffset = result.startOffset - 1;
          adjustIndex = true;
      }
  }

  if (length == 1) {
    const range = new Range();
    range.setStart(offsetNode, result.startOffset);
    range.setEnd(offsetNode, result.startOffset + 1);

    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    return;
  }

  while (paragraph && paragraph.nodeName !== 'P') {
    paragraph = paragraph.parentNode;
  }
  if (paragraph === null) {
    paragraph = result.startContainer.parentNode;
  }
  var noFuriganaText = [];
  var lastNode;

  var endOffset = 0;
  var done = false;

  for (var value of paragraph.childNodes.values()) {
    if (done) {
      console.log(noFuriganaText.join());
      break;
    }
    
    if (value.nodeName === "#text") {
      endOffset = 0;
      lastNode = value;
      for (var i = 0; i < value.textContent.length; i++) {
        noFuriganaText.push(value.textContent[i]);
        endOffset = endOffset + 1;
        if (noFuriganaText.length >= length + index) {
          done = true;
          break;
        }
      }
    } else {
      for (var node of value.childNodes.values()) {
        if (done) {
          break;
        }

        if (node.nodeName === "#text") {
          endOffset = 0;
          lastNode = node;

          for (var i = 0; i < node.textContent.length; i++) {
            noFuriganaText.push(node.textContent[i]);
            endOffset = endOffset + 1;
            if (noFuriganaText.length >= length + index) {
              done = true;
              break;
            }
          }
        } else if (node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
          endOffset = 0;
          lastNode = node.firstChild;
          for (var i = 0; i < node.firstChild.textContent.length; i++) {
            noFuriganaText.push(node.firstChild.textContent[i]);
            endOffset = endOffset + 1;
            if (noFuriganaText.length >= length + index) {
              done = true;
              break;
            }
          }
        }
      }
    }
  }

  const range = new Range();
  range.setStart(offsetNode, result.startOffset - adjustIndex + whitespaceOffset);
  range.setEnd(lastNode, endOffset);
  
  var selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
}
""";

  String get leftArrowSimulateJs => '''
    var evt = document.createEvent('MouseEvents');
    evt.initEvent('wheel', true, true); 
    evt.deltaY = +0.001 * ${mediaSource.volumePageTurningSpeed * (mediaSource.volumePageTurningInverted ? -1 : 1)};
    document.body.dispatchEvent(evt); 
    ''';

  String get rightArrowSimulateJs => '''
    var evt = document.createEvent('MouseEvents');
    evt.initEvent('wheel', true, true); 
    evt.deltaY = -0.001 * ${mediaSource.volumePageTurningSpeed * (mediaSource.volumePageTurningInverted ? -1 : 1)};
    document.body.dispatchEvent(evt); 
    ''';
}
