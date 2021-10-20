import 'dart:io';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:provider/provider.dart';

class PlayerHomePage extends MediaHomePage {
  const PlayerHomePage({
    Key? key,
    required MediaType mediaType,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  @override
  State<StatefulWidget> createState() => PlayerHomePageState();
}

class PlayerHomePageState extends State<PlayerHomePage> {
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
        onTap: () async {
          String? path = await FilesystemPicker.open(
            title: 'Pick Video',
            context: context,
            rootDirectory: Directory("storage/emulated/0"),
            fsType: FilesystemType.file,
            pickText: 'Pick Video',
            folderIconColor: Colors.red,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VlcPlayerWithControls(
                  controller: VlcPlayerController.file(File(path!))),
            ),
          );

          // mediaType.launchMediaPageFromUri(context, await selectFile())
        },
        child: Container(
          padding: const EdgeInsets.all(36),
          color: Colors.grey,
          child: Text(
            appModel.translate("start_reading"),
          ),
        ),
      ),
    );
  }
}
