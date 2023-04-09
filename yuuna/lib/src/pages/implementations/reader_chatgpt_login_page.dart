import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderChatgptSource] which shows the content of the current
/// clipboard as selectable text.
class ReaderChatgptLoginPage extends BasePage {
  /// Create an instance of this tab page.
  const ReaderChatgptLoginPage({
    super.key,
  });

  @override
  BasePageState createState() => _ReaderChatgptLoginPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderChatgptLoginPageState extends BasePageState {
  ReaderChatgptSource get source => ReaderChatgptSource.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.login),
        leading: const BackButton(),
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent:
                'Mozilla 5.0 (Linux; U; Android 13) Chrome/104.0.5112.99',
          ),
          android: AndroidInAppWebViewOptions(
            forceDark: appModel.isDarkMode
                ? AndroidForceDark.FORCE_DARK_ON
                : AndroidForceDark.FORCE_DARK_OFF,
          ),
        ),
        initialUrlRequest: URLRequest(
          url: Uri.parse('https://chat.openai.com/auth/login'),
        ),
        onLoadStop: (controller, uri) async {
          Cookie? accessCookie = await CookieManager.instance().getCookie(
            url: Uri.parse('https://chat.openai.com/'),
            name: '__Secure-next-auth.session-token',
          );
          Cookie? clearanceCookie = await CookieManager.instance().getCookie(
            url: Uri.parse('https://chat.openai.com/'),
            name: 'cf_clearance',
          );

          if (accessCookie != null && clearanceCookie != null) {
            source.messageAccessToken = null;
            await source.prepareMessageAccessToken();
            if (mounted && source.messageAccessToken != null) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          }
        },
      ),
    );
  }
}
