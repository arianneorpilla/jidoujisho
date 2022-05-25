import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

/// An enhancement used effectively as a shortcut for clearing the contents
/// of a [CreatorModel] pertaining to a certain field.
class BingImagesSearchEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  BingImagesSearchEnhancement()
      : super(
          uniqueKey: key,
          label: 'Bing Images Search',
          description:
              'Search Bing for images with the current image query or the word.',
          icon: Icons.image_search,
          field: ImageField.instance,
        );

  final Map<String, List<NetworkToFileImage>> _bingCache = {};

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'bing_images_search';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    ImageExportField imageField = field as ImageExportField;
    String? searchTerm;

    if (cause != EnhancementTriggerCause.auto) {
      searchTerm = imageField.getSearchTermWithFallback(
        appModel: appModel,
        creatorModel: creatorModel,
        fallbackSearchTerms: [TermField.instance],
      );
    } else {
      searchTerm = creatorModel.getFieldController(TermField.instance).text;

      if (searchTerm.trim().isEmpty) {
        return;
      }
    }

    /// Show loading state.
    imageField.setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: true,
        searchTerm: searchTerm!);
    try {
      List<NetworkToFileImage> images =
          await scrapeBingImages(context: context, searchTerm: searchTerm);

      imageField.setSearchSuggestions(
        appModel: appModel,
        creatorModel: creatorModel,
        images: images,
        searchTermUsed: searchTerm,
      );
    } finally {
      /// Finish loading state.
      imageField.setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: false,
        searchTerm: searchTerm,
      );
    }
  }

  /// Fetch images from Bing Images.
  Future<List<NetworkToFileImage>> scrapeBingImages({
    required BuildContext context,
    required String searchTerm,
  }) async {
    if (_bingCache[searchTerm] != null) {
      return _bingCache[searchTerm]!;
    }

    List<NetworkToFileImage> images = [];

    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse("https://www.bing.com/images/search?q=$searchTerm')"),
        ),
        onLoadStop: (controller, uri) async {
          await Future.delayed(const Duration(milliseconds: 1000), () {});

          dom.Document document = parser.parse(await controller.getHtml());

          List<dom.Element> imgElements =
              document.getElementsByClassName('iusc');

          for (int i = 0; i < imgElements.length; i++) {
            Map<dynamic, dynamic> imgMap =
                jsonDecode(imgElements[i].attributes['m']!);
            String imageURL = imgMap['turl'];

            Directory appDirDoc = await getApplicationSupportDirectory();
            String bingImagesPath = '${appDirDoc.path}/bingImages';
            Directory bingImagesDir = Directory(bingImagesPath);
            if (!bingImagesDir.existsSync()) {
              bingImagesDir.createSync();
            }

            String imagePath = '$bingImagesPath/$i';
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

    if (images.isNotEmpty) {
      _bingCache[searchTerm] = images;
    }

    return images;
  }
}
