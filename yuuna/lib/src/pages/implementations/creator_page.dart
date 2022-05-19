import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:yuuna/models.dart';

/// The page used for the Card Creator to modify a note before export. Relies
/// on the [CreatorModel].
class CreatorPage extends BasePage {
  /// Construct an instance of the [HomePage].
  const CreatorPage({
    required this.decks,
    required this.editMode,
    super.key,
  });

  /// List of decks that are fetched prior to navigating to this page.
  final List<String> decks;

  /// Whether or not the creator page allows editing of set enhancements.
  final bool editMode;

  @override
  BasePageState<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends BasePageState<CreatorPage> {
  String get creatorExportingAsLabel =>
      appModel.translate('creator_exporting_as');
  String get creatorExportingAsEditingLabel =>
      appModel.translate('creator_exporting_as_editing');
  String get infoEnhancementsLabel => appModel.translate('info_enhancements');
  String get creatorExportCard => appModel.translate('creator_export_card');
  String get assignManualEnhancementLabel =>
      appModel.translate('assign_manual_enhancement');
  String get assignAutoEnhancementLabel =>
      appModel.translate('assign_auto_enhancement');
  String get removeEnhancementLabel => appModel.translate('remove_enhancement');
  String get editActionsLabel => appModel.translate('edit_actions');

  /// Get the export details pertaining to the fields.
  ExportDetails get exportDetails => creatorModel.getExportDetails(ref);

  final ScrollController _scrollController = ScrollController();

  Future<bool> onWillPop() async {
    if (!widget.editMode) {
      creatorModel.clearAll();
    }
    return true;
  }

  Color get activeButtonColor =>
      Theme.of(context).unselectedWidgetColor.withOpacity(0.1);
  Color get inactiveButtonColor =>
      Theme.of(context).unselectedWidgetColor.withOpacity(0.05);
  Color get activeTextColor => Theme.of(context).appBarTheme.foregroundColor!;
  Color get inactiveTextColor => Theme.of(context).unselectedWidgetColor;

  @override
  void initState() {
    super.initState();

    /// Check if the current profile is valid and report any discrepancies.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appModel.validateSelectedMapping(
        context: context,
        mapping: appModel.lastSelectedMapping,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: buildAppBar(),
          body: buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildLeading(),
      title: buildTitle(),
      actions: buildActions(),
      titleSpacing: 8,
    );
  }

