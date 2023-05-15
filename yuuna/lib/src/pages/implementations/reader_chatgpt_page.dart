import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gpt_tokenizer/flutter_gpt_tokenizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderChatgptSource] which allows the user to interact with the
/// ChatGPT service.
class ReaderChatgptPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderChatgptPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderChatgptPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderChatgptPageState extends BaseSourcePageState<ReaderChatgptPage> {
  ReaderChatgptSource get source => ReaderChatgptSource.instance;

  final ScrollController _scrollController =
      ReaderMediaType.instance.scrollController;
  final TextEditingController _controller = TextEditingController();

  Orientation? _lastOrientation;
  bool _isLoading = false;

  late OpenAI _openAI;

  final ValueNotifier<String> _progressNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != _lastOrientation) {
      clearDictionaryResult();
      _lastOrientation = orientation;
    }

    if (source.apiKey == null || source.apiKey!.trim().isEmpty) {
      return buildNoApiKey();
    } else {
      _openAI = OpenAI.instance.build(
        token: source.apiKey,
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 5),
        ),
        isLog: true,
      );

      return Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (appModel.messages.isEmpty)
                  buildEmpty()
                else
                  GestureDetector(
                    onTap: clearDictionaryResult,
                    child: buildMessageBuilder(),
                  ),
                Column(
                  children: [
                    const Space.extraBig(),
                    Expanded(
                      child: buildDictionary(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          buildTextField(),
          SizedBox(height: getBottomInsets() * 0.85)
        ],
      );
    }
  }

  Widget buildEmpty() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.chat_outlined,
        message: t.no_messages,
      ),
    );
  }

  double getBottomInsets() {
    if (MediaQuery.of(context).viewInsets.bottom >
        MediaQuery.of(context).viewPadding.bottom) {
      return MediaQuery.of(context).viewInsets.bottom -
          MediaQuery.of(context).viewPadding.bottom;
    }
    return 0;
  }

  Widget buildTextField() {
    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: TextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(300),
        ],
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        readOnly: _isLoading,
        decoration: InputDecoration(
          hintText: t.enter_message,
          suffixIcon: _isLoading
              ? SizedBox(
                  height: Spacing.of(context).spaces.extraBig,
                  width: Spacing.of(context).spaces.extraBig,
                  child: Padding(
                    padding: Spacing.of(context).insets.all.semiBig,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
                    ),
                  ),
                )
              : JidoujishoIconButton(
                  icon: Icons.send,
                  tooltip: t.send,
                  onTap: () => onSubmitted(_controller.text),
                ),
        ),
        onTap: () {
          clearDictionaryResult();
          Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
        },
        onSubmitted: onSubmitted,
      ),
    );
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.doWhile(() {
        if (_scrollController.position.extentBefore == 0) {
          return Future.value(false);
        }
        return _scrollController
            .animateTo(_scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear)
            .then((value) => true);
      });
    }
  }

  Future<List<Map<String, String>>> getMessages() async {
    List<MessageItem> messageItems =
        appModel.messages.sublist(max(0, appModel.messages.length - 20));

    while (messageItems.isNotEmpty &&
        4096 <
            await Tokenizer().count(
                jsonEncode(getMessagesFromList(messageItems)),
                modelName: 'gpt-3.5-turbo')) {
      messageItems.removeAt(0);
    }

    return getMessagesFromList(messageItems);
  }

  List<Map<String, String>> getMessagesFromList(List<MessageItem> items) {
    return items
        .map((item) => {
              'role': item.isBot ? 'assistant' : 'user',
              'content': item.message,
            })
        .toList();
  }

  final _buffer = StringBuffer();
  StreamSubscription? _streamSubscription;

  void onSubmitted(String input) async {
    String text = input.trim();
    if (text.isEmpty) {
      _controller.clear();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _controller.clear();
    _buffer.clear();
    _progressNotifier.value = '';

    late int userMessageId;

    setState(() {
      userMessageId = appModel.addMessage(
        MessageItem(
          message: text,
          isBot: false,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);

    int? responseIndex;

    final chatComplete = _openAI.onChatCompletionSSE(
      request: ChatCompleteText(
        model: ChatModel.chatGptTurbo0301Model,
        messages: await getMessages(),
        maxToken: 1500,
      ),
    );

    _streamSubscription = chatComplete.listen(
      (data) {
        if (responseIndex != data.choices.lastOrNull?.index) {
          responseIndex = data.choices.lastOrNull?.index;
          _buffer.clear();
        }

        _buffer.write(data.choices.lastOrNull?.message?.content);
        _progressNotifier.value = _buffer.toString();

        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 100), curve: Curves.linear);

        String memory = _buffer.toString().trim();
        Future.delayed(const Duration(seconds: 10), () {
          if (memory.isNotEmpty &&
              _buffer.toString().trim() == memory &&
              _isLoading) {
            appModel.removeMessage(userMessageId);
            _streamSubscription?.cancel();
            _streamSubscription = null;

            Fluttertoast.showToast(msg: t.error_chatgpt_response);

            setState(() {
              _isLoading = false;
            });

            _controller.text = input;
          }
        });
      },
      onError: (error, stack) {
        appModel.removeMessage(userMessageId);
        debugPrint('$error');
        debugPrint('$stack');

        Fluttertoast.showToast(msg: t.error_chatgpt_response);

        setState(() {
          _isLoading = false;
        });

        _controller.text = input;
      },
      onDone: addBotMessage,
    );
  }

  void addBotMessage() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    appModel.addMessage(
      MessageItem(
        message: _buffer.toString(),
        isBot: true,
      ),
    );

    setState(() {
      _isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
  }

  Widget buildNoApiKey() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.login,
        message: t.missing_api_key,
      ),
    );
  }

  Widget buildMessageBuilder() {
    List<MessageItem> messages = appModel.messages.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 60),
      reverse: true,
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: _scrollController,
      itemCount: _isLoading ? messages.length + 1 : messages.length,
      itemBuilder: (context, index) {
        if (index == 0 && _isLoading) {
          return ValueListenableBuilder(
            valueListenable: _progressNotifier,
            builder: (context, value, child) {
              return buildMessage(
                isBot: true,
                isLoading: true,
                text: _progressNotifier.value,
              );
            },
          );
        }

        MessageItem item = messages[_isLoading ? index - 1 : index];

        return buildMessage(
          text: item.message,
          isBot: item.isBot,
          isLoading: false,
        );
      },
    );
  }

  JidoujishoSelectableTextController? _lastTappedController;

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _lastTappedController?.clearSelection();
    source.clearCurrentSentence();
  }

  List<InlineSpan> getTextSpans({
    required JidoujishoSelectableTextController controller,
    required String text,
  }) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: const TextStyle(fontSize: 18),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) {
              onTapDown(
                character: character,
                text: text,
                index: index,
                controller: controller,
                details: details,
              );
            },
        ),
      );
    });

    return spans;
  }

  void onTapDown({
    required String text,
    required String character,
    required int index,
    required TapDownDetails details,
    required JidoujishoSelectableTextController controller,
  }) {
    _lastTappedController?.clearSelection();
    _lastTappedController = controller;

    bool wholeWordCondition =
        controller.selection.start <= index && controller.selection.end > index;

    if (wholeWordCondition && currentResult != null) {
      clearDictionaryResult();
      return;
    }

    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;

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

    String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
      text: text,
      index: index,
    );

    if (character.trim().isNotEmpty) {
      /// If we cut off at a lone surrogate, offset the index back by 1. The
      /// selection meant to select the index before
      RegExp loneSurrogate = RegExp(
        '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
      );
      if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
        index = index - 1;
      }
      bool isSpaceDelimited = appModel.targetLanguage.isSpaceDelimited;
      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex =
          appModel.targetLanguage.getStartingIndex(text: text, index: index) +
              whitespaceOffset;
      int length = appModel.targetLanguage
          .textToWords(searchTerm)
          .firstWhere((e) => e.trim().isNotEmpty)
          .length;

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        int length = isSpaceDelimited
            ? appModel.targetLanguage
                .textToWords(searchTerm)
                .firstWhere((e) => e.trim().isNotEmpty)
                .length
            : max(1, currentResult?.bestLength ?? 0);

        controller.setSelection(offsetIndex, offsetIndex + length);

        JidoujishoTextSelection selection =
            appModel.targetLanguage.getSentenceFromParagraph(
          paragraph: text,
          index: index,
          startOffset: offsetIndex,
          endOffset: offsetIndex + length,
        );

        source.setCurrentSentence(
          selection: selection,
        );
      });
    } else {
      clearDictionaryResult();
    }

    FocusScope.of(context).unfocus();
  }

  Widget buildMessage({
    required String text,
    required bool isBot,
    required bool isLoading,
  }) {
    text = RemoveEmoji().removemoji(text);
    final JidoujishoSelectableTextController controller =
        JidoujishoSelectableTextController();

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.of(context).spaces.extraSmall,
        left: Spacing.of(context).spaces.normal,
        right: Spacing.of(context).spaces.normal,
      ),
      child: Card(
        color: isBot ? null : Colors.red.withOpacity(0.5),
        child: Padding(
          padding: Spacing.of(context).insets.all.normal,
          child: isLoading && text.isEmpty
              ? JumpingDotsProgressIndicator(
                  fontSize: theme.textTheme.bodyMedium!.fontSize!,
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                )
              : Row(
                  children: [
                    Expanded(
                      child: JidoujishoSelectableText.rich(
                        TextSpan(children: [
                          ...getTextSpans(
                            controller: controller,
                            text: text,
                          ),
                          if (isLoading)
                            WidgetSpan(
                              child: SizedBox(
                                width: theme.textTheme.bodyMedium!.fontSize,
                                child: JumpingDotsProgressIndicator(
                                  fontSize:
                                      theme.textTheme.bodyMedium!.fontSize!,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor!,
                                ),
                              ),
                            ),
                        ]),
                        selectionControls: JidoujishoTextSelectionControls(
                          searchAction: (selection) async {
                            source.setCurrentSentence(
                              selection: JidoujishoTextSelection(text: text),
                            );
                            await appModel.openRecursiveDictionarySearch(
                              searchTerm: selection,
                              killOnPop: false,
                            );
                            source.clearCurrentSentence();
                          },
                          stashAction: onStash,
                          shareAction: onShare,
                          creatorAction: (selection) async {
                            await appModel.openCreator(
                              creatorFieldValues: CreatorFieldValues(
                                textValues: {
                                  SentenceField.instance: selection.text,
                                  ClozeBeforeField.instance:
                                      selection.textBefore,
                                  ClozeInsideField.instance:
                                      selection.textInside,
                                  ClozeAfterField.instance: selection.textAfter,
                                },
                              ),
                              killOnPop: false,
                              ref: ref,
                            );
                          },
                          allowCopy: true,
                          allowSelectAll: false,
                          allowCut: true,
                          allowPaste: true,
                        ),
                        controller: controller,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    buildSentencePickerButton(text),
                    buildCardCreatorButton(text),
                  ],
                ),
        ),
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget buildSentencePickerButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.sentence_picker,
        icon: Icons.colorize,
        onTap: () async {
          appModel.openExampleSentenceDialog(
            exampleSentences: appModel.targetLanguage
                .getSentences(message)
                .map((e) => e.trim())
                .toList(),
            onSelect: (selection) {
              appModel.openCreator(
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    SentenceField.instance: selection.join(
                        appModel.targetLanguage.isSpaceDelimited ? ' ' : ''),
                  },
                ),
                killOnPop: false,
                ref: ref,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCardCreatorButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.card_creator,
        icon: Icons.note_add,
        onTap: () async {
          await appModel.openCreator(
            creatorFieldValues: CreatorFieldValues(
              textValues: {
                SentenceField.instance: message,
                ClozeAfterField.instance: '',
                ClozeBeforeField.instance: '',
                ClozeInsideField.instance: '',
              },
            ),
            killOnPop: false,
            ref: ref,
          );
        },
      ),
    );
  }
}
