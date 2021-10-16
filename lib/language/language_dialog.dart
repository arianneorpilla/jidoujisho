import 'package:chisachan/language/app_localizations.dart';
import 'package:chisachan/models/app_model.dart';
import 'package:chisachan/util/drop_down_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LanguageDialogState();
}

class LanguageDialogState extends State<LanguageDialog> {
  ScrollController scrollController = ScrollController();

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
      actions: <Widget>[
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
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguage(), "target_language"),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
          DropDownMenu(
            options: appModel.availableLanguages
                .map((language) => language.languageName)
                .toList(),
            initialOption: appModel.getTargetLanguage(),
            optionCallback: appModel.setTargetLanguage,
            voidCallback: () {
              setState(() {});
            },
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguage(), "app_language"),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
          DropDownMenu(
            options: AppLocalizations.localizations(),
            initialOption: appModel.getAppLanguage(),
            optionCallback: appModel.setAppLanguage,
            voidCallback: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
