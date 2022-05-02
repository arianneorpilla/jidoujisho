import 'package:chisa/util/center_icon_message.dart';
import 'package:chisa/util/marquee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_import.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/drop_down_menu.dart';

class DictionaryDialog extends StatefulWidget {
  const DictionaryDialog({
    Key? key,
    this.manageAllowed = false,
    this.onDictionaryChange,
  }) : super(key: key);

  final bool manageAllowed;
  final Function()? onDictionaryChange;

  @override
  State<StatefulWidget> createState() => DictionaryDialogState();
}

class DictionaryDialogState extends State<DictionaryDialog> {
  ScrollController scrollController = ScrollController();

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    DictionaryFormat lastDictionaryFormat = appModel
        .getDictionaryFormatFromName(appModel.getLastDictionaryFormatName());

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      shape: const RoundedRectangleBorder(),
      content: buildContent(),
      actions: (widget.manageAllowed)
          ? <Widget>[
              if (appModel.getCurrentDictionary() != null)
                TextButton(
                  child: Text(
                    appModel.translate('dialog_remove'),
                    style: TextStyle(
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                  onPressed: () async {
                    showDictionaryDeleteDialog(context);
                  },
                ),
              TextButton(
                child: Text(
                  appModel.translate('dialog_import'),
                ),
                onPressed: () async {
                  await dictionaryFileImport(
                      context, appModel, lastDictionaryFormat);
                  //await dictionaryImport(context);
                  setState(() {});
                },
              ),
              TextButton(
                child: Text(
                  appModel.translate('dialog_close'),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]
          : [],
    );
  }

  Widget buildContent() {
    List<String> importedDictionaries = appModel.getImportedDictionaryNames();

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (importedDictionaries.isEmpty)
            showEmptyMessage()
          else
            showDictionaryList(),
          if (widget.manageAllowed) showFormatSelection(),
        ],
      ),
    );
  }

  Widget showFormatSelection() {
    List<String> options = appModel.getDictionaryFormatNames();
    String initialOption = appModel.getLastDictionaryFormatName();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 1,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(
                width: 0.5,
                color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            appModel.translate('import_format'),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
        ),
        DropDownMenu(
          options: options,
          initialOption: initialOption,
          optionCallback: appModel.setLastDictionaryFormatName,
          voidCallback: () {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget showEmptyMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: showCenterIconMessage(
        context: context,
        label: appModel.translate('import_dictionaries_for_use'),
        icon: Icons.auto_stories,
        jumpingDots: false,
      ),
    );
  }

  Widget showDictionaryList() {
    String currentDictionaryName = appModel.getCurrentDictionaryName();
    List<Dictionary> importedDictionaries = appModel.getDictionaryRecord();

    return RawScrollbar(
      controller: scrollController,
      thumbColor:
          (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: importedDictionaries.length,
        itemBuilder: (context, index) {
          Dictionary dictionary = importedDictionaries[index];

          return ListTile(
            dense: true,
            selected: currentDictionaryName == dictionary.dictionaryName,
            selectedTileColor: Theme.of(context).selectedRowColor,
            title: Row(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Marquee(
                      text: dictionary.dictionaryName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
                if (widget.manageAllowed &&
                    importedDictionaries.length >= 2 &&
                    currentDictionaryName == dictionary.dictionaryName)
                  IconButton(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      constraints: const BoxConstraints(),
                      iconSize: 18,
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        appModel.moveDictionaryUp(dictionary);
                        setState(() {});
                      }),
                if (widget.manageAllowed &&
                    importedDictionaries.length >= 2 &&
                    currentDictionaryName == dictionary.dictionaryName)
                  IconButton(
                      padding: const EdgeInsets.only(left: 16),
                      constraints: const BoxConstraints(),
                      iconSize: 18,
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        appModel.moveDictionaryDown(dictionary);
                        setState(() {});
                      }),
              ],
            ),
            onTap: () async {
              await appModel
                  .setCurrentDictionaryName(dictionary.dictionaryName);
              if (widget.onDictionaryChange != null) {
                widget.onDictionaryChange?.call();
              }

              if (!widget.manageAllowed) {
                Navigator.pop(context);
              }
              setState(() {});
            },
          );
        },
      ),
    );
  }

  void showDictionaryDeleteDialog(BuildContext context) {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(appModel.getCurrentDictionaryName()),
      content: Text(
        appModel.translate('remove_dictionary_confirmation'),
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              appModel.translate('dialog_yes'),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () async {
              await appModel.deleteCurrentDictionary();
              Navigator.pop(context);
              setState(() {});
            }),
        TextButton(
            child: Text(
              appModel.translate('dialog_no'),
            ),
            onPressed: () => Navigator.pop(context)),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}
