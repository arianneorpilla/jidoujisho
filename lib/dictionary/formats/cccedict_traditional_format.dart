import 'dart:async';
import 'dart:io';

import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_import.dart';
import 'package:flutter/semantics.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archive/flutter_archive.dart';

class CCCEdictTraditionalFormat extends DictionaryFormat {
  CCCEdictTraditionalFormat()
      : super(
          formatName: "CC-CEDICT (Traditional)",
          prepareWorkingDirectory:
              prepareWorkingDirectoryCCCEdictSimplifiedFormat,
          getDictionaryName: getDictionaryNameCCCEdictSimplifiedFormat,
          getDictionaryEntries: getDictionaryEntriesCCCEdictSimplifiedFormat,
          getDictionaryMetadata: getDictionaryMetadataCCCEdictSimplifiedFormat,
        );
}

@override
FutureOr<void> prepareWorkingDirectoryCCCEdictSimplifiedFormat(
    ImportPreparationParams params) async {
  await ZipFile.extractToDirectory(
      zipFile: params.file, destinationDir: params.workingDirectory);
}

@override
FutureOr<String> getDictionaryNameCCCEdictSimplifiedFormat(
    ImportDirectoryParams params) {
  return "CC-CEDICT (Traditional)";
}

@override
FutureOr<List<DictionaryEntry>> getDictionaryEntriesCCCEdictSimplifiedFormat(
    ImportDirectoryParams params) async {
  List<DictionaryEntry> entries = [];

  File cedictFile = File(p.join(params.workingDirectory.path, "cedict_ts.u8"));
  List<String> lines = cedictFile.readAsStringSync().split("\n");

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    if (line.startsWith("#")) {
      continue;
    }

    RegExp regExp = RegExp("([^\\s]+)\\s([^\\s]+)\\s(\\[.+\\])\\s(/.+/)");

    RegExpMatch match = regExp.firstMatch(line)!;

    String word = match.group(1) ?? ""; // group 1 for traditional
    String reading = match.group(3) ?? "";
    String unsplitTerms = match.group(4) ?? "";

    reading = reading.replaceAll("[", "").replaceAll("]", "");

    String meaning = "";
    List<String> terms = unsplitTerms.split("/");
    terms.removeWhere((term) => term.trim().isEmpty);
    if (terms.length == 1) {
      meaning = terms.first;
    } else {
      for (String term in terms) {
        meaning += "• $term\n";
      }
      meaning = meaning.trim();
    }

    DictionaryEntry entry = DictionaryEntry(
      word: word,
      reading: reading,
      meaning: meaning,
      popularity: meaning.split("\n").length.toDouble(),
    );

    entries.add(entry);

    if (i % 1000 == 0) {
      params.sendPort.send("Found ${entries.length} entries...");
    }
  }

  params.sendPort.send("Found ${entries.length} entries...");

  return entries;
}

@override
FutureOr<Map<String, String>> getDictionaryMetadataCCCEdictSimplifiedFormat(
    ImportDirectoryParams params) {
  return {};
}
