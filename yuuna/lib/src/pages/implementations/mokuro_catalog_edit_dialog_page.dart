import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing a new Mokuro catalog.
class MokuroCatalogEditDialogPage extends BasePage {
  /// Create an instance of this page.
  const MokuroCatalogEditDialogPage({
    this.catalog,
    super.key,
  });

  /// Not null if editing a catalog.
  final MokuroCatalog? catalog;

  @override
  BasePageState createState() => _MokuroCatalogEditDialogPageState();
}

class _MokuroCatalogEditDialogPageState
    extends BasePageState<MokuroCatalogEditDialogPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.catalog?.name);
    _urlController = TextEditingController(text: widget.catalog?.url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.big,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [buildSaveButton()];

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

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(t.dialog_save),
    );
  }

  void executeSave() async {
    String name = _nameController.text.trim();
    String url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) {
      return;
    }

    MokuroCatalog catalog = MokuroCatalog(
      name: name,
      url: url,
      order: widget.catalog?.order ?? appModel.nextCatalogOrder,
      id: widget.catalog?.id,
    );
    if (appModel.catalogUrlHasDuplicate(catalog)) {
      Fluttertoast.showToast(msg: t.duplicate_catalog);
      return;
    }
    final navigator = Navigator.of(context);

    await appModel.addCatalog(catalog);

    navigator.pop();
  }
}
