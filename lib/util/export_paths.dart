import 'dart:io';

Future<void> initialiseExportPaths() async {
  if (!getDCIMDirectory().existsSync()) {
    getDCIMDirectory().createSync(recursive: true);
  }
  if (!getDCIMNoMediaFile().existsSync()) {
    getDCIMNoMediaFile().createSync();
  }
}

Directory getDCIMDirectory() {
  return Directory("storage/emulated/0/DCIM/jidoujisho/");
}

File getDCIMNoMediaFile() {
  return File("storage/emulated/0/DCIM/jidoujisho/.nomedia");
}

String getPreviewImagePath() {
  return getDCIMDirectory().path + "exportImage.jpg";
}

String getPreviewImageMultiPath(int index) {
  return getDCIMDirectory().path + "exportImage$index.jpg";
}

String getPreviewAudioPath() {
  return getDCIMDirectory().path + "exportAudio.mp3";
}
