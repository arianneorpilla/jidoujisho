import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';

class BingSearchEnhancement extends AnkiExportEnhancement {
  BingSearchEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Bing Image Search",
          enhancementDescription:
              "Search Bing for images with the current image query or the word.",
          enhancementIcon: Icons.image_search,
          enhancementField: AnkiExportField.image,
        );

  Map<String, http.Response> bingCache = {};

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    /// If an image exists, and it is not an image from search, do nothing and
    /// keep the current image.
    if (state.imageSearchTermNotifier.value.isEmpty &&
        params.imageFiles.isNotEmpty) {
      return params;
    }

    String searchTerm = "";

    if (params.imageSearch.trim().isNotEmpty) {
      searchTerm = params.imageSearch;
    } else if (params.word.trim().isNotEmpty) {
      searchTerm = params.word;
    } else {
      return params;
    }

    /// Notify the [CreatorPageState] that we are searching.
    state.notifyImageSearching(searchTerm: searchTerm);

    String cacheKey = "${appModel.getCurrentLanguage()}/$searchTerm";

    try {
      List<NetworkToFileImage> images =
          await scrapeBingImages(context, searchTerm, cacheKey);

      if (images.isNotEmpty) {
        params.imageFiles = images;
        params.imageFile = images.first.file;
        params.imageSearch = "";

        state.notifyImageDetails(
          searchTerm: searchTerm,
          index: 0,
        );
      }
    } catch (e) {
      /// Notify the [CreatorPageState] that we are not searching / later
      /// image results are not from a search.
      state.notifyImageNotSearching();
    }

    return params;
  }

  Future<List<NetworkToFileImage>> scrapeBingImages(
      BuildContext context, String searchTerm, String cacheKey) async {
    List<NetworkToFileImage> images = [];

    late http.Response response;

    if (bingCache[cacheKey] != null) {
      response = bingCache[cacheKey]!;
    } else {
      var client = http.Client();
      response = await client.get(Uri.parse(
          'https://www.bing.com/images/search?q=$searchTerm&FORM=HDRSC2'));
      bingCache[cacheKey] = response;
    }

    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse("https://www.bing.com/images/search?q=$searchTerm')"),
        ),
        onLoadStop: (controller, uri) async {
          await Future.delayed(const Duration(milliseconds: 500), () {});

          dom.Document document = parser.parse(await controller.getHtml());

          List<dom.Element> imgElements =
              document.getElementsByClassName("iusc");

          for (int i = 0; i < imgElements.length; i++) {
            Map<dynamic, dynamic> imgMap =
                jsonDecode(imgElements[i].attributes["m"]!);
            String imageURL = imgMap["turl"];

            Directory appDirDoc = await getApplicationSupportDirectory();
            String bingImagesPath = "${appDirDoc.path}/bingImages";
            Directory bingImagesDir = Directory(bingImagesPath);
            if (!bingImagesDir.existsSync()) {
              bingImagesDir.createSync();
            }

            String imagePath = "$bingImagesPath/$i";
            File imageFile = File(imagePath);
            if (imageFile.existsSync()) {
              imageFile.deleteSync();
            }

            NetworkToFileImage image =
                NetworkToFileImage(url: imageURL, file: imageFile);
            if (i == 0) {
              await precacheImage(image, context);
            } else {
              precacheImage(image, context);
            }
            images.add(image);
          }

          webViewBusy = false;
        });

    await webView.run();

    while (webViewBusy) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }

    return images;
  }
}
