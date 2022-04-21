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
    return const AlertDialog(
      title: Text('Dictionary'),
    );
  }
}
