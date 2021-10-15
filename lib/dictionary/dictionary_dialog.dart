import 'package:daijidoujisho/dictionary/dictionary_format.dart';
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

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
      actions: <Widget>[
        TextButton(
          child: const Text('IMPORT'),
          onPressed: () async {
            //await dictionaryImport(context);
            setState(() {});
          },
        ),
        TextButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget buildContent() {
    List<String> importedDictionaries = appModel.getImportedDictionaries();
    List<DictionaryFormat> dictionaryFormats =
        appModel.availableDictionaryFormats;

    List<String> options =
        dictionaryFormats.map((format) => format.formatName).toList();
    String initialOption = appModel.getLastDictionaryFormat();

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          importedDictionaries.isEmpty
              ? showEmptyMessage()
              : showDictionaryList(),
          Divider(
            color: Theme.of(context).unselectedWidgetColor,
          ),
          DropDownMenu(
            options: options,
            initialOption: initialOption,
            callback: appModel.setLastDictionaryFormat,
          ),
        ],
      ),
    );
  }

  Widget showEmptyMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
            "No imported dictionaries",
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
    String currentDictionary = appModel.getCurrentDictionary();
    List<String> importedDictionaries = appModel.getImportedDictionaries();

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: importedDictionaries.length,
        itemBuilder: (context, index) {
          String dictionaryName = importedDictionaries[index];

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
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () async {
              await appModel.setCurrentDictionary(dictionaryName);
              if (!widget.manageAllowed) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }

  Widget showFormatList() {
    List<DictionaryFormat> dictionaryFormats = [];

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: dictionaryFormats.length,
        itemBuilder: (context, index) {
          DictionaryFormat dictionaryFormat = dictionaryFormats[index];

          return ListTile(
            dense: true,
            title: Row(
              children: [
                Icon(
                  dictionaryFormat.formatIcon,
                  size: 20.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  dictionaryFormat.formatName,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () async {
              // await appModel.setCurrentDictionary(dictionaryName);
              // if (!widget.manageAllowed) {
              //   Navigator.pop(context);
              // }
            },
          );
        },
      ),
    );
  }
}
