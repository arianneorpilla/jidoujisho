import 'package:chisa/util/center_icon_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_utils.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/drop_down_menu.dart';

class DictionaryDialog extends StatefulWidget {
  const DictionaryDialog({
    Key? key,
    this.manageAllowed = false,
  }) : super(key: key);

  final bool manageAllowed;

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
      actions: (widget.manageAllowed)
          ? <Widget>[
              if (appModel.getDictionaryRecord().isNotEmpty)
                TextButton(
                  child: Text(
                    AppLocalizations.getLocalizedValue(
                        appModel.getAppLanguageName(), "dialog_delete"),
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
                  AppLocalizations.getLocalizedValue(
                      appModel.getAppLanguageName(), "dialog_import"),
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
                  AppLocalizations.getLocalizedValue(
                      appModel.getAppLanguageName(), "dialog_close"),
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
          importedDictionaries.isEmpty
              ? showEmptyMessage()
              : showDictionaryList(),
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
          height: 1.0,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFBDBDBD),
                width: 0.0,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguageName(), "import_format"),
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
        label: AppLocalizations.getLocalizedValue(
            appModel.getAppLanguageName(), "import_dictionaries_for_use"),
        icon: Icons.auto_stories,
        jumpingDots: false,
      ),
    );
  }

  Widget showDictionaryList() {
    String currentDictionary = appModel.getCurrentDictionaryName();
    List<Dictionary> importedDictionaries = appModel.getDictionaryRecord();

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: importedDictionaries.length,
        itemBuilder: (context, index) {
          String dictionaryName = importedDictionaries[index].dictionaryName;

          return ListTile(
            dense: true,
            selected: (currentDictionary == dictionaryName),
            selectedTileColor: Theme.of(context).selectedRowColor,
            title: Row(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 20.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  dictionaryName,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        appModel.getIsDarkMode() ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () async {
              await appModel.setCurrentDictionaryName(dictionaryName);
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(appModel.getCurrentDictionaryName()),
      content: Text(
        AppLocalizations.getLocalizedValue(
            appModel.getAppLanguageName(), "delete_dictionary_confirmation"),
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguageName(), "dialog_yes"),
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
              AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguageName(), "dialog_no"),
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
