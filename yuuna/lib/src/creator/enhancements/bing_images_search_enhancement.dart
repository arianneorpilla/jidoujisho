import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

/// An enhancement used effectively as a shortcut for clearing the contents
/// of a [CreatorModel] pertaining to a certain field.
class BingImagesSearchEnhancement extends ImageEnhancement {
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
      if (searchTerm == null) {
        return;
      }
    } else {
      searchTerm = creatorModel.getFieldController(TermField.instance).text;

      if (searchTerm.trim().isEmpty) {
        return;
      }
    }

    await imageField.setImages(
      cause: cause,
      appModel: appModel,
      creatorModel: creatorModel,
      newAutoCannotOverride: false,
      searchTerm: searchTerm,
      generateImages: () async {
        return fetchImages(
          appModel: appModel,
          context: context,
          searchTerm: searchTerm,
        );
      },
    );
  }

  @override
  Future<List<NetworkToFileImage>> fetchImages({
    required AppModel appModel,
    required BuildContext context,
    String? searchTerm,
  }) async {
    List<NetworkToFileImage> images = [];

    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
            "https://www.bing.com/images/search?q=$searchTerm')",
          ),
        ),
        onLoadStop: (controller, uri) async {
          Directory appDirDoc = await getApplicationSupportDirectory();
          String bingImagesPath = '${appDirDoc.path}/bingImages';
          Directory bingImagesDir = Directory(bingImagesPath);
          if (bingImagesDir.existsSync()) {
            bingImagesDir.deleteSync(recursive: true);
          }
          bingImagesDir.createSync();

          await Future.delayed(const Duration(milliseconds: 1000), () {});

          dom.Document document = parser.parse(await controller.getHtml());

          List<dom.Element> imgElements =
              document.getElementsByClassName('iusc');

          String timestamp =
              DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
          Directory imageDir = Directory('$bingImagesPath/$timestamp');
          imageDir.createSync();
          for (int i = 0; i < imgElements.length; i++) {
            Map<dynamic, dynamic> imgMap =
                jsonDecode(imgElements[i].attributes['m']!);
            String imageURL = imgMap['turl'];

            String imagePath = '${imageDir.path}/$i';
            File imageFile = File(imagePath);

            /// Instant export requires a file to already be written to the
            /// file system.
            if (i == 0) {
              http.Response response = await http.get(Uri.parse(imageURL));
              File(imagePath).writeAsBytesSync(response.bodyBytes);
            }
            NetworkToFileImage image = NetworkToFileImage(
              url: imageURL,
              file: imageFile,
            );

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
