import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:spaces/spaces.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/i18n/strings.g.dart';
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

  String get commentsLabel => appModel.translate('comments');
  String get repliesLabel => appModel.translate('replies');
  String get placeholderLabel => appModel.translate('no_comments_queried');
  String get backLabel => appModel.translate('back');

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
      tooltip: backLabel,
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
            text: widget.comment == null ? commentsLabel : repliesLabel,
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
          ref.refresh(widget.comment != null
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
        message: placeholderLabel,
      ),
    );
  }

  Widget buildMessageBuilder({
    required PagingController<int, Comment> pagingController,
  }) {
    ScrollController controller = ScrollController();

    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      thickness: 3,
      child: PagedListView<int, Comment>(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        scrollController: controller,
        pagingController: pagingController,
        key: UniqueKey(),
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
      ),
    );
  }

  SelectableTextController? _lastTappedController;

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _lastTappedController?.clearSelection();
    source.clearCurrentSentence();
  }

  List<InlineSpan> getTextSpans({
    required SelectableTextController controller,
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
              _lastTappedController?.clearSelection();
              _lastTappedController = controller;

              bool firstCharacterCondition =
                  !appModel.targetLanguage.isSpaceDelimited &&
                      (controller.selection.start == index);
              bool wholeWordCondition =
                  appModel.targetLanguage.isSpaceDelimited &&
                      controller.selection.start <= index &&
                      controller.selection.end > index;

              if ((firstCharacterCondition || wholeWordCondition) &&
                  currentResult != null) {
                clearDictionaryResult();
                return;
              }

              source.setCurrentSentence('$author:\n$text');

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

              String searchTerm =
                  appModel.targetLanguage.getSearchTermFromIndex(
                text: text,
                index: index,
              );

              if (character.trim().isNotEmpty) {
                bool isSpaceDelimited =
                    appModel.targetLanguage.isSpaceDelimited;
                int whitespaceOffset =
                    searchTerm.length - searchTerm.trimLeft().length;
                int offsetIndex = appModel.targetLanguage
                        .getStartingIndex(text: text, index: index) +
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
                });
              } else {
                clearDictionaryResult();
              }

              FocusScope.of(context).unfocus();
            },
        ),
      );
    });

    return spans;
  }

  Widget buildComment({
    required Comment comment,
    bool headComment = false,
  }) {
    final SelectableTextController controller = SelectableTextController();
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
                    child: SelectableText.rich(
                      TextSpan(
                        children: getTextSpans(
                          controller: controller,
                          author: comment.author,
                          text: comment.text,
                        ),
                      ),
                      selectionControls: JidoujishoTextSelectionControls(
                        searchAction: (selection) async {
                          source.setCurrentSentence(
                              '${comment.author}:\n${comment.text}');
                          await appModel.openRecursiveDictionarySearch(
                            searchTerm: selection,
                            killOnPop: false,
                          );
                          source.clearCurrentSentence();
                        },
                        searchActionLabel: searchLabel,
                        stashAction: onContextStash,
                        stashActionLabel: stashLabel,
                        creatorAction: (selection) async {
                          launchCreator(
                              term: selection, sentence: comment.text);
                        },
                        creatorActionLabel: creatorLabel,
                        allowCopy: true,
                        allowSelectAll: false,
                        allowCut: true,
                        allowPaste: true,
                      ),
                      controller: controller,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  buildTextSegmentButton('${comment.author}:\n${comment.text}'),
                  buildCardCreatorButton('${comment.author}:\n${comment.text}'),
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
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget buildTextSegmentButton(String message) {
    String tooltip = appModel.translate('text_segmentation');

    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: tooltip,
        icon: Icons.account_tree,
        onTap: () async {
          appModel.openTextSegmentationDialog(
            sourceText: message,
            onSearch: (selection, items) async {
              source.setCurrentSentence(message);
              await appModel.openRecursiveDictionarySearch(
                searchTerm: selection,
                killOnPop: false,
              );
              source.clearCurrentSentence();
            },
            onSelect: (selection, items) {
              appModel.openCreator(
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    TermField.instance: selection,
                    SentenceField.instance: message,
                  },
                ),
                killOnPop: false,
                ref: ref,
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  void onContextSearch(String searchTerm, {String? sentence}) async {}

  Widget buildCardCreatorButton(String message) {
    String tooltip = appModel.translate('card_creator');

    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: tooltip,
        icon: Icons.note_add,
        onTap: () async {
          launchCreator(term: '', sentence: message);
        },
      ),
    );
  }

  void launchCreator({required String term, required String sentence}) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: sentence,
          TermField.instance: term,
        },
      ),
      killOnPop: false,
      ref: ref,
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
