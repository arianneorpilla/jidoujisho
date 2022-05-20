import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

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
  String get mappingsDeleteConfirmationLabel =>
      appModel.translate('mappings_delete_confirmation');
  String get copyOfMappingLabel => appModel.translate('copy_of_mapping');
  String get optionsCopyLabel => appModel.translate('options_copy');
  String get optionsDeleteLabel => appModel.translate('options_delete');
  String get optionsEditLabel => appModel.translate('options_edit');
  String get showOptionsLabel => appModel.translate('show_options');
  String get dialogCreateLabel => appModel.translate('dialog_create');
  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get dialogDeleteLabel => appModel.translate('dialog_delete');
  String get dialogSaveLabel => appModel.translate('dialog_save');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get mappingNameLabel => appModel.translate('mapping_name');
  String get emptyFieldLabel => appModel.translate('field_label_empty');
  String get mappingNameHintLabel => appModel.translate('mapping_name_hint');
  String get modelToMapLabel => appModel.translate('model_to_map');
  String get errorMappingName => appModel.translate('error_profile_name');
  String get errorMappingNameContent =>
      appModel.translate('error_profile_name_content');
  String get errorStandardProfileName =>
      appModel.translate('error_standard_profile_name');
  String get errorStandardProfileNameContent =>
      appModel.translate('error_standard_profile_name_content');

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
      child: Text(dialogCreateLabel),
      onPressed: () async {
        String model = appModel.lastSelectedModel ?? widget.initialModel;
        List<String> modelFields = await appModel.getFieldList(model);
        List<int?> fieldIndexes =
            List.generate(modelFields.length, (index) => null);

        AnkiMapping newMapping = AnkiMapping(
          label: '',
          model: model,
          fieldIndexes: fieldIndexes,
          tags: [],
          order: 0,
          enhancements: AnkiMapping.defaultEnhancements,
          actions: AnkiMapping.defaultActions,
        );

        await showMappingEditDialog(newMapping);
      },
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(dialogCloseLabel),
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
      controller: _scrollController,
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        shrinkWrap: true,
        itemCount: mappings.length,
        itemBuilder: (context, index) => buildMappingTile(mappings[index]),
        onReorder: (oldIndex, newIndex) async {
          /// Moving a mapping to the last entry results in an index equal
          /// to the length of mappings, so this has to be readjusted.
          if (newIndex == mappings.length) {
            newIndex = mappings.length - 1;
          }

          AnkiMapping newSelectedMapping = mappings[newIndex];
          appModel.setLastSelectedMapping(newSelectedMapping);
          updateSelectedOrder(newSelectedMapping.order);

          appModel.updateMappingsOrder(oldIndex, newIndex);
          setState(() {});

          await appModel.validateSelectedMapping(
            context: context,
            mapping: newSelectedMapping,
          );
        },
      ),
    );
  }

  Widget buildMappingTile(AnkiMapping mapping) {
    return ListTile(
      key: ValueKey(mapping.label),
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
          if (_selectedOrder == mapping.order) buildMappingTileTrailing(mapping)
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
    );
  }

  Widget buildMappingTileTrailing(AnkiMapping mapping) {
    return JidoujishoIconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icons.more_vert,
      onTapDown: (details) =>
          openMappingOptionsMenu(details: details, mapping: mapping),
      tooltip: showOptionsLabel,
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

  void openMappingOptionsMenu(
      {required TapDownDetails details, required AnkiMapping mapping}) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(mapping),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems(AnkiMapping mapping) {
    return [
      buildPopupItem(
        label: optionsEditLabel,
        icon: Icons.edit,
        action: () async {
          await showMappingEditDialog(mapping);
        },
      ),
      buildPopupItem(
        label: optionsCopyLabel,
        icon: Icons.copy,
        action: () async {
          AnkiMapping mappingClone = mapping.copyWith(
            label: copyOfMappingLabel.replaceAll(
              '%mapping_name%',
              mapping.label,
            ),
          );

          mappingClone.id = null;

          await showMappingEditDialog(mappingClone);
        },
      ),
      if (AnkiMapping.standardProfileName != mapping.label)
        buildPopupItem(
          label: optionsDeleteLabel,
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
        mappingsDeleteConfirmationLabel,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            dialogDeleteLabel,
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
          child: Text(dialogCancelLabel),
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
            modelToMapLabel,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMappingFieldDropdowns({
    required AnkiMapping mappingClone,
    required List<String> modelFields,
  }) {
    List<Field?> fields = mappingClone.getFields();
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
                options: FieldExtension.valuesWithNull,
                initialOption: fields.elementAt(index),
                generateLabel: (field) {
                  if (field == null) {
                    return emptyFieldLabel;
                  } else {
                    return field.label(appModel);
                  }
                },
                onChanged: (field) {
                  if (field == null) {
                    mappingClone.fieldIndexes[index] = null;
                  } else {
                    mappingClone.fieldIndexes[index] = field.index;
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
        labelText: mappingNameLabel,
        hintText: mappingNameHintLabel,
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
            dialogSaveLabel,
          ),
          onPressed: () async {
            addNewMapping(
              name: controller.text,
              mapping: mappingClone,
            );
          },
        ),
        TextButton(
          child: Text(dialogCancelLabel),
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
          title: Text(errorStandardProfileName),
          content: Text(
            errorStandardProfileNameContent,
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(dialogCloseLabel),
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
            title: Text(errorMappingName),
            content: Text(
              errorMappingNameContent,
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                child: Text(dialogCloseLabel),
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
