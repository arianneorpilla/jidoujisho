import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement that can be used to select an audio file.
class PickAudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  PickAudioEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: 'Pick Audio',
          description: 'Pick an audio file to use with an external picker.',
          icon: Icons.upload_file,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'pick_audio';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    AudioExportField audioField = field as AudioExportField;
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (pickedFile == null) {
      return;
    }

    File file = File(pickedFile.files.single.path!);

    Directory appDirDoc = await getApplicationSupportDirectory();
    String pickAudioPath = '${appDirDoc.path}/audioRecorder';
    Directory pickAudioDir = Directory(pickAudioPath);
    if (pickAudioDir.existsSync()) {
      pickAudioDir.deleteSync(recursive: true);
    }
    pickAudioDir.createSync(recursive: true);

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory audioDir = Directory('$pickAudioPath/$timestamp');
    String audioPath = '${audioDir.path}/audio';
    audioDir.createSync(recursive: true);

    file.copySync(audioPath);
    File audioFile = File(audioPath);

    await audioField.setAudio(
      cause: cause,
      appModel: appModel,
      creatorModel: creatorModel,
      newAutoCannotOverride: false,
      generateAudio: () async {
        return audioFile;
      },
    );
  }

  @override
  Future<File?> fetchAudio({
    required AppModel appModel,
    required BuildContext context,
    required String term,
    required String reading,
  }) async {
    return null;
  }
}
