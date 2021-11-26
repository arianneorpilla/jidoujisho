import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_enhancement_dialog.dart';
import 'package:chisa/anki/anki_export_params.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/drop_down_menu.dart';
import 'package:chisa/util/image_select_widget.dart';
import 'package:chisa/util/popup_item.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({
    Key? key,
    this.initialParams,
    this.editMode = false,
    this.autoMode = false,
    this.backgroundColor,
    this.appBarColor,
    this.popOnExport = false,
    this.hideActions = false,
    this.exportCallback,
    required this.decks,
  }) : super(key: key);

  final AnkiExportParams? initialParams;
  final bool editMode;
  final bool autoMode;
  final Color? backgroundColor;
  final Color? appBarColor;
  final bool popOnExport;
  final bool hideActions;
  final List<String> decks;
  final Function()? exportCallback;

  @override
  State<StatefulWidget> createState() => CreatorPageState();
}

class CreatorPageState extends State<CreatorPage> {
  AnkiExportParams exportParams = AnkiExportParams();
  late AppModel appModel;

  ScrollController scrollController = ScrollController();

  final TextEditingController audioController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();
  final TextEditingController wordController = TextEditingController();
  final TextEditingController readingController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController extraController = TextEditingController();
  final ValueNotifier<List<NetworkToFileImage>> imagesNotifier =
      ValueNotifier<List<NetworkToFileImage>>(const []);
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<File?> audioNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<bool> imageSearchingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<String> imageSearchTermNotifier =
      ValueNotifier<String>("");
  final ValueNotifier<int> imageListNotifier = ValueNotifier<int>(0);

  AudioPlayer audioPlayer = AudioPlayer();

  final ValueNotifier<Duration> positionNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> durationNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<PlayerState> playerStateNotifier =
      ValueNotifier<PlayerState>(PlayerState.PAUSED);
  final ValueNotifier<bool> canExportNotifier = ValueNotifier<bool>(false);

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

