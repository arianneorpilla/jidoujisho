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
  return getDCIMDirectory().path + "previewImage.jpg";
}

String getPreviewImageMultiPath(int index) {
  return getDCIMDirectory().path + "previewImage$index.jpg";
}

String getPreviewAudioPath() {
  return getDCIMDirectory().path + "previewAudio.mp3";
}

String getExportImagePath() {
  return getDCIMDirectory().path + "exportImage.jpg";
}

String getExportAudioPath() {
  return getDCIMDirectory().path + "exportAudio.mp3";
}
