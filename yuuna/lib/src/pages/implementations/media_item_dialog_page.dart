import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/pages/implementations/media_item_edit_dialog_page.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used upon long-pressing a [MediaItem].
class MediaItemDialogPage extends BasePage {
  /// Create an instance of this page.
  const MediaItemDialogPage({
    required this.item,
    required this.isHistory,
    this.extraActions,
    super.key,
  });

  /// The [MediaItem] pertaining to the page.
  final MediaItem item;

  /// Whether or not the media items are in history.
  final bool isHistory;

  /// Extra actions to include in the dialog page if supplied by a
  /// media source.
  final List<Widget>? Function(MediaItem)? extraActions;

  @override
  BasePageState createState() => _MediaItemDialogPageState();
}

class _MediaItemDialogPageState extends BasePageState<MediaItemDialogPage> {
  MediaSource get mediaSource => widget.item.getMediaSource(appModel: appModel);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: buildTitle(),
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildTitle() {
    return SelectableText(
      mediaSource.getDisplayTitleFromMediaItem(widget.item),
      selectionControls: selectionControls,
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                mediaSource.icon,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              const Space.small(),
              Text(
                mediaSource.getLocalisedSourceName(appModel),
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
          const Space.normal(),
          AspectRatio(
            aspectRatio: mediaSource.aspectRatio,
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              imageErrorBuilder: (_, __, ___) {
                if (widget.item.extraUrl != null) {
                  return FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    imageErrorBuilder: (_, __, ___) => const SizedBox.expand(),
                    image: mediaSource.getDisplayThumbnailFromMediaItem(
                      appModel: appModel,
                      item: widget.item,
                      fallbackUrl: widget.item.extraUrl,
                    ),
                    fit: BoxFit.fitWidth,
                  );
                } else {
                  return const SizedBox.expand();
                }
              },
              image: mediaSource.getDisplayThumbnailFromMediaItem(
                appModel: appModel,
                item: widget.item,
              ),
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get actions => [
        if (widget.item.canDelete && widget.isHistory) buildClearButton(),
        if (widget.extraActions != null) ...?widget.extraActions!(widget.item),
        if (widget.item.canEdit && widget.isHistory) buildEditButton(),
        buildLaunchButton(),
      ];

  String get launchLabel {
    MediaType mediaType = widget.item.getMediaType(appModel: appModel);
    if (mediaType == PlayerMediaType.instance) {
      return t.dialog_play;
    } else if (mediaType == ReaderMediaType.instance) {
      return t.dialog_read;
    } else if (mediaType == ViewerMediaType.instance) {
      return t.dialog_view;
    } else {
      throw UnimplementedError('Media type launch label unimplemented');
    }
  }

  Widget buildClearButton() {
    return TextButton(
      onPressed: executeClear,
      child: Text(
        t.dialog_clear,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget buildLaunchButton() {
    return TextButton(
      onPressed: executeLaunch,
      child: Text(
        launchLabel,
      ),
    );
  }

  Widget buildEditButton() {
    return TextButton(
      onPressed: executeEdit,
      child: Text(t.dialog_edit),
    );
  }

  void executeEdit() async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => MediaItemEditDialogPage(item: widget.item),
    );
  }

  void executeLaunch() async {
    Navigator.pop(context);
    await appModel.openMedia(
      mediaSource: mediaSource,
      ref: ref,
      item: widget.item,
    );
  }

  void executeClear() async {
    final navigator = Navigator.of(context);
    await appModel.deleteMediaItem(widget.item);
    navigator.pop();
  }
}
