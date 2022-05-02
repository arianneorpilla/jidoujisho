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
    Key? key,
  }) : super(key: key);

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
  String get optionsDeleteLabel => appModel.translate('options_delete');
  String get optionsEditLabel => appModel.translate('options_edit');
  String get showOptionsLabel => appModel.translate('show_options');
  String get dialogAddNewLabel => appModel.translate('dialog_add_new');
  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get dialogDeleteLabel => appModel.translate('dialog_delete');
  String get dialogSaveLabel => appModel.translate('dialog_save');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get mappingNameLabel => appModel.translate('mapping_name');
  String get emptyFieldLabel => appModel.translate('field_label_empty');
  String get mappingNameHintLabel => appModel.translate('mapping_name_hint');
  String get modelToMapLabel => appModel.translate('model_to_map');
  String get invalidMappingName => appModel.translate('invalid_mapping_name');
  String get invalidMappingNameContent =>
      appModel.translate('invalid_mapping_name_content');

  final ScrollController _scrollController = ScrollController();
  int _selectedOrder = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.exceptBottom.big,
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
      child: Text(dialogAddNewLabel),
      onPressed: () async {
        String model = appModel.lastSelectedModel ?? widget.initialModel;
        List<String> modelFields = await AnkiUtilities.getFieldList(model);
        List<int?> fieldIndexes =
            List.generate(modelFields.length, (index) => null);

        AnkiMapping newMapping = AnkiMapping(
          label: '',
          model: model,
          fieldIndexes: fieldIndexes,
          tags: [],
          order: 0,
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

    return Scrollbar(
      controller: _scrollController,
      child: ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: mappings.length,
        itemBuilder: (context, index) => buildMappingTile(mappings[index]),
        onReorder: (oldIndex, newIndex) {
          /// Moving a mapping to the last entry results in an index equal
          /// to the length of mappings, so this has to be readjusted.
          if (newIndex == mappings.length) {
            newIndex = mappings.length - 1;
          }

          appModel.setLastSelectedMapping(mappings[newIndex]);
          updateSelectedOrder(newIndex);
          appModel.updateMappingsOrder(oldIndex, newIndex);
          setState(() {});
        },
      ),
    );
  }

  Widget buildMappingTile(AnkiMapping mapping) {
    return ListTile(
        key: ValueKey(mapping.label),
        selected: appModel.lastSelectedMapping?.label == mapping.label,
        leading: const Icon(Icons.send_to_mobile),
        title: Row(
          children: [
            Expanded(
              child: JidoujishoMarquee(
                  text: mapping.label,
                  style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize)),
            ),
            if (_selectedOrder == mapping.order) const Space.normal(),
            if (_selectedOrder == mapping.order)
              buildMappingTileTrailing(mapping)
          ],
        ),
        onTap: () async {
          await appModel.setLastSelectedMapping(mapping);
          updateSelectedOrder(mapping.order);
        });
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
    required IconData icon,
    required Function() action,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: textTheme.bodyMedium?.fontSize,
            color: color,
          ),
          const Space.normal(),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: color)),
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
      if (AnkiMapping.defaultMappingName != mapping.label)
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
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              const Space.normal(),
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
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).focusColor),
        ),
        prefixIcon: const Icon(Icons.send_to_mobile),
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
    List<String> modelFields = await AnkiUtilities.getFieldList(mapping.model);

    Widget alertDialog = AlertDialog(
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
      tags: [name],
    );

    /// If this mapping does not already exist in the database.
    if (mapping.id == null) {
      /// Set the order of this mapping to the next order to be added to the
      /// database.
      int order = appModel.nextMappingOrder;
      newMapping = newMapping.copyWith(order: order);

      /// If the name is blank or the mapping exists, error.
      if (name.isEmpty || appModel.mappingNameHasDuplicate(newMapping)) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => AlertDialog(
            title: Text(invalidMappingName),
            content: Text(invalidMappingNameContent),
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
