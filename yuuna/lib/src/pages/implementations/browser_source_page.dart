import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page for browsing a catalog until a volume is opened.
class BrowserSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const BrowserSourcePage({
    required super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _BrowserSourcePageState();
}

class _BrowserSourcePageState extends BaseSourcePageState<BrowserSourcePage> {
  final String userAgent =
      'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.57 Mobile Safari/537.36';

  final ValueNotifier<bool> _isMenuHidden = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _backAvailableNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _forwardAvailableNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<Uri?> _uriNotifier = ValueNotifier<Uri?>(null);
  final ValueNotifier<String?> _titleNotifier = ValueNotifier<String?>(null);

  late final List<String> _readingListUrls;

  Timer? _menuHideTimer;

  @override
  void initState() {
    _readingListUrls = appModelNoUpdate
        .getMediaSourceHistory(mediaSource: mediaSource)
        .map((e) => e.mediaIdentifier)
        .toList();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item != null && widget.item!.position != 0) {
        widget.item!.position = DateTime.now().millisecondsSinceEpoch;
        appModel.addMediaItem(widget.item!);
      }
    });
  }

  bool _controllerInitialised = false;

  late InAppWebViewController _controller;

  ReaderBrowserSource get mediaSource => ReaderBrowserSource.instance;

  DateTime? lastMessageTime;
  Orientation? lastOrientation;

  Duration get consoleMessageDebounce => const Duration(milliseconds: 50);
  double get blurRadius => 8;

  Widget buildGoBackButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _backAvailableNotifier,
      builder: (context, value, child) {
        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Material(
                child: Tooltip(
                  message: t.go_back,
                  child: InkWell(
                    onTap: value ? () => _controller.goBack() : null,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.unselectedWidgetColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color:
                            value ? null : theme.disabledColor.withOpacity(0.2),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildGoForwardButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _forwardAvailableNotifier,
      builder: (context, value, child) {
        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Material(
                child: Tooltip(
                  message: t.go_forward,
                  child: InkWell(
                    onTap: value ? () => _controller.goForward() : null,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.unselectedWidgetColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color:
                            value ? null : theme.disabledColor.withOpacity(0.2),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBrowseButton() {
    return ValueListenableBuilder<Uri?>(
      valueListenable: _uriNotifier,
      builder: (context, value, child) {
        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Material(
                child: Tooltip(
                  message: t.browse,
                  child: InkWell(
                    onTap: browseAction,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.unselectedWidgetColor.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.language,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildReadingListButton() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _uriNotifier,
        _titleNotifier,
      ],
      builder: (context, values, child) {
        String mediaIdentifier = Uri.decodeFull(
            _uriNotifier.value?.removeFragment().toString() ?? '');

        bool inReadingList = _readingListUrls.contains(mediaIdentifier);

        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Material(
                child: Tooltip(
                  message: t.add_to_reading_list,
                  child: InkWell(
                    onTap: _titleNotifier.value == null
                        ? null
                        : () => inReadingList
                            ? existsReadingListAction(mediaIdentifier)
                            : addReadingListAction(mediaIdentifier),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.unselectedWidgetColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.bookmark_outline,
                        color: _titleNotifier.value == null
                            ? theme.disabledColor
                            : inReadingList
                                ? theme.colorScheme.primary
                                : null,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _busy = false;

  void existsReadingListAction(String url) {
    _readingListUrls.remove(url);

    Uri? temp = _uriNotifier.value;
    _uriNotifier.value = null;
    _uriNotifier.value = temp;

    appModel.removeFromReadingList(url);

    Fluttertoast.showToast(msg: t.reading_list_remove_toast);
  }

  void addReadingListAction(String url) async {
    if (_busy) {
      return;
    }

    try {
      _busy = true;
      _readingListUrls.add(url);

      Uri? temp = _uriNotifier.value;
      _uriNotifier.value = null;
      _uriNotifier.value = temp;

      BrowserBookmark bookmark =
          BrowserBookmark(name: _titleNotifier.value ?? '', url: url);

      Uint8List? screenshot = await _controller.takeScreenshot(
          screenshotConfiguration: ScreenshotConfiguration(
        snapshotWidth: 300,
        quality: 70,
      ));

      String? base64Image;
      if (screenshot != null) {
        base64Image =
            'data:image/png;base64,${base64.encode(screenshot.toList())}';
      }

      MediaItem item = mediaSource.generateMediaItem(
        bookmark,
        base64Image: base64Image,
      );

      item.position = DateTime.now().millisecondsSinceEpoch;

      appModel.addMediaItem(item);

      Fluttertoast.showToast(msg: t.reading_list_add_toast);
    } finally {
      _busy = false;
    }
  }

  void browseAction() async {
    await showDialog(
      context: context,
      builder: (context) => BrowserDialogPage(
        text: Uri.decodeFull(
            _uriNotifier.value?.removeFragment().toString() ?? ''),
        onBrowse: (url) {
          _controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
        },
      ),
    );
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
          copyMenuItem(),
          shareMenuItem(),
          creatorMenuItem(),
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

  ContextMenuItem copyMenuItem() {
    return ContextMenuItem(
      iosId: '3',
      androidId: 3,
      title: t.copy,
      action: copyMenuAction,
    );
  }

  ContextMenuItem shareMenuItem() {
    return ContextMenuItem(
      iosId: '4',
      androidId: 4,
      title: t.share,
      action: shareMenuAction,
    );
  }

  ContextMenuItem creatorMenuItem() {
    return ContextMenuItem(
      iosId: '5',
      androidId: 5,
      title: t.creator,
      action: creatorMenuAction,
    );
  }

  void searchMenuAction() async {
    String searchTerm = await getSelectedText();

    await unselectWebViewTextSelection(_controller);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
    await Future.delayed(const Duration(milliseconds: 5), () {});
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void stashMenuAction() async {
    String searchTerm = await getSelectedText();
    appModel.addToStash(terms: [searchTerm]);
    await unselectWebViewTextSelection(_controller);
  }

  void creatorMenuAction() async {
    String text = await getSelectedText();

    await unselectWebViewTextSelection(_controller);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});

    await appModel.openCreator(
      ref: ref,
      killOnPop: false,
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: text,
          TermField.instance: '',
          ClozeBeforeField.instance: '',
          ClozeInsideField.instance: '',
          ClozeAfterField.instance: '',
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 5), () {});
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void copyMenuAction() async {
    String searchTerm = await getSelectedText();
    Clipboard.setData(ClipboardData(text: searchTerm));
    await unselectWebViewTextSelection(_controller);
  }

  void shareMenuAction() async {
    String searchTerm = await getSelectedText();
    Share.share(searchTerm);
    await unselectWebViewTextSelection(_controller);
  }

  Future<String> getSelectedText() async {
    return (await _controller.getSelectedText() ?? '')
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .split('\n')
        .map((e) => e.trim())
        .join()
        .trim();
  }

  int scrollX = 0;
  int scrollY = 0;

  Widget buildWebView() {
    return InAppWebView(
      onScrollChanged: (controller, newX, newY) {
        if ((scrollX - newX).abs() > 20) {
          _menuHideTimer?.cancel();
          _isMenuHidden.value = newX > scrollX;
        } else if ((scrollY - newY).abs() > 20) {
          _menuHideTimer?.cancel();
          _isMenuHidden.value = newY > scrollY;
        }

        scrollX = newX;
        scrollY = newY;
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: userAgent,
        ),
        android: AndroidInAppWebViewOptions(
          useShouldInterceptRequest: true,
        ),
      ),
      initialUrlRequest:
          URLRequest(url: Uri.parse(widget.item!.mediaIdentifier)),
      contextMenu: contextMenu,
      onConsoleMessage: onConsoleMessage,
      onWebViewCreated: (controller) {
        _controller = controller;
        _controllerInitialised = true;
      },
      onLoadStop: (controller, uri) async {
        _uriNotifier.value = uri;
        _titleNotifier.value = await controller.getTitle();
        _backAvailableNotifier.value = await controller.canGoBack();
        _forwardAvailableNotifier.value = await controller.canGoForward();

        mediaSource.setLastAddress(Uri.decodeFull(
            _uriNotifier.value?.removeFragment().toString() ?? ''));

        controller.evaluateJavascript(source: javascriptToExecute);
      },
    );
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

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: !mediaSource.extendPageBeyondNavigationBar,
          bottom: false,
          child: Stack(
            alignment: Alignment.topRight,
            fit: StackFit.expand,
            children: <Widget>[
              buildWebView(),
              Padding(
                padding: Spacing.of(context).insets.onlyTop.extraBig * 1.5,
                child: buildDictionary(),
              ),
              buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActions() {
    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isMenuHidden,
        builder: (context, value, _) {
          return IgnorePointer(
            ignoring: value,
            child: AnimatedOpacity(
              opacity: value ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  buildGoBackButton(),
                  buildGoForwardButton(),
                  buildBrowseButton(),
                  buildReadingListButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
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
      debugPrint(message.message);
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
          if (y < MediaQuery.of(context).size.height * 0.5) {
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
          /// If we cut off at a lone surrogate, offset the index back by 1. The
          /// selection meant to select the index before
          RegExp loneSurrogate = RegExp(
            '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
          );
          if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
            index = index - 1;
          }
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

          int length = appModel.targetLanguage.getGuessHighlightLength(
            searchTerm: searchTerm,
          );

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
            length = appModel.targetLanguage.getFinalHighlightLength(
              result: currentResult,
              searchTerm: searchTerm,
            );

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

            mediaSource.setCurrentSentence(
              selection: appModel.targetLanguage.getSentenceFromParagraph(
                paragraph: text,
                index: index,
                startOffset: offsetIndex,
                endOffset: offsetIndex + length,
              ),
            );
          });
        } catch (e) {
          clearDictionaryResult();
        }

        break;
    }
  }

  Future<void> unselectWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String source = '''
if (!window.getSelection().isCollapsed) {
  window.getSelection().removeAllRanges();
}
''';
    await webViewController.evaluateJavascript(source: source);
  }

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
    if (value && value.nodeName === "#text") {
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
        if (node && node.nodeName === "#text") {
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
        } else if (node && node.firstChild && node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
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
      nodes = nodesInRange.filter((node) => node && node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
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
      nodes = nodesInRange.filter((node) => node && node.nodeName == "#text" && node.parentElement.nodeName !== "RT" && node.parentElement.nodeName !== "RP" && node.parentElement.parentElement.nodeName !== "RT" && node.parentElement.parentElement.nodeName !== "RP");
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
document.body.addEventListener('click', tapToSelect, true);
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
    
    if (value && value.nodeName === "#text") {
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

        if (node && node.nodeName === "#text") {
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
        } else if (node && node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
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
  if (isSpaceDelimited) {
    range.expand("word");
  } else {
    range.setEnd(lastNode, endOffset);
  }
  
  var selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
}
""";
}
