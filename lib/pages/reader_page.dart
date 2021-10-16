import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:chisachan/media/media_page.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ReaderPage extends MediaPage {
  const ReaderPage({
    Key? key,
    required mediaType,
    required uri,
    initialProgress = 0,
  }) : super(
          key: key,
          mediaType: mediaType,
          uri: uri,
          initialProgress: initialProgress,
        );

  @override
  State<StatefulWidget> createState() => ReaderPageState();
}

class ReaderPageState extends MediaPageState {
  @override
  void initState() {
    super.initState();
    prepareMediaParameters().then((params) => setState(() {
          mediaParameters = params;
        }));
  }

  bool isReaderLoaded = false;

  late InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        horizontalScrollBarEnabled: false,
        verticalScrollBarEnabled: false,
        disableVerticalScroll: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    if (mediaParameters.isEmpty) {
      return showOverlayLoadingWidget();
    } else {
      return showContentWidget();
    }
  }

  // Future<void> recompressImage(File file) async {
  //   String actualPath = file.absolute.path;
  //   String compressedPath = p.withoutExtension(actualPath) +
  //       "_compressed" +
  //       p.extension(actualPath);

  //   File? compressedFile = await FlutterImageCompress.compressAndGetFile(
  //     actualPath,
  //     compressedPath,
  //     quality: 10,
  //   );

  //   file.deleteSync();
  //   compressedFile!.renameSync(actualPath);
  // }

  @override
  Future<Map<String, dynamic>> prepareMediaParameters() async {
    File epubFile = File.fromUri(widget.uri);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory workingDir = Directory(p.join(appDocDir.path, "working"));
    String recompressedPath = p.join(appDocDir.path, "recompressed.epub");
    File recompressed = File(recompressedPath);

    if (workingDir.existsSync()) {
      workingDir.deleteSync(recursive: true);
    }
    if (recompressed.existsSync()) {
      recompressed.deleteSync();
    }

    workingDir.createSync();

    // if (epubFile.lengthSync() > 1024 * 1024) {
    //   await ZipFile.extractToDirectory(
    //       zipFile: epubFile, destinationDir: workingDir);

    //   List<FileSystemEntity> entities = workingDir.listSync(recursive: true);

    //   for (FileSystemEntity entity in entities) {
    //     workingDir.listSync(recursive: true).forEach((entity) async {});

    //     String mime = lookupMimeType(entity.path) ?? "";

    //     if (mime.endsWith("jpeg") || mime.endsWith("jpg")) {
    //       await recompressImage(entity as File);
    //     }
    //   }

    //   await ZipFile.createFromDirectory(
    //       sourceDir: workingDir, zipFile: recompressed);

    //   epubFile = recompressed;
    // }

    EpubBook epubBook = await EpubReader.readBook(epubFile.readAsBytesSync());
    String fontPath = "fonts/NotoSerifJP-Regular.otf";
    String fontUri = await getFontUri(fontPath, "font/opentype");

    mediaParameters["epub"] = epubBook;
    mediaParameters["font"] = fontUri;

    return mediaParameters;
  }

  EpubBook getEpubBook() {
    return mediaParameters["epub"];
  }

  String getFont() {
    return mediaParameters["font"];
  }

  @override
  Future<void> updateHistory() {
    // TODO: implement updateHistory
    throw UnimplementedError();
  }

  Future<String> getFontUri(String fontAssetPath, String fontMime) async {
    final fontData = await rootBundle.load(fontAssetPath);
    final buffer = fontData.buffer;
    return Uri.dataFromBytes(
            buffer.asUint8List(fontData.offsetInBytes, fontData.lengthInBytes),
            mimeType: fontMime)
        .toString();
  }

  /// Show the content that appears during web loading, transparent overlay
  /// over the loading text.
  Widget showOverlayLoadingWidget() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget showContentWidget() {
    EpubContent bookContent = getEpubBook().Content!;

    Map<String?, EpubTextContentFile>? htmlFiles = bookContent.Html;
    String htmlContent = "";

    for (EpubTextContentFile htmlFile in htmlFiles!.values) {
      htmlContent += htmlFile.Content ?? "";
    }

    htmlContent += '''
      <meta name="viewport" content= "width=device-width, user-scalable=no">
    ''';

    bookContent.Images!.forEach((fileName, content) {
      String base64Image = base64Encode(content.Content!);
      String mimeType = content.ContentMimeType.toString();

      htmlContent = htmlContent.replaceAll(
          "../$fileName", "data:$mimeType;base64,$base64Image");
      htmlContent = htmlContent.replaceAll(
          fileName ?? "", "data:$mimeType;base64,$base64Image");
    });

    return Stack(
      children: [
        InAppWebView(
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, uri) {
            setState(() {
              isReaderLoaded = true;
            });
          },
          initialOptions: options,
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(
              source: '''
              function addStyle(styleString) {
                const style = document.createElement('style');
                style.textContent = styleString;
                document.head.append(style);
              }

              addStyle(`
                @font-face { font-family: NotoSerifJP; src: url(${getFont()});}

                html {
                  font-size: 28px;
                  writing-mode: vertical-rl;
                  line-break: normal;
                  text-align: right;
                }

                body {
                  margin-top: 5%;
                  margin-bottom: 3%;
                }

                p {
                  font-family: "NotoSerifJP";
                  text-align: left;
                }
              `);
            ''',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
            ),
          ]),
          initialData: InAppWebViewInitialData(
            data: htmlContent,
            mimeType: 'text/html',
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.CANCEL;
          },
        ),
        if (!isReaderLoaded) showOverlayLoadingWidget(),
      ],
    );
  }
}
