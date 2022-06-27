import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A global [Provider] for Twitter tweet data.
final tweetsProvider =
    FutureProvider.autoDispose<TwitterResponse<List<TweetData>, TweetMeta>>(
        (ref) {
  return ReaderTwitterSource.instance.getTweets();
});

/// A media source that allows the user to provide their own Twitter OAuth key
/// in order to load and mine tweets from their Twitter timeline.
class ReaderTwitterSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderTwitterSource._privateConstructor()
      : super(
          uniqueKey: 'reader_twitter',
          sourceName: 'Twitter (Experimental)',
          description: 'Login via OAuth to read and mine tweets from a personal'
              ' Twitter timeline.',
          icon: FontAwesomeIcons.twitter,
          implementsSearch: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderTwitterSource get instance => _instance;

  static final ReaderTwitterSource _instance =
      ReaderTwitterSource._privateConstructor();

  /// The redirect URI used for Twitter.
  static String redirectUri = 'jidoujisho-twitter://';

  /// Used for Twitter developer API access. Do not abuse quota or user will
  /// need to provide their own.
  static String get apiKey => throw UnimplementedError();

  /// Used for Twitter developer API access. Do not abuse quota or user will
  /// need to provide their own.
  static String get apiSecretKey => throw UnimplementedError();

  /// Used for Twitter developer API access. Do not abuse quota or user will
  /// need to provide their own.
  static String get bearerToken => throw UnimplementedError();

  /// Default maximum number of tweets to fetch.
  static int maxResults = 50;

  /// Oauth URL.
  String get oauthUrl =>
      getPreference<String>(key: 'oauth2.0', defaultValue: '');

  /// Get a [count] number of tweets using the API details.
  Future<TwitterResponse<List<TweetData>, TweetMeta>> getTweets(
      {int? count}) async {
    final twitterLogin = TwitterLogin(
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      redirectURI: redirectUri,
    );
    AuthResult login = await twitterLogin.loginV2();
    switch (login.status) {
      case TwitterLoginStatus.loggedIn:
        late TwitterResponse<List<TweetData>, TweetMeta> tweetsResponse;

        TwitterApi api = TwitterApi(
          bearerToken: bearerToken,
          oauthTokens: OAuthTokens(
            consumerKey: apiKey,
            consumerSecret: apiSecretKey,
            accessToken: login.authToken!,
            accessTokenSecret: login.authTokenSecret!,
          ),
        );

        tweetsResponse = await api.tweetsService.lookupHomeTimeline(
          userId: '${login.user!.id}',
          expansions: TweetExpansion.values,
          userFields: UserField.values,
          tweetFields: TweetField.values,
          maxResults: count ?? maxResults,
        );

        return tweetsResponse;

      case TwitterLoginStatus.cancelledByUser:
      case TwitterLoginStatus.error:
      case null:
        throw Exception('Please try again.');
    }
  }

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return const ReaderTwitterSourcePage();
  }
}
