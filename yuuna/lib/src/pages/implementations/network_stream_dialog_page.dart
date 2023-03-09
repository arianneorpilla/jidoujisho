import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing [SubtitleOptions].
class NetworkStreamDialogPage extends BasePage {
  /// Create an instance of this page.
  const NetworkStreamDialogPage({
    required this.onPlay,
    super.key,
  });

  /// On search action.
  final Function(String) onPlay;

  @override
  BasePageState createState() => _NetworkStreamDialogPageState();
}

class _NetworkStreamDialogPageState
    extends BasePageState<NetworkStreamDialogPage> {
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

  List<Widget> get actions => [buildPlayButton()];

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
                labelText: t.stream_url,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildPlayButton() {
    return TextButton(
      child: Text(t.dialog_play),
      onPressed: executePlay,
    );
  }

  void executePlay() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    widget.onPlay(_controller.text.trim());
  }
}
