import 'dart:convert';

import 'package:chisa/util/dictionary_entry_widget.dart';
import 'package:chisa/dictionary/formats/yomichan_term_bank_format.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class YomichanTermBankFormatWidget extends DictionaryWidget {
  YomichanTermBankFormatWidget({
    required dictionaryEntry,
    required dictionaryFormat,
    required dictionary,
    required context,
  }) : super(
          context: context,
          dictionaryEntry: dictionaryEntry,
          dictionary: dictionary,
          dictionaryFormat: dictionaryFormat,
        );

  Map<String, dynamic> getDictionaryCache() {
    AppModel appModel = Provider.of<AppModel>(context);
    return appModel.getDictionaryCache(dictionary.dictionaryName);
  }

  @override
  Widget buildMainWidget({Widget? word, Widget? reading, Widget? meaning}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        word ?? buildWord(),
        const SizedBox(height: 5),
        reading ?? buildReading(),
        meaning ?? buildMeaning(),
      ],
    );
  }

  @override
  Widget buildMeaning() {
    List<Widget> tagWidgets = [];

    if (getDictionaryCache()["yomichanTags"] == null) {
      List<YomichanTag> yomichanTags =
          YomichanTag.getTagsFromMetadata(dictionary.metadata);
      getDictionaryCache()["yomichanTags"] = yomichanTags;
    }
    Map<String, dynamic> map = jsonDecode(dictionaryEntry.extra);
    List<YomichanTag> tagsStore = getDictionaryCache()["yomichanTags"];

    if (map["meanings"] == null) {
      return super.buildMeaning();
    }

    List<dynamic> uncastNames = map["termTags"];
    List<String> termTagNames =
        uncastNames.map((uncastName) => uncastName.toString()).toList();

    List<YomichanTag> yomichanTermTags =
        YomichanTag.getTagsFromNames(tagsStore, termTagNames);

    for (YomichanTag tag in yomichanTermTags) {
      tagWidgets.add(
        GestureDetector(
          onTap: () {
            Fluttertoast.showToast(
              msg: "${tag.tagName} - ${tag.tagNotes}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: tag.getTagColor(),
              textColor: Colors.white,
              fontSize: 16.0,
            );
          },
          child: Container(
            child: Text(
              tag.tagName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            color: tag.getTagColor(),
            padding: const EdgeInsets.all(3),
          ),
        ),
      );
      tagWidgets.add(const SizedBox(width: 5));
    }

    // tagWidgets.removeLast();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Wrap(children: tagWidgets),
        ),
        buildTaggedMeaning(),
      ],
    );
  }

  Widget buildTaggedMeaning() {
    if (getDictionaryCache()["yomichanTags"] == null) {
      List<YomichanTag> yomichanTags =
          YomichanTag.getTagsFromMetadata(dictionary.metadata);
      getDictionaryCache()["yomichanTags"] = yomichanTags;
    }
    Map<String, dynamic> map = jsonDecode(dictionaryEntry.extra);
    List<YomichanTag> tagsStore = getDictionaryCache()["yomichanTags"];

    if (map["meanings"] == null) {
      return super.buildMeaning();
    }

    List<List<String>> definitionTagNames = [];
    List<dynamic> listOfListOfTags = map["definitionTags"];
    for (List<dynamic> listOfTags in listOfListOfTags) {
      List<String> castTags =
          listOfTags.map((uncastTag) => uncastTag.toString()).toList();
      definitionTagNames.add(castTags);
    }
    List<String> meanings = List.castFrom(map["meanings"]);
    List<List<YomichanTag>> yomichanDefinitionTags = definitionTagNames
        .map((tagList) => YomichanTag.getTagsFromNames(tagsStore, tagList))
        .toList();

    List<List<Widget>> definitionWidgets = [];
    for (List<YomichanTag> tagList in yomichanDefinitionTags) {
      List<Widget> tagWidgets = [];
      for (YomichanTag tag in tagList) {
        tagWidgets.add(
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(
                msg: "${tag.tagName} - ${tag.tagNotes}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: tag.getTagColor(),
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Container(
              child: Text(
                tag.tagName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
              color: tag.getTagColor(),
              padding: const EdgeInsets.all(3),
            ),
          ),
        );
        tagWidgets.add(const SizedBox(width: 5));
      }
      definitionWidgets.add(tagWidgets);
    }

    List<Widget> meaningWidgets = [];

    for (int i = 0; i < meanings.length; i++) {
      List<InlineSpan> inlineSpanWidgets = [];
      for (int j = 0; j < definitionWidgets[i].length; j++) {
        inlineSpanWidgets.add(
          WidgetSpan(
            child: definitionWidgets[i][j],
          ),
        );
      }

      inlineSpanWidgets.add(
        TextSpan(
          text: meanings[i],
        ),
      );

      meaningWidgets.add(
        SizedBox(height: (i == 0) ? 10 : 5),
      );
      meaningWidgets.add(
        Text.rich(
          TextSpan(
            text: '',
            style: const TextStyle(
              fontSize: 15,
            ),
            children: inlineSpanWidgets,
          ),
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (i == meanings.length - 1) {
        meaningWidgets.add(
          const SizedBox(height: 10),
        );
      }
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: meaningWidgets,
      ),
    );
  }
}
