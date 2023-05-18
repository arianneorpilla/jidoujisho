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
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [buildPlayButton()];

  Widget buildContent() {
    ScrollController scrollController = ScrollController();

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (1 / 3),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlayButton() {
    return TextButton(
      onPressed: executePlay,
      child: Text(t.dialog_play),
    );
  }

  void executePlay() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    widget.onPlay(_controller.text.trim());
  }
}
