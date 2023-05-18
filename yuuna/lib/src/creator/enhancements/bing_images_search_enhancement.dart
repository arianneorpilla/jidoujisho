import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

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

  /// Used to store results that have already been found at runtime.
  final Map<String, List<NetworkToFileImage>> _bingCache = {};

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
          searchTerm: searchTerm,
        );
      },
    );
  }

  @override
  Future<List<NetworkToFileImage>> fetchImages({
    required AppModel appModel,
    String? searchTerm,
  }) async {
    if (_bingCache[searchTerm!] != null) {
      return _bingCache[searchTerm]!;
    }

    List<NetworkToFileImage> images = [];

    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
            "https://www.bing.com/images/search?q=$searchTerm')",
          ),
        ),
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            blockNetworkImage: true,
          ),
        ),
        onLoadStop: (controller, uri) async {
          Directory appDirDoc = await getApplicationSupportDirectory();
          String bingImagesPath = '${appDirDoc.path}/bingImages';
          Directory bingImagesDir = Directory(bingImagesPath);
          if (bingImagesDir.existsSync()) {
            if (_bingCache.isEmpty) {
              bingImagesDir.deleteSync(recursive: true);
            }
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
              File networkFile =
                  await DefaultCacheManager().getSingleFile(imageURL);
              networkFile.copySync(imagePath);
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

    if (images.isNotEmpty) {
      _bingCache[searchTerm] = images;
    }

    return images;
  }
}
