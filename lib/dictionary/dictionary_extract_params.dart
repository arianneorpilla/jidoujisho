import 'package:chisa/dictionary/dictionary_entry.dart';

class DictionaryExtractParams {
  DictionaryExtractParams({
    required this.dictionaryName,
    required this.dictionaryEntries,
  });

  /// The name of the dictionary discerned from the dictionary file.
  final String dictionaryName;

  /// Entries extracted from the dictionary file.
  final List<DictionaryEntry> dictionaryEntries;
}
