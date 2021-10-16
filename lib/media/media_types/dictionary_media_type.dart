import 'dart:io';

import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:provider/provider.dart';

class DictionaryMediaType extends MediaType {
  DictionaryMediaType()
      : super(
          mediaTypeName: "Dictionary",
          mediaTypeIcon: Icons.auto_stories,
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  Widget getHomeBody(BuildContext context) {
    return Column(children: [
      buildSearchField(context),
      buildCardCreatorButton(context),
      Expanded(
        child: buildDictionaryHistory(context),
      ),
    ]);
  }

  Future<Uri> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File epubFile = File(result.files.single.path!);
      if (isUriSupported(epubFile.uri)) {
        return epubFile.uri;
      } else {
        throw Exception("Uri is not supported.");
      }
    } else {
      throw Exception("No file picked.");
    }
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return BottomNavigationBarItem(
      label: AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "dictionary_media_type"),
      icon: Icon(mediaTypeIcon),
    );
  }

  @override
  MediaHistoryItem getNewHistoryItem(Uri uri) {
    throw UnimplementedError();
  }

  @override
  bool isUriSupported(Uri uri) {
    File file;

    try {
      file = File.fromUri(uri);
    } on UnsupportedError {
      return false;
    }

    return lookupMimeType(file.path) == "application/epub+zip";
  }

  @override
  void launchMediaPageFromHistory(
      BuildContext context, MediaHistoryItem mediaHistoryItem) {
    // TODO: implement launchMediaPage
  }

  @override
  void launchMediaPageFromUri(BuildContext context, Uri uri) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          mediaType: this,
          uri: uri,
        ),
      ),
    );
  }

  TextEditingController wordController = TextEditingController(text: "");

  Widget buildSearchField(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLines: 1,
        controller: wordController,
        onFieldSubmitted: (result) {
          // wordFieldSearch();
        },
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).unselectedWidgetColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 18,
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () async {
                  print(wordController.text);
                  DictionarySearchResult result =
                      await appModel.searchDictionary(wordController.text);

                  for (DictionaryEntry entry in result.results) {
                    print(entry.headword);
                  }
                },
              ),
              IconButton(
                iconSize: 18,
                icon: Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => appModel.showDictionaryMenu(context),
              ),
              IconButton(
                iconSize: 18,
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => wordController.clear(),
              ),
            ],
          ),
          labelText: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "search"),
          hintText: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "enter_search_term_here"),
        ),
      ),
    );
  }

  Widget buildCardCreatorButton(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: InkWell(
        child: Container(
          color: Theme.of(context).unselectedWidgetColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.note_add_sharp, size: 16),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.getLocalizedValue(
                      appModel.getAppLanguageName(), "card_creator"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {},
      ),
    );
  }

  @override
  MediaHistory getMediaHistory(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return DefaultMediaHistory(
      sharedPreferences: appModel.sharedPreferences,
      prefsDirectory: mediaTypeName,
    );
  }

  Widget buildDictionaryHistory(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    if (getMediaHistory(context).getItems().isEmpty) {
      return showCenterIconMessage(
        context: context,
        label: AppLocalizations.getLocalizedValue(
            appModel.getAppLanguageName(), "dictionary_history_empty"),
        icon: mediaTypeIcon,
        jumpingDots: false,
      );
    } else {
      return Container();
    }
  }
}