  void checkForButtonRefresh() {
    canExportNotifier.value = exportParams != AnkiExportParams();
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialParams != null) {
      setCurrentParams(widget.initialParams!);
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await setAndComputeInitialFields();
      checkForButtonRefresh();
      exportParams.addListener(checkForButtonRefresh);
    });

    audioPlayer.onDurationChanged.listen((duration) {
      durationNotifier.value = duration;
    });
    audioPlayer.onAudioPositionChanged.listen((duration) {
      positionNotifier.value = duration;
    });
    audioPlayer.onPlayerStateChanged.listen((playerState) {
      playerStateNotifier.value = playerState;
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.release();
    super.dispose();
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
        exportParams = await enhancement.enhanceParams(
          context: context,
          appModel: appModel,
          params: exportParams,
          autoMode: true,
          state: this,
        );
      }
    }

    setCurrentParams(exportParams);
  }

  AnkiExportParams getCurrentParams() {
    return exportParams;
  }

  void setCurrentParams(AnkiExportParams newParams, {AnkiExportField? field}) {
    exportParams.setAllValues(newParams);

    setState(() {
      sentenceController.text = exportParams.sentence;
      wordController.text = exportParams.word;
      readingController.text = exportParams.reading;
      meaningController.text = exportParams.meaning;
      extraController.text = exportParams.extra;
      imageController.text = exportParams.imageSearch;
      audioController.text = exportParams.audioSearch;
      imagesNotifier.value = exportParams.imageFiles;
      imageNotifier.value = exportParams.imageFile;
      audioNotifier.value = exportParams.audioFile;

      if (audioNotifier.value != null) {
        audioPlayer.setUrl(audioNotifier.value!.path, isLocal: true).then((_) {
          audioPlayer.getDuration().then((milliseconds) {
            positionNotifier.value = Duration.zero;
            durationNotifier.value = Duration(milliseconds: milliseconds);
          });
        });
      }
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
            state: this,
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
              state: this,
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
    required Function(String) onChanged,
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
      onChanged: onChanged,
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
      return appModel.translate("creator_options_menu");
    } else if (widget.autoMode) {
      return appModel.translate("creator_options_auto");
    } else {
      return appModel.translate("card_creator");
    }
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar:
          ((imagesNotifier.value.isNotEmpty || imageSearchingNotifier.value) &&
              orientation == Orientation.landscape),
      appBar: ((imagesNotifier.value.isNotEmpty ||
                  imageSearchingNotifier.value) &&
              orientation == Orientation.landscape)
          ? null
          : AppBar(
              backgroundColor: widget.appBarColor,
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
                if (!widget.editMode && !widget.autoMode && !widget.hideActions)
                  getSeeMoreButton(context),
              ],
            ),
      body: Stack(
        children: [
          if (widget.backgroundColor != null)
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: buildFields(),
          ),
        ],
      ),
    );
  }

  Widget buildFields() {
    Orientation orientation = MediaQuery.of(context).orientation;
    if ((imagesNotifier.value.isNotEmpty || imageSearchingNotifier.value) &&
        orientation == Orientation.landscape) {
      return buildLandscapeFields();
    } else {
      return buildPortraitFields();
    }
  }

  Widget buildAudioPlayer() {
    return Row(
      children: [
        buildPlayButton(),
        buildDurationAndPosition(),
        buildSlider(),
      ],
    );
  }

  Widget buildExportButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
        child: ValueListenableBuilder<bool>(
            valueListenable: canExportNotifier,
            builder: (context, bool canExport, _) {
              return InkWell(
                child: Container(
                  color: (canExport)
                      ? Theme.of(context).unselectedWidgetColor.withOpacity(0.1)
                      : Theme.of(context)
                          .unselectedWidgetColor
                          .withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 16,
                          color: (canExport)
                              ? null
                              : Theme.of(context).unselectedWidgetColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          appModel.translate("export_card"),
                          style: TextStyle(
                            fontSize: 16,
                            color: (canExport)
                                ? null
                                : Theme.of(context).unselectedWidgetColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: (canExport)
                    ? () async {
                        if (exportParams != AnkiExportParams()) {
                          await addNote(
                            deck: appModel.getLastAnkiDroidDeck(),
                            params: exportParams,
                          );

                          if (widget.exportCallback != null) {
                            widget.exportCallback!();
                          } else {
                            setCurrentParams(AnkiExportParams());
                            setState(() {});

                            Fluttertoast.showToast(
                              msg:
                                  "${appModel.translate("deck_label_before")}『${appModel.getLastAnkiDroidDeck()}』${appModel.translate("deck_label_after")}",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              fontSize: 16.0,
                            );
                          }
                        }
                      }
                    : null,
              );
            }),
      ),
    );
  }

  Widget buildLandscapeFields() {
    ScrollController scrollerImage = ScrollController();
    ScrollController scrollerText = ScrollController();
    return SafeArea(
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  backgroundColor: widget.appBarColor,
                  title: Text(
                    getTitle(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RawScrollbar(
                      controller: scrollerImage,
                      thumbColor: (appModel.getIsDarkMode())
                          ? Colors.grey[700]
                          : Colors.grey[400],
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        controller: scrollerImage,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (imagesNotifier.value.isNotEmpty ||
                                  imageSearchingNotifier.value)
                                ImageSelectWidget(
                                  appModel: appModel,
                                  imageSearchingNotifier:
                                      imageSearchingNotifier,
                                  imageListNotifier: imageListNotifier,
                                  imageSearchTermNotifier:
                                      imageSearchTermNotifier,
                                  fileNotifier: imageNotifier,
                                  filesNotifier: imagesNotifier,
                                ),
                              if (audioNotifier.value != null)
                                buildAudioPlayer(),
                              if (!widget.autoMode && !widget.editMode)
                                buildDeckDropDown(),
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: RawScrollbar(
                controller: scrollerText,
                thumbColor: (appModel.getIsDarkMode())
                    ? Colors.grey[700]
                    : Colors.grey[400],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: scrollController,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              displayField(
                                context: context,
                                field: AnkiExportField.sentence,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setSentence(value);
                                },
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.word,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setWord(value);
                                },
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.reading,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setReading(value);
                                },
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.meaning,
                                keyboardType: TextInputType.multiline,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setMeaning(value);
                                },
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.image,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setImageSearch(value);
                                },
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.audio,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setAudioSearch(value);
                                },
                              ),
                              displayField(
                                context: context,
                                field: AnkiExportField.extra,
                                onFieldSubmitted: (value) {},
                                onChanged: (value) {
                                  exportParams.setExtra(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    buildExportButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeckDropDown() {
    return DropDownMenu(
      options: widget.decks,
      initialOption: appModel.getLastAnkiDroidDeck(),
      optionCallback: appModel.setLastAnkiDroidDeck,
      voidCallback: () {
        setState(() {});
      },
    );
  }

  Widget buildPortraitFields() {
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (imagesNotifier.value.isNotEmpty ||
                      imageSearchingNotifier.value)
                    ImageSelectWidget(
                      appModel: appModel,
                      imageSearchingNotifier: imageSearchingNotifier,
                      imageSearchTermNotifier: imageSearchTermNotifier,
                      imageListNotifier: imageListNotifier,
                      fileNotifier: imageNotifier,
                      filesNotifier: imagesNotifier,
                    ),
                  if (audioNotifier.value != null) buildAudioPlayer(),
                  if (!widget.autoMode && !widget.editMode) buildDeckDropDown(),
                  displayField(
                    context: context,
                    field: AnkiExportField.sentence,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setSentence(value);
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.word,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setWord(value);
                    },
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.reading,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setReading(value);
                    },
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.meaning,
                    keyboardType: TextInputType.multiline,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setMeaning(value);
                    },
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.image,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setImageSearch(value);
                    },
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.audio,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setAudioSearch(value);
                    },
                  ),
                  displayField(
                    context: context,
                    field: AnkiExportField.extra,
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {
                      exportParams.setExtra(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        buildExportButton(),
      ],
    );
  }

  // The [ImageSelectWidget] needs to know if the search term for the image
  /// has changed. If your [AnkiExportEnhancement] uses search, notify it with
  /// the search term using this.
  void notifyImageSearching({required searchTerm}) {
    setState(() {
      imageSearchingNotifier.value = true;
      imageSearchTermNotifier.value = searchTerm;
    });
  }

  /// The [ImageSelectWidget] needs to know if the search term for the image
  /// has changed. If your [AnkiExportEnhancement] uses search, notify it with
  /// the search term using this.
  void notifyImageDetails({required String searchTerm, int? index}) {
    setState(() {
      imageSearchTermNotifier.value = searchTerm;
      imageSearchingNotifier.value = false;
      if (index != null) {
        imageListNotifier.value = index;
      }
    });
  }

  /// The [ImageSelectWidget] needs to know if the search term for the image
  /// has changed. If your [AnkiExportEnhancement] changes the image and is
  /// not the result of an image search, use this.
  void notifyImageNotSearching() {
    setState(() {
      imageSearchTermNotifier.value = "";
      imageListNotifier.value = 0;
      imageSearchingNotifier.value = false;
    });
  }

  Widget buildPlayButton() {
    return MultiValueListenableBuider(
      valueListenables: [
        playerStateNotifier,
      ],
      builder: (context, values, _) {
        PlayerState playerState = values.elementAt(0);

        IconData iconData = Icons.play_arrow;

        switch (playerState) {
          case PlayerState.STOPPED:
            iconData = Icons.replay;
            break;
          case PlayerState.PLAYING:
            iconData = Icons.pause;
            break;
          case PlayerState.PAUSED:
          case PlayerState.COMPLETED:
            iconData = Icons.play_arrow;
            break;
        }

        return IconButton(
          icon: Icon(iconData, size: 24),
          onPressed: () {
            switch (playerState) {
              case PlayerState.STOPPED:
                audioPlayer.play(audioNotifier.value!.path);
                break;
              case PlayerState.PLAYING:
                audioPlayer.pause();
                break;
              case PlayerState.PAUSED:
                audioPlayer.play(audioNotifier.value!.path);
                break;
              case PlayerState.COMPLETED:
                audioPlayer.play(audioNotifier.value!.path);
                break;
            }
          },
        );
      },
    );
  }

  Widget buildDurationAndPosition() {
    return MultiValueListenableBuider(
      valueListenables: [
        durationNotifier,
        positionNotifier,
        playerStateNotifier,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        PlayerState playerState = values.elementAt(2);

        if (duration == Duration.zero) {
          return const SizedBox.shrink();
        }

        String getPositionText() {
          if (playerState == PlayerState.COMPLETED) {
            position = Duration.zero;
          }

          if (position.inHours == 0) {
            var strPosition = position.toString().split('.')[0];
            return "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          } else {
            return position.toString().split('.')[0];
          }
        }

        String getDurationText() {
          if (duration.inHours == 0) {
            var strDuration = duration.toString().split('.')[0];
            return "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
          } else {
            return duration.toString().split('.')[0];
          }
        }

        return Text(
          "${getPositionText()} / ${getDurationText()}",
        );
      },
    );
  }

  Widget buildSlider() {
    return MultiValueListenableBuider(
      valueListenables: [
        durationNotifier,
        positionNotifier,
        playerStateNotifier,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        PlayerState playerState = values.elementAt(2);

        bool validPosition = duration.compareTo(position) >= 0;
        double sliderValue =
            validPosition ? position.inMilliseconds.toDouble() : 0;

        if (playerState == PlayerState.COMPLETED) {
          sliderValue = 0;
        }

        return Expanded(
          child: Slider(
            activeColor: Theme.of(context).focusColor,
            inactiveColor: Theme.of(context).unselectedWidgetColor,
            value: sliderValue,
            min: 0.0,
            max: (!validPosition || playerState == PlayerState.COMPLETED)
                ? 1.0
                : duration.inMilliseconds.toDouble(),
            onChanged: validPosition
                ? (progress) {
                    if (playerState == PlayerState.COMPLETED) {
                      sliderValue = progress.floor().toDouble();
                      audioPlayer.play(
                        audioNotifier.value!.path,
                        position: Duration(
                          milliseconds: sliderValue.toInt(),
                        ),
                      );
                    } else {
                      sliderValue = progress.floor().toDouble();
                      audioPlayer
                          .seek(Duration(milliseconds: sliderValue.toInt()));
                    }
                  }
                : null,
          ),
        );
      },
    );
  }

  void showDropDownOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        popupItem(
          label: appModel.translate("creator_options_menu"),
          icon: Icons.widgets,
          action: () async {
            await navigateToCreator(
              context: context,
              appModel: appModel,
              editMode: true,
            );
            setState(() {});
          },
        ),
        popupItem(
          label: appModel.translate("creator_options_auto"),
          icon: Icons.hdr_auto,
          action: () async {
            await navigateToCreator(
              context: context,
              appModel: appModel,
              autoMode: true,
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
