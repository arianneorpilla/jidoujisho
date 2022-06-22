import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for picking a source for a media type.
class MediaSourcePickerDialogPage extends BasePage {
  /// Create an instance of this page.
  const MediaSourcePickerDialogPage({
    required this.mediaType,
    super.key,
  });

  /// What media type is being picked for a source in the dialog.
  final MediaType mediaType;

  @override
  BasePageState createState() => _MediaSourcePickerDialogPageState();
}

class _MediaSourcePickerDialogPageState
    extends BasePageState<MediaSourcePickerDialogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
    );
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();
    List<MediaSource> mediaSources =
        appModel.mediaSources[widget.mediaType]!.values.toList();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: buildSourceTiles(mediaSources),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSourceTiles(List<MediaSource> mediaSources) {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: mediaSources.length,
        itemBuilder: (context, index) => buildSourceTile(mediaSources[index]),
      ),
    );
  }

  Widget buildSourceTile(MediaSource mediaSource) {
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(mediaSource.uniqueKey),
      child: ListTile(
        leading: Icon(
          mediaSource.icon,
          color: theme.appBarTheme.foregroundColor,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaSource.getLocalisedSourceName(appModel),
                    style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                  ),
                  Text(
                    mediaSource.getLocalisedDescription(appModel),
                    style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          appModel.setCurrentSourceForMediaType(
            mediaType: widget.mediaType,
            mediaSource: mediaSource,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
