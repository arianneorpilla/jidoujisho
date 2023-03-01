import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// The content of the dialog used for managing dictionaries.
class DictionaryDialogPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  String get importFormatLabel => appModel.translate('import_format');
  String get dictionaryMenuEmptyLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get showOptionsLabel => appModel.translate('show_options');
  String get dictionaryCollapseLabel => appModel.translate('options_collapse');
  String get dictionaryExpandLabel => appModel.translate('options_expand');
  String get dictionaryDeleteLabel => appModel.translate('options_delete');
  String get dictionaryShowLabel => appModel.translate('options_show');
  String get dictionaryHideLabel => appModel.translate('options_hide');
  String get dialogImportLabel => appModel.translate('dialog_import');
  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get dialogDeleteLabel => appModel.translate('dialog_delete');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get dialogClearLabel => appModel.translate('dialog_clear');

  final ScrollController _scrollController = ScrollController();
  int _selectedOrder = 0;

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
        buildClearButton(),
        buildImportButton(),
        buildCloseButton(),
      ];

  Future<void> showDictionaryDeleteDialog() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.dialog_title_dictionary_clear),
      content: Text(
        t.dialog_content_dictionary_clear,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            dialogDeleteLabel,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            await appModel.deleteDictionaries();
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

  Widget buildImportButton() {
    return TextButton(
      child: Text(dialogImportLabel),
      onPressed: () async {
        await FilePicker.platform.clearTemporaryFiles();

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          /// Change when adding multiple dictionary formats.
          type: appModel.lastSelectedDictionaryFormat.fileType,
          allowedExtensions:
              appModel.lastSelectedDictionaryFormat.allowedExtensions,
          allowMultiple: true,
        );
        if (result == null) {
          return;
        }

        for (int i = 0; i < result.files.length; i++) {
          PlatformFile platformFile = result.files[i];
          File file = File(platformFile.path!);
          await appModel.importDictionary(
            file: file,
            currentCount: i + 1,
            totalCount: result.files.length,
            onImportSuccess: () {
              _selectedOrder = appModel.dictionaries.length - 1;
              setState(() {});
            },
          );
        }

        await FilePicker.platform.clearTemporaryFiles();
      },
    );
  }

  Widget buildClearButton() {
    return TextButton(
      child: Text(
        dialogClearLabel,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: showDictionaryDeleteDialog,
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
    List<Dictionary> dictionaries = appModel.dictionaries;
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
              if (dictionaries.isEmpty)
                buildEmptyMessage()
              else
                Flexible(
                  child: buildDictionaryList(dictionaries),
                ),
              const JidoujishoDivider(),
              buildImportDropdown(),
              buildSlowImportSwitch(),
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
        icon: DictionaryMediaType.instance.outlinedIcon,
        message: dictionaryMenuEmptyLabel,
      ),
    );
  }

  Widget buildDictionaryList(List<Dictionary> dictionaries) {
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ReorderableColumn(
        scrollController: _scrollController,
        children: List.generate(
          dictionaries.length,
          (index) => buildDictionaryTile(dictionaries[index]),
        ),
        onReorder: (oldIndex, newIndex) {
          List<Dictionary> cloneDictionaries = [];
          cloneDictionaries.addAll(dictionaries);

          Dictionary item = cloneDictionaries[oldIndex];
          cloneDictionaries.remove(item);
          cloneDictionaries.insert(newIndex, item);

          cloneDictionaries.forEachIndexed((index, dictionary) {
            dictionary.order = index;
          });

          updateSelectedOrder(newIndex);

          appModel.updateDictionaryOrder(cloneDictionaries);
          setState(() {});
        },
      ),
    );
  }

  Icon getIcon({
    required Dictionary dictionary,
    required DictionaryFormat dictionaryFormat,
  }) {
    if (dictionary.hidden) {
      return Icon(
        Icons.visibility_off,
        size: textTheme.titleLarge?.fontSize,
        color: theme.unselectedWidgetColor,
      );
    } else if (dictionary.collapsed) {
      return Icon(
        Icons.close_fullscreen,
        size: textTheme.titleLarge?.fontSize,
        color: theme.unselectedWidgetColor,
      );
    } else {
      return Icon(
        dictionaryFormat.icon,
        size: textTheme.titleLarge?.fontSize,
      );
    }
  }

  Widget buildDictionaryTile(Dictionary dictionary) {
    DictionaryFormat dictionaryFormat =
        appModel.dictionaryFormats[dictionary.formatKey]!;

    return Material(
      type: MaterialType.transparency,
      key: ValueKey(dictionary.name),
      child: ListTile(
        selected: _selectedOrder == dictionary.order,
        leading: getIcon(
          dictionary: dictionary,
          dictionaryFormat: dictionaryFormat,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  JidoujishoMarquee(
                    text: dictionary.name,
                    style: TextStyle(
                      fontSize: textTheme.bodyMedium?.fontSize,
                      color: dictionary.hidden
                          ? theme.unselectedWidgetColor
                          : null,
                    ),
                  ),
                  JidoujishoMarquee(
                    text: dictionaryFormat.name,
                    style: TextStyle(
                      fontSize: textTheme.bodySmall?.fontSize,
                      color: dictionary.hidden
                          ? theme.unselectedWidgetColor
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedOrder == dictionary.order) const Space.normal(),
            if (_selectedOrder == dictionary.order)
              buildDictionaryTileTrailing(dictionary)
          ],
        ),
        onTap: () {
          updateSelectedOrder(dictionary.order);
        },
      ),
    );
  }

  Widget buildDictionaryTileTrailing(Dictionary dictionary) {
    return JidoujishoIconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icons.more_vert,
      onTapDown: (details) =>
          openDictionaryOptionsMenu(details: details, dictionary: dictionary),
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

  void openDictionaryOptionsMenu(
      {required TapDownDetails details, required Dictionary dictionary}) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(dictionary),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems(Dictionary dictionary) {
    return [
      buildPopupItem(
        label: dictionary.collapsed
            ? dictionaryExpandLabel
            : dictionaryCollapseLabel,
        icon:
            dictionary.collapsed ? Icons.open_in_full : Icons.close_fullscreen,
        action: () {
          appModel.toggleDictionaryCollapsed(dictionary);
          setState(() {});
        },
      ),
      buildPopupItem(
        label: dictionary.hidden ? dictionaryShowLabel : dictionaryHideLabel,
        icon: dictionary.collapsed ? Icons.visibility : Icons.visibility_off,
        action: () {
          appModel.toggleDictionaryHidden(dictionary);
          setState(() {});
        },
      ),
    ];
  }

  Widget buildImportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Spacing.of(context).insets.onlyLeft.small,
          child: Text(
            importFormatLabel,
            style: TextStyle(
              fontSize: 10,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        JidoujishoDropdown<DictionaryFormat>(
          options: appModel.dictionaryFormats.values.toList(),
          initialOption: appModel.lastSelectedDictionaryFormat,
          generateLabel: (format) => format.name,
          onChanged: (format) {
            appModel.setLastSelectedDictionaryFormat(format!);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget buildSlowImportSwitch() {
    ValueNotifier<bool> _notifier = ValueNotifier<bool>(appModel.useSlowImport);
    String label = appModel.translate('use_slow_import');

    return Row(
      children: [
        Expanded(child: Text(label)),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.toggleSlowImport();
                _notifier.value = appModel.useSlowImport;
              },
            );
          },
        )
      ],
    );
  }
}
