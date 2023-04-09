import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:spaces/spaces.dart';
import 'package:wakelock/wakelock.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page for browsing a catalog until a volume is opened.
class MokuroCatalogBrowsePage extends BaseSourcePage {
  /// Create an instance of this page.
  const MokuroCatalogBrowsePage({
    required super.item,
    required this.catalog,
    super.key,
  });

  /// The catalog pertaining to this page.
  final MokuroCatalog? catalog;

  @override
  BaseSourcePageState createState() => _MokuroCatalogBrowsePageState();
}

class _MokuroCatalogBrowsePageState
    extends BaseSourcePageState<MokuroCatalogBrowsePage>
    with WidgetsBindingObserver {
  late final ValueNotifier<String> _titleNotifier;
  late final ValueNotifier<String> _urlNotifier;
  final ValueNotifier<bool> _backAvailableNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _isMokuroPageFoundNotifier;

  bool _controllerInitialised = false;

  late InAppWebViewController _controller;
  MediaItem? _mediaItem;

  ReaderMokuroSource get mediaSource => ReaderMokuroSource.instance;

  @override
  void initState() {
    super.initState();

    _titleNotifier =
        ValueNotifier<String>(widget.catalog?.name ?? widget.item?.title ?? '');
    _urlNotifier = ValueNotifier<String>(
        widget.catalog?.url ?? widget.item?.mediaIdentifier ?? '');
    _isMokuroPageFoundNotifier = ValueNotifier<bool>(widget.item != null);
    if (widget.item != null) {
      _mediaItem = widget.item;
    }

    _isMokuroPageFoundNotifier.addListener(() {
      setState(() {});
    });

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

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      title: buildTitle(),
      actions: buildActions(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  List<Widget> buildActions() {
    return [
      buildGoBackButton(),
      const Space.small(),
      buildCreateCatalogButton(),
      const Space.extraSmall(),
    ];
  }

  Widget buildGoBackButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _backAvailableNotifier,
      builder: (context, value, child) {
        if (!value) {
          return const SizedBox.shrink();
        } else {
          return JidoujishoIconButton(
            tooltip: t.create_catalog,
            icon: Icons.keyboard_return,
            onTap: _controller.goBack,
          );
        }
      },
    );
  }

  Widget buildCreateCatalogButton() {
    return JidoujishoIconButton(
      tooltip: t.create_catalog,
      icon: Icons.bookmark_add,
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => MokuroCatalogEditDialogPage(
            catalog: MokuroCatalog(
              name: _titleNotifier.value,
              url: _urlNotifier.value,
              order: appModel.nextCatalogOrder,
            ),
          ),
        );
      },
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _titleNotifier,
                builder: (context, value, child) {
                  return JidoujishoMarquee(
                    text: value,
                    style: TextStyle(fontSize: textTheme.titleMedium?.fontSize),
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _urlNotifier,
                builder: (context, value, child) {
                  return JidoujishoMarquee(
                    text: value,
                    style: TextStyle(fontSize: textTheme.labelSmall?.fontSize),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          disableContextMenu: true,
        ),
        android: AndroidInAppWebViewOptions(
          initialScale: MediaQuery.of(context).size.width ~/ 1.5,
        ),
      ),
      initialUrlRequest: URLRequest(
          url: Uri.parse(widget.catalog?.url ?? widget.item!.mediaIdentifier)),
      onConsoleMessage: onConsoleMessage,
      onWebViewCreated: (controller) {
        _controller = controller;
        _controllerInitialised = true;
      },
      onLoadStop: (controller, uri) async {
        String title = await controller.getTitle() ?? '';
        String url = (await controller.getUrl()).toString();
        bool canGoBack = await controller.canGoBack();

        _titleNotifier.value = title;
        _urlNotifier.value = url;
        _backAvailableNotifier.value = canGoBack;

        if (!_isMokuroPageFoundNotifier.value) {
          MediaItem? item =
              await ReaderMokuroSource.instance.generateMediaItemFromWebView(
            appModel: appModel,
            controller: controller,
          );
          if (item != null) {
            await Wakelock.enable();
            await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.immersiveSticky);
            appModel.setCurrentMediaItem(item);

            _isMokuroPageFoundNotifier.value = true;
            _mediaItem = item;
            appModel.addMediaItem(item);
          }
        }

        if (_mediaItem != null) {
          await controller.evaluateJavascript(source: javascriptToExecute);
          await updateOrientation();
          Future.delayed(const Duration(milliseconds: 300), () {
            controller.evaluateJavascript(source: 'zoomFitToScreen();');
          });

          Future.delayed(const Duration(seconds: 1), _focusNode.requestFocus);
        }
      },
    );
  }

  DateTime? lastMessageTime;
  Orientation? lastOrientation;

  Duration get consoleMessageDebounce => const Duration(milliseconds: 50);

  final FocusNode _focusNode = FocusNode();
  bool _isRecursiveSearching = false;

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
        updateOrientation();
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
          appBar: _isMokuroPageFoundNotifier.value ? null : buildAppBar(),
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
                Padding(
                  padding: Spacing.of(context).insets.onlyTop.extraBig * 1.5,
                  child: buildDictionary(),
                ),
              ],
            ),
          ),
        ),
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
    await _controller.evaluateJavascript(
      source:
          'selectTextForTextLength($cursorX, $cursorY, $offsetIndex, $length, $whitespaceOffset, $isSpaceDelimited);',
    );
  }

  void saveMediaItem() async {
    String dataJson = await _controller.evaluateJavascript(
        source: 'localStorage.getItem(storageKey);');
    Map<String, dynamic> data = jsonDecode(dataJson);

    int page2Idx = int.tryParse(data['page2_idx'].toString()) ?? -1;
    int pageIdx = int.tryParse(data['page_idx'].toString()) ?? -1;

    if (page2Idx != -1) {
      _mediaItem!.position = page2Idx;
      appModel.updateMediaItem(_mediaItem!);
      return;
    }
    if (pageIdx != -1) {
      _mediaItem!.position = pageIdx;
      appModel.updateMediaItem(_mediaItem!);
    }
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
      case 'save':
        saveMediaItem();
        break;
      case 'lookup':
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

        int index = messageJson['index'];
        String text = messageJson['text'];
        int x = messageJson['x'];
        int y = messageJson['y'];
        String sentence = messageJson['sentence'];
        String? imageUrl = messageJson['imageUrl'];
        String nextLine = messageJson['nextLine'];

        late JidoujishoPopupPosition position;
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          if (y < MediaQuery.of(context).size.height * 0.6) {
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
            text: text.trimRight() + nextLine.trim(),
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

          String sanitizedSentence =
              sentence.split('\n').map((e) => e.trim()).join();

          mediaSource.setCurrentSentence(sanitizedSentence);
          mediaSource.setExtraData(imageUrl);
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

  Future<void> updateOrientation() async {
    await _controller.evaluateJavascript(source: '''
state.singlePageView = ${MediaQuery.of(context).orientation == Orientation.portrait}
saveState();
updatePage(state.page_idx);
''');
  }

  /// This is executed upon page load and change.
  /// More accurate readability courtesy of
  /// https://github.com/birchill/10ten-ja-reader/blob/fbbbde5c429f1467a7b5a938e9d67597d7bd5ffa/src/content/get-text.ts#L314
  String javascriptToExecute = """
/*jshint esversion: 6 */
// yikes
setInterval(saveHandler, 6000);
function saveHandler() {
 console.log(JSON.stringify({
	    "jidoujisho-message-type": "save",
 }));
}

function tapToSelect(e) {
  if (e.target.tagName != 'P') {
    console.log(JSON.stringify({
				"index": -1,
				"text": '',
				"jidoujisho-message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
        "sentence": "",
        "nextLine": "",
			}));
    return;
  }

  if (getSelectionText()) {
    console.log(JSON.stringify({
				"index": -1,
				"text": getSelectionText(),
				"jidoujisho-message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
        "sentence": "",
        "nextLine": "",
			}));
    return;
  }

  var lastTextBox = e.target.closest('.textBox');
  
  var pageContainer = e.target.closest('.pageContainer');
  var backgroundStyle = pageContainer.style.backgroundImage;
  var imageUrl = backgroundStyle.substring(5, backgroundStyle.length - 2);

  var sentence = "";
  var result = document.caretRangeFromPoint(e.clientX, e.clientY);
  
  if (lastTextBox != null) {
    sentence = lastTextBox.textContent;
  } else {
    console.log(JSON.stringify({
				"index": -1,
				"text": getSelectionText(),
				"jidoujisho-message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
        "sentence": "",
        "nextLine": "",
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

  var nextLine = "";
  var nextElementSibling = e.target.nextElementSibling;

  if (nextElementSibling) {
    nextLine = nextElementSibling.textContent;
  }
  
  var character = text[index];
  if (character) {
    console.log(JSON.stringify({
      "index": index,
      "text": text,
      "jidoujisho-message-type": "lookup",
      "x": e.clientX,
      "y": e.clientY,
      "sentence": sentence,
      "imageUrl": imageUrl,
      "nextLine": nextLine,
    }));
    console.log(character);
  } else {
    console.log(JSON.stringify({
      "index": -1,
      "text": getSelectionText(),
      "jidoujisho-message-type": "lookup",
      "x": e.clientX,
      "y": e.clientY,
      "sentence": sentence,
      "imageUrl": imageUrl,
      "nextLine": nextLine,
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
    if (${mediaSource.volumePageTurningInverted}) {
      prevPage();
    } else {
      nextPage();
    }
    ''';

  String get rightArrowSimulateJs => '''
    if (${mediaSource.volumePageTurningInverted}) {
      nextPage();
    } else {
      prevPage();
    }
    ''';
}
