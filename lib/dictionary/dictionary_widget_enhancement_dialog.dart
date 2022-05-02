import 'package:chisa/util/marquee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:chisa/util/dictionary_widget_field.dart';

class DictionaryWidgetEnhancementDialog extends StatefulWidget {
  const DictionaryWidgetEnhancementDialog({
    required this.field,
    Key? key,
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
      shape: const RoundedRectangleBorder(),
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
          if (enhancements.isEmpty)
            showEmptyMessage()
          else
            showEnhancementList(enhancements),
        ],
      ),
    );
  }

  Widget showEmptyMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: showCenterIconMessage(
        context: context,
        label: appModel.translate('no_more_available_enhancements'),
        icon: Icons.auto_fix_high,
        jumpingDots: false,
      ),
    );
  }

  Widget showEnhancementList(List<DictionaryWidgetEnhancement> enhancements) {
    return RawScrollbar(
      controller: scrollController,
      thumbColor:
          (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
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
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Marquee(
                      text: enhancement.enhancementName,
                      style: TextStyle(
                        fontSize: 16,
                        color: appModel.getIsDarkMode()
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
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
