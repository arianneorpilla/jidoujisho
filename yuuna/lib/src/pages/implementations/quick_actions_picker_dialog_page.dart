import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for picking quick actions for a profile.
class QuickActionsPickerDialogPage extends BasePage {
  /// Create an instance of this page.
  const QuickActionsPickerDialogPage({
    required this.mapping,
    required this.slotNumber,
    super.key,
  });

  /// What mapping to alter upon picking an enhancement.
  final AnkiMapping mapping;

  /// What slot number to fill the enhancement for.
  final int slotNumber;

  @override
  BasePageState createState() => _QuickActionsPickerDialogPageState();
}

class _QuickActionsPickerDialogPageState
    extends BasePageState<QuickActionsPickerDialogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
    );
  }

  Widget buildContent() {
    List<String> activeQuickActions =
        appModel.lastSelectedMapping.getActionNames();
    List<QuickAction> quickActions = appModel.quickActions.values.toList();

    quickActions
        .removeWhere((action) => activeQuickActions.contains(action.uniqueKey));

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
              if (quickActions.isEmpty)
                buildEmptyMessage()
              else
                Flexible(
                  child: buildQuickActionTiles(quickActions),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.electric_bolt,
        message: t.no_more_available_quick_actions,
      ),
    );
  }

  Widget buildQuickActionTiles(List<QuickAction> quickActions) {
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: quickActions.length,
        itemBuilder: (context, index) =>
            buildQuickActionTile(quickActions[index]),
      ),
    );
  }

  Widget buildQuickActionTile(QuickAction quickAction) {
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(quickAction.uniqueKey),
      child: ListTile(
        leading: Icon(
          quickAction.icon,
          size: textTheme.titleLarge?.fontSize,
          color: theme.appBarTheme.foregroundColor,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quickAction.getLocalisedLabel(appModel),
                    style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                  ),
                  Text(
                    quickAction.getLocalisedDescription(appModel),
                    style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          appModel.setQuickAction(
            mapping: widget.mapping,
            slotNumber: widget.slotNumber,
            quickAction: quickAction,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
