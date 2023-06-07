import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog upon selecting 'Edit' in the
/// [MediaItemDialogPage].
class MediaItemEditDialogPage extends BasePage {
  /// Create an instance of this page.
  const MediaItemEditDialogPage({
    required this.item,
    super.key,
  });

  /// The [MediaItem] pertaining to the page.
  final MediaItem item;

  @override
  BasePageState createState() => _MediaItemEditDialogPageState();
}

class _MediaItemEditDialogPageState
    extends BasePageState<MediaItemEditDialogPage> {
  MediaSource get mediaSource => widget.item.getMediaSource(appModel: appModel);
  ImageProvider? _defaultImageProvider;
  ImageProvider? _coverImageProvider;

  File? _newFile;
  bool _clearOverrideImage = false;

  final TextEditingController _nameOverrideController = TextEditingController();
  final TextEditingController _coverOverrideController =
      TextEditingController(text: '-');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultImageProvider == null) {
      String? overrideTitle =
          mediaSource.getOverrideTitleFromMediaItem(widget.item);
      String title = overrideTitle ?? widget.item.title;
      _nameOverrideController.text = title;

      _defaultImageProvider = mediaSource.getDisplayThumbnailFromMediaItem(
        appModel: appModel,
        item: widget.item,
        noOverride: true,
      );
      _coverImageProvider = mediaSource.getDisplayThumbnailFromMediaItem(
        appModel: appModel,
        item: widget.item,
      );
    }

    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildTitle() {
    return Text(mediaSource.getDisplayTitleFromMediaItem(widget.item));
  }

  Widget buildContent() {
    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: double.maxFinite, height: 1),
          TextField(
            controller: _nameOverrideController,
            maxLines: null,
            decoration: InputDecoration(
              suffixIcon: JidoujishoIconButton(
                tooltip: t.undo,
                isWideTapArea: true,
                icon: Icons.undo,
                onTap: () async {
                  _nameOverrideController.text = widget.item.title;
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
          TextField(
            readOnly: true,
            controller: _coverOverrideController,
            style: const TextStyle(color: Colors.transparent),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: Spacing.of(context).insets.all.small,
                      child: Image(
                          image: _coverImageProvider ?? _defaultImageProvider!,
                          fit: BoxFit.fitHeight),
                    ),
                  ),
                  const SizedBox(width: 5),
                  JidoujishoIconButton(
                    tooltip: t.pick_image,
                    isWideTapArea: true,
                    icon: Icons.file_upload,
                    onTap: () async {
                      ImagePicker imagePicker = ImagePicker();
                      final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile != null) {
                        _newFile = File(pickedFile.path);
                        _coverImageProvider = FileImage(_newFile!);
                        if (_newFile != null) {
                          _clearOverrideImage = false;
                        }
                      }

                      setState(() {});
                    },
                  ),
                  JidoujishoIconButton(
                    tooltip: t.undo,
                    isWideTapArea: true,
                    icon: Icons.undo,
                    onTap: () async {
                      _newFile = null;
                      _coverImageProvider = null;
                      _clearOverrideImage = true;

                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get actions => [
        buildCancelButton(),
        buildSaveButton(),
      ];

  Widget buildCancelButton() {
    return TextButton(
      onPressed: executeCancel,
      child: Text(t.dialog_cancel),
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(t.dialog_save),
    );
  }

  void executeCancel() async {
    Navigator.pop(context);
  }

  void executeSave() async {
    final navigator = Navigator.of(context);

    if (_nameOverrideController.text.trim().isNotEmpty) {
      await mediaSource.setOverrideTitleFromMediaItem(
        item: widget.item,
        title: _nameOverrideController.text,
      );

      await mediaSource.setOverrideThumbnailFromMediaItem(
        appModel: appModel,
        item: widget.item,
        file: _newFile,
        clearOverrideImage: _clearOverrideImage,
      );

      navigator.pop();
      navigator.pop();
      mediaSource.mediaType.refreshTab();
    }
  }
}
