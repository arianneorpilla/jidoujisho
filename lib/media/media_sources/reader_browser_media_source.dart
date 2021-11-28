import 'dart:async';
import 'dart:typed_data';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/util/cached_memory_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:transparent_image/transparent_image.dart';

class ReaderBrowserSource extends ReaderMediaSource {
  ReaderBrowserSource()
      : super(
          sourceName: "Browser",
          icon: Icons.public,
        );

  late InAppWebViewController controller;
  late InAppLocalhostServer server;

  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    throw UnsupportedError("Not supported for browser");
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    if (item.extra["thumbnail"] == null) {
      return MemoryImage(kTransparentImage);
    }

    Uint8List thumbnail =
        Uint8List.fromList(List<int>.from(item.extra["thumbnail"]));

    /// A cached version of [MemoryImage] so that the image does not reload
    /// on every revisit
    return CacheImageProvider(item.key, thumbnail);
  }

  @override
  ReaderLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return ReaderLaunchParams.network(
      mediaHistoryItem: item,
      mediaSource: this,
      appModel: appModel,
      // Should probably be false, linking to context from outside the app
      // could be a serious security issue.
      saveHistoryItem: false,
    );
  }

  @override
  int get getSearchDebounceDelay => 0;

  @override
  List<Widget> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  ) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return [
      if (appModel.getSearchHistory(historyType: getIdentifier()).isNotEmpty)
        MediaSourceActionButton(
          context: context,
          source: this,
          refreshCallback: refreshCallback,
          showIfClosed: false,
          showIfOpened: true,
          icon: Icons.delete_forever,
          onPressed: () async {
            appModel.setSearchHistory([], historyType: getIdentifier());
            refreshCallback();
          },
        )
    ];
  }

  @override
  bool get isDirectTextEntry => true;

  @override
  Future<void> onDirectTextEntrySubmit(
    BuildContext context,
    String query,
  ) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    await launchMediaPage(
      context,
      ReaderLaunchParams.network(
        appModel: appModel,
        mediaSource: this,
        mediaHistoryItem: MediaHistoryItem(
          key: query,
          title: "",
          alias: "",
          extra: {},
          sourceName: sourceName,
          currentProgress: 0,
          completeProgress: 0,
          mediaTypePrefs: mediaType.prefsDirectory(),
        ),
        // Should probably be false, linking to context from outside the app
        // could be a serious security issue.
        saveHistoryItem: false,
      ),
    );
  }

  ValueNotifier<bool> canGoBack = ValueNotifier<bool>(false);
  ValueNotifier<bool> justBookmarked = ValueNotifier<bool>(false);
  ValueNotifier<bool> justNavigated = ValueNotifier<bool>(false);
  ValueNotifier<bool> justBack = ValueNotifier<bool>(false);
  ValueNotifier<bool> justForward = ValueNotifier<bool>(false);

  @override
  Widget buildReaderArea(BuildContext context, ReaderPageState state) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return Stack(
      alignment: Alignment.topRight,
      children: [
        InAppWebView(
          contextMenu: getContextMenu(state),
          initialUrlRequest: URLRequest(
              url: Uri.parse(state.widget.params.mediaHistoryItem.key)),
          initialOptions: getInitialOptions(),
          onWebViewCreated: (newController) {
            controller = newController;
          },
          onLoadStop: (controller, uri) async {
            if (uri.toString().trim().isNotEmpty) {
              appModel.addToSearchHistory(uri.toString(),
                  historyType: getIdentifier());
            }
            canGoBack.value = await controller.canGoBack();
          },
          onTitleChanged: (controller, title) async {
            canGoBack.value = await controller.canGoBack();
            Uri? uri = await controller.getUrl();
            if (uri.toString().trim().isNotEmpty) {
              appModel.addToSearchHistory(uri.toString(),
                  historyType: getIdentifier());
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!appModel.getIncognitoMode())
                ValueListenableBuilder<bool>(
                    valueListenable: justBookmarked,
                    builder: (_, value, __) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (value)
                                    ? Colors.red.withOpacity(0.5)
                                    : state.dictionaryColor.withOpacity(0.7)),
                            child: Icon(
                              Icons.bookmark,
                              color: state.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              size: 20,
                            ),
                          ),
                          onTap: () async {
                            justBookmarked.value = true;
                            String url = (await controller.getUrl()).toString();
                            String title = await controller.getTitle() ?? "";
                            Uint8List? thumbnail =
                                await controller.takeScreenshot();

                            MediaHistoryItem item = MediaHistoryItem(
                              key: url,
                              title: title,
                              extra: (thumbnail != null)
                                  ? {"thumbnail": thumbnail}
                                  : {},
                              sourceName: sourceName,
                              currentProgress: 0,
                              completeProgress: 0,
                              mediaTypePrefs: mediaType.prefsDirectory(),
                            );
                            await mediaType
                                .getMediaHistory(appModel)
                                .addItem(item);

                            justBookmarked.value = false;
                          },
                        ),
                      );
                    }),
              ValueListenableBuilder<bool>(
                  valueListenable: justNavigated,
                  builder: (_, value, __) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (value)
                                  ? Colors.red.withOpacity(0.5)
                                  : state.dictionaryColor.withOpacity(0.7)),
                          child: Icon(
                            Icons.explore,
                            color:
                                state.isDarkMode ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          state.setSearchTerm("");

                          justNavigated.value = true;
                          String url = (await controller.getUrl()).toString();
                          String newUrl = url;
                          TextEditingController editingController =
                              TextEditingController(text: url);

                          await showDialog(
                            context: context,
                            builder: (context) {
                              editingController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      editingController.value.text.length);
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      editingController.value.text.length);
                              return AlertDialog(
                                contentPadding: const EdgeInsets.only(
                                    top: 20, left: 20, right: 20, bottom: 20),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                content: TextFormField(
                                  autofocus: true,
                                  onFieldSubmitted: (value) async {
                                    Navigator.pop(context);
                                    await controller.loadUrl(
                                        urlRequest:
                                            URLRequest(url: Uri.parse(newUrl)));
                                  },
                                  controller: editingController,
                                  maxLines: 1,
                                  onTap: () => editingController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: editingController
                                              .value.text.length),
                                  keyboardType: TextInputType.url,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .unselectedWidgetColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).focusColor),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.subdirectory_arrow_left,
                                        color: state.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await controller.loadUrl(
                                            urlRequest: URLRequest(
                                                url: Uri.parse(newUrl)));
                                      },
                                    ),
                                    hintText:
                                        appModel.translate("enter_a_link"),
                                  ),
                                  onChanged: (value) {
                                    newUrl = value;
                                  },
                                ),
                              );
                            },
                          );

                          justNavigated.value = false;
                        },
                      ),
                    );
                  }),
              ValueListenableBuilder<bool>(
                  valueListenable: justBack,
                  builder: (_, value, __) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (value)
                                  ? Colors.red.withOpacity(0.5)
                                  : state.dictionaryColor.withOpacity(0.7)),
                          child: Icon(
                            Icons.arrow_back,
                            color:
                                state.isDarkMode ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          justBack.value = true;
                          await Future.delayed(
                              const Duration(milliseconds: 200), () {});
                          await controller.goBack();
                          justBack.value = false;
                        },
                      ),
                    );
                  }),
              ValueListenableBuilder<bool>(
                  valueListenable: justForward,
                  builder: (_, value, __) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (value)
                                  ? Colors.red.withOpacity(0.5)
                                  : state.dictionaryColor.withOpacity(0.7)),
                          child: Icon(
                            Icons.arrow_forward,
                            color:
                                state.isDarkMode ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          justForward.value = true;
                          await Future.delayed(
                              const Duration(milliseconds: 200), () {});
                          await controller.goForward();

                          justForward.value = false;
                        },
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
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
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
    );
  }

  ContextMenu getContextMenu(ReaderPageState state) {
    AppModel appModel = Provider.of<AppModel>(state.context, listen: false);

    return ContextMenu(
      options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
      menuItems: [
        ContextMenuItem(
          androidId: 1,
          iosId: "1",
          title: appModel.translate("search"),
          action: () async {
            String searchTerm = await getWebViewTextSelection(controller);

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

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems(
      {required BuildContext context,
      required String searchTerm,
      required int pageKey}) {
    return null;
  }
}
