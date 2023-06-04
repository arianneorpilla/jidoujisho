import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing a new [BrowserBookmark].
class BrowserBookmarkDialogPage extends BasePage {
  /// Create an instance of this page.
  const BrowserBookmarkDialogPage({
    this.bookmark,
    this.onUpdate,
    super.key,
  });

  /// Not null if editing a catalog.
  final BrowserBookmark? bookmark;

  /// On delete or save.
  final Function()? onUpdate;

  @override
  BasePageState createState() => _BrowserBookmarkDialogPageState();
}

class _BrowserBookmarkDialogPageState
    extends BasePageState<BrowserBookmarkDialogPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.bookmark?.name);
    _urlController = TextEditingController(text: widget.bookmark?.url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.big,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        if (widget.bookmark != null) buildDeleteButton(),
        buildSaveButton(),
      ];

  Widget buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (2 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: t.name,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: t.url,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return TextButton(
      child: Text(
        t.dialog_delete,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      onPressed: executeDelete,
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      child: Text(t.dialog_save),
      onPressed: executeSave,
    );
  }

  void executeDelete() async {
    if (widget.bookmark != null && widget.bookmark!.id != null) {
      appModel.deleteBookmark(widget.bookmark!);
      widget.onUpdate?.call();
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void executeSave() async {
    String name = _nameController.text.trim();
    String url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) {
      return;
    }

    BrowserBookmark bookmark = BrowserBookmark(
      name: name,
      url: url,
      id: widget.bookmark?.id,
    );

    await appModel.addBookmark(bookmark);
    widget.onUpdate?.call();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
