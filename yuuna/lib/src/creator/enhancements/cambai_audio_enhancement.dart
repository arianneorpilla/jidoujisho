import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';

/// An enhancement for synthesising audio via CAMB AI's text-to-speech API.
///
/// Unlike [ForvoAudioEnhancement] and [JapanesePod101AudioEnhancement],
/// which fetch pre-recorded audio, this enhancement generates speech on
/// demand, so it works for any word — including rare terms that have no
/// community recordings — and supports every language CAMB AI supports.
///
/// Requires a CAMB AI API key, supplied at build time via:
///     flutter build ... --dart-define=CAMB_API_KEY=<your key>
///
/// Get a key at https://studio.camb.ai.
class CambAiAudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  CambAiAudioEnhancement()
      : super(
          uniqueKey: key,
          label: 'CAMB AI',
          description:
              'Generate word audio with CAMB AI text-to-speech '
              '(multi-language, low-latency).',
          icon: Icons.record_voice_over,
          field: AudioField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'cambai_audio';

  /// Compile-time API key. Override with
  /// ``flutter build ... --dart-define=CAMB_API_KEY=<key>``.
  static const String _apiKey =
      String.fromEnvironment('CAMB_API_KEY', defaultValue: '');

  /// Endpoint for the streaming TTS API.
  static const String _endpoint = 'https://client.camb.ai/apis/tts-stream';

  /// MARS model to use. ``mars-pro`` trades ~1s latency for higher quality,
  /// which is the right tradeoff for one-shot word lookups where audio is
  /// cached and played on demand.
  static const String _speechModel = 'mars-pro';

  /// Maps jidoujisho [Language.languageCode]s to CAMB AI BCP-47 codes.
  static const Map<String, String> _languageToBcp47 = <String, String>{
    'ja': 'ja-jp',
    'en': 'en-us',
    'es': 'es-es',
    'fr': 'fr-fr',
    'de': 'de-de',
    'it': 'it-it',
    'pt': 'pt-br',
    'nl': 'nl-nl',
    'ru': 'ru-ru',
    'ko': 'ko-kr',
    'zh': 'zh-cn',
    'hi': 'hi-in',
    'ar': 'ar-sa',
  };

  /// Maps BCP-47 codes to a default CAMB voice ID. These are public voices
  /// from https://client.camb.ai/apis/list-voices and can be overridden via
  /// per-language settings in a future iteration.
  static const Map<String, int> _defaultVoiceByLanguage = <String, int>{
    'ja-jp': 147320,
    'en-us': 147320,
    'es-es': 147320,
    'fr-fr': 147320,
    'de-de': 147320,
    'it-it': 147320,
    'pt-br': 147320,
    'nl-nl': 147320,
    'ru-ru': 147320,
    'ko-kr': 147320,
    'zh-cn': 147320,
    'hi-in': 147320,
    'ar-sa': 147320,
  };

  /// Cache of already-synthesised audio keyed by ``<language>/<text>``.
  final Map<String, File> _cache = <String, File>{};

  /// HTTP client reused across requests.
  final http.Client _client = http.Client();

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    AudioExportField audioField = field as AudioExportField;
    String? searchTerm;

    if (cause != EnhancementTriggerCause.auto) {
      searchTerm = audioField.getSearchTermWithFallback(
        appModel: appModel,
        creatorModel: creatorModel,
        fallbackSearchTerms: [
          TermField.instance,
          ReadingField.instance,
        ],
      );
    } else {
      searchTerm = creatorModel.getFieldController(TermField.instance).text;
      if (searchTerm.trim().isEmpty) {
        return;
      }
    }

    await audioField.setAudio(
      appModel: appModel,
      creatorModel: creatorModel,
      searchTerm: searchTerm,
      newAutoCannotOverride: false,
      cause: cause,
      generateAudio: () async {
        final String reading =
            creatorModel.getFieldController(ReadingField.instance).text;
        return fetchAudio(
          appModel: appModel,
          context: context,
          term: searchTerm!,
          reading: reading,
        );
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
    if (_apiKey.isEmpty) {
      debugPrint(
        'CambAiAudioEnhancement: CAMB_API_KEY is empty. Rebuild the app '
        'with --dart-define=CAMB_API_KEY=<your key>.',
      );
      return null;
    }

    // For Japanese, prefer the kana reading so kanji are pronounced correctly.
    // For other languages, the reading field is usually empty — fall back
    // to the term itself.
    final String textToSpeak =
        reading.trim().isNotEmpty ? reading.trim() : term.trim();
    if (textToSpeak.isEmpty) {
      return null;
    }

    final Language language = appModel.targetLanguage;
    final String bcp47 =
        _languageToBcp47[language.languageCode] ?? 'en-us';
    final int voiceId = _defaultVoiceByLanguage[bcp47] ?? 147320;

    final String cacheKey = '$bcp47/$voiceId/$textToSpeak';
    final File? cached = _cache[cacheKey];
    if (cached != null && cached.existsSync()) {
      return cached;
    }

    try {
      final http.Response response = await _client.post(
        Uri.parse(_endpoint),
        headers: <String, String>{
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'text': textToSpeak,
          'voice_id': voiceId,
          'language': bcp47,
          'speech_model': _speechModel,
          'output_configuration': <String, String>{'format': 'mp3'},
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          'CambAiAudioEnhancement: tts-stream returned '
          '${response.statusCode}: ${response.body}',
        );
        return null;
      }

      final Directory supportDir = await getApplicationSupportDirectory();
      final Directory cambDir =
          Directory('${supportDir.path}/cambAiAudio')..createSync(recursive: true);
      final String safeFileName =
          '${bcp47}_${voiceId}_${textToSpeak.hashCode}.mp3';
      final File file = File('${cambDir.path}/$safeFileName');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      _cache[cacheKey] = file;
      return file;
    } catch (e) {
      debugPrint('CambAiAudioEnhancement: request failed: $e');
      return null;
    }
  }
}
