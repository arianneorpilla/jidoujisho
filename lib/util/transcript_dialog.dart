import 'dart:async';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle/subtitle.dart';

Widget transcriptDialog({
  required BuildContext context,
  required List<Subtitle> subtitles,
  required Subtitle? currentSubtitle,
  required String regexFilter,
  required Duration subtitleDelay,
  required FutureOr<void> Function(int)? onTapCallback,
  required FutureOr<void> Function(int)? onLongPressCallback,
}) {
  AppModel appModel = Provider.of<AppModel>(context);

  if (subtitles.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subtitles_off_outlined,
            color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
            size: 72,
          ),
          const SizedBox(height: 6),
          Text(
            appModel.translate("player_subtitles_transcript_empty"),
            style: TextStyle(
              fontSize: 20,
              color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  int selectedIndex = 0;
  if (currentSubtitle != null) {
    selectedIndex = currentSubtitle.index - 1;
  }

  return ScrollablePositionedList.builder(
    physics: const BouncingScrollPhysics(),
    itemScrollController: itemScrollController,
    itemPositionsListener: itemPositionsListener,
    initialScrollIndex: (selectedIndex - 2 > 0) ? selectedIndex - 2 : 0,
    itemCount: subtitles.length,
    itemBuilder: (context, index) {
      Subtitle subtitle = subtitles[index];
      String subtitleText = subtitle.data;

      if (regexFilter.isNotEmpty) {
        subtitleText = subtitleText.replaceAll(RegExp(regexFilter), "");
      }
      if (subtitleText.trim().isNotEmpty) {
        subtitleText = "『$subtitleText』";
      }

      Color durationColor = Theme.of(context).unselectedWidgetColor;

      Duration offsetStart = subtitle.start - subtitleDelay;
      Duration offsetEnd = subtitle.end - subtitleDelay;
      String offsetStartText = getTimestampFromDuration(offsetStart);
      String offsetEndText = getTimestampFromDuration(offsetEnd);
      String subtitleDuration = "$offsetStartText - $offsetEndText";

      return Material(
        color: Colors.transparent,
        child: ListTile(
          selected: selectedIndex == index,
          selectedTileColor: Colors.red.withOpacity(0.15),
          dense: true,
          title: Column(
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.textsms_outlined,
                    size: 12.0,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    subtitleDuration,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: durationColor,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 20,
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
          onTap: () async {
            if (onTapCallback != null) {
              onTapCallback(index);
              Navigator.pop(context);
            }
          },
          onLongPress: () async {
            if (onLongPressCallback != null) {
              onLongPressCallback(index);
              Navigator.pop(context);
            }
          },
        ),
      );
    },
  );
}

Future<void> openTranscript({
  required BuildContext context,
  required List<Subtitle> subtitles,
  required Duration subtitleDelay,
  Subtitle? currentSubtitle,
  required String regexFilter,
  FutureOr<void> Function(int)? onTapCallback,
  FutureOr<void> Function(int)? onLongPressCallback,
}) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);
  Color backgroundColor = appModel.getIsDarkMode()
      ? const Color(0xcc212121)
      : const Color(0xefeeeeee);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  await showDialog(
    barrierColor: backgroundColor,
    context: context,
    builder: (context) => transcriptDialog(
      context: context,
      subtitles: subtitles,
      currentSubtitle: currentSubtitle,
      subtitleDelay: subtitleDelay,
      regexFilter: regexFilter,
      onTapCallback: onTapCallback,
      onLongPressCallback: onLongPressCallback,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
}
