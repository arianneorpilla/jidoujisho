import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:flutter/material.dart';

/// A standard dictionary entry widget for use of any simple formats, to be
/// overriden by any more complex formats if so desired.
class DictionaryWidget {
  DictionaryWidget({
    required this.context,
    required this.dictionaryEntry,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.selectable,
  });

  final BuildContext context;
  final DictionaryEntry dictionaryEntry;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final bool selectable;

  Widget buildWord() {
    return Text(
      dictionaryEntry.word,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget buildReading() {
    return Text(dictionaryEntry.reading);
  }

  Widget buildMeaning({required bool selectable}) {
    return SelectableText(
      dictionaryEntry.meaning,
      enableInteractiveSelection: selectable,
      toolbarOptions: const ToolbarOptions(copy: true),
      style: const TextStyle(
        fontSize: 15,
      ),
    );
  }

  Widget buildMainWidget({Widget? word, Widget? reading, Widget? meaning}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        word ?? buildWord(),
        const SizedBox(height: 5),
        reading ?? buildReading(),
        const SizedBox(height: 10),
        Flexible(
          child: SingleChildScrollView(
            child: meaning ?? buildMeaning(selectable: selectable),
          ),
        ),
      ],
    );
  }
}
