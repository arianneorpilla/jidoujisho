import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/models/app_model.dart';

class AnkiExportEnhancementDialog extends StatefulWidget {
  const AnkiExportEnhancementDialog({
    Key? key,
    required this.field,
    required this.autoMode,
  }) : super(key: key);

  final AnkiExportField field;
  final bool autoMode;

  @override
  State<StatefulWidget> createState() => AnkiExportEnhancementDialogState();
}

class AnkiExportEnhancementDialogState
    extends State<AnkiExportEnhancementDialog> {
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
    List<AnkiExportEnhancement> enhancements =
        appModel.getFieldEnhancements(widget.field);

    List<AnkiExportEnhancement?> existings =
        appModel.getExportEnabledFieldEnhancement(widget.field);
    for (AnkiExportEnhancement? existing in existings) {
      if (existing != null && !widget.autoMode) {
        enhancements.remove(existing);
      }
    }

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

  Widget showEnhancementList(List<AnkiExportEnhancement> enhancements) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: enhancements.length,
        itemBuilder: (context, index) {
          AnkiExportEnhancement enhancement = enhancements[index];

          return ListTile(
            dense: true,
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

              setState(() {});
            },
          );
        },
      ),
    );
  }
}
