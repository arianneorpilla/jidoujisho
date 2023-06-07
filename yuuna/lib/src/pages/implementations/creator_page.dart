import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spaces/spaces.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:yuuna/models.dart';

/// The page used for the Card Creator to modify a note before export. Relies
/// on the [CreatorModel].
class CreatorPage extends BasePage {
  /// Construct an instance of the [HomePage].
  const CreatorPage({
    required this.decks,
    required this.editEnhancements,
    required this.editFields,
    required this.killOnPop,
    required this.subtitles,
    super.key,
  });

  /// List of decks that are fetched prior to navigating to this page.
  final List<String> decks;

  /// Whether or not the creator page allows editing of set enhancements.
  final bool editEnhancements;

  /// Whether or not the creator page allows editing of set fields.
  final bool editFields;

  /// If true, popping will exit the application.
  final bool killOnPop;

  /// Used to generate multiple images if required and invoked from a
  /// media source. See [MediaSource.generateImages].
  final List<Subtitle>? subtitles;

  @override
  BasePageState<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends BasePageState<CreatorPage> {
  bool get isCardEditing => !widget.editEnhancements && !widget.editFields;

  /// Get the export details pertaining to the fields.
  CreatorFieldValues get exportDetails => creatorModel.getExportDetails(ref);

  Future<bool> onWillPop() async {
    if (isCardEditing) {
      creatorModel.clearAll(
        overrideLocks: true,
        savedTags: appModel.savedTags,
      );
    }

    if (widget.killOnPop) {
      appModel.shutdown();
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

  /// For controlling collapsed fields.
  late final ExpandableController expandableController;

  bool _creatorInitialised = false;

  @override
  void initState() {
    super.initState();

    expandableController =
        ExpandableController(initialExpanded: !isCardEditing);
  }

  @override
  void dispose() {
    for (Field field in appModel.activeFields) {
      if (field is AudioExportField) {
        field.onCreatorClose();
      }
    }

    super.dispose();
  }

  Future<void> initialiseCreator() async {
    appModel.validateSelectedMapping(
      context: context,
      mapping: appModel.lastSelectedMapping,
    );

    for (Field field in appModel.activeFields) {
      /// If a media source has a generate images or audio function, then use that
      /// over any set auto enhancement.
      if (appModel.isMediaOpen && appModel.getCurrentMediaItem() != null) {
        MediaSource mediaSource =
            appModel.getCurrentMediaItem()!.getMediaSource(appModel: appModel);
        if (field is ImageField && mediaSource.overridesAutoImage) {
          if (!appModel
              .getCurrentMediaItem()!
              .getMediaSource(appModel: appModel)
              .shouldGenerateImage) {
            continue;
          }

          await field.setImages(
            appModel: appModel,
            creatorModel: creatorModel,
            searchTerm: '',
            newAutoCannotOverride: true,
            cause: EnhancementTriggerCause.manual,
            generateImages: () async {
              return mediaSource.generateImages(
                appModel: appModel,
                item: appModel.getCurrentMediaItem()!,
                subtitles: widget.subtitles,
                options: appModel.currentSubtitleOptions!.value,
                data: mediaSource.currentExtraData,
              );
            },
          );

          if (field.currentImageSuggestions == null ||
              field.currentImageSuggestions!.isEmpty) {
            Enhancement? enhancement = appModel.lastSelectedMapping
                .getAutoFieldEnhancement(appModel: appModel, field: field);

            if (enhancement != null && context.mounted) {
              enhancement.enhanceCreatorParams(
                context: context,
                ref: ref,
                appModel: appModel,
                creatorModel: creatorModel,
                cause: EnhancementTriggerCause.auto,
              );
            }
          }
          continue;
        }
        if (field is AudioSentenceField && mediaSource.overridesAutoAudio) {
          if (!appModel
              .getCurrentMediaItem()!
              .getMediaSource(appModel: appModel)
              .shouldGenerateAudio) {
            continue;
          }

          await field.setAudio(
            appModel: appModel,
            creatorModel: creatorModel,
            searchTerm: '',
            newAutoCannotOverride: true,
            cause: EnhancementTriggerCause.manual,
            generateAudio: () async {
              return mediaSource.generateAudio(
                appModel: appModel,
                item: appModel.getCurrentMediaItem()!,
                subtitles: widget.subtitles,
                options: appModel.currentSubtitleOptions!.value,
                data: mediaSource.currentExtraData,
              );
            },
          );
          continue;
        }
      }

      Enhancement? enhancement = appModel.lastSelectedMapping
          .getAutoFieldEnhancement(appModel: appModel, field: field);

      if (enhancement != null && context.mounted) {
        enhancement.enhanceCreatorParams(
          context: context,
          ref: ref,
          appModel: appModel,
          creatorModel: creatorModel,
          cause: EnhancementTriggerCause.auto,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!appModel.isDatabaseOpen) {
      return const SizedBox.shrink();
    }

    if (!_creatorInitialised && isCardEditing) {
      _creatorInitialised = true;
      initialiseCreator();
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            buildBlur(),
            buildScaffold(),
          ],
        ),
      ),
    );
  }

  Widget buildBlur() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      title: buildTitle(),
      actions: buildActions(),
      titleSpacing: 8,
    );
  }