  Widget buildEditModeTutorialMessage() {
    return ListTile(
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
              text: infoEnhancementsLabel,
              style: TextStyle(
                fontSize: textTheme.bodySmall?.fontSize,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Future<void> exportCard() async {}

  Widget buildExportButton() {
    late bool isExportable;
    if (widget.editMode) {
      isExportable = false;
    } else {
      isExportable = exportDetails.isExportable;
    }

    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: InkWell(
        onTap: isExportable ? exportCard : null,
        child: Container(
          padding: Spacing.of(context).insets.vertical.normal,
          alignment: Alignment.center,
          width: double.infinity,
          color: isExportable ? activeButtonColor : inactiveButtonColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add,
                size: textTheme.titleSmall?.fontSize,
                color: isExportable ? activeTextColor : inactiveTextColor,
              ),
              const Space.small(),
              Text(
                creatorExportCard,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExportable ? activeTextColor : inactiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditActionsButton() {
    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: InkWell(
        onTap: showQuickActionsPage,
        child: Container(
          padding: Spacing.of(context).insets.vertical.normal,
          alignment: Alignment.center,
          width: double.infinity,
          color: activeButtonColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.electric_bolt,
                size: textTheme.titleSmall?.fontSize,
                color: activeTextColor,
              ),
              const Space.small(),
              Text(
                editActionsLabel,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: activeTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showQuickActionsPage() {
    showDialog(
      context: context,
      builder: (context) => const CreatorQuickActionsPage(),
    );
  }

  Widget? buildBody() {
    return Column(
      children: [
        Expanded(child: buildPortraitFields()),
        if (widget.editMode) buildEditActionsButton() else buildExportButton(),
      ],
    );
  }

  Widget buildPortraitFields() {
    return Padding(
      padding: Spacing.of(context).insets.horizontal.small,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          controller: _scrollController,
          children: [
            if (widget.editMode) buildEditModeTutorialMessage(),
            if (!widget.editMode) buildDeckDropdown(),
            buildTextFields(),
          ],
        ),
      ),
    );
  }

  Widget buildDeckDropdown() {
    return JidoujishoDropdown<String>(
      enabled: !widget.editMode,
      options: widget.decks,
      initialOption: appModel.lastSelectedDeckName,
      generateLabel: (deckName) => deckName,
      onChanged: (deckName) {
        appModel.setLastSelectedDeck(deckName!);
        setState(() {});
      },
    );
  }

  Widget buildTextFields() {
    AnkiMapping mapping = appModel.lastSelectedMapping;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Field.values.length - 1,
      itemBuilder: (context, index) {
        Field field = Field.values[index];
        return buildTextField(
          mapping: mapping,
          field: field,
        );
      },
    );
  }

  Widget? buildLeading() {
    return const BackButton();
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              JidoujishoMarquee(
                text: widget.editMode
                    ? creatorExportingAsEditingLabel
                    : creatorExportingAsLabel,
                style: TextStyle(fontSize: textTheme.labelSmall?.fontSize),
              ),
              JidoujishoMarquee(
                text: appModel.lastSelectedMappingName,
                style: TextStyle(fontSize: textTheme.titleMedium?.fontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAutoEnhancementEditButton({
    required AnkiMapping mapping,
    required Field field,
  }) {
    Enhancement? enhancement =
        mapping.getAutoFieldEnhancement(appModel: appModel, field: field);

    if (enhancement == null) {
      return JidoujishoIconButton(
        tooltip: assignAutoEnhancementLabel,
        icon: Icons.add_circle,
        onTap: () async {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => EnhancementsPickerDialogPage(
              mapping: mapping,
              slotNumber: AnkiMapping.autoModeSlotNumber,
              field: field,
            ),
          );
          setState(() {});
        },
      );
    } else {
      return JidoujishoIconButton(
        tooltip: removeEnhancementLabel,
        enabledColor: theme.colorScheme.primary,
        icon: enhancement.icon,
        onTap: () async {
          appModel.removeAutoFieldEnhancement(mapping: mapping, field: field);
          setState(() {});
        },
      );
    }
  }

  List<Widget> buildManualEnhancementEditButtons(
      {required AnkiMapping mapping, required Field field}) {
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumFieldEnhancements; i++) {
      Widget button = buildManualEnhancementEditButton(
        mapping: mapping,
        field: field,
        slotNumber: i,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  List<Widget> buildManualEnhancementButtons(
      {required AnkiMapping mapping, required Field field}) {
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumFieldEnhancements; i++) {
      Widget button = buildManualEnhancementButton(
        mapping: mapping,
        field: field,
        slotNumber: i,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildManualEnhancementButton({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
  }) {
    String? enhancementName = mapping.enhancements[field]![slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return const SizedBox.shrink();
    } else {
      return JidoujishoIconButton(
        tooltip: enhancement.getLocalisedLabel(appModel),
        icon: enhancement.icon,
        onTap: () async {
          enhancement!.enhanceCreatorParams(
            context: context,
            ref: ref,
            appModel: appModel,
            creatorModel: creatorModel,
            cause: EnhancementTriggerCause.manual,
          );
          setState(() {});
        },
      );
    }
  }

  Widget buildManualEnhancementEditButton({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
  }) {
    String? enhancementName = mapping.enhancements[field]![slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return JidoujishoIconButton(
        tooltip: assignManualEnhancementLabel,
        icon: Icons.add_circle,
        onTap: () async {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => EnhancementsPickerDialogPage(
              mapping: mapping,
              slotNumber: slotNumber,
              field: field,
            ),
          );
          setState(() {});
        },
      );
    } else {
      return JidoujishoIconButton(
        tooltip: removeEnhancementLabel,
        enabledColor: theme.colorScheme.primary,
        icon: enhancement.icon,
        onTap: () async {
          appModel.removeFieldEnhancement(
            mapping: mapping,
            field: field,
            slotNumber: slotNumber,
          );
          setState(() {});
        },
      );
    }
  }

  Widget buildTextField({
    required AnkiMapping mapping,
    required Field field,
  }) {
    if (widget.editMode) {
      return TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: buildAutoEnhancementEditButton(
            mapping: mapping,
            field: field,
          ),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: buildManualEnhancementEditButtons(
              mapping: mapping,
              field: field,
            ),
          ),
          labelText: field.label(appModel),
          hintText: field.hint(appModel),
        ),
      );
    } else {
      return TextFormField(
        onChanged: (value) {
          setState(() {});
        },
        maxLines:
            (field == Field.sentence || field == Field.meaning) ? null : 1,
        controller: creatorModel.getFieldController(field),
        decoration: InputDecoration(
          prefixIcon: Icon(field.icon(appModel)),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: buildManualEnhancementButtons(
              mapping: mapping,
              field: field,
            ),
          ),
          labelText: field.label(appModel),
          hintText: field.hint(appModel),
        ),
      );
    }
  }

  List<Widget> buildActions() {
    if (widget.editMode) {
      return [];
    } else {
      return [
        buildManageEnhancementsButton(),
        const Space.small(),
        buildSwitchProfilesButton(),
        const Space.extraSmall(),
      ];
    }
  }

  Widget buildSwitchProfilesButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('switch_profiles'),
      icon: Icons.switch_account,
      onTapDown: openProfilesMenu,
    );
  }

  Widget buildManageEnhancementsButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('enhancements'),
      icon: Icons.auto_fix_high,
      onTap: () async {
        await appModel.openCreatorEnhancementsEditor();
        setState(() {});
      },
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: textTheme.bodyMedium?.fontSize,
              color: color,
            ),
          if (icon != null) const Space.normal(),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
      value: action,
    );
  }

  void openProfilesMenu(TapDownDetails details) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getProfileItems(),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getProfileItems() {
    return appModel.mappings.map((mapping) {
      return buildPopupItem(
        label: mapping.label,
        action: () async {
          await appModel.setLastSelectedMapping(mapping);
          setState(() {});
        },
      );
    }).toList();
  }
}
