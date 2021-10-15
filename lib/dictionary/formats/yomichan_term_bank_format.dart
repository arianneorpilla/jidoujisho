import 'dart:io';

import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/dictionary/dictionary_utils.dart';
import 'package:daijidoujisho/dictionary/dictionary_search_results.dart';
import 'package:mime/mime.dart';

class YomichanTermBankFormat extends DictionaryFormat {
  YomichanTermBankFormat() : super(formatName: "Yomichan Term Bank");

  @override
  bool isUriSupported(Uri uri) {
    return (lookupMimeType(uri.path) ?? "") == 'application/zip';
  }

  @override
  Future<Directory> prepareWorkingDirectory(ImportPreparationParams params) {
    // TODO: implement prepareWorkingDirectory
    throw UnimplementedError();
  }

  @override
  Future<String> getDictionaryName(ImportProcessingParams params) {
    // TODO: implement getDictionaryName
    throw UnimplementedError();
  }

  @override
  Future<List<DictionaryEntry>> extractDictionaryEntries(
      ImportProcessingParams params) {
    // TODO: implement extractDictionaryEntries
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getDictionaryMetadata(
      ImportProcessingParams params) {
    // TODO: implement getDictionaryMetadata
    throw UnimplementedError();
  }

  @override
  DictionarySearchResult processResultsFromEntries(
      List<DictionaryEntry> entries) {
    // TODO: implement processResultsFromEntries
    throw UnimplementedError();
  }
}
