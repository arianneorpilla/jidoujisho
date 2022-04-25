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

  /// From a term that is length n, get all prefixes of the word for n-1 up to 1.
  static List<String> allPrefixes(
    String term, {
    List<String>? prefixes,
  }) {
    prefixes ??= [];

    if (term.length <= 1) {
      return prefixes;
    } else {
      String nextTerm = term.substring(0, term.length - 1);
      prefixes.add(term);

      return allPrefixes(nextTerm, prefixes: prefixes);
    }
  }
}
