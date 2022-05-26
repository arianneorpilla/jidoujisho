import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for picking creator enhancements for a field.
class EnhancementsPickerDialogPage extends BasePage {
  /// Create an instance of this page.
  const EnhancementsPickerDialogPage({
    required this.mapping,
    required this.field,
    required this.slotNumber,
    super.key,
  });

  /// What mapping to alter upon picking an enhancement.
  final AnkiMapping mapping;

  /// What field's enhancements are being picked for in the dialog.
  final Field field;

  /// What slot number to fill the enhancement for.
  final int slotNumber;

  /// Checks if the dialog page is picking for the auto mode slot.
  bool get autoMode => slotNumber == AnkiMapping.autoModeSlotNumber;

  @override
  BasePageState createState() => _EnhancementsPickerDialogPage();
}

class _EnhancementsPickerDialogPage
    extends BasePageState<EnhancementsPickerDialogPage> {
  String get noMoreAvailableEnhancementsLabel =>
      appModel.translate('no_more_available_enhancements');

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
    List<String> activeEnhancements = appModel.lastSelectedMapping
        .getManualFieldEnhancementNames(field: widget.field);
    List<Enhancement> enhancements =
        (appModel.enhancements[widget.field] ?? {}).values.toList();
    if (!widget.autoMode) {
      enhancements.removeWhere(
          (enhancement) => activeEnhancements.contains(enhancement.uniqueKey));
    }

    ScrollController contentController = ScrollController();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (enhancements.isEmpty)
                buildEmptyMessage()
              else
                Flexible(
                  child: buildEnhancementTiles(enhancements),
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
        icon: Icons.auto_fix_high,
        message: noMoreAvailableEnhancementsLabel,
      ),
    );
  }

  Widget buildEnhancementTiles(List<Enhancement> enhancements) {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: enhancements.length,
        itemBuilder: (context, index) =>
            buildEnhancementTile(enhancements[index]),
      ),
    );
  }

  Widget buildEnhancementTile(Enhancement enhancement) {
    return ListTile(
      key: ValueKey(enhancement.uniqueKey),
      leading: Icon(
        enhancement.icon,
        color: theme.appBarTheme.foregroundColor,
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enhancement.getLocalisedLabel(appModel),
                  style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                ),
                Text(
                  enhancement.getLocalisedDescription(appModel),
                  style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        appModel.setFieldEnhancement(
          mapping: widget.mapping,
          field: widget.field,
          slotNumber: widget.slotNumber,
          enhancement: enhancement,
        );
        Navigator.pop(context);
      },
    );
  }
}
