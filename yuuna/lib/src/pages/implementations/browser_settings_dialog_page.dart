import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing browser settings.
class BrowserSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const BrowserSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _BrowserSettingsDialogPageState();
}

class _BrowserSettingsDialogPageState extends BasePageState {
  ReaderBrowserSource get source => ReaderBrowserSource.instance;
  late final TextEditingController _hostsField;

  @override
  void initState() {
    super.initState();
    _hostsField = TextEditingController(text: source.hostsText);
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

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildHighlightOnTapSwitch(),
              buildExtendPageSwitch(),
              // const Space.small(),
              // const JidoujishoDivider(),
              // buildHostsField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExtendPageSwitch() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(source.extendPageBeyondNavigationBar);

    return Row(
      children: [
        Expanded(
          child: Text(t.extend_page_beyond_navbar),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleExtendPageBeyondNavigationBar();
                notifier.value = source.extendPageBeyondNavigationBar;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildHighlightOnTapSwitch() {
    ValueNotifier<bool> notifier = ValueNotifier<bool>(source.highlightOnTap);

    return Row(
      children: [
        Expanded(
          child: Text(t.highlight_on_tap),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleHighlightOnTap();
                notifier.value = source.highlightOnTap;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildHostsField() {
    return TextField(
      autocorrect: false,
      onChanged: source.setHostsText,
      controller: _hostsField,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: JidoujishoIconButton(
          tooltip: t.clear,
          size: 18,
          onTap: () async {
            _hostsField.clear();
            source.setHostsText('');
            FocusScope.of(context).unfocus();
          },
          icon: Icons.clear,
        ),
        labelText: t.ad_block_hosts,
      ),
    );
  }
}
