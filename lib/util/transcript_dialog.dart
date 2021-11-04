import 'dart:async';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle/subtitle.dart';

Widget transcriptDialog({
  required BuildContext context,
  required List<Subtitle> subtitles,
  required Subtitle? currentSubtitle,
  required Pattern? regexFilter,
  required FutureOr<void> Function(int)? onTapCallback,
  required FutureOr<void> Function(int)? onLongPressCallback,
}) {
  AppModel appModel = Provider.of<AppModel>(context);

  if (subtitles.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.subtitles_off_outlined,
            color: Colors.white,
            size: 72,
          ),
          const SizedBox(height: 6),
          Text(
            appModel.translate("player_subtitles_transcript_empty"),
            style: const TextStyle(fontSize: 20, color: Colors.white),
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
    itemScrollController: itemScrollController,
    itemPositionsListener: itemPositionsListener,
    initialScrollIndex: (selectedIndex - 2 > 0) ? selectedIndex - 2 : 0,
    itemCount: subtitles.length,
    itemBuilder: (context, index) {
      Subtitle subtitle = subtitles[index];
      String subtitleText = subtitle.data;

      if (regexFilter != null) {
        subtitleText = subtitleText.replaceAll(regexFilter, subtitleText);
      }
      if (subtitleText.trim().isNotEmpty) {
        subtitleText = "『$subtitleText』";
      }

      String subtitleStart = getTimestampFromDuration(subtitle.start);
      String subtitleEnd = getTimestampFromDuration(subtitle.end);
      String subtitleDuration = "$subtitleStart - $subtitleEnd";

      return ListTile(
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 6),
          ],
        ),
        onTap: () async {
          if (onTapCallback != null) {
            await onTapCallback(index);
            Navigator.pop(context);
          }
        },
        onLongPress: () async {
          if (onLongPressCallback != null) {
            await onLongPressCallback(index);
            Navigator.pop(context);
          }
        },
      );
    },
  );
}

Future<void> openTranscript({
  required BuildContext context,
  required List<Subtitle> subtitles,
  Subtitle? currentSubtitle,
  Pattern? regexFilter,
  FutureOr<void> Function(int)? onTapCallback,
  FutureOr<void> Function(int)? onLongPressCallback,
}) async {
  await showModalBottomSheet(
    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => transcriptDialog(
      context: context,
      subtitles: subtitles,
      currentSubtitle: currentSubtitle,
      regexFilter: regexFilter,
      onTapCallback: onTapCallback,
      onLongPressCallback: onLongPressCallback,
    ),
  );
}
