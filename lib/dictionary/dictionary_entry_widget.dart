import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:flutter/material.dart';

/// A standard dictionary entry widget for use of any simple formats, to be
/// overriden by any more complex formats if so desired.
class DictionaryEntryWidget {
  DictionaryEntryWidget({
    required this.context,
    required this.dictionaryEntry,
  });

  final BuildContext context;
  final DictionaryEntry dictionaryEntry;

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

  Widget buildMeaning() {
    return Text(
      "\n${dictionaryEntry.meaning}\n",
      style: const TextStyle(
        fontSize: 15,
      ),
    );
  }

  Widget buildExtra() {
    return const SizedBox.shrink();
  }

  Widget buildMainWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildWord(),
        const SizedBox(height: 5),
        buildReading(),
        buildMeaning(),
      ],
    );
  }
}
