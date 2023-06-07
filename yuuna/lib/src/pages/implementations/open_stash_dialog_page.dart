import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing and viewing items in the Stash.
class OpenStashDialogPage extends BasePage {
  /// Create an instance of this page.
  const OpenStashDialogPage({
    required this.onSelect,
    required this.onSearch,
    super.key,
  });

  /// The callback to be called when a selection has been made.
  final Function(String)? onSelect;

  /// The callback to be called for a selection to perform a search on.
  final Function(String)? onSearch;

  @override
  BasePageState createState() => _OpenStashDialogPage();
}

class _OpenStashDialogPage extends BasePageState<OpenStashDialogPage> {
  final ScrollController _scrollController = ScrollController();

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
      actions: appModel.getStash().isEmpty ? null : actions,
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.inventory_2,
        message: t.stash_placeholder,
      ),
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: appModel.getStash().isEmpty
              ? buildEmptyMessage()
              : Wrap(children: getTextWidgets().reversed.toList()),
        ),
      ),
    );
  }

  List<Widget> getTextWidgets() {
    List<Widget> widgets = [];

    appModel.getStash().forEachIndexed((index, segment) {
      Widget widget = GestureDetector(
        onTap: () {
          if (_selectionNotifier.value == index) {
            _selectionNotifier.value = null;
          } else {
            _selectionNotifier.value = index;
          }
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
        buildClearButton(),
        buildExportButton(),
        buildSearchButton(),
        buildSelectButton(),
      ];

  Widget buildClearButton() {
    return TextButton(
      onPressed: executeClear,
      child: Text(
        t.dialog_clear,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget buildExportButton() {
    return TextButton(
      onPressed: executeExport,
      child: Text(t.dialog_share),
    );
  }

  Widget buildSearchButton() {
    return TextButton(
      onPressed: executeSearch,
      child: Text(t.dialog_search),
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      onPressed: executeSelect,
      child: Text(t.dialog_select),
    );
  }

  void executeExport() async {
    String exportText = appModel.getStash().reversed.toList().join('\n');
    await Share.share(exportText);
  }

  void executeSelect() {
    if (_selectionNotifier.value != null) {
      String selection = appModel.getStash()[_selectionNotifier.value!];
      widget.onSelect?.call(selection);
      Navigator.pop(context);
    }
  }

  void executeSearch() {
    if (_selectionNotifier.value != null) {
      String selection = appModel.getStash()[_selectionNotifier.value!];
      widget.onSearch?.call(selection);
    }
  }

  void executeClear() async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.stash_clear_title),
        content: Text(t.stash_clear_description),
        actions: [
          TextButton(
              child: Text(
                t.dialog_clear,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              onPressed: () {
                appModel.clearStash();
                Navigator.pop(context);
                setState(() {});
              }),
          TextButton(
            child: Text(t.dialog_close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
