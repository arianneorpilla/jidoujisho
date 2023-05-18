import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// A media source that allows the user to stream video from a URL.
class PlayerNetworkStreamSource extends PlayerMediaSource {
  /// Define this media source.
  PlayerNetworkStreamSource._privateConstructor()
      : super(
          uniqueKey: 'player_network_stream',
          sourceName: 'Network Stream',
          description: 'Stream videos from a direct URL.',
          icon: Icons.podcasts,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static PlayerNetworkStreamSource get instance => _instance;

  static final PlayerNetworkStreamSource _instance =
      PlayerNetworkStreamSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    return PlayerSourcePage(
      item: item,
      source: this,
      useHistory: false,
    );
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildSettingsButton(
        appModel: appModel,
        context: context,
        ref: ref,
      ),
      FloatingSearchBarAction(
        child: JidoujishoIconButton(
          size: Theme.of(context).textTheme.titleLarge?.fontSize,
          tooltip: t.stream,
          icon: Icons.link,
          onTap: () async {
            showStreamDialog(
              appModel: appModel,
              context: context,
              ref: ref,
            );
          },
        ),
      ),
    ];
  }

  /// Produce media item from URL.
  MediaItem getMediaItemFromUrl({
    required String videoUrl,
    String? extra,
    String? title,
    int? position,
  }) {
    return MediaItem(
      title: title ?? videoUrl,
      mediaIdentifier: videoUrl,
      mediaSourceIdentifier: uniqueKey,
      mediaTypeIdentifier: mediaType.uniqueKey,
      extra: extra,
      position: position ?? 0,
      duration: 0,
      canEdit: false,
      canDelete: false,
    );
  }

  /// Shows the dialog where the user can enter a link.
  void showStreamDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    showDialog(
      context: context,
      builder: (context) => NetworkStreamDialogPage(
        onPlay: (videoUrl) {
          Navigator.pop(context);

          MediaItem item = getMediaItemFromUrl(videoUrl: videoUrl);

          appModel.openMedia(
            ref: ref,
            mediaSource: this,
            item: item,
          );
        },
      ),
    );
  }

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    showStreamDialog(
      appModel: appModel,
      context: context,
      ref: ref,
    );
  }

  @override
  Future<VlcPlayerController> preparePlayerController({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    String dataSource = item.mediaIdentifier;
    int startTime = item.position;

    List<String> videoParams = [
      VlcVideoOptions.dropLateFrames(false),
      VlcVideoOptions.skipFrames(false),
    ];
    List<String> advancedParams = [
      '--start-time=$startTime',
      VlcAdvancedOptions.networkCaching(20000),
    ];
    List<String> soutParams = [
      '--start-time=$startTime',
      VlcStreamOutputOptions.soutMuxCaching(20000),
    ];
    List<String> audioParams = [
      '--audio-language=${appModel.targetLanguage.languageCode},${appModel.appLocale.languageCode}',
      '--sub-track=99999',
      if (appModel.playerUseOpenSLES) '--aout=opensles',
    ];

    return VlcPlayerController.network(
      dataSource,
      hwAcc: appModel.playerHardwareAcceleration ? HwAcc.auto : HwAcc.disabled,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions(advancedParams),
        audio: VlcAudioOptions(audioParams),
        sout: VlcStreamOutputOptions(soutParams),
        video: VlcVideoOptions(videoParams),
      ),
    );
  }

  @override
  Future<List<SubtitleItem>> prepareSubtitles({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    List<SubtitleItem> items = [];

    Map<String, dynamic> intentExtra = jsonDecode(item.extra ?? '{}');

    List<String>? fileNames;
    List<String>? subtitleNames;

    if (intentExtra['subs'] != null && intentExtra['subs.name'] != null) {
      fileNames ??= List<String>.from(intentExtra['subs']);
      subtitleNames ??= List<String>.from(intentExtra['subs.name']);
    }

    if (fileNames == null && intentExtra['subtitles_location'] != null) {
      fileNames = [intentExtra['subtitles_location']];
      subtitleNames = ['External'];
    }

    fileNames ??= [];
    subtitleNames ??= [];

    for (int i = 0; i < fileNames.length; i++) {
      String fileName = fileNames[i];
      String subtitleName = subtitleNames[i];

      String temporaryDirectoryPath = (await getTemporaryDirectory()).path;
      String temporaryFileName =
          'jidoujisho-${DateFormat('yyyyMMddTkkmmss').format(DateTime.now())}';

      try {
        File file = File('$temporaryDirectoryPath/$temporaryFileName.ass');

        http.Response request = await http.get(Uri.parse(fileName));
        Uint8List bytes = request.bodyBytes;
        await file.writeAsBytes(bytes);
        SubtitleItem? subtitleItem = await SubtitleUtils.subtitlesFromFile(
          file: file,
          metadata: subtitleName,
          source: fileName,
          type: SubtitleItemType.webSubtitle,
        );
        items.add(subtitleItem);
      } catch (e) {
        debugPrint('$e');
      }
    }

    String? preferredFilename;
    if (intentExtra['subs.enable'] != null) {
      List<String> enabledSubtitles =
          List<String>.from(intentExtra['subs.enable']);
      if (enabledSubtitles.isNotEmpty) {
        preferredFilename = enabledSubtitles.first;
      }
    }

    SubtitleItem? preferredItem =
        items.firstWhereOrNull((item) => preferredFilename == item.source);

    items.remove(preferredItem);
    if (preferredItem != null) {
      items.insert(0, preferredItem);
    }

    return items;
  }
}
