import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    required this.killOnPop,
    super.key,
  });

  /// List of decks that are fetched prior to navigating to this page.
  final List<String> decks;

  /// Whether or not the creator page allows editing of set enhancements.
  final bool editMode;

  /// If true, popping will exit the application.
  final bool killOnPop;

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
  String get backLabel => appModel.translate('back');
  String get searchLabel => appModel.translate('search');
  String get stashLabel => appModel.translate('stash');

  /// Get the export details pertaining to the fields.
  CreatorFieldValues get exportDetails => creatorModel.getExportDetails(ref);

  final ScrollController _scrollController = ScrollController();

  Future<bool> onWillPop() async {
    if (!widget.editMode) {
      creatorModel.clearAll();
    }

    if (widget.killOnPop) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return false;
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
          resizeToAvoidBottomInset: true,
          appBar: buildAppBar(),
          body: buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
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
      child: RawScrollbar(
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
      itemCount: appModel.activeFields.length - 1,
      itemBuilder: (context, index) {
        FieldNua field = appModel.activeFields[index];
        return buildTextField(
          mapping: mapping,
          field: field,
        );
      },
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      size: textTheme.titleLarge?.fontSize,
      tooltip: backLabel,
      icon: Icons.arrow_back,
      onTap: () {
        if (widget.killOnPop) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        } else {
          Navigator.pop(context);
        }
      },
    );
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
    required FieldNua field,
  }) {
    Enhancement? enhancement =
        mapping.getAutoFieldEnhancement(appModel: appModel, field: field);

    if (enhancement == null) {
      return JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
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
        size: textTheme.titleLarge?.fontSize,
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
      {required AnkiMapping mapping, required FieldNua field}) {
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
      {required AnkiMapping mapping, required FieldNua field}) {
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
    required FieldNua field,
    required int slotNumber,
  }) {
    String? enhancementName =
        mapping.enhancements[field.uniqueKey]![slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: Spacing.of(context).insets.onlyLeft.small,
        child: JidoujishoIconButton(
          busy: true,
          size: textTheme.titleLarge?.fontSize,
          tooltip: enhancement.getLocalisedLabel(appModel),
          icon: enhancement.icon,
          onTap: () async {
            await enhancement!.enhanceCreatorParams(
              context: context,
              ref: ref,
              appModel: appModel,
              creatorModel: creatorModel,
              cause: EnhancementTriggerCause.manual,
            );
          },
        ),
      );
    }
  }

  Widget buildManualEnhancementEditButton({
    required AnkiMapping mapping,
    required FieldNua field,
    required int slotNumber,
  }) {
    String? enhancementName =
        mapping.enhancements[field.uniqueKey]![slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return Padding(
        padding: Spacing.of(context).insets.onlyLeft.small,
        child: JidoujishoIconButton(
          size: textTheme.titleLarge?.fontSize,
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
        ),
      );
    } else {
      return Padding(
        padding: Spacing.of(context).insets.onlyLeft.small,
        child: JidoujishoIconButton(
          size: textTheme.titleLarge?.fontSize,
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
        ),
      );
    }
  }

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: (searchTerm) => appModel.openRecursiveDictionarySearch(
          searchTerm: searchTerm,
          killOnPop: false,
        ),
        searchActionLabel: searchLabel,
        stashAction: (searchTerm) {
          appModel.addToStash(terms: [searchTerm]);
        },
        stashActionLabel: stashLabel,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: true,
        allowPaste: true,
      );

  Widget buildTextField({
    required AnkiMapping mapping,
    required FieldNua field,
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
          labelText: field.label,
          hintText: field.description,
        ),
        selectionControls: selectionControls,
      );
    } else {
      return TextFormField(
        onChanged: (value) {
          setState(() {});
        },
        maxLines: field.maxLines,
        controller: creatorModel.getFieldController(field),
        decoration: InputDecoration(
          prefixIcon: Icon(
            field.icon,
            size: textTheme.titleLarge?.fontSize,
          ),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: buildManualEnhancementButtons(
              mapping: mapping,
              field: field,
            ),
          ),
          labelText: field.label,
          hintText: field.description,
        ),
        selectionControls: selectionControls,
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
