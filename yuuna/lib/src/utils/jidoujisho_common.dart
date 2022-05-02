import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:path/path.dart' as path;

/// A collection of common methods that are used across the application.
class JidoujishoCommon {
  /// Used to filter an image to have no saturation with transparency.
  static const ColorFilter greyscaleWithAlphaFilter = ColorFilter.matrix(
    <double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
  );

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
      prefixes.add(term);
      return prefixes;
    } else {
      String nextTerm = term.substring(0, term.length - 1);
      prefixes.add(term);

      return allPrefixes(nextTerm, prefixes: prefixes);
    }
  }

  /// From a term that is length n, get all prefixes of the word for n-1 up to 1.
  static List<String> allKanaPrefixes(
    String term, {
    required KanaKit kanaKit,
    List<String>? prefixes,
  }) {
    prefixes ??= [];

    if (term.length <= 1) {
      if (kanaKit.isKana(term)) {
        prefixes.add(term);
      }

      return prefixes;
    } else {
      String nextTerm = term.substring(0, term.length - 1);
      if (kanaKit.isKana(term)) {
        prefixes.add(term);
      }

      return allKanaPrefixes(nextTerm, kanaKit: kanaKit, prefixes: prefixes);
    }
  }
}
