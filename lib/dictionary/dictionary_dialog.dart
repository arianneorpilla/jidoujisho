import 'package:daijidoujisho/dictionary/dictionary.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/dictionary/dictionary_utils.dart';
import 'package:daijidoujisho/language/app_localizations.dart';
import 'package:daijidoujisho/models/app_model.dart';
import 'package:daijidoujisho/util/drop_down_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    DictionaryFormat lastDictionaryFormat = appModel.getLastDictionaryFormat();

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
      actions: <Widget>[
        TextButton(
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguage(), "dialog_import"),
          ),
          onPressed: () async {
            await dictionaryFileImport(context, appModel, lastDictionaryFormat);
            //await dictionaryImport(context);
            setState(() {});
          },
        ),
        TextButton(
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguage(), "dialog_close"),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget buildContent() {
    List<String> importedDictionaries = appModel.getImportedDictionaryNames();
    List<String> options = appModel.getDictionaryFormatNames();
    String initialOption = appModel.getLastDictionaryFormatName();

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          importedDictionaries.isEmpty
              ? showEmptyMessage()
              : showDictionaryList(),
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
                  appModel.getAppLanguage(), "import_format"),
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
      ),
    );
  }

  Widget showEmptyMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories,
            size: 36,
            color: Theme.of(context).unselectedWidgetColor,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguage(), "no_available_dictionaries"),
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
              fontSize: 20,
            ),
          ),
        ],
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
            },
          );
        },
      ),
    );
  }
}
