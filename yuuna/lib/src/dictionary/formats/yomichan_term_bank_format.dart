import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';

/// A dictionary format for archives in the Yomichan Term Bank V3 schema.
/// Example dictionaries for this format may be downloaded from the Yomichan
/// website.
///
/// Details on the schema can be found here:
/// https://github.com/FooSoft/yomichan/blob/master/ext/data/schemas/dictionary-term-bank-v3-schema.json
class YomichanTermBankFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with a set of top-level helper methods.
  YomichanTermBankFormat()
      : super(
          formatName: 'Yomichan Term Bank',
          formatIcon: Icons.auto_stories,
          requiresFile: true,
          prepareDirectoryFunction: prepareDirectory,
          prepareNameFunction: prepareName,
          prepareEntriesFunction: prepareEntries,
          prepareMetadataFunction: prepareMetadata,
        );

  /// See [DictionaryFormat]'s [prepareDirectoryFunction] for details.
  static Future<void> prepareDirectory(PrepareDirectoryParams params) async {
    /// Extract the user selected archive to the working directory.
    await ZipFile.extractToDirectory(
      zipFile: params.file,
      destinationDir: params.workingDirectory,
    );
  }

  /// See [DictionaryFormat]'s [prepareNameFunction] for details.
  static Future<String> prepareName(PrepareDictionaryParams params) async {
    /// Get the index, which contains the name of the dictionary contained by
    /// the archive.
    String indexFilePath =
        path.join(params.workingDirectory.path, 'index.json');
    File indexFile = File(indexFilePath);
    String indexJson = indexFile.readAsStringSync();
    Map<String, dynamic> index = jsonDecode(indexJson);

    String dictionaryName = (index['title'] as String).trim();
    return dictionaryName;
  }

  /// See [DictionaryFormat]'s [prepareEntriesFunction] for details.
  static Future<List<DictionaryEntry>> prepareEntries(
      PrepareDictionaryParams params) async {
    throw UnimplementedError();
  }

  /// See [DictionaryFormat]'s [prepareMetadataFunction] for details.
  static Future<Map<String, String>> prepareMetadata(
      PrepareDictionaryParams params) async {
    throw UnimplementedError();
  }
}