  Widget buildTutorialMessage() {
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
              text:
                  widget.editEnhancements ? t.info_enhancements : t.info_fields,
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

  Widget buildCollapsableHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.of(context).spaces.normal,
        horizontal: Spacing.of(context).spaces.small,
      ),
      child: Row(
        children: [
          Icon(Icons.edit_note,
              color: Theme.of(context).unselectedWidgetColor,
              size: textTheme.labelLarge?.fontSize),
          const Space.semiSmall(),
          Text(
            t.hidden_fields,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpandablePanel() {
    if (!widget.editFields &&
        appModel.lastSelectedMapping.creatorCollapsedFieldKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpandablePanel(
      theme: ExpandableThemeData(
        iconPadding: Spacing.of(context).insets.onlyRight.small,
        iconSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        expandIcon: Icons.arrow_drop_down,
        collapseIcon: Icons.arrow_drop_down,
        iconColor: Theme.of(context).unselectedWidgetColor,
        headerAlignment: ExpandablePanelHeaderAlignment.center,
      ),
      controller: expandableController,
      header: buildCollapsableHeader(),
      collapsed: const SizedBox.shrink(),
      expanded: buildCollapsedTextFields(),
    );
  }

  Future<void> exportCard() async {
    await appModel.addNote(
      creatorFieldValues: creatorModel.getExportDetails(ref),
      mapping: appModel.lastSelectedMapping,
      deck: appModel.lastSelectedDeckName,
      onSuccess: () {
        creatorModel.clearAll(
          overrideLocks: false,
          savedTags: appModel.savedTags,
        );
        creatorModel.getFieldController(TagsField.instance).text =
            appModel.savedTags;

        if (appModel.closeCreatorOnExport) {
          if (widget.killOnPop) {
            appModel.shutdown();
          } else {
            Navigator.pop(context);
          }
        }
      },
    );
  }

  Widget buildExportButton() {
    late bool isExportable;
    if (widget.editEnhancements) {
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
                t.creator_export_card,
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
                t.edit_actions,
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

  Widget buildEditFieldsButton() {
    return Padding(
      padding: Spacing.of(context).insets.exceptBottom.normal,
      child: InkWell(
        onTap: () async {
          await appModel.openCreatorFieldsEditor();
          setState(() {});
        },
        child: Container(
          padding: Spacing.of(context).insets.vertical.normal,
          alignment: Alignment.center,
          width: double.infinity,
          color: activeButtonColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: textTheme.titleSmall?.fontSize,
                color: activeTextColor,
              ),
              const Space.small(),
              Text(
                t.edit_fields,
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

  Widget buildScaffold() {
    bool showPortrait = (appModel.activeFields.contains(ImageField.instance) &&
            !ImageField.instance.showWidget &&
            !ImageField.instance.isSearching) ||
        MediaQuery.of(context).orientation == Orientation.portrait ||
        widget.editEnhancements ||
        widget.editFields ||
        !appModel.activeFields.contains(ImageField.instance);

    return Scaffold(
      backgroundColor:
          theme.colorScheme.background.withOpacity(isCardEditing ? 0.5 : 1),
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: showPortrait ? buildAppBar() : null,
      body: showPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  Widget buildLandscape() {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Column(
              children: [
                buildAppBar(),
                const Space.semiBig(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (appModel.activeFields.contains(ImageField.instance))
                        Expanded(
                          child: ImageField.instance.buildTopWidget(
                            context: context,
                            ref: ref,
                            appModel: appModel,
                            creatorModel: creatorModel,
                            orientation: Orientation.landscape,
                          ),
                        ),
                      if (appModel.activeFields.contains(AudioField.instance))
                        AudioField.instance.buildTopWidget(
                          context: context,
                          ref: ref,
                          appModel: appModel,
                          creatorModel: creatorModel,
                          orientation: Orientation.landscape,
                        ),
                      if (appModel.activeFields
                          .contains(AudioSentenceField.instance))
                        AudioSentenceField.instance.buildTopWidget(
                          context: context,
                          ref: ref,
                          appModel: appModel,
                          creatorModel: creatorModel,
                          orientation: Orientation.landscape,
                        ),
                    ],
                  ),
                ),
                buildDeckDropdown(),
                const Space.small(),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: buildFields(isPortrait: false)),
                if (widget.editEnhancements) buildEditFieldsButton(),
                if (widget.editEnhancements) buildEditActionsButton(),
                if (isCardEditing) buildExportButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPortrait() {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(child: buildFields(isPortrait: true)),
          if (widget.editEnhancements) buildEditFieldsButton(),
          if (widget.editEnhancements) buildEditActionsButton(),
          if (isCardEditing) buildExportButton(),
        ],
      ),
    );
  }

  Widget buildFields({required bool isPortrait}) {
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: creatorModel.scrollController,
      child: Padding(
        padding: Spacing.of(context).insets.horizontal.small,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          controller: creatorModel.scrollController,
          children: [
            if (isCardEditing && isPortrait) buildTopWidgets(),
            if (!isCardEditing) buildTutorialMessage(),
            if (isCardEditing && isPortrait) buildDeckDropdown(),
            buildTextFields(),
            buildExpandablePanel(),
          ],
        ),
      ),
    );
  }

  Widget buildTopWidgets() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appModel.activeFields.length,
      itemBuilder: (context, index) {
        Field field = appModel.activeFields[index];
        if (field is ImageExportField) {
          return field.buildTopWidget(
            context: context,
            ref: ref,
            appModel: appModel,
            creatorModel: creatorModel,
            orientation: Orientation.portrait,
          );
        } else if (field is AudioExportField) {
          return field.buildTopWidget(
            context: context,
            ref: ref,
            appModel: appModel,
            creatorModel: creatorModel,
            orientation: Orientation.portrait,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget buildDeckDropdown() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        JidoujishoDropdown<String>(
          enabled: !widget.editEnhancements,
          options: widget.decks,
          initialOption: appModel.lastSelectedDeckName,
          generateLabel: (deckName) => deckName,
          onChanged: (deckName) {
            appModel.setLastSelectedDeck(deckName!);
            setState(() {});
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(
                width: 0.5,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextFields() {
    AnkiMapping mapping = appModel.lastSelectedMapping;
    List<Field> fields = mapping.getCreatorFields();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.editFields ? fields.length + 1 : fields.length,
      itemBuilder: (context, index) {
        if (widget.editFields && index == fields.length) {
          return buildAddTextField(mapping: mapping, isCollapsed: false);
        }

        Field field = fields[index];
        return buildTextField(
          mapping: mapping,
          field: field,
          isCollapsed: false,
        );
      },
    );
  }

  Widget buildCollapsedTextFields() {
    AnkiMapping mapping = appModel.lastSelectedMapping;
    List<Field> fields = mapping.getCreatorCollapsedFields();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.editFields ? fields.length + 1 : fields.length,
      itemBuilder: (context, index) {
        if (widget.editFields && index == fields.length) {
          return buildAddTextField(mapping: mapping, isCollapsed: true);
        }

        Field field = fields[index];
        return buildTextField(
          mapping: mapping,
          field: field,
          isCollapsed: true,
        );
      },
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () {
        if (widget.killOnPop) {
          appModel.shutdown();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildSearchClearButton() {
    return JidoujishoIconButton(
      tooltip: t.clear_creator_title,
      icon: Icons.delete_sweep,
      onTap: showClearPrompt,
    );
  }

  void showClearPrompt() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.clear_creator_title),
      content: Text(t.clear_creator_description),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () async {
            creatorModel.clearAll(
              overrideLocks: true,
              savedTags: appModel.savedTags,
            );
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Widget buildTitle() {
    late String label;
    if (widget.editEnhancements) {
      label = t.creator_exporting_as_enhancements_editing;
    } else if (widget.editFields) {
      label = t.creator_exporting_as_fields_editing;
    } else {
      label = t.creator_exporting_as;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              JidoujishoMarquee(
                text: label,
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

  Widget buildRemoveFieldButton({
    required AnkiMapping mapping,
    required Field field,
    required bool isCollapsed,
  }) {
    return JidoujishoIconButton(
      isWideTapArea: true,
      size: textTheme.titleLarge?.fontSize,
      tooltip: t.remove_field,
      enabledColor: theme.colorScheme.primary,
      icon: field.icon,
      onTap: () async {
        appModel.removeField(
          mapping: mapping,
          field: field,
          isCollapsed: isCollapsed,
        );
        setState(() {});
      },
    );
  }

  Widget buildAddFieldButton({
    required AnkiMapping mapping,
    required bool isCollapsed,
  }) {
    return JidoujishoIconButton(
      isWideTapArea: true,
      size: textTheme.titleLarge?.fontSize,
      tooltip: t.add_field,
      icon: Icons.add_circle,
      onTap: () async {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => FieldPickerDialogPage(
            mapping: mapping,
            isCollapsed: isCollapsed,
          ),
        );
        setState(() {});
      },
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
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.assign_auto_enhancement,
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
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.remove_enhancement,
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
    String? enhancementName =
        (mapping.enhancements![field.uniqueKey] ?? {})[slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return const SizedBox.shrink();
    } else {
      return JidoujishoIconButton(
        isWideTapArea: true,
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
      );
    }
  }

  Widget buildManualEnhancementEditButton({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
  }) {
    String? enhancementName =
        (mapping.enhancements![field.uniqueKey] ?? {})[slotNumber];
    Enhancement? enhancement;

    if (enhancementName != null) {
      enhancement = appModel.enhancements[field]![enhancementName];
    }

    if (enhancement == null) {
      return JidoujishoIconButton(
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.assign_manual_enhancement,
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
        isWideTapArea: true,
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.remove_enhancement,
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

  void onSentenceSearch(JidoujishoTextSelection selection) async {
    String searchTerm = selection.textInside;
    String afterSearchTerm = searchTerm;

    final subscription =
        appModel.cardCreatorRecursiveSearchStream.listen((event) {
      if (searchTerm == afterSearchTerm) {
        creatorModel.setSentenceAndCloze(selection);
      }
    });

    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      onUpdateQuery: (query) {
        afterSearchTerm = query;
      },
      killOnPop: false,
    );

    subscription.cancel();
  }

  MaterialTextSelectionControls get sentenceSelectionControls =>
      JidoujishoTextSelectionControls(
        sentenceAction: onSentenceSearch,
        stashAction: onStash,
        shareAction: onShare,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: true,
        allowPaste: true,
      );

  Widget buildTextField({
    required AnkiMapping mapping,
    required Field field,
    required bool isCollapsed,
  }) {
    if (!isCardEditing) {
      return TextFormField(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        enableInteractiveSelection: false,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: widget.editEnhancements
              ? buildAutoEnhancementEditButton(
                  mapping: mapping,
                  field: field,
                )
              : buildRemoveFieldButton(
                  mapping: mapping,
                  field: field,
                  isCollapsed: isCollapsed,
                ),
          suffixIcon: widget.editEnhancements
              ? Padding(
                  padding: Spacing.of(context).insets.onlyRight.small,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: buildManualEnhancementEditButtons(
                      mapping: mapping,
                      field: field,
                    ),
                  ),
                )
              : null,
          labelText: field.getLocalisedLabel(appModel),
          hintText: field.getLocalisedDescription(appModel),
        ),
      );
    } else {
      return TextFormField(
        onChanged: (value) {
          setState(() {});
        },
        maxLines: field.maxLines,
        controller: creatorModel.getFieldController(field),
        decoration: InputDecoration(
          prefixIcon: buildPrefixIcon(field),
          suffixIcon: (mapping.enhancements![field.uniqueKey] ?? {}).isNotEmpty
              ? Padding(
                  padding: Spacing.of(context).insets.onlyRight.small,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: buildManualEnhancementButtons(
                      mapping: mapping,
                      field: field,
                    ),
                  ),
                )
              : null,
          labelText: field.getLocalisedLabel(appModel),
        ),
        selectionControls: field is SentenceField
            ? sentenceSelectionControls
            : selectionControls,
      );
    }
  }

  Widget buildPrefixIcon(Field field) {
    return ValueListenableBuilder<bool>(
      valueListenable: creatorModel.getLockedNotifier(field),
      builder: (context, locked, child) {
        return JidoujishoIconButton(
            tooltip: locked ? t.field_unlock : t.field_lock,
            size: textTheme.titleLarge?.fontSize,
            enabledColor: locked ? Colors.red : null,
            icon: locked ? Icons.lock : field.icon,
            onTap: () {
              creatorModel.toggleLock(field);

              Fluttertoast.showToast(
                msg: locked
                    ? t.field_unlocked(field: field.getLocalisedLabel(appModel))
                    : t.field_locked(field: field.getLocalisedLabel(appModel)),
              );
            });
      },
    );
  }

  Widget buildAddTextField({
    required AnkiMapping mapping,
    required bool isCollapsed,
  }) {
    return TextFormField(
      enableInteractiveSelection: false,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: buildAddFieldButton(
          mapping: mapping,
          isCollapsed: isCollapsed,
        ),
        labelText: t.add_field,
        hintText: t.add_field_hint,
      ),
    );
  }

  List<Widget> buildActions() {
    if (!isCardEditing) {
      return [];
    } else {
      return [
        buildCloseOnExportButton(),
        const Space.small(),
        buildSearchClearButton(),
        const Space.small(),
        buildManageEnhancementsButton(),
        buildSwitchProfilesButton(),
        const Space.extraSmall(),
      ];
    }
  }

  Widget buildSwitchProfilesButton() {
    return PopupMenuButton<VoidCallback>(
      splashRadius: 20,
      padding: EdgeInsets.zero,
      tooltip: t.switch_profiles,
      icon: Icon(
        Icons.switch_account,
        color: theme.iconTheme.color,
        size: 24,
      ),
      color: Theme.of(context).popupMenuTheme.color,
      onSelected: (value) => value(),
      itemBuilder: (context) => getProfileItems(),
    );
  }

  Widget buildManageEnhancementsButton() {
    return JidoujishoIconButton(
      tooltip: t.enhancements,
      icon: Icons.auto_fix_high,
      onTap: () async {
        await appModel.openCreatorEnhancementsEditor();
        setState(() {});
      },
    );
  }

  /// Allows user to toggle whether or not to filter for videos with
  /// closed captions.
  Widget buildCloseOnExportButton() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(appModel.closeCreatorOnExport);

    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return JidoujishoIconButton(
          size: Theme.of(context).textTheme.titleLarge?.fontSize,
          tooltip: t.close_on_export,
          enabledColor: value ? Colors.red : null,
          icon: Icons.exit_to_app,
          onTap: () {
            appModel.toggleCloseCreatorOnExport();
            notifier.value = appModel.closeCreatorOnExport;

            Fluttertoast.showToast(
              msg: appModel.closeCreatorOnExport
                  ? t.close_on_export_on
                  : t.close_on_export_off,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          },
        );
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
      value: action,
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
    );
  }

  Rect _getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  final GlobalKey _profileMenuKey = GlobalKey();
  final GlobalKey _scaffoldKey = GlobalKey();

  void openProfilesMenu(TapDownDetails details) async {
    RelativeRect position = RelativeRect.fromRect(
        _getWidgetGlobalRect(_profileMenuKey),
        _getWidgetGlobalRect(_scaffoldKey));
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
