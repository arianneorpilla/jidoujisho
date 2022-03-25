import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:path/path.dart' as path;

/// A collection of common methods that are used across the application.
class JidoujishoCommon {
  /// Return the app external directory found in the public DCIM directory.
  /// This path also initialises the folder if it does not exist, and includes
  /// a .nomedia file within the folder.
  static Future<Directory> getJidoujishoDirectory() async {
    String dcimDirectory = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DCIM,
    );

    String directoryPath = path.join(dcimDirectory, 'jidoujisho');
    String noMediaFilePath = path.join(dcimDirectory, 'jidoujisho', '.nomedia');

    Directory jidoujishoDirectory = Directory(directoryPath);
    File noMediaFile = File(noMediaFilePath);

    if (!jidoujishoDirectory.existsSync()) {
      jidoujishoDirectory.createSync(recursive: true);
    }
    if (!noMediaFile.existsSync()) {
      noMediaFile.createSync();
    }

    return jidoujishoDirectory;
  }
}
