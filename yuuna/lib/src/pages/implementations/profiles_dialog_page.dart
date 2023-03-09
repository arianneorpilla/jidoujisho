import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// The content of the dialog used for managing profiles.
class ProfilesDialogPage extends BasePage {
  /// Create an instance of this page.
  const ProfilesDialogPage({
    required this.models,
    required this.initialModel,
    super.key,
  });

  /// A list of usable models obtained from Anki prior to calling this dialog
  /// page.
  final List<String> models;

  /// The last model selected prior to calling this dialog page.
  final String initialModel;

  @override
  BasePageState createState() => _ProfilesDialogPageState();
}

class _ProfilesDialogPageState extends BasePageState<ProfilesDialogPage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedOrder = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await appModel.validateSelectedMapping(
        context: context,
        mapping: appModel.lastSelectedMapping,
      );
    });
  }

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
        buildAddNewButton(),
        buildCloseButton(),
      ];

  Widget buildAddNewButton() {
    return TextButton(
      child: Text(t.dialog_create),
      onPressed: () async {
        String model = appModel.lastSelectedModel ?? widget.initialModel;
        List<String> modelFields = await appModel.getFieldList(model);
        List<String?> exportFieldKeys =
            List.generate(modelFields.length, (index) => null);

        AnkiMapping newMapping = AnkiMapping(
          label: '',
          model: model,
          exportFieldKeys: exportFieldKeys,
          creatorFieldKeys: AnkiMapping.defaultCreatorFieldKeys,
          creatorCollapsedFieldKeys:
              AnkiMapping.defaultCreatorCollapsedFieldKeys,
          tags: [],
          order: 0,
          enhancements: AnkiMapping.defaultEnhancementsByLanguage[
              appModel.targetLanguage.languageCountryCode],
          actions: AnkiMapping.defaultActionsByLanguage[
              appModel.targetLanguage.languageCountryCode],
          exportMediaTags: true,
          useBrTags: true,
          prependDictionaryNames: true,
        );

        await showMappingEditDialog(newMapping);
      },
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  void updateSelectedOrder(int? newIndex) {
    if (newIndex != null) {
      _selectedOrder = newIndex;
      setState(() {});
    }
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: buildMappingList(),
          ),
          const JidoujishoDivider(),
          buildImportDropdown(),
        ],
      ),
    );
  }

  Widget buildMappingList() {
    List<AnkiMapping> mappings = appModel.mappings;

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ReorderableColumn(
        scrollController: _scrollController,
        children: List.generate(
          mappings.length,
          (index) => buildMappingTile(mappings[index]),
        ),
        onReorder: (oldIndex, newIndex) async {
          List<AnkiMapping> cloneMappings = [];
          cloneMappings.addAll(mappings);

          AnkiMapping item = cloneMappings[oldIndex];
          cloneMappings.remove(item);
          cloneMappings.insert(newIndex, item);

          cloneMappings.forEachIndexed((index, mapping) {
            mapping.order = index;
          });

          appModel.setLastSelectedMapping(item);
          updateSelectedOrder(newIndex);

          appModel.updateMappingsOrder(cloneMappings);
          setState(() {});

          await appModel.validateSelectedMapping(
            context: context,
            mapping: item,
          );
        },
      ),
    );
  }

  Widget buildMappingTile(AnkiMapping mapping) {
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(mapping.label),
      child: ListTile(
        selected: appModel.lastSelectedMapping.label == mapping.label,
        leading: const Icon(Icons.account_box),
        title: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  JidoujishoMarquee(
                    text: mapping.label,
                    style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                  ),
                  JidoujishoMarquee(
                    text: mapping.model,
                    style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                  ),
                ],
              ),
            ),
            if (_selectedOrder == mapping.order) const Space.normal(),
            if (_selectedOrder == mapping.order)
              buildMappingTileTrailing(mapping.label)
          ],
        ),
        onTap: () async {
          appModel.setLastSelectedMapping(mapping);
          updateSelectedOrder(mapping.order);

          await appModel.validateSelectedMapping(
            context: context,
            mapping: mapping,
          );
        },
      ),
    );
  }

  Widget buildMappingTileTrailing(String label) {
    return JidoujishoIconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icons.more_vert,
      onTapDown: (details) => openMappingOptionsMenu(
        details: details,
        label: label,
      ),
      tooltip: t.show_options,
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

  void openMappingOptionsMenu({
    required TapDownDetails details,
    required String label,
  }) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(label),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems(String label) {
    AnkiMapping mapping = appModel.getMappingFromLabel(label)!;

    return [
      buildPopupItem(
        label: t.options_edit,
        icon: Icons.edit,
        action: () async {
          await showMappingEditDialog(mapping);
        },
      ),
      buildPopupItem(
        label: t.options_copy,
        icon: Icons.copy,
        action: () async {
          AnkiMapping mappingClone =
              mapping.copyWith(label: t.copy_of_mapping(name: mapping.label));

          mappingClone.id = null;

          await showMappingEditDialog(mappingClone);
        },
      ),
      if (AnkiMapping.standardProfileName != mapping.label)
        buildPopupItem(
          label: t.options_delete,
          icon: Icons.delete,
          action: () {
            showMappingDeleteDialog(mapping);
          },
          color: theme.colorScheme.primary,
        ),
    ];
  }

  Future<void> showMappingDeleteDialog(AnkiMapping mapping) async {
    Widget alertDialog = AlertDialog(
      title: Text(mapping.label),
      content: Text(
        t.mappings_delete_confirmation,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_delete,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            appModel.deleteMapping(mapping);
            Navigator.pop(context);

            _selectedOrder = -1;
            setState(() {});
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Widget buildImportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Spacing.of(context).insets.onlyLeft.small,
          child: Text(
            t.model_to_map,
            style: TextStyle(
              fontSize: 10,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        JidoujishoDropdown<String>(
          options: widget.models,
          initialOption: widget.initialModel,
          generateLabel: (modelName) => modelName,
          onChanged: (modelName) {
            appModel.setLastSelectedModelName(modelName!);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget buildEditContent({
    required List<String> modelFields,
    required AnkiMapping mappingClone,
    required TextEditingController controller,
  }) {
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
              buildMappingNameFormField(controller: controller),
              const Space.normal(),
              Flexible(
                child: buildMappingFieldDropdowns(
                  modelFields: modelFields,
                  mappingClone: mappingClone,
                ),
              ),
              const Space.normal(),
              buildWrapImageAudio(mappingClone: mappingClone),
              const Space.small(),
              buildUseBrTags(mappingClone: mappingClone),
              const Space.small(),
              buildPrependDictionaryNames(mappingClone: mappingClone),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWrapImageAudio({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(mappingClone.exportMediaTags ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.wrap_image_audio)),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.exportMediaTags = value;
                _notifier.value = value;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildUseBrTags({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(mappingClone.useBrTags ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.use_br_tags)),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.useBrTags = value;
                _notifier.value = value;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildPrependDictionaryNames({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(mappingClone.prependDictionaryNames ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.prepend_dictionary_names)),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.prependDictionaryNames = value;
                _notifier.value = value;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildMappingFieldDropdowns({
    required AnkiMapping mappingClone,
    required List<String> modelFields,
  }) {
    List<Field?> fields = mappingClone.getExportFields();
    ScrollController scrollController = ScrollController();

    return SingleChildScrollView(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: modelFields.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: Spacing.of(context).insets.onlyLeft.small,
                child: Text(
                  modelFields.elementAt(index),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.unselectedWidgetColor,
                  ),
                ),
              ),
              JidoujishoDropdown<Field?>(
                options: [null, ...globalFields],
                initialOption: fields.elementAt(index),
                generateLabel: (field) {
                  if (field == null) {
                    return t.field_label_empty;
                  } else {
                    return field.label;
                  }
                },
                onChanged: (field) {
                  if (field == null) {
                    mappingClone.exportFieldKeys[index] = null;
                  } else {
                    mappingClone.exportFieldKeys[index] = field.uniqueKey;
                  }
                  setState(() {});
                },
              ),
              if (index != modelFields.length - 1) const Space.normal(),
            ],
          );
        },
      ),
    );
  }

  Widget buildMappingNameFormField({
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_box),
        labelText: t.mapping_name,
        hintText: t.mapping_name_hint,
      ),
    );
  }

  Future<void> showMappingEditDialog(
    AnkiMapping mapping,
  ) async {
    AnkiMapping mappingClone = mapping.copyWith();
    TextEditingController controller =
        TextEditingController(text: mapping.label);
    List<String> modelFields = await appModel.getFieldList(mapping.model);

    Widget alertDialog = AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      content: buildEditContent(
        modelFields: modelFields,
        mappingClone: mappingClone,
        controller: controller,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_save,
          ),
          onPressed: () async {
            addNewMapping(
              name: controller.text,
              mapping: mappingClone,
            );
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Future<void> addNewMapping(
      {required String name, required AnkiMapping mapping}) async {
    /// Assign the name to the mapping.
    AnkiMapping newMapping = mapping.copyWith(
      label: name,
      tags: [mapping.model],
    );

    /// Error if the mapping attempts to rename the standard profile.
    if (mapping.label == AnkiMapping.standardProfileName &&
        name != AnkiMapping.standardProfileName) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.error_standard_profile_name),
          content: Text(
            t.error_standard_profile_name_content,
          ),
          actions: [
            TextButton(
              child: Text(t.dialog_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

      return;
    }

    /// If this mapping does not already exist in the database.
    if (mapping.id == null) {
      /// Set the order of this mapping to the next order to be added to the
      /// database.
      int order = appModel.nextMappingOrder;
      newMapping = newMapping.copyWith(order: order);

      /// If the name is blank or the mapping exists, error.
      if (name.isEmpty ||
          name.contains('%mappingName%') ||
          appModel.mappingNameHasDuplicate(newMapping)) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.error_profile_name),
            content: Text(
              t.error_profile_name_content,
            ),
            actions: [
              TextButton(
                child: Text(t.dialog_close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );

        return;
      }
    }

    appModel.addMapping(newMapping);
    Navigator.pop(context);

    _selectedOrder = mapping.order;
    setState(() {});
  }
}
