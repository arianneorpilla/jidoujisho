import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for editing quick actions.
class CreatorQuickActionsPage extends BasePage {
  /// Create an instance of this page.
  const CreatorQuickActionsPage({super.key});

  @override
  BasePageState createState() => _CreatorQuickActionsPageState();
}

class _CreatorQuickActionsPageState extends BasePageState {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                dense: true,
                title: Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      WidgetSpan(
                        child: Icon(
                          Icons.info,
                          size: textTheme.bodySmall?.fontSize,
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(width: 8),
                      ),
                      TextSpan(
                        text: t.info_actions,
                        style: TextStyle(
                          fontSize: textTheme.bodySmall?.fontSize,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              buildSlots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSlots() {
    AnkiMapping mapping = appModel.lastSelectedMapping;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: buildEditActionsButtons(mapping: mapping),
      ),
    );
  }

  List<Widget> buildEditActionsButtons({required AnkiMapping mapping}) {
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      Widget button = buildEditActionsButton(
        mapping: mapping,
        slotNumber: i,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildEditActionsButton({
    required AnkiMapping mapping,
    required int slotNumber,
  }) {
    String? actionName = mapping.actions![slotNumber];
    QuickAction? action;

    if (actionName != null) {
      action = appModel.quickActions[actionName];
    }

    if (action == null) {
      return JidoujishoIconButton(
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.assign_action,
        icon: Icons.add_circle,
        onTap: () async {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => QuickActionsPickerDialogPage(
              mapping: mapping,
              slotNumber: slotNumber,
            ),
          );
          setState(() {});
        },
      );
    } else {
      return JidoujishoIconButton(
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.remove_action,
        enabledColor: theme.colorScheme.primary,
        icon: action.icon,
        onTap: () async {
          appModel.removeQuickAction(
            mapping: mapping,
            slotNumber: slotNumber,
          );
          setState(() {});
        },
      );
    }
  }
}
