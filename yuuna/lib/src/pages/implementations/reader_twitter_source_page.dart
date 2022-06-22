import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spaces/spaces.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/src/pages/base_source_page.dart';
import 'package:yuuna/utils.dart';

/// The media page used for the [ReaderTwitterSource].
class ReaderTwitterSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const ReaderTwitterSourcePage({
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderTwitterSourcePageState();
}

class _ReaderTwitterSourcePageState
    extends BaseSourcePageState<ReaderTwitterSourcePage> {
  /// The media source pertaining to this page.
  ReaderTwitterSource get mediaSource => ReaderTwitterSource.instance;

  final ScrollController _scrollController = ScrollController();
  String get backLabel => appModel.translate('back');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
      title: Text(mediaSource.getLocalisedSourceName(appModel)),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: backLabel,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget buildBody() {
    AsyncValue<TwitterResponse<List<TweetData>, TweetMeta>> tweets =
        ref.watch(tweetsProvider);

    return tweets.when(
      data: buildTweetsList,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(tweetsProvider);
        },
      ),
      loading: buildLoading,
    );
  }

  Widget buildTweetsList(
      TwitterResponse<List<TweetData>, TweetMeta> twitterResponse) {
    return RawScrollbar(
      controller: _scrollController,
      thickness: 3,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: twitterResponse.data.length,
        itemBuilder: (context, index) => buildTweet(
          tweet: twitterResponse.data[index],
          includes: twitterResponse.includes!,
        ),
      ),
    );
  }

  Widget buildTweet({
    required TweetData tweet,
    required Includes includes,
  }) {
    return InkWell(
      child: Card(
        color: appModel.isDarkMode
            ? const Color.fromARGB(255, 15, 15, 15)
            : const Color.fromARGB(255, 246, 246, 246),
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.semiBig,
            top: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopRow(
                tweet: tweet,
                includes: includes,
              ),
              const Space.normal(),
              SelectableText(
                tweet.text,
                selectionControls: selectionControls,
              ),
              const Space.normal(),
            ],
          ),
        ),
      ),
      onTap: () {
        onTweetTap(tweet);
      },
    );
  }

  Widget buildTopRow({
    required TweetData tweet,
    required Includes includes,
  }) {
    UserData userData =
        includes.users!.firstWhere((user) => user.id == tweet.authorId!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: Spacing.of(context).spaces.big,
            height: Spacing.of(context).spaces.big,
            placeholder: (_, __) => const SizedBox.shrink(),
            imageUrl: userData.profileImageUrl!,
          ),
        ),
        const Space.normal(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold, height: 1.1),
              ),
              Text(
                '@${userData.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          DateFormat('yyyy-MM-dd kk:mm').format(tweet.createdAt!),
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void onTweetTap(TweetData tweet) async {
    await appModel.openCreator(
      ref: ref,
      killOnPop: false,
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: tweet.text,
        },
      ),
    );
  }
}
