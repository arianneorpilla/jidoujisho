import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/pages/implementations/media_item_edit_dialog_page.dart';

/// The content of the dialog used upon long-pressing a [MediaItem].
class MediaItemDialogPage extends BasePage {
  /// Create an instance of this page.
  const MediaItemDialogPage({
    required this.item,
    super.key,
  });

  /// The [MediaItem] pertaining to the page.
  final MediaItem item;

  @override
  BasePageState createState() => _MediaItemDialogPageState();
}

class _MediaItemDialogPageState extends BasePageState<MediaItemDialogPage> {
  String get dialogPlayLabel => appModel.translate('dialog_play');
  String get dialogReadLabel => appModel.translate('dialog_read');
  String get dialogViewLabel => appModel.translate('dialog_view');
  String get dialogClearLabel => appModel.translate('dialog_clear');
  String get dialogEditLabel => appModel.translate('dialog_edit');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get mediaItemDeleteConfirmation =>
      appModel.translate('media_item_delete_confirmation');

  MediaSource get mediaSource => widget.item.getMediaSource(appModel: appModel);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
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
          Image(
            image: mediaSource.getDisplayThumbnailFromMediaItem(
              appModel: appModel,
              item: widget.item,
            ),
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  List<Widget> get actions => [
        if (widget.item.canDelete) buildClearButton(),
        if (widget.item.canEdit) buildEditButton(),
        buildLaunchButton(),
      ];

  String get launchLabel {
    MediaType mediaType = widget.item.getMediaType(appModel: appModel);
    if (mediaType == PlayerMediaType.instance) {
      return dialogPlayLabel;
    } else if (mediaType == ReaderMediaType.instance) {
      return dialogReadLabel;
    } else if (mediaType == ViewerMediaType.instance) {
      return dialogViewLabel;
    } else {
      throw UnimplementedError('Media type launch label unimplemented');
    }
  }

  Widget buildClearButton() {
    return TextButton(
      child: Text(
        dialogClearLabel,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      onPressed: executeClear,
    );
  }

  Widget buildLaunchButton() {
    return TextButton(
      child: Text(
        launchLabel,
      ),
      onPressed: executeLaunch,
    );
  }

  Widget buildEditButton() {
    return TextButton(
      child: Text(dialogEditLabel),
      onPressed: executeEdit,
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
      context: context,
      mediaSource: mediaSource,
      ref: ref,
      item: widget.item,
    );
  }

  void executeClear() async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        title: buildTitle(),
        content: Text(
          mediaItemDeleteConfirmation,
        ),
        actions: [
          TextButton(
            child: Text(
              dialogClearLabel,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              appModel.deleteMediaItem(widget.item);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(dialogCancelLabel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
