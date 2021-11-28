import 'dart:async';
import 'dart:convert';

import 'package:chisa/util/cached_memory_image.dart';
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
    if (item.extra["thumbnail"] == null) {
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

  @override
  List<Widget> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  ) {
    ValueNotifier<bool> horizontalHackNotifier =
        ValueNotifier<bool>(getHorizontalHack(context));
    return [
      FloatingSearchBarAction(
        showIfClosed: true,
        showIfOpened: true,
        child: ValueListenableBuilder<bool>(
          valueListenable: horizontalHackNotifier,
          builder: (context, bool isHorizontal, child) {
            return CircularButton(
              icon: Icon(
                (isHorizontal)
                    ? Icons.text_rotation_none
                    : Icons.text_rotate_vertical,
                size: 20,
                color: (Provider.of<AppModel>(context, listen: false)
                        .getIsDarkMode()
                    ? Colors.white
                    : Colors.black),
              ),
              onPressed: () async {
                await toggleHorizontalHack(context);
                horizontalHackNotifier.value = getHorizontalHack(context);
              },
            );
          },
        ),
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
      initialOptions: getInitialOptions(),
      onWebViewCreated: (newController) {
        controller = newController;
      },
      onConsoleMessage: (controller, consoleMessage) async {
        await onConsoleMessage(controller, consoleMessage, state);
      },
      onLoadStop: (controller, uri) async {
        await controller.evaluateJavascript(source: textClickJs);
        if (getHorizontalHack(context)) {
          await controller.evaluateJavascript(source: horizontalHackJs);
        }
        await onLoadStop(controller, uri, state);
      },
      onTitleChanged: (controller, title) async {
        await controller.evaluateJavascript(source: textClickJs);
        if (getHorizontalHack(context)) {
          await controller.evaluateJavascript(source: horizontalHackJs);
        }
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

        try {
          if (index != -1 && index >= 0) {
            String term = await state.appModel
                .getCurrentLanguage()
                .wordFromIndex(text, index);

            unselectWebViewTextSelection(controller);

            if (isCreator == "yes") {
              state.openCardCreator(term);
            } else {
              Clipboard.setData(ClipboardData(text: term));
            }
          }
        } catch (e) {
          Clipboard.setData(const ClipboardData(text: ""));
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
          String wordCountText = messageJson["bookmark"];
          int currentProgress = int.tryParse(wordCountText.split("/")[0]) ?? 0;
          int completeProgress =
              int.tryParse(wordCountText.split("/")[1].split(" ")[0]) ?? 0;

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
            await controller.scrollTo(x: state.scrollX, y: 0, animated: false);
            state.setScrollX(-1);
            state.setScrollY(-1);
          }
        });

        break;
      case "jidoujisho-theme":
        String themeName = messageJson["themeName"];
        changeTheme(themeName, state);
        break;
    }
  }

  Future<void> onLoadStop(InAppWebViewController controller, Uri? uri,
      ReaderPageState state) async {
    String themeName = await controller.evaluateJavascript(
        source: "document.documentElement.className");
    changeTheme(themeName, state);

    String currentTitle = await controller.getTitle() ?? "";

    currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
    if (currentTitle == "ッツ Ebook Reader") {
      currentTitle = "";
    }

    state.setTitle(currentTitle);
  }

  Future<void> onTitleChanged(InAppWebViewController controller, String? title,
      ReaderPageState state) async {
    String themeName = await controller.evaluateJavascript(
        source: "document.documentElement.className");
    changeTheme(themeName, state);

    String currentTitle = await controller.getTitle() ?? "";

    currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
    if (currentTitle == "ッツ Ebook Reader") {
      currentTitle = "";
    }

    state.setTitle(currentTitle);
  }

  void changeTheme(String themeName, ReaderPageState state) {
    switch (themeName) {
      case "light-theme":
      case "ecru-theme":
      case "blue-theme":
        state.setIsDarkMode(false);
        break;
      case "grey-theme":
      case "black-theme":
      case "dark-theme":
        state.setIsDarkMode(true);
        break;
    }
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

  InAppWebViewGroupOptions getInitialOptions() {
    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
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

              String searchTerm = await getWebViewTextSelection(controller);
              Clipboard.setData(ClipboardData(text: searchTerm));
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
                  Clipboard.setData(
                    ClipboardData(text: searchTerm),
                  );
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
              Clipboard.setData(ClipboardData(text: searchTerm));
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
              Clipboard.setData(ClipboardData(text: searchTerm));
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
                  Clipboard.setData(ClipboardData(text: searchTerm));
                },
              );
            },
          ),
          ContextMenuItem(
            androidId: 3,
            iosId: "3",
            title: appModel.translate("creator"),
            action: () async {
              String searchTerm = await getWebViewTextSelection(controller);
              Clipboard.setData(ClipboardData(text: searchTerm));
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
var reader = document.getElementsByTagName('app-reader')[0];
var bookmark = document.getElementsByClassName('fa-bookmark')[0].parentElement.parentElement;
var settings = document.getElementsByClassName('fa-cog')[0].parentElement.parentElement;
var info = document.getElementsByClassName('information-overlay bottom-overlay scroll-information')[0];
var firstImage = document.getElementsByTagName("image")[0];
var firstImg = document.getElementsByTagName("img")[0];
var blob;
if (firstImage != null) {
  blob = firstImage.attributes.href.textContent;
} else if (firstImg != null) {
  blob = firstImg.src;
} else {
  blob = "";
}
if (blob != null) {
  getBase64Image(blob).then(base64Image => console.log(JSON.stringify({
				"base64Image": base64Image,
        "bookmark": info.textContent,
				"jidoujisho": "jidoujisho-metadata"
			})));
}
bookmark.addEventListener('touchstart', function() {
  console.log(JSON.stringify({
				"bookmark": info.textContent,
				"jidoujisho": "jidoujisho-bookmark"
			}));
});
reader.addEventListener('touchend', function() {
	if (touchmoved !== true) {
		var touch = touchevent.touches[0];
		var result = document.caretRangeFromPoint(touch.clientX, touch.clientY);
		var selectedElement = result.startContainer;
    var paragraph = result.startContainer;
    while (paragraph && paragraph.nodeName !== 'P') {
      paragraph = paragraph.parentNode;
    }
    if (paragraph == null) {
      paragraph = result.startContainer.parentNode;
    }
    console.log(paragraph.nodeName);
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
});
reader.addEventListener('touchmove', () => {
	touchmoved = true;
	touchevent = null;
});
reader.addEventListener('touchstart', (e) => {
	touchmoved = false;
	touchevent = e;
});
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
reader.addEventListener('auxclick', (e) => {
  if (getSelectionText()) {
    console.log(JSON.stringify({
				"offset": -1,
				"text": getSelectionText(),
				"jidoujisho": "jidoujisho",
        "isCreator": "yes",
			}));
  }
});
reader.addEventListener('click', (e) => {
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
    console.log(paragraph.nodeName);
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
});

document.getElementsByClassName('custom-svg-icon')[0].remove();

var MutationObserver = window.MutationObserver;
var observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
   	console.log(JSON.stringify({
				"themeName": mutation.target.className,
				"jidoujisho": "jidoujisho-theme"
			}));
  });
});

var config = {attributes: true,  childList: false,  characterData: false};
observer.observe(document.documentElement, config);
""";

  String horizontalHackJs = """
var icons = document.getElementsByTagName('fa-icon');
for (var i = 0; i < icons.length; i++) {
    var icon = icons[i];
    icon.style.setProperty("-webkit-transform", "rotate(90deg)", null);
}

settings.addEventListener('touchstart', function() {
  console.log(JSON.stringify({
				"bookmark": info.textContent,
				"jidoujisho": "jidoujisho-bookmark"
			}));
});

document.body.style.setProperty('text-orientation', 'sideways', 'important');
""";

  @override
  bool getHorizontalHack(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    return appModel.sharedPreferences
            .getBool("$getIdentifier()://horizontalHack") ??
        false;
  }

  Future<void> toggleHorizontalHack(BuildContext context) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    await appModel.sharedPreferences.setBool(
        "$getIdentifier()://horizontalHack", !getHorizontalHack(context));
  }
}
