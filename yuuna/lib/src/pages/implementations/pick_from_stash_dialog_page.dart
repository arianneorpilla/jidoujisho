import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing and viewing items in the Stash.
class PickFromStashDialogPage extends BasePage {
  /// Create an instance of this page.
  const PickFromStashDialogPage({
    required this.stashContents,
    required this.onSelect,
    super.key,
  });

  /// The contents of the [SearchHistory] entity used for the Stash.
  final List<String> stashContents;

  /// The callback to be called when a selection has been made.
  final Function(String)? onSelect;

  @override
  BasePageState createState() => _PickFromStashDialogPageState();
}

class _PickFromStashDialogPageState
    extends BasePageState<PickFromStashDialogPage> {
  final ScrollController _scrollController = ScrollController();

  String get dialogExportLabel => appModel.translate('dialog_export');
  String get dialogSelectLabel => appModel.translate('dialog_select');
  String get dialogClearLabel => appModel.translate('dialog_clear');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get dialogCloseLabel => appModel.translate('dialog_close');

  String get stashClearTitle => appModel.translate('stash_clear_title');

  String get stashClearDescription =>
      appModel.translate('stash_clear_description');
  String get stashPlaceholder => appModel.translate('stash_placeholder');

  final ValueNotifier<int?> _selectionNotifier = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
      actions: widget.stashContents.isEmpty ? null : actions,
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.inventory_2,
        message: stashPlaceholder,
      ),
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: widget.stashContents.isEmpty
              ? buildEmptyMessage()
              : Wrap(children: getTextWidgets()),
        ),
      ),
    );
  }

  List<Widget> getTextWidgets() {
    List<Widget> widgets = [];

    widget.stashContents.forEachIndexed((index, segment) {
      Widget widget = GestureDetector(
        onTap: () {
          _selectionNotifier.value = index;
        },
        child: ValueListenableBuilder<int?>(
          valueListenable: _selectionNotifier,
          builder: (context, value, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.of(context).spaces.small,
                horizontal: Spacing.of(context).spaces.semiSmall,
              ),
              margin: EdgeInsets.only(
                top: Spacing.of(context).spaces.normal,
                right: Spacing.of(context).spaces.normal,
              ),
              color: index == _selectionNotifier.value
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.unselectedWidgetColor.withOpacity(0.1),
              child: SizedBox(
                height: (textTheme.titleLarge?.fontSize)! * 1.3,
                child: Text(
                  segment,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: textTheme.titleMedium?.fontSize,
                  ),
                ),
              ),
            );
          },
        ),
      );

      widgets.add(widget);
    });

    return widgets;
  }

  List<Widget> get actions => [
        if (widget.stashContents.isNotEmpty) buildClearButton(),
        if (widget.stashContents.isNotEmpty) buildExportButton(),
        if (widget.stashContents.isNotEmpty) buildSelectButton(),
      ];

  Widget buildClearButton() {
    return TextButton(
      child: Text(
        dialogClearLabel,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      onPressed: executeClear,
    );
  }

  Widget buildExportButton() {
    return TextButton(
      child: Text(dialogExportLabel),
      onPressed: executeExport,
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      child: Text(dialogSelectLabel),
      onPressed: executeSelect,
    );
  }

  String get selection => widget.stashContents[_selectionNotifier.value!];

  void executeExport() async {
    String exportText = widget.stashContents.join('\n');
    await Share.share(exportText);
  }

  void executeSelect() {
    Navigator.pop(context);
    widget.onSelect?.call(selection);
  }

  void executeClear() async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stashClearTitle),
        content: Text(
          stashClearDescription,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
              child: Text(dialogClearLabel),
              onPressed: () {
                appModel.clearStash();
                setState(() {});
              }),
          TextButton(
            child: Text(dialogCloseLabel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
