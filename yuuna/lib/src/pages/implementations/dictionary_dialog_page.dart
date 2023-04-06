import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
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
  final ScrollController _scrollController = ScrollController();
  int? _selectedOrder;

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

  Future<void> showDictionaryClearDialog() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.dialog_title_dictionary_clear),
      content: Text(
        t.dialog_content_dictionary_clear,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => const DictionaryDialogDeletePage(),
            );

            await appModel.deleteDictionaries();

            if (mounted) {
              Navigator.pop(context);
            }

            if (mounted) {
              Navigator.pop(context);
            }

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

  Future<void> showDictionaryDeleteDialog(Dictionary dictionary) async {
    Widget alertDialog = AlertDialog(
      title: Text(t.dialog_title_dictionary_delete(name: dictionary.name)),
      content: Text(
        t.dialog_content_dictionary_delete,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_delete,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) =>
                  DictionaryDialogDeletePage(name: dictionary.name),
            );

            await appModel.deleteDictionary(dictionary);

            if (mounted) {
              Navigator.pop(context);
            }

            if (mounted) {
              Navigator.pop(context);
            }

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

  Widget buildImportButton() {
    return TextButton(
      child: Text(t.dialog_import),
      onPressed: () async {
        /// A [ValueNotifier] that will update a message based on the progress of
        /// the ongoing dictionary file import. See [DictionaryImportProgressPage].
        ValueNotifier<String> progressNotifier =
            ValueNotifier<String>(t.import_start);
        ValueNotifier<int?> countNotifier = ValueNotifier<int?>(null);
        ValueNotifier<int?> totalNotifier = ValueNotifier<int?>(null);
        progressNotifier.addListener(() {
          debugPrint('[Dictionary Import] ${progressNotifier.value}');
        });

        await FilePicker.platform.clearTemporaryFiles();

        FileType type = appModel.lastSelectedDictionaryFormat.fileType;
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          /// Change when adding multiple dictionary formats.
          type: type,
          allowedExtensions: type == FileType.any
              ? null
              : appModel.lastSelectedDictionaryFormat.allowedExtensions,
          allowMultiple: true,
          onFileLoading: (status) {
            if (status == FilePickerStatus.done) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => DictionaryDialogImportPage(
                  progressNotifier: progressNotifier,
                  countNotifier: countNotifier,
                  totalNotifier: totalNotifier,
                ),
              );
            }
          },
        );
        if (result == null) {
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }

        totalNotifier.value = result.files.length;
        for (int i = 0; i < result.files.length; i++) {
          countNotifier.value = i + 1;

          PlatformFile platformFile = result.files[i];
          File file = File(platformFile.path!);

          await appModel.importDictionary(
            progressNotifier: progressNotifier,
            file: file,
            onImportSuccess: () {
              _selectedOrder = appModel.dictionaries.last.order;
              setState(() {});
            },
          );
        }

        await FilePicker.platform.clearTemporaryFiles();

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildClearButton() {
    return TextButton(
      child: Text(
        t.dialog_clear,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: showDictionaryClearDialog,
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
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
        message: t.dictionaries_menu_empty,
      ),
    );
  }

  Map<Dictionary, ValueNotifier<bool>> _notifiersByDictionary = {};

  Widget buildDictionaryList(List<Dictionary> dictionaries) {
    _notifiersByDictionary = {};
    _selectedOrder ??= dictionaries.firstOrNull?.order;

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ReorderableColumn(
        scrollController: _scrollController,
        children: List.generate(dictionaries.length, (index) {
          Dictionary dictionary = dictionaries[index];

          _notifiersByDictionary.putIfAbsent(
            dictionaries[index],
            () => ValueNotifier<bool>(dictionary.order == _selectedOrder),
          );
          return buildDictionaryTile(
            dictionaries[index],
            _notifiersByDictionary[dictionary]!,
          );
        }),
        onReorder: (oldIndex, newIndex) {
          List<Dictionary> cloneDictionaries = [];
          cloneDictionaries.addAll(dictionaries);

          Dictionary item = cloneDictionaries[oldIndex];
          cloneDictionaries.remove(item);
          cloneDictionaries.insert(newIndex, item);

          cloneDictionaries.forEachIndexed((index, dictionary) {
            dictionary.order = index;
          });

          _selectedOrder = newIndex;

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
    if (dictionary.isHidden(appModel.targetLanguage)) {
      return Icon(
        Icons.visibility_off,
        size: textTheme.titleLarge?.fontSize,
        color: theme.unselectedWidgetColor,
      );
    } else if (dictionary.isCollapsed(appModel.targetLanguage)) {
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

  Widget buildDictionaryTile(
    Dictionary dictionary,
    ValueNotifier<bool> notifier,
  ) {
    DictionaryFormat dictionaryFormat =
        appModel.dictionaryFormats[dictionary.formatKey]!;

    return ValueListenableBuilder<bool>(
      key: ValueKey(dictionary.name),
      valueListenable: notifier,
      builder: (context, value, _) {
        return Material(
          type: MaterialType.transparency,
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
                          color: dictionary.isHidden(appModel.targetLanguage)
                              ? theme.unselectedWidgetColor
                              : null,
                        ),
                      ),
                      JidoujishoMarquee(
                        text: dictionaryFormat.name,
                        style: TextStyle(
                          fontSize: textTheme.bodySmall?.fontSize,
                          color: dictionary.isHidden(appModel.targetLanguage)
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
              _selectedOrder = dictionary.order;

              for (int i = 0; i < _notifiersByDictionary.length; i++) {
                _notifiersByDictionary.entries.elementAt(i).value.value = false;
              }
              notifier.value = true;
            },
          ),
        );
      },
    );
  }

  Widget buildDictionaryTileTrailing(Dictionary dictionary) {
    return JidoujishoIconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icons.more_vert,
      onTapDown: (details) =>
          openDictionaryOptionsMenu(details: details, dictionary: dictionary),
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
        label: dictionary.isCollapsed(appModel.targetLanguage)
            ? t.options_expand
            : t.options_collapse,
        icon: dictionary.isCollapsed(appModel.targetLanguage)
            ? Icons.open_in_full
            : Icons.close_fullscreen,
        action: () {
          appModel.toggleDictionaryCollapsed(dictionary);
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
        },
      ),
      buildPopupItem(
        label: dictionary.isHidden(appModel.targetLanguage)
            ? t.options_show
            : t.options_hide,
        icon: dictionary.isCollapsed(appModel.targetLanguage)
            ? Icons.visibility
            : Icons.visibility_off,
        action: () {
          appModel.toggleDictionaryHidden(dictionary);
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
        },
      ),
      buildPopupItem(
        label: t.options_delete,
        icon: Icons.delete,
        action: () {
          showDictionaryDeleteDialog(dictionary);
        },
        color: theme.colorScheme.primary,
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
            t.import_format,
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

    return Row(
      children: [
        Expanded(child: Text(t.use_slow_import)),
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
