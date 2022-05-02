import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/drop_down_menu.dart';
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
      shape: const RoundedRectangleBorder(),
      content: buildContent(),
      actions: <Widget>[
        TextButton(
          child: Text(
            appModel.translate('dialog_close'),
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
              appModel.translate('target_language'),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
          DropDownMenu(
            options: appModel.availableLanguages.keys.toList(),
            initialOption: appModel.getTargetLanguageName(),
            optionCallback: appModel.setTargetLanguageName,
            voidCallback: () {
              setState(() {});
            },
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              appModel.translate('app_language'),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
          DropDownMenu(
            options: appModel.getAppLanguageNames(),
            initialOption: appModel.getAppLanguageName(),
            optionCallback: appModel.setAppLanguageName,
            voidCallback: () {
              setState(() {});
            },
          ),
          ListTile(
            dense: true,
            title: Text.rich(
              TextSpan(
                text: '',
                children: <InlineSpan>[
                  WidgetSpan(
                    child: Icon(
                      Icons.info,
                      size: 14.0,
                      color: Colors.lightBlue.shade400,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(width: 8.0),
                  ),
                  TextSpan(
                    text: appModel.translate('localisation_warning'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.lightBlue.shade400,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
