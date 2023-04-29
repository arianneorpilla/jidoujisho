import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A media source that allows the user to paste and select text.
class ReaderChatgptSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderChatgptSource._privateConstructor()
      : super(
          uniqueKey: 'reader_chatgpt',
          sourceName: 'ChatGPT',
          description:
              'Allows the user to login to OpenAI and access its unofficial REST API.',
          icon: Icons.chat_outlined,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderChatgptSource get instance => _instance;

  static final ReaderChatgptSource _instance =
      ReaderChatgptSource._privateConstructor();

  /// Used to get the API key.
  String? get apiKey {
    return getPreference<String?>(key: 'openai_api_key', defaultValue: null);
  }

  /// Used to persist the API key.
  Future<void> setApiKey(String? value) async {
    await setPreference(key: 'openai_api_key', value: value);
  }

  /// Access token used for sending messages.
  String? messageAccessToken;

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {}

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    throw UnsupportedError('ChatGPT source does not launch any page');
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildClearButton(
        context: context,
        ref: ref,
        appModel: appModel,
      ),
      buildApiKeyButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  /// Menu bar action.
  Widget buildApiKeyButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.api_key,
        icon: Icons.key,
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => const ChatgptSettingsDialogPage(),
          );

          mediaType.refreshTab();
        },
      ),
    );
  }

  /// Menu bar action.
  Widget buildClearButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.clear_message_title,
        icon: Icons.clear_all,
        onTap: () {
          showClearPrompt(
            appModel: appModel,
            context: context,
            ref: ref,
          );
        },
      ),
    );
  }

  /// Shows when the clear button is pressed.
  void showClearPrompt(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) async {
    Widget alertDialog = AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      title: Text(t.clear_message_title),
      content: Text(t.clear_message_description),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            appModel.clearMessages();
            mediaType.refreshTab();
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const ReaderChatgptPage();
  }
}
