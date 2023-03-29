import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

// ignore: implementation_imports
import 'package:flutter_chatgpt_api/src/models/chat_response.model.dart';

/// A global [Provider] for getting necessary cookies.
final accessCookieProvider = FutureProvider<Cookie?>((ref) {
  return CookieManager.instance().getCookie(
    url: Uri.parse('https://chat.openai.com/'),
    name: '__Secure-next-auth.session-token',
  );
});

/// A global [Provider] for getting necessary cookies.
final clearanceCookieProvider = FutureProvider<Cookie?>((ref) {
  return CookieManager.instance().getCookie(
    url: Uri.parse('https://chat.openai.com/'),
    name: 'cf_clearance',
  );
});

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

  /// List of chat messages sent to and received from ChatGPT.
  List<ChatMessage> messages = [];

  /// Gets the last response from ChatGPT.
  ChatResponse? lastResponse;

  /// Access token used for sending messages.
  String? messageAccessToken;

  /// Used for preparing the actual access token used for sending messages.
  /// This is different from the access token persisted in the cookies.
  Future<void> prepareMessageAccessToken() async {
    bool webViewBusy = true;

    if (messageAccessToken == null) {
      HeadlessInAppWebView webView = HeadlessInAppWebView(
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              userAgent:
                  'Mozilla 5.0 (Linux; U; Android 13) Chrome/104.0.5112.99',
            ),
          ),
          initialUrlRequest: URLRequest(
            url: Uri.parse('https://chat.openai.com/api/auth/session'),
          ),
          onLoadStop: (controller, uri) async {
            messageAccessToken = await controller.evaluateJavascript(
                source: 'JSON.parse(document.body.textContent).accessToken;');

            webViewBusy = false;
          });

      await webView.run();

      while (webViewBusy) {
        await Future.delayed(const Duration(milliseconds: 100), () {});
      }

      await webView.dispose();
    }
  }

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
      buildLoginButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  /// Menu bar action.
  Widget buildLoginButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.login,
        icon: Icons.login,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const ReaderChatgptLoginPage()),
          );

          ref.refresh(accessCookieProvider);
          ref.refresh(clearanceCookieProvider);
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
        tooltip: t.clear_text_title,
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
            messages = [];
            lastResponse = null;
            appModel.refresh();

            Navigator.pop(context);
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
