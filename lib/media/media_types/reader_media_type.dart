import 'dart:io';

import 'package:daijidoujisho/pages/reader_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:daijidoujisho/media/media_history_item.dart';
import 'package:daijidoujisho/media/media_type.dart';

class ReaderMediaType extends MediaType {
  ReaderMediaType()
      : super(
          mediaTypeName: "Reader",
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  Widget getHomeBody(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () async => launchMediaPageFromUri(context, await selectFile()),
        child: Container(
          padding: const EdgeInsets.all(36),
          color: Colors.grey,
          child: const Text("Select EPUB File"),
        ),
      ),
    );
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
  BottomNavigationBarItem getHomeTab() {
    return const BottomNavigationBarItem(
      label: "Reader",
      icon: Icon(Icons.library_books),
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
}
