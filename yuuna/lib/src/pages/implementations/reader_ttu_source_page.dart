import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/src/pages/base_source_page.dart';
import 'package:yuuna/utils.dart';

/// The media page used for the [ReaderTtuSource].
class ReaderTtuSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const ReaderTtuSourcePage({
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderTtuSourcePageState();
}

class _ReaderTtuSourcePageState
    extends BaseSourcePageState<ReaderTtuSourcePage> {
  /// The media source pertaining to this page.
  ReaderTtuSource get mediaSource => ReaderTtuSource.instance;

  DateTime? lastMessageTime;
  Orientation? lastOrientation;

  Duration get consoleMessageDebounce => const Duration(milliseconds: 50);

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != lastOrientation) {
      clearDictionaryResult();
      lastOrientation = orientation;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              buildBody(),
              buildDictionary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    AsyncValue<LocalAssetsServer> tweets = ref.watch(ttuProvider);

    return tweets.when(
      data: buildReaderArea,
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(ttuProvider);
        },
      ),
    );
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

  Widget buildReaderArea(LocalAssetsServer server) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: getInitialUrl(server: server)),
      contextMenu: ContextMenu(
        options: ContextMenuOptions(
          hideDefaultSystemContextMenuItems: true,
        ),
      ),
      onConsoleMessage: onConsoleMessage,
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      onLoadStop: (controller, uri) async {
        await controller.evaluateJavascript(source: javascriptToExecute);
      },
      onTitleChanged: (controller, title) async {
        await controller.evaluateJavascript(source: javascriptToExecute);
      },
    );
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

    Map<String, dynamic> messageJson;
    try {
      messageJson = jsonDecode(message.message);
    } catch (e) {
      debugPrint(prettyJson(message.toJson()));
      return;
    }

    switch (messageJson['jidoujisho-message-type']) {
      case 'lookup':
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

        if (text.isEmpty || index == text.length) {
          clearDictionaryResult();
          mediaSource.clearCurrentSentence();
        } else {
          try {
            String searchTerm = text.substring(index);

            searchDictionaryResult(
              searchTerm: searchTerm,
              position: position,
            );
            String sentence = appModel.targetLanguage.getSentenceFromParagraph(
              paragraph: text,
              index: index,
            );
            mediaSource.setCurrentSentence(sentence);
          } catch (e) {
            clearDictionaryResult();
          } finally {
            unselectWebViewTextSelection(controller);
          }
        }

        break;
    }
  }

  Future<void> unselectWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String source = 'window.getSelection().removeAllRanges();';
    await webViewController.evaluateJavascript(source: source);
  }

  Uri getInitialUrl({required LocalAssetsServer server}) {
    String address = server.address.address;
    int port = server.boundPort!;

    return Uri.parse('http://$address:$port');
  }

  InAppWebViewGroupOptions getInitialOptions() {
    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        disableContextMenu: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        verticalScrollbarThumbColor: Colors.transparent,
        verticalScrollbarTrackColor: Colors.transparent,
        horizontalScrollbarThumbColor: Colors.transparent,
        horizontalScrollbarTrackColor: Colors.transparent,
        scrollbarFadingEnabled: false,
      ),
    );
  }

  /// This is executed upon page load and change.
  String javascriptToExecute = """
/*jshint esversion: 6 */
var getImageBlob = function(url) {
	return new Promise(async resolve => {
		let response = await fetch(url);
		let blob = response.blob();
		resolve(blob);
	});
};
var blobToBase64 = function(blob) {
	return new Promise(resolve => {
		let reader = new FileReader();
		reader.onload = function() {
			let dataUrl = reader.result;
			resolve(dataUrl);
		};
		reader.readAsDataURL(blob);
	});
}
var getBase64Image = async function(url) {
	let blob = await getImageBlob(url);
	let base64 = await blobToBase64(blob);
	return base64;
}
var touchmoved;
var touchevent;
var reader = document.getElementsByTagName('app-book-reader');

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
  } else {
    var result = document.caretRangeFromPoint(e.clientX, e.clientY);
    var selectedElement = result.startContainer;
    var paragraph = result.startContainer;
    while (paragraph && paragraph.nodeName !== 'P') {
      paragraph = paragraph.parentNode;
    }
    if (paragraph == null) {
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
    
		console.log(JSON.stringify({
				"index": index,
				"text": text,
				"jidoujisho-message-type": "lookup",
        "x": e.clientX,
        "y": e.clientY,
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

if (reader.length != 0) {
  reader[0].addEventListener('click', tapToSelect);
}

var firstImage = document.getElementsByTagName("image")[0];
var firstImg = document.getElementsByTagName("img")[0];
var input = document.body.getElementsByTagName("input");

var blob;
if (firstImage != null) {
  blob = firstImage.attributes.href.textContent;
} else if (firstImg != null) {
  blob = firstImg.src;
} else {
  blob = "";
}
if (blob != null) {
  var info = document.getElementsByClassName('bottom-2')[0];
  getBase64Image(blob).then(base64Image => console.log(JSON.stringify({
				"base64Image": base64Image,
        "bookmark": info.textContent,
				"jidoujisho-message-type": "metadata"
			})));
}

MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

var observer = new MutationObserver(function(mutations, observer) {
    var reader = document.getElementsByClassName('book-content')
    if (reader.length != 0) {
      reader[0].addEventListener('click', tapToSelect);
    }
    
});

observer.observe(document, {
  subtree: true,
  attributes: true
});

if (input.length == 2) {
  input[1].parentElement.remove();
}
if (document.body.getElementsByClassName('fa-bookmark').length != 0) {
  document.body.getElementsByClassName("flex items-center text-xl xl:text-lg px-4 xl:px-3")[0].remove();
  document.body.getElementsByClassName("fa-expand")[0].parentElement.remove();
}

var reader = document.getElementsByClassName('book-content')
if (reader.length != 0) {
  document.querySelector('body').addEventListener('click', function(e) {
  var reader = document.getElementsByClassName('book-content')
    

  var element = document.getElementsByClassName('svelte-fa')[0];
  if (e.target === element && element.contains(e.target)) {
    var info = document.getElementsByClassName('bottom-2')[0];
    console.log(JSON.stringify({
              "bookmark": info.textContent,
              "jidoujisho-message-type": "bookmark"
            }));
  }
}, true);
}
""";
}
