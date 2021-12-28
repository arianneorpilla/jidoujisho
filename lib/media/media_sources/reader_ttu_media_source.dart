import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:chisa/util/cached_memory_image.dart';
import 'package:chisa/util/media_source_action_button.dart';

class ReaderTtuMediaSource extends ReaderMediaSource {
  ReaderTtuMediaSource()
      : super(
          sourceName: "ッツ Ebook Reader",
          icon: Icons.chrome_reader_mode_outlined,
        );

  late InAppWebViewController controller;

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    return item.author;
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    if (item.extra["thumbnail"] == null || item.extra["thumbnail"].isEmpty) {
      return MemoryImage(kTransparentImage);
    }

    UriData data = Uri.parse(item.extra["thumbnail"]).data!;

    /// A cached version of [MemoryImage] so that the image does not reload
    /// on every revisit
    return CacheImageProvider(item.key, data.contentAsBytes());
  }

  @override
  bool get noSearchAction => true;

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    MediaHistoryItem item = MediaHistoryItem(
      key: "https://ttu-ebook.web.app/?min=",
      mediaTypePrefs: MediaType.reader.prefsDirectory(),
      sourceName: sourceName,
      currentProgress: 0,
      completeProgress: 0,
      extra: {},
    );

    ReaderLaunchParams params = ReaderLaunchParams.network(
      appModel: appModel,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );

    await launchMediaPage(context, params);
  }

  @override
  ReaderLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return ReaderLaunchParams.network(
      mediaHistoryItem: item,
      mediaSource: this,
      appModel: appModel,
      saveHistoryItem: true,
    );
  }

  Future<void> showClearAllDialog(
    BuildContext context,
  ) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        appModel.translate("clear_reader_history"),
      ),
      content: Text(
        appModel.translate("clear_reader_history_warning"),
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              appModel.translate("dialog_yes"),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () async {
              await mediaType.getMediaHistory(appModel).clearAllItems();
              await setClearCache(context, true);

              Navigator.pop(context);
            }),
        TextButton(
            child: Text(
              appModel.translate("dialog_no"),
            ),
            onPressed: () => Navigator.pop(context)),
      ],
    );

    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  @override
  List<Widget> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  ) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return [
      FloatingSearchBarAction.icon(
        onTap: () async {
          await showClearAllDialog(context);
        },
        icon: Icon(
          Icons.clear_all,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
        size: 20,
        showIfClosed: true,
        showIfOpened: true,
      ),
      MediaSourceActionButton(
        context: context,
        source: this,
        refreshCallback: refreshCallback,
        showIfClosed: true,
        showIfOpened: false,
        icon: Icons.launch,
        onPressed: () async {
          await onSearchBarTap(context);
          refreshCallback();
        },
      )
    ];
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) {
    return null;
  }

  @override
  Widget buildReaderArea(BuildContext context, ReaderPageState state) {
    return InAppWebView(
      contextMenu: getContextMenu(state),
      initialUrlRequest:
          URLRequest(url: Uri.parse(state.widget.params.mediaHistoryItem.key)),
      initialOptions: getInitialOptions(context),
      onWebViewCreated: (newController) {
        controller = newController;
      },
      onConsoleMessage: (controller, consoleMessage) async {
        print(consoleMessage);
        await onConsoleMessage(controller, consoleMessage, state);
      },
      onLoadStop: (controller, uri) async {
        await controller.evaluateJavascript(source: textClickJs);
        await onLoadStop(controller, uri, state);
      },
      onTitleChanged: (controller, title) async {
        await controller.evaluateJavascript(source: textClickJs);
        await onTitleChanged(controller, title, state);
      },
    );
  }

  Future<void> onConsoleMessage(InAppWebViewController controller,
      ConsoleMessage consoleMessage, ReaderPageState state) async {
    Map<String, dynamic> messageJson;
    try {
      messageJson = jsonDecode(consoleMessage.message);
    } catch (e) {
      return;
    }

    switch (messageJson["jidoujisho"]) {
      case "jidoujisho":
        int index = messageJson["offset"];
        String text = messageJson["text"];
        String? isCreator = messageJson["isCreator"];

        state.setScrollX(await controller.getScrollX() ?? -1);
        state.setScrollY(await controller.getScrollY() ?? -1);

        try {
          if (index != -1 && index >= 0) {
            String term = await state.appModel
                .getCurrentLanguage()
                .wordFromIndex(text, index);

            unselectWebViewTextSelection(controller);

            if (isCreator == "yes") {
              state.openCardCreator(term);
            } else {
              state.setSearchTerm(term);
            }
          }
        } catch (e) {
          state.setSearchTerm("");
          debugPrint("Out of range deselect");
        } finally {
          unselectWebViewTextSelection(controller);
        }

        break;
      case "jidoujisho-bookmark":
        String currentIndexText = (await controller.getUrl())
            .toString()
            .replaceAll("https://ttu-ebook.web.app/b/", "")
            .replaceAll("?min=", "");
        int currentIndex = int.parse(currentIndexText);

        String currentTitle = (await controller.getTitle()).toString();
        currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
        if (currentTitle == "ッツ Ebook Reader") {
          currentTitle = "";
        }

        state.setUrl("https://ttu-ebook.web.app/b/$currentIndex?min=");

        state.setTitle(currentTitle);

        state.setAuthor("");

        if (messageJson["bookmark"] != null) {
          String wordCountText = messageJson["bookmark"].trim();
          int currentProgress = int.tryParse(wordCountText.split("/")[0]) ?? 0;
          int completeProgress =
              int.tryParse(wordCountText.split("/")[1].trim().split(" ")[0]) ??
                  0;

          state.setCurrentProgress(currentProgress);
          state.setCompleteProgress(completeProgress);
        }

        await state.updateHistory();

        break;
      case "jidoujisho-metadata":
        if (messageJson["base64Image"].startsWith("data:image/")) {
          state.setThumbnail(messageJson["base64Image"]);
        }

        Future.delayed(const Duration(seconds: 2), () async {
          if (state.scrollX != -1) {
            await controller.scrollTo(
              x: state.scrollX,
              y: state.scrollY,
              animated: false,
            );
            state.setScrollX(-1);
            state.setScrollY(-1);
          }
        });

        break;
    }
  }

  Future<void> onLoadStop(InAppWebViewController controller, Uri? uri,
      ReaderPageState state) async {
    String currentTitle = await controller.getTitle() ?? "";

    currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
    if (currentTitle == "ッツ Ebook Reader") {
      currentTitle = "";
    }

    state.setTitle(currentTitle);
  }

  Future<void> onTitleChanged(InAppWebViewController controller, String? title,
      ReaderPageState state) async {
    String currentTitle = await controller.getTitle() ?? "";

    currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
    if (currentTitle == "ッツ Ebook Reader") {
      currentTitle = "";
    }

    state.setTitle(currentTitle);
  }

  Future<void> unselectWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String unselectJs = "window.getSelection().removeAllRanges();";
    await webViewController.evaluateJavascript(source: unselectJs);
  }

  String sanitizeWebViewTextSelection(String? text) {
    if (text == null) {
      return "";
    }

    text = text.replaceAll("\\n", "\n");
    text = text.trim();
    return text;
  }

  Future<String> getWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String? selectedText = await webViewController.getSelectedText();
    selectedText = sanitizeWebViewTextSelection(selectedText);
    return selectedText;
  }

  InAppWebViewGroupOptions getInitialOptions(BuildContext context) {
    bool clearCache = getClearCache(context);
    setClearCache(context, false);

    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        clearCache: clearCache,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        verticalScrollbarThumbColor: Colors.transparent,
        verticalScrollbarTrackColor: Colors.transparent,
        horizontalScrollbarThumbColor: Colors.transparent,
        horizontalScrollbarTrackColor: Colors.transparent,
        scrollbarFadingEnabled: false,
      ),
    );
  }

  ContextMenu getContextMenu(ReaderPageState state) {
    AppModel appModel = Provider.of<AppModel>(state.context, listen: false);

    if (getHorizontalHack(state.context)) {
      return ContextMenu(
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
        menuItems: [
          ContextMenuItem(
            androidId: 3,
            iosId: "3",
            title: "➡️",
            action: () async {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);

              state.setScrollX(await controller.getScrollX() ?? -1);

              String searchTerm = await getWebViewTextSelection(controller);
              state.setSearchTerm("");
              unselectWebViewTextSelection(controller);
              await state.openCardCreator(searchTerm);

              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
              ]);
            },
          ),
          ContextMenuItem(
            androidId: 2,
            iosId: "2",
            title: "📚",
            action: () async {
              String searchTerm = await getWebViewTextSelection(controller);

              state.setScrollX(await controller.getScrollX() ?? -1);
              unselectWebViewTextSelection(controller);
              await appModel.showDictionaryMenu(
                state.context,
                horizontalHack: true,
                themeData: state.themeData,
                onDictionaryChange: () {
                  state.refreshDictionaryWidget();
                },
              );
            },
          ),
          ContextMenuItem(
            androidId: 1,
            iosId: "1",
            title: "🔎",
            action: () async {
              String searchTerm = await getWebViewTextSelection(controller);

              state.setScrollX(await controller.getScrollX() ?? -1);
              state.setSearchTerm(searchTerm);
              unselectWebViewTextSelection(controller);
            },
          ),
        ],
        onCreateContextMenu: (result) {
          state.setSearchTerm("");
        },
      );
    } else {
      return ContextMenu(
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
        menuItems: [
          ContextMenuItem(
            androidId: 1,
            iosId: "1",
            title: appModel.translate("search"),
            action: () async {
              String searchTerm = await getWebViewTextSelection(controller);

              state.setScrollX(await controller.getScrollX() ?? -1);
              state.setSearchTerm(searchTerm);
              unselectWebViewTextSelection(controller);
            },
          ),
          ContextMenuItem(
            androidId: 2,
            iosId: "2",
            title: appModel.translate("dictionaries"),
            action: () async {
              String searchTerm = await getWebViewTextSelection(controller);

              state.setScrollX(await controller.getScrollX() ?? -1);
              unselectWebViewTextSelection(controller);
              await appModel.showDictionaryMenu(
                state.context,
                themeData: state.themeData,
                onDictionaryChange: () {
                  state.setSearchTerm(searchTerm);
                },
              );
            },
          ),
          ContextMenuItem(
            androidId: 3,
            iosId: "3",
            title: appModel.translate("creator"),
            action: () async {
              state.setScrollX(await controller.getScrollX() ?? -1);
              String searchTerm = await getWebViewTextSelection(controller);
              state.setSearchTerm(searchTerm);
              unselectWebViewTextSelection(controller);
              state.openCardCreator(searchTerm);
            },
          ),
        ],
        onCreateContextMenu: (result) {
          state.setSearchTerm("");
        },
      );
    }
  }

  String textClickJs = """
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
				"offset": -1,
				"text": getSelectionText(),
				"jidoujisho": "jidoujisho",
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
				"offset": offset,
				"text": text,
				"jidoujisho": "jidoujisho"
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
				"jidoujisho": "jidoujisho-metadata"
			})));
}

function removeElementsByClass(className){
    var elements = document.getElementsByClassName(className);
    while(elements.length > 0){
        elements[0].parentNode.removeChild(elements[0]);
    }
}

MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

var observer = new MutationObserver(function(mutations, observer) {
    removeElementsByClass("rounded-full");
    var input = document.body.getElementsByTagName("input");
    if (input.length == 2) {
      input[1].parentElement.remove();
    }

    if (document.body.getElementsByClassName('fa-bookmark').length != 0) {
       document.body.getElementsByClassName("flex items-center text-xl xl:text-lg px-4 xl:px-3")[0].remove();
      document.body.getElementsByClassName("fa-expand")[0].parentElement.remove();
    }

    var reader = document.getElementsByTagName('app-book-reader');
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

document.querySelector('body').addEventListener('click', function(e) {
  if (e.target.classList.contains('fa-bookmark') || e.target.firstChild.classList.contains('fa-bookmark')) {
    var info = document.getElementsByClassName('bottom-2')[0];
    console.log(JSON.stringify({
              "bookmark": info.textContent,
              "jidoujisho": "jidoujisho-bookmark"
            }));
  }
}, true);
""";

  bool getClearCache(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    return appModel.sharedPreferences
            .getBool("$getIdentifier()://clearCache") ??
        false;
  }

  Future<void> setClearCache(BuildContext context, bool clearCache) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    await appModel.sharedPreferences
        .setBool("$getIdentifier()://clearCache", clearCache);
  }
}
