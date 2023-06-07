import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:spaces/spaces.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderWebsocketSource] which shows lyrics of current playing
/// media.
class PlayerCommentsPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const PlayerCommentsPage({
    required this.videoUrl,
    this.comment,
    super.item,
    super.key,
  });

  /// The URL of the video that the page is showing comments for.
  final String videoUrl;

  /// Comment if this is a reply thread.
  final Comment? comment;

  @override
  BaseSourcePageState createState() => _PlayerCommentsPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _PlayerCommentsPageState extends BaseSourcePageState<PlayerCommentsPage> {
  @override
  double get dictionaryEntryOpacity => 0.5;

  PlayerYoutubeSource get source => PlayerYoutubeSource.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildBlur(),
        Scaffold(
          appBar: buildAppBar(),
          backgroundColor: Theme.of(context).cardColor.withOpacity(0.85),
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: clearDictionaryResult,
                  child: buildBody(),
                ),
                buildDictionary(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Action upon selecting the Search option.
  @override
  void onSearch(String searchTerm, {String? sentence = ''}) async {
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  Widget buildBlur() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      title: buildTitle(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () async {
        Navigator.pop(context);
      },
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.comment == null ? t.comments : t.replies,
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    AsyncValue<PagingController<int, Comment>?> pagingController = ref.watch(
        widget.comment != null
            ? repliesProvider(widget.comment!)
            : commentsProvider(widget.videoUrl));

    return pagingController.when(
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.invalidate(widget.comment != null
              ? repliesProvider(widget.comment!)
              : commentsProvider(widget.videoUrl));
        },
      ),
      data: (pagingController) {
        if (pagingController == null) {
          return buildPlaceholder();
        }

        return buildMessageBuilder(pagingController: pagingController);
      },
    );
  }

  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.comments_disabled,
        message: t.no_comments_queried,
      ),
    );
  }

  Widget buildMessageBuilder({
    required PagingController<int, Comment> pagingController,
  }) {
    ScrollController controller = ScrollController();

    return PagedListView<int, Comment>(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      scrollController: controller,
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<Comment>(
        firstPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        newPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        noItemsFoundIndicatorBuilder: (context) {
          return buildPlaceholder();
        },
        itemBuilder: (context, comment, index) {
          if (index == 0 && widget.comment != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildComment(comment: widget.comment!, headComment: true),
                buildComment(comment: comment),
              ],
            );
          } else {
            return buildComment(comment: comment);
          }
        },
      ),
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
    required String author,
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
            ..onTapDown = (details) async {
              onTapDown(
                author: author,
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
    required String author,
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

      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex =
          appModel.targetLanguage.getStartingIndex(text: text, index: index) +
              whitespaceOffset;
      int length = appModel.targetLanguage.getGuessHighlightLength(
        searchTerm: searchTerm,
      );

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        length = appModel.targetLanguage.getFinalHighlightLength(
          result: currentResult,
          searchTerm: searchTerm,
        );

        controller.setSelection(offsetIndex, offsetIndex + length);

        final range = TextRange(start: offsetIndex, end: offsetIndex + length);
        source.setCurrentSentence(
          selection: JidoujishoTextSelection(
            text: text,
            range: range,
          ),
        );
      });
    } else {
      clearDictionaryResult();
    }

    FocusScope.of(context).unfocus();
  }

  Widget buildComment({
    required Comment comment,
    bool headComment = false,
  }) {
    String text = RemoveEmoji().clean(comment.text);
    final JidoujishoSelectableTextController controller =
        JidoujishoSelectableTextController();
    String videoChannelId = source.getChannelIdFromVideo(widget.videoUrl);

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.of(context).spaces.extraSmall,
        left: (headComment || widget.comment == null)
            ? Spacing.of(context).spaces.normal
            : Spacing.of(context).spaces.big,
        right: Spacing.of(context).spaces.normal,
      ),
      child: Card(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: Spacing.of(context).insets.all.normal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CommentAvatarCircle(
                    channelId: comment.channelId.value,
                    size: 24,
                  ),
                  const Space.small(),
                  SelectableText(
                    comment.author,
                    style: theme.textTheme.labelSmall,
                    selectionControls: selectionControls,
                  ),
                  if (comment.isHearted) const Space.small(),
                  if (comment.isHearted)
                    CommentAvatarCircle(
                      channelId: videoChannelId,
                      size: 16,
                    ),
                  if (comment.isHearted) const Space.extraSmall(),
                  if (comment.isHearted)
                    const Icon(
                      Icons.favorite,
                      size: 12,
                      color: Colors.redAccent,
                    )
                ],
              ),
              const Space.small(),
              Row(
                children: [
                  Expanded(
                    child: JidoujishoSelectableText.rich(
                      TextSpan(
                        children: getTextSpans(
                          controller: controller,
                          author: comment.author,
                          text: text,
                        ),
                      ),
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
                        creatorAction: (text) async {
                          await appModel.openCreator(
                            creatorFieldValues: CreatorFieldValues(
                              textValues: {
                                SentenceField.instance: text,
                                TermField.instance: '',
                                ClozeBeforeField.instance: '',
                                ClozeInsideField.instance: '',
                                ClozeAfterField.instance: '',
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
              const Space.normal(),
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_sharp,
                    size: 11,
                  ),
                  const Space.small(),
                  Text(
                    '${comment.likeCount}',
                    style: theme.textTheme.labelSmall,
                  ),
                  const Space.normal(),
                  if (!headComment && comment.replyCount > 0)
                    InkWell(
                      onTap: () {
                        clearDictionaryResult();

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) => PlayerCommentsPage(
                              videoUrl: widget.videoUrl,
                              comment: comment,
                            ),
                            settings: RouteSettings(
                              name: (PlayerCommentsPage).toString(),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.reply,
                            size: 11,
                            color: Colors.red,
                          ),
                          const Space.small(),
                          Text(
                            t.view_replies.reply(n: comment.replyCount),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
                .where((e) => e.isNotEmpty)
                .toList(),
            onSelect: (selection) {
              appModel.openCreator(
                ref: ref,
                killOnPop: false,
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    SentenceField.instance: selection.join(
                        appModel.targetLanguage.isSpaceDelimited ? ' ' : ''),
                    TermField.instance: '',
                    ClozeBeforeField.instance: '',
                    ClozeInsideField.instance: '',
                    ClozeAfterField.instance: '',
                  },
                ),
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
                TermField.instance: '',
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

/// Shows the avatar of a channel.
class CommentAvatarCircle extends ConsumerWidget {
  /// Initialise this widget.
  const CommentAvatarCircle({
    required this.channelId,
    required this.size,
    super.key,
  });

  /// Channel ID to show.
  final String channelId;

  /// Size of the circle.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Channel> channel = ref.watch(channelProvider(channelId));

    return SizedBox(
      height: size,
      width: size,
      child: channel.when(
        loading: SizedBox.shrink,
        error: (_, __) => const SizedBox.shrink(),
        data: (channel) {
          return CircleAvatar(
            child: CachedNetworkImage(
              color: Colors.transparent,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (_, __) => const SizedBox.shrink(),
              imageUrl: channel.logoUrl,
              fit: BoxFit.fill,
            ),
          );
        },
      ),
    );
  }
}
