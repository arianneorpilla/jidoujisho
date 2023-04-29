import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing ChatGPT settings.
class ChatgptSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const ChatgptSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _ChatgptSettingsDialogPageState();
}

class _ChatgptSettingsDialogPageState extends BasePageState {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();

    _apiKeyController =
        TextEditingController(text: ReaderChatgptSource.instance.apiKey ?? '');
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

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: contentController,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (1 / 3),
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildApiKeyField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildApiKeyField() {
    return TextField(
      onChanged: (value) {
        ReaderChatgptSource.instance.setApiKey(value.trim());
      },
      controller: _apiKeyController,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: t.api_key,
      ),
    );
  }
}
