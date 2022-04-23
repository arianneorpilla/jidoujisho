import 'package:flutter/material.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for managing dictionaries.
class DictionaryDialogPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogPage({Key? key}) : super(key: key);

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  String get importFormatLabel => appModel.translate('import_format');

  String get dialogImport => appModel.translate('dialog_import');
  String get dialogClose => appModel.translate('dialog_close');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildImportButton(),
        buildCloseButton(),
      ];

  Widget buildImportButton() {
    return TextButton(
      child: Text(dialogImport),
      onPressed: appModel.importDictionary,
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(dialogClose),
      onPressed: () => Navigator.pop(context),
    );
  }
}
