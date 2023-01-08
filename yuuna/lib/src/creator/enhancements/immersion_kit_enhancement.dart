import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:http/http.dart' as http;

/// An entity used to neatly return and organise results fetched from
/// ImmersionKit.
class ImmersionKitResult {
  /// Define a result with the given parameters.
  ImmersionKitResult({
    required this.text,
    required this.source,
    required this.imageUrl,
    required this.audioUrl,
    required this.wordList,
    required this.wordIndices,
  });

  /// The sentence in plain unformatted form.
  String text;

  /// The context from which the text was obtained.
  String source;

  /// The image of the context.
  String imageUrl;

  /// The audio of the context.
  String audioUrl;

  /// List of split words.
  List<String> wordList;

  /// Index of the words to highlight.
  List<int> wordIndices;
}

/// An enhancement used to fetch example sentences via Massif.
class ImmersionKitEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  ImmersionKitEnhancement()
      : super(
          uniqueKey: key,
          label: 'ImmersionKit',
          description:
              'Get example sentences complete with an image and audio.',
          icon: Icons.movie,
          field: TermField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'immersion_kit';

  /// Used to store results that have already been found at runtime.
  final Map<String, List<ImmersionKitResult>> _immersionKitCache = {};

  /// Client used to communicate with the Massif API.
  final http.Client _client = http.Client();

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    Directory appDirDoc = await getApplicationSupportDirectory();
    String immersionKitImagePath = '${appDirDoc.path}/immersion_kit';
    Directory immersionKitImageDir = Directory(immersionKitImagePath);
    if (immersionKitImageDir.existsSync()) {
      immersionKitImageDir.deleteSync(recursive: true);
    }
    immersionKitImageDir.createSync(recursive: true);

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory directory = Directory('${immersionKitImageDir.path}/$timestamp');
    directory.createSync();

    String searchTerm = creatorModel.getFieldController(field).text;
    List<ImmersionKitResult> exampleSentences = await searchForSentences(
      context: context,
      appModel: appModel,
      searchTerm: searchTerm,
    );

    appModel.openImmersionKitSentenceDialog(
      exampleSentences: exampleSentences,
      onSelect: (selection) async {
        creatorModel.getFieldController(SentenceField.instance).text =
            selection.text;

        await ImageField.instance.setImages(
          cause: cause,
          appModel: appModel,
          creatorModel: creatorModel,
          newAutoCannotOverride: false,
          generateImages: () async {
            String imagePath = '${directory.path}/image';
            File imageFile = File(imagePath);
            http.Response imageResponse =
                await http.get(Uri.parse(selection.imageUrl));
            imageFile.writeAsBytesSync(imageResponse.bodyBytes);

            return [NetworkToFileImage(file: imageFile)];
          },
        );

        await AudioSentenceField.instance.setAudio(
          appModel: appModel,
          creatorModel: creatorModel,
          searchTerm: searchTerm,
          newAutoCannotOverride: false,
          cause: cause,
          generateAudio: () async {
            String audioPath = '${directory.path}/audio.mp3';
            File audioFile = File(audioPath);
            http.Response audioResponse =
                await http.get(Uri.parse(selection.audioUrl));
            audioFile.writeAsBytesSync(audioResponse.bodyBytes);

            return audioFile;
          },
        );
      },
    );
  }

  /// Search the Massif API for example sentences and return a list of results.
  Future<List<ImmersionKitResult>> searchForSentences({
    required BuildContext context,
    required AppModel appModel,
    required String searchTerm,
  }) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }

    if (_immersionKitCache[searchTerm] != null) {
      return _immersionKitCache[searchTerm]!;
    }

    List<ImmersionKitResult> results = [];

    late http.Response response;

    try {
      /// Query the ImmersionKit API for results.
      response = await _client.get(Uri.parse(
          'https://api.immersionkit.com/look_up_dictionary?keyword=${Uri.encodeComponent(searchTerm)}&sort=shortness&min_length=${max(searchTerm.length, 10)}'));

      Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

      /// For each response, create a [ImmersionKitResult] that can be used to display
      /// the widget as well as hold the sentence and source data.
      List<Map<String, dynamic>> dataResponse =
          List<Map<String, dynamic>>.from(json['data']);

      Map<String, dynamic> firstHit = dataResponse.first;

      List<Map<String, dynamic>> examples =
          List<Map<String, dynamic>>.from(firstHit['examples']);

      if (examples.isEmpty) {
        response = await _client.get(Uri.parse(
            'https://api.immersionkit.com/look_up_dictionary?keyword=${Uri.encodeComponent(searchTerm)}'));
        json = jsonDecode(utf8.decode(response.bodyBytes));
        dataResponse = List<Map<String, dynamic>>.from(json['data']);
        firstHit = dataResponse.first;
        examples = List<Map<String, dynamic>>.from(firstHit['examples']);
      }

      for (Map<String, dynamic> example in examples) {
        String source = example['deck_name'];
        String text = example['sentence'];

        List<String> wordList = List<String>.from(example['word_list']);
        List<int> wordIndices = List<int>.from(example['word_index']);

        String imageUrl = example['image_url'];
        String audioUrl = example['sound_url'];

        ImmersionKitResult result = ImmersionKitResult(
          text: text,
          source: source,
          imageUrl: imageUrl,
          audioUrl: audioUrl,
          wordList: wordList,
          wordIndices: wordIndices,
        );

        /// Sentence examples that are merely the word itself are pretty
        /// redundant.
        if (result.text != searchTerm) {
          results.add(result);
        }
      }

      /// Make sure series aren't too consecutive.
      results.shuffle();
      results.sort((a, b) => a.text.length.compareTo(b.text.length));

      /// Save this into cache.
      _immersionKitCache[searchTerm] = results;

      return results;
    } catch (e) {
      /// Used to log if this third-party service is down or changes domains.
      appModel.showFailedToCommunicateMessage();

      throw Exception(
        'Failed to communicate with ImmersionKit: ${response.reasonPhrase}',
      );
    }
  }
}
