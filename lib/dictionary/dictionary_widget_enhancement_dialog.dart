import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:chisa/util/dictionary_widget_field.dart';

class DictionaryWidgetEnhancementDialog extends StatefulWidget {
  const DictionaryWidgetEnhancementDialog({
    Key? key,
    required this.field,
  }) : super(key: key);

  final DictionaryWidgetField field;
  @override
  State<StatefulWidget> createState() => AnkiExportEnhancementDialogState();
}

class AnkiExportEnhancementDialogState
    extends State<DictionaryWidgetEnhancementDialog> {
  ScrollController scrollController = ScrollController();

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
    );
  }

  Widget buildContent() {
    List<DictionaryWidgetEnhancement> enhancements =
        appModel.getFieldWidgetEnhancements(widget.field);

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          enhancements.isEmpty
              ? showEmptyMessage()
              : showEnhancementList(enhancements),
        ],
      ),
    );
  }

  Widget showEmptyMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: showCenterIconMessage(
        context: context,
        label: AppLocalizations.getLocalizedValue(
            appModel.getAppLanguageName(), "no_more_available_enhancements"),
        icon: Icons.auto_fix_high,
        jumpingDots: false,
      ),
    );
  }

  Widget showEnhancementList(List<DictionaryWidgetEnhancement> enhancements) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: enhancements.length,
        itemBuilder: (context, index) {
          DictionaryWidgetEnhancement enhancement = enhancements[index];

          return ListTile(
            dense: true,
            selected: (enhancement ==
                (appModel.getFieldWidgetEnhancement(widget.field))),
            selectedTileColor: Theme.of(context).selectedRowColor,
            title: Row(
              children: [
                Icon(
                  enhancement.enhancementIcon,
                  size: 20.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  enhancement.enhancementName,
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
              Navigator.pop(context, enhancement);
            },
          );
        },
      ),
    );
  }
}
