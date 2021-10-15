import 'package:flutter/material.dart';

/// A model for updating the import status of a dictionary.
class DictionaryProgressModel with ChangeNotifier {
  String _progressMessage = "";
  final List<String> _filesProcessed = [];

  String get progressMessage => _progressMessage;
  List<String> get filesProcessed => _filesProcessed;

  /// Called after a file has finished being extracted for entries.
  void updateProgress(
    String progressMessage,
    String fileName,
  ) {
    _progressMessage = progressMessage;
    _filesProcessed.add(fileName);
    notifyListeners();
  }
}
