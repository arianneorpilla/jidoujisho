import 'dart:io';
import 'dart:isolate';

/// For isolate communication purposes. See a dictionary format's directory
/// preparation method.
class PrepareDirectoryParams {
  /// Prepare parameters for a dictionary format's directory preparation method.
  PrepareDirectoryParams({
    required this.file,
    required this.workingDirectory,
    required this.sendPort,
  });

  /// A file from which the contents must be put in working directory.
  final File file;

  /// A working directory to be used in isolation and where data is to be
  /// handled in later steps.
  final Directory workingDirectory;

  /// For communication with a [ReceivePort] for isolate updates.
  final SendPort sendPort;
}

/// For isolate communication purposes. See a dictionary format's name, entries
/// and metadata preparation methods.
class PrepareDictionaryParams {
  /// Prepare parameters for a dictionary format's name, entries and metadata
  /// preparation methods.
  PrepareDictionaryParams({
    required this.workingDirectory,
    required this.sendPort,
  });

  /// A working directory from which to extract dictionary data from.
  final Directory workingDirectory;

  /// For communication with the [ReceivePort] for isolate updates.
  final SendPort sendPort;
}
