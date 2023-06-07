import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog after clicking 'Open Link' for the Mokuro source.
class MokuroLinkDialogPage extends BasePage {
  /// Create an instance of this page.
  const MokuroLinkDialogPage({
    required this.onRead,
    super.key,
  });

  /// On search action.
  final Function(Uri) onRead;

  @override
  BasePageState createState() => _MokuroLinkDialogPageState();
}

class _MokuroLinkDialogPageState extends BasePageState<MokuroLinkDialogPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.big,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [buildReadButton()];

  Widget buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (2 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: JidoujishoIconButton(
                  size: 18,
                  tooltip: t.paste,
                  onTap: () async {
                    _controller.text =
                        (await Clipboard.getData('text/plain'))?.text ?? '';
                  },
                  icon: Icons.paste,
                ),
                labelText: t.url,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildReadButton() {
    return TextButton(
      onPressed: executeRead,
      child: Text(t.dialog_read),
    );
  }

  void executeRead() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    Uri? uri = Uri.tryParse(_controller.text.trim());
    if (uri != null) {
      widget.onRead(uri);
    }
  }
}
