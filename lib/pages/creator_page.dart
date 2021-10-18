import 'dart:io';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_enhancement_dialog.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage(
      {Key? key,
      this.initialParams,
      this.editMode = false,
      this.autoMode = false})
      : super(key: key);

  final AnkiExportParams? initialParams;
  final bool editMode;
  final bool autoMode;

  @override
  State<StatefulWidget> createState() => CreatorPageState();
}

class CreatorPageState extends State<CreatorPage> {
  late AnkiExportParams exportParams;
  late AppModel appModel;

  ScrollController scrollController = ScrollController();

  final TextEditingController audioController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();
  final TextEditingController wordController = TextEditingController();
  final TextEditingController readingController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController extraController = TextEditingController();
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<File?> audioNotifier = ValueNotifier<File?>(null);

  TextEditingController getFieldController(AnkiExportField field) {
    switch (field) {
      case AnkiExportField.sentence:
        return sentenceController;
      case AnkiExportField.word:
        return wordController;
      case AnkiExportField.reading:
        return readingController;
      case AnkiExportField.meaning:
        return meaningController;
      case AnkiExportField.extra:
        return extraController;
      case AnkiExportField.image:
        return imageController;
      case AnkiExportField.audio:
        return audioController;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setAndComputeInitialFields();
    });
  }

  Future<void> setAndComputeInitialFields() async {
    if (widget.initialParams == null) {
      exportParams = AnkiExportParams();
    } else {
      exportParams = widget.initialParams!;
    }

    for (AnkiExportField field in AnkiExportField.values) {
      AnkiExportEnhancement? enhancement =
          appModel.getAutoFieldEnhancement(field);
      if (enhancement != null) {
        exportParams = await enhancement.enhanceParams(exportParams);
      }
    }

    setState(() {
      setCurrentParams(exportParams);
    });
  }

  AnkiExportParams getCurrentParams() {
    return AnkiExportParams(
      sentence: sentenceController.text,
      word: wordController.text,
      reading: readingController.text,
      meaning: meaningController.text,
      extra: extraController.text,
      imageFile: imageNotifier.value,
      audioFile: audioNotifier.value,
    );
  }

  void setCurrentParams(AnkiExportParams newParams, {AnkiExportField? field}) {
    exportParams = newParams;

    setState(() {
      if (field == AnkiExportField.image) {
        imageController.text = "";
      }
      if (field == AnkiExportField.audio) {
        audioController.text = "";
      }
      sentenceController.text = exportParams.sentence;
      wordController.text = exportParams.word;
      readingController.text = exportParams.reading;
      meaningController.text = exportParams.meaning;
      extraController.text = exportParams.extra;
      imageNotifier.value = exportParams.imageFile;
      audioNotifier.value = exportParams.audioFile;
    });
  }

  Widget getEmptyBox(
      {required AnkiExportField field,
      required int position,
      required bool autoMode}) {
    return IconButton(
      iconSize: 18,
      color: Theme.of(context).unselectedWidgetColor,
      onPressed: () async {
        AnkiExportEnhancement? enhancement = await showDialog(
          context: context,
          builder: (context) => AnkiExportEnhancementDialog(
            field: field,
            autoMode: autoMode,
          ),
        );

        if (enhancement != null) {
          if (autoMode) {
            await enhancement.setAuto();
          } else {
            await enhancement.setEnabled(field, position);
          }
          setState(() {});
        }
      },
      icon: Icon((widget.autoMode) ? Icons.hdr_auto : Icons.widgets),
    );
  }

  void refresh() {
    setState(() {});
  }

  List<Widget> getFieldEnhancementWidgets(
      {required BuildContext context, required AnkiExportField field}) {
    List<Widget> widgets = [];
    if (widget.autoMode) {
      AnkiExportEnhancement? enhancement =
          appModel.getAutoFieldEnhancement(field);

      if (enhancement == null) {
        widgets.add(
          getEmptyBox(
            field: field,
            position: 0,
            autoMode: true,
          ),
        );
      } else {
        widgets.add(
          enhancement.getButton(
            context: context,
            paramsCallback: getCurrentParams,
            updateCallback: setCurrentParams,
            editMode: widget.editMode,
            autoMode: widget.autoMode,
            position: 0,
          ),
        );
      }
    } else {
      List<AnkiExportEnhancement?> enhancements =
          appModel.getExportEnabledFieldEnhancement(field);

      for (int position = 0; position < enhancements.length; position++) {
        AnkiExportEnhancement? enhancement = enhancements[position];
        if (enhancement == null) {
          if (widget.editMode) {
            widgets.add(
              getEmptyBox(
                field: field,
                position: position,
                autoMode: false,
              ),
            );
          }
        } else {
          widgets.add(
            enhancement.getButton(
              context: context,
              paramsCallback: getCurrentParams,
              updateCallback: setCurrentParams,
              editMode: widget.editMode,
              autoMode: widget.autoMode,
              position: position,
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget displayField({
    required BuildContext context,
    required AnkiExportField field,
    required Function(String) onFieldSubmitted,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return TextFormField(
      readOnly: (widget.editMode || widget.autoMode),
      maxLines: null,
      controller: getFieldController(field),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).focusColor),
        ),
        prefixIcon: Icon(field.icon(appModel)),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: getFieldEnhancementWidgets(context: context, field: field),
        ),
        labelText: field.label(appModel),
        hintText: field.hint(appModel),
      ),
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
    );
  }

  Widget getSeeMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
      child: GestureDetector(
        child: const Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) =>
            showDropDownOptions(context, details.globalPosition),
      ),
    );
  }

  String getTitle() {
    if (widget.editMode) {
      return AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "creator_options_menu");
    } else if (widget.autoMode) {
      return AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "creator_options_auto");
    } else {
      return AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "card_creator");
    }
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!widget.editMode && !widget.autoMode) getSeeMoreButton(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // showImagePreview(),
                      // DropDownMenu(
                      //   options: decks,
                      //   selectedOption: _selectedDeck,
                      //   optionCallback: ,
                      // ),
                      displayField(
                        context: context,
                        field: AnkiExportField.image,
                        onFieldSubmitted: (value) {},
                      ),
                      displayField(
                        context: context,
                        field: AnkiExportField.audio,
                        onFieldSubmitted: (value) {},
                      ),

                      displayField(
                        context: context,
                        field: AnkiExportField.sentence,
                        onFieldSubmitted: (value) {},
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                      displayField(
                        context: context,
                        field: AnkiExportField.word,
                        onFieldSubmitted: (value) {},
                      ),
                      displayField(
                        context: context,
                        field: AnkiExportField.reading,
                        onFieldSubmitted: (value) {},
                      ),
                      displayField(
                        context: context,
                        field: AnkiExportField.meaning,
                        keyboardType: TextInputType.multiline,
                        onFieldSubmitted: (value) {},
                      ),
                      displayField(
                        context: context,
                        field: AnkiExportField.extra,
                        onFieldSubmitted: (value) {},
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //showExportButton(),
        ],
      ),
    );
  }

  void showDropDownOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "creator_options_menu"),
          icon: Icons.widgets,
          action: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const CreatorPage(editMode: true),
                transitionDuration: Duration.zero,
              ),
            );
            setState(() {});
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "creator_options_auto"),
          icon: Icons.hdr_auto,
          action: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const CreatorPage(autoMode: true),
                transitionDuration: Duration.zero,
              ),
            );
            setState(() {});
          },
        ),
      ],
      elevation: 8.0,
    );

    if (callbackAction != null) {
      callbackAction();
    }
  }
}
