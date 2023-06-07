import 'package:change_notifier_builder/change_notifier_builder.dart';
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

class _ProfilesDialogPageState extends BasePageState<ProfilesDialogPage>
    with ChangeNotifier {
  final ScrollController _scrollController = ScrollController();
  int? _selectedOrder;

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
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
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
    ScrollController contentController = ScrollController();
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: contentController,
        child: Padding(
          padding: contentController.hasClients
              ? Spacing.of(context).insets.onlyRight.normal
              : EdgeInsets.zero,
          child: SingleChildScrollView(
            controller: contentController,
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
          ),
        ),
      ),
    );
  }

  Map<AnkiMapping, ValueNotifier<bool>> _notifiersByMapping = {};
  Widget buildMappingList() {
    List<AnkiMapping> mappings = appModel.mappings;
    _selectedOrder = appModel.lastSelectedMapping.order;

    _notifiersByMapping = {};

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ReorderableColumn(
        scrollController: _scrollController,
        children: List.generate(
          mappings.length,
          (index) {
            AnkiMapping mapping = mappings[index];

            _notifiersByMapping.putIfAbsent(
              mapping,
              () => ValueNotifier<bool>(mapping.order == _selectedOrder),
            );

            return buildMappingTile(
              mapping,
              _notifiersByMapping[mapping]!,
            );
          },
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

  Widget buildMappingTile(
    AnkiMapping mapping,
    ValueNotifier<bool> notifier,
  ) {
    return ValueListenableBuilder<bool>(
      key: ValueKey(mapping.label),
      valueListenable: notifier,
      builder: (context, value, _) {
        return Material(
          type: MaterialType.transparency,
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
                        style:
                            TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                      ),
                      JidoujishoMarquee(
                        text: mapping.model,
                        style:
                            TextStyle(fontSize: textTheme.bodySmall?.fontSize),
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
              _selectedOrder = mapping.order;
              appModel.setLastSelectedMapping(mapping, notify: false);

              for (int i = 0; i < _notifiersByMapping.length; i++) {
                _notifiersByMapping.entries.elementAt(i).value.value = false;
              }
              notifier.value = true;

              await appModel.validateSelectedMapping(
                context: context,
                mapping: mapping,
              );
            },
          ),
        );
      },
    );
  }

  Widget buildMappingTileTrailing(String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<VoidCallback>(
          splashRadius: 20,
          padding: EdgeInsets.zero,
          tooltip: t.show_options,
          color: Theme.of(context).popupMenuTheme.color,
          onSelected: (value) => value(),
          itemBuilder: (context) => getMenuItems(label),
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: Icon(
              Icons.more_vert,
              color: theme.iconTheme.color,
              size: 24,
            ),
          ),
        ),
      ),
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

  final _modelNotifier = ChangeNotifier();

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
        ChangeNotifierBuilder(
          notifier: _modelNotifier,
          builder: (_, __, ___) => JidoujishoDropdown<String>(
            options: widget.models,
            initialOption: widget.initialModel,
            generateLabel: (modelName) => modelName,
            onChanged: (modelName) {
              appModel.setLastSelectedModelName(modelName!);
              _modelNotifier.notifyListeners();
            },
          ),
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
        child: Padding(
          padding: Spacing.of(context).insets.onlyRight.normal,
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
      ),
    );
  }

  Widget buildWrapImageAudio({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(mappingClone.exportMediaTags ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.wrap_image_audio)),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.exportMediaTags = value;
                notifier.value = value;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildUseBrTags({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(mappingClone.useBrTags ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.use_br_tags)),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.useBrTags = value;
                notifier.value = value;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildPrependDictionaryNames({required AnkiMapping mappingClone}) {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(mappingClone.prependDictionaryNames ?? false);

    return Row(
      children: [
        Expanded(child: Text(t.prepend_dictionary_names)),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                mappingClone.prependDictionaryNames = value;
                notifier.value = value;
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
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
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
    final mediaQuery = MediaQuery.of(context);
    final spacing = Spacing.of(context);
    List<String> modelFields = await appModel.getFieldList(mapping.model);

    Widget alertDialog = AlertDialog(
      contentPadding: mediaQuery.orientation == Orientation.portrait
          ? spacing.insets.exceptBottom.big
          : spacing.insets.exceptBottom.normal.copyWith(
              left: spacing.spaces.semiBig,
              right: spacing.spaces.semiBig,
            ),
      actionsPadding: spacing.insets.exceptBottom.normal.copyWith(
        left: spacing.spaces.normal,
        right: spacing.spaces.normal,
        bottom: spacing.spaces.normal,
        top: spacing.spaces.extraSmall,
      ),
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
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => alertDialog,
      );
    }
  }

  Future<void> addNewMapping(
      {required String name, required AnkiMapping mapping}) async {
    /// Assign the name to the mapping.
    AnkiMapping newMapping = mapping.copyWith(
      label: name,
      tags: [mapping.model],
    );

    final navigator = Navigator.of(context);

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
    navigator.pop();

    setState(() {});
  }
}
