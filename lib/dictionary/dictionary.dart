import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';

abstract class Dictionary {
  Dictionary({
    required this.dictionaryName,
    required this.formatName,
  });

  /// The name of the dictionary. For example, this could be "Merriam-Webster
  /// Dictionary" or "大辞林" or "JMdict".
  ///
  /// Dictionary names are meant to be unique, meaning two dictionaries of the
  /// same name should not be allowed to be added in the database. The
  /// database will also effectively use this dictionary name as a directory
  /// prefix.
  final String dictionaryName;

  /// The format that the dictionary was sourced from.
  final String formatName;

  /// Get the format from the format name.
  DictionaryFormat getDictionaryFormat(String formatName);

  /// Search the database for a given search term and return a list of
  /// appropriate [DictionaryEntry] items.
  List<DictionaryEntry> searchForEntries(String searchTerm);

  /// Given a list of [DictionaryEntry], add these to the database.
  Future<void> addEntries(List<DictionaryEntry> entries);

  /// Delete this dictionary and erase its contents from the database.
  Future<void> deleteDictionary();
}
