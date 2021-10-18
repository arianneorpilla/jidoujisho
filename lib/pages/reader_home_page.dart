import 'dart:io';

import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReaderHomePage extends MediaHomePage {
  const ReaderHomePage({
    Key? key,
    required MediaType mediaType,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  @override
  State<StatefulWidget> createState() => ReaderHomePageState();
}

class ReaderHomePageState extends State<ReaderHomePage> {
  late MediaType mediaType;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    mediaType = widget.mediaType;
  }

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Center(
      child: InkWell(
        onTap: () async =>
            mediaType.launchMediaPageFromUri(context, await selectFile()),
        child: Container(
          padding: const EdgeInsets.all(36),
          color: Colors.grey,
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguageName(), "start_reading"),
          ),
        ),
      ),
    );
  }

  Future<Uri> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File epubFile = File(result.files.single.path!);
      if (mediaType.isUriSupported(epubFile.uri)) {
        return epubFile.uri;
      } else {
        throw Exception("Uri is not supported.");
      }
    } else {
      throw Exception("No file picked.");
    }
  }
}
