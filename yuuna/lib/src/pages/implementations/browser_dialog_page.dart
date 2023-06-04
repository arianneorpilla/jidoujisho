import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when choosing a browser.
class BrowserDialogPage extends BasePage {
  /// Create an instance of this page.
  const BrowserDialogPage({
    required this.onBrowse,
    this.text = '',
    super.key,
  });

  /// Initial text.
  final String text;

  /// On browse action.
  final Function(String) onBrowse;

  @override
  BasePageState createState() => _BrowserDialogPageState();
}

class _BrowserDialogPageState extends BasePageState<BrowserDialogPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
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

  List<Widget> get actions => [buildBrowseButton()];

  Widget buildContent() {
    ScrollController scrollController = ScrollController();

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'https://',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: JidoujishoIconButton(
                    size: 18,
                    tooltip: t.clear,
                    onTap: () async {
                      _controller.clear();
                    },
                    icon: Icons.clear,
                  ),
                  labelText: t.url,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBrowseButton() {
    return TextButton(
      child: Text(t.dialog_browse),
      onPressed: executeBrowse,
    );
  }

  void executeBrowse() async {
    String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (mounted) {
      Navigator.pop(context);
    }
    widget.onBrowse(text);
  }
}
