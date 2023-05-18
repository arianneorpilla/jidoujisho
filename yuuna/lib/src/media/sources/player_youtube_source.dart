import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:subtitle/subtitle.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Used to not block the UI isolate.
Future<ClosedCaptionManifest> computeCaptionsManifest(String videoId) async {
  YoutubeExplode yt = YoutubeExplode();
  ClosedCaptionManifest manifest = await yt.videos.closedCaptions.getManifest(
    videoId,
    formats: [ClosedCaptionFormat.vtt],
  );

  return manifest;
}

/// Used to not block the UI isolate.
Future<CommentsList?> computeCommentsList(CommentsList? commentsList) async {
  return commentsList?.nextPage();
}

/// Used to not block the UI isolate.
Future<Channel> computeChannel(String channelId) async {
  YoutubeExplode yt = YoutubeExplode();
  return yt.channels.get(channelId);
}

/// A global [Provider] for getting the paging controller for comments for a
/// video.
final commentsProvider =
    FutureProvider.family<PagingController<int, Comment>?, String>((ref, url) {
  return PlayerYoutubeSource.instance.getCommentsForVideo(url);
});

/// A global [Provider] for getting the paging controller for replies for a
/// comment.
final repliesProvider =
    FutureProvider.family<PagingController<int, Comment>?, Comment>(
        (ref, comment) {
  return PlayerYoutubeSource.instance.getRepliesForComment(comment);
});

/// A global [Provider] for getting the paging controller for replies for a
/// comment.
final channelProvider = FutureProvider.family<Channel, String>((ref, id) {
  return PlayerYoutubeSource.instance.getChannelFromId(id);
});

/// A media source that allows the user to stream a selected video from YouTube.
class PlayerYoutubeSource extends PlayerMediaSource {
  /// Define this media source.
  PlayerYoutubeSource._privateConstructor()
      : super(
          uniqueKey: 'player_youtube',
          sourceName: 'YouTube',
          description: 'Search and watch videos from YouTube.',
          icon: Icons.smart_display,
          implementsSearch: true,
          implementsHistory: true,
        );

  /// Get the singleton instance of this media type.
  static PlayerYoutubeSource get instance => _instance;

  static final PlayerYoutubeSource _instance =
      PlayerYoutubeSource._privateConstructor();

  /// HTTP client for search queries.
  final YoutubeHttpClient _client = YoutubeHttpClient();

  late final SearchClient _searchClient;
  late final VideoClient _videoClient;
  late final PlaylistClient _playlistClient;
  late final ChannelClient _channelClient;
  late final CommentsClient _commentsClient;

  final Map<String, Video> _videoCache = <String, Video>{};
  final Map<String, StreamManifest> _streamManifestCache =
      <String, StreamManifest>{};
  final Map<String, Map<int, VideoSearchList>> _searchListCache =
      <String, Map<int, VideoSearchList>>{};
  final Map<String, ClosedCaptionManifest> _closedCaptionManifestCache =
      <String, ClosedCaptionManifest>{};
  final Map<String, PagingController<int, MediaItem>> _pagingControllerCache =
      <String, PagingController<int, MediaItem>>{};
  final Map<String, Playlist> _playlistCache = <String, Playlist>{};
  final Map<String, PagingController<int, Comment>> _commentsPagingCache =
      <String, PagingController<int, Comment>>{};
  final Map<Comment, PagingController<int, Comment>> _repliesPagingCache =
      <Comment, PagingController<int, Comment>>{};
  final Map<String, Channel> _channelCache = {};
  final Map<String, SubtitleController> _subtitleControllerCache = {};

  @override
  Future<void> prepareResources() async {
    _searchClient = SearchClient(_client);
    _videoClient = VideoClient(_client);
    _playlistClient = PlaylistClient(_client);
    _channelClient = ChannelClient(_client);
    _commentsClient = CommentsClient(_client);
  }

  @override
  BaseMediaSearchBar? buildBar() {
    return const YoutubeMediaSearchBar();
  }

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    return PlayerSourcePage(
      item: item,
      source: this,
      useHistory: true,
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
      buildTrendingButton(
        context: context,
        ref: ref,
        appModel: appModel,
      ),
      buildCaptionFilterButton(
        context: context,
        ref: ref,
        appModel: appModel,
      ),
    ];
  }

  /// Allows user to launch trending playlists page.
  Widget buildTrendingButton({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.trending,
        icon: Icons.whatshot,
        onTap: () => showTrendingVideos(
          context: context,
          appModel: appModel,
        ),
      ),
    );
  }

  /// Allows user to toggle whether or not to filter for videos with
  /// closed captions.
  Widget buildCaptionFilterButton({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    ValueNotifier<bool> notifier = ValueNotifier<bool>(isCaptionFilterOn);

    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, value, child) {
          return JidoujishoIconButton(
            size: Theme.of(context).textTheme.titleLarge?.fontSize,
            tooltip: t.caption_filter,
            enabledColor: value ? Colors.red : null,
            icon: Icons.closed_caption,
            onTap: () {
              toggleCaptionFilter();
              notifier.value = !value;
            },
          );
        },
      ),
    );
  }

  @override
  Future<List<MediaItem>?> searchMediaItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) async {
    late VideoSearchList? searchList;

    searchTerm = searchTerm.trim();

    String storeKey = searchTerm;
    if (isCaptionFilterOn) {
      storeKey = '$searchTerm [filter:cc]';
    }

    _searchListCache[storeKey] ??= {};
    Map<int, VideoSearchList> store = _searchListCache[storeKey]!;

    if (pageKey == 1) {
      if (store[1] == null) {
        searchList = await _searchClient.search(searchTerm,
            filter: isCaptionFilterOn
                ? FeatureFilters.subTitles
                : TypeFilters.video);
      } else {
        searchList = store[1];
      }
    } else {
      VideoSearchList lastList = store[pageKey - 1]!;
      searchList = await lastList.nextPage();
    }

    if (searchList == null) {
      return null;
    } else {
      store[pageKey] = searchList;
    }

    List<MediaItem> items = [];
    List<Video> videos = [];

    for (Video video in searchList) {
      if (video.duration == null ||
          video.duration == Duration.zero ||
          video.isLive) {
        continue;
      }

      videos.add(video);
      _videoCache[video.url] = video;
      items.add(getMediaItem(video));
    }

    return items;
  }

  @override
  Future<List<String>> generateSearchSuggestions(String searchTerm) async {
    return _searchClient.getQuerySuggestions(searchTerm);
  }

  /// Gets a Video instance from a Uri with caching.
  String getChannelIdFromVideo(String videoUrl) {
    Video video = _videoCache[videoUrl]!;
    return video.channelId.value;
  }

  /// Gets a Video instance from a Uri with caching.
  Future<Video> getVideoFromUrl(String url) async {
    Video? video = _videoCache[url];
    if (video == null) {
      video = await _videoClient.get(url);
      _videoCache[url] = video;
    }

    return video;
  }

  /// Creatres a media item from a URL.
  Future<MediaItem> getMediaItemFromUrl(String url) async {
    Video video = await getVideoFromUrl(url);
    return getMediaItem(video);
  }

  /// Creates a media item from a YouTube [Video] entity.
  MediaItem getMediaItem(Video video) {
    return MediaItem(
      title: video.title,
      mediaIdentifier: video.url,
      mediaSourceIdentifier: uniqueKey,
      mediaTypeIdentifier: mediaType.uniqueKey,
      position: 0,
      duration: video.duration?.inSeconds ?? 0,
      canDelete: true,
      canEdit: false,
      imageUrl: video.thumbnails.maxResUrl,
      extraUrl: video.thumbnails.mediumResUrl,
      author: video.author,
      authorIdentifier: video.channelId.value,
    );
  }

  @override
  Future<void> prepareMediaResources({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    String videoId = VideoId(item.mediaIdentifier).value;
    bool subtitlesCached = getSubtitleItems(videoId) != null &&
        getSubtitleMetadata(videoId) != null;
    bool streamCached = _streamManifestCache[videoId] != null;

    if (!subtitlesCached || !streamCached) {
      ComputeManifestParams params = ComputeManifestParams(
        videoId: videoId,
        subtitlesCached: subtitlesCached,
        closedCaptionsManifest: _closedCaptionManifestCache[videoId],
      );
      VideoManifest videoManifest = await compute(computeManifests, params);
      _streamManifestCache[videoId] = videoManifest.streamManifest;
      _closedCaptionManifestCache[videoId] ??=
          videoManifest.closedCaptionManifest;

      if (!subtitlesCached) {
        setSubtitleMetadata(
          videoId: videoId,
          metadata: videoManifest.subtitlesByLanguageCache.keys.toList(),
        );
        setSubtitleItems(
          videoId: videoId,
          subtitles: videoManifest.subtitlesByLanguageCache.values.toList(),
        );
      }
    }
  }

  @override
  Future<VlcPlayerController> preparePlayerController({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    String dataSource = await getDataSource(item);
    String audioUrl = await getAudioUrl(item, dataSource);

    int startTime = item.position;
    if (item.duration - item.position < 60) {
      startTime = 0;
    }

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
      '--input-slave=$audioUrl',
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

  /// Gets the [StreamManifest] if in cache and fetches it
  /// and stores it if otherwise.
  StreamManifest getStreamManifest(MediaItem item) {
    String videoId = VideoId(item.mediaIdentifier).value;
    return _streamManifestCache[videoId]!;
  }

  /// Gets the [ClosedCaptionManifest] if in cache and fetches it
  /// and stores it if otherwise.
  Future<ClosedCaptionManifest> getClosedCaptionsManifest(
      MediaItem item) async {
    String videoId = VideoId(item.mediaIdentifier).value;

    ClosedCaptionManifest? manifest = _closedCaptionManifestCache[videoId];

    if (manifest == null) {
      manifest = await compute(computeCaptionsManifest, videoId);
      _closedCaptionManifestCache[videoId] = manifest!;
    }

    return manifest;
  }

  @override
  Future<List<SubtitleItem>> prepareSubtitles({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    String videoId = VideoId(item.mediaIdentifier).value;
    List<String> subtitlesList = [...getSubtitleItems(videoId)!];
    List<String> metadataList = [...getSubtitleMetadata(videoId)!];

    String? targetLanguageItem;
    String? appLanguageItem;
    String? targetLanguageMeta;
    String? appLanguageMeta;
    int targetLanguageIndex = -1;
    int appLanguageIndex = -1;

    targetLanguageIndex = metadataList.indexWhere(
        (e) => e.contains('[${appModel.targetLanguage.languageCode}]'));
    appLanguageIndex = metadataList
        .indexWhere((e) => e.contains('[${appModel.appLocale.languageCode}]'));

    if (targetLanguageIndex != -1) {
      targetLanguageMeta = metadataList.removeAt(targetLanguageIndex);
      targetLanguageItem = subtitlesList.removeAt(targetLanguageIndex);
    }

    targetLanguageIndex = metadataList.indexWhere(
        (e) => e.contains('[${appModel.targetLanguage.languageCode}]'));
    appLanguageIndex = metadataList
        .indexWhere((e) => e.contains('[${appModel.appLocale.languageCode}]'));

    if (appLanguageIndex != -1 && targetLanguageIndex != appLanguageIndex) {
      appLanguageMeta = metadataList.removeAt(appLanguageIndex);
      appLanguageItem = subtitlesList.removeAt(appLanguageIndex);
    }

    subtitlesList = [
      if (targetLanguageItem != null) targetLanguageItem,
      if (appLanguageItem != null) appLanguageItem,
      ...subtitlesList,
    ];

    metadataList = [
      if (targetLanguageMeta != null) targetLanguageMeta,
      if (appLanguageMeta != null) appLanguageMeta,
      ...metadataList,
    ];

    return subtitlesList.mapIndexed((index, subtitles) {
      String metadata = metadataList[index];

      _subtitleControllerCache.putIfAbsent(
        subtitles,
        () => SubtitleController(
          provider: SubtitleProvider.fromString(
            data: subtitles,
            type: SubtitleType.vtt,
          ),
        ),
      );
      SubtitleController controller = _subtitleControllerCache[subtitles]!;

      return SubtitleItem(
        controller: controller,
        metadata: metadata,
        type: SubtitleItemType.webSubtitle,
      );
    }).toList();
  }

  /// Get cached item.
  List<String>? getSubtitleItems(String videoId) {
    return getPreference<List<String>?>(
      key: 'subtitles_cache/$videoId',
      defaultValue: null,
    );
  }

  /// Set cached item.
  void setSubtitleItems(
      {required String videoId, required List<String> subtitles}) async {
    await setPreference<List<String>?>(
      key: 'subtitles_cache/$videoId',
      value: subtitles,
    );
  }

  /// Get cached item.
  List<String>? getSubtitleMetadata(String videoId) {
    return getPreference<List<String>?>(
      key: 'subtitle_metadata_cache/$videoId',
      defaultValue: null,
    );
  }

  /// Set cached item.
  void setSubtitleMetadata(
      {required String videoId, required List<String> metadata}) async {
    await setPreference<List<String>?>(
      key: 'subtitle_metadata_cache/$videoId',
      value: metadata,
    );
  }

  /// Gets the network URL for a certain video quality.
  String getVideoUrlForQuality({
    required StreamManifest manifest,
    required VideoQuality quality,
  }) {
    List<VideoStreamInfo> muxed = manifest.muxed
        .where((e) => e.videoCodec.contains('avc1'))
        .where((e) => e.videoQuality == quality)
        .toList();
    if (muxed.isNotEmpty) {
      return muxed.withHighestBitrate().url.toString();
    }

    return manifest.videoOnly
        .where((e) => e.videoCodec.contains('avc1'))
        .where((e) => e.videoQuality == quality)
        .withHighestBitrate()
        .url
        .toString();
  }

  /// Used to get the data source to use as the video URL. This also sets the
  /// caching for both manifests.
  Future<String> getDataSource(MediaItem item) async {
    StreamManifest manifest = getStreamManifest(item);

    List<VideoQuality> qualities = getVideoQualities(manifest);
    VideoQuality currentQuality = preferredQuality;
    while (!qualities.contains(currentQuality)) {
      if (currentQuality.index == 0) {
        currentQuality = qualities.first;
        break;
      }
      VideoQuality fallbackQuality =
          VideoQuality.values[currentQuality.index - 1];
      qualities.remove(currentQuality);
      currentQuality = fallbackQuality;
    }

    return getVideoUrlForQuality(
      manifest: manifest,
      quality: currentQuality,
    );
  }

  /// Used to get the audio source for a video.
  Future<String> getAudioUrl(MediaItem item, String dataSource) async {
    StreamManifest manifest = getStreamManifest(item);

    if (manifest.muxed
        .where((e) => e.videoCodec.contains('avc1'))
        .map((e) => e.url.toString())
        .contains(dataSource)) {
      return dataSource;
    } else {
      AudioStreamInfo streamAudioInfo =
          manifest.audioOnly.sortByBitrate().lastWhere((info) {
        return info.audioCodec.contains('mp4a');
      });
      return streamAudioInfo.url.toString();
    }
  }

  /// Gets the video qualities available for a [StreamManifest].
  List<VideoQuality> getVideoQualities(
    StreamManifest manifest,
  ) {
    List<VideoQuality> muxed = manifest.muxed
        .where((e) => e.videoCodec.contains('avc1'))
        .map((e) => e.videoQuality)
        .toList();
    List<VideoQuality> videoOnly = manifest.videoOnly
        .where((e) => e.videoCodec.contains('avc1'))
        .map((e) => e.videoQuality)
        .toList();

    List<VideoQuality> qualities = [
      ...muxed,
      ...videoOnly,
    ];

    qualities = qualities.toSet().toList();
    qualities.sort((a, b) => a.index.compareTo(b.index));
    return qualities;
  }

  /// Add your target language country under this Trending 20 playlist support.
  String? getTrendingPlaylistId(Language language) {
    // Language Customizable
    switch (language.languageCountryCode) {
      case 'ja-JP': // Japanese (Japan)
        return 'PLuXL6NS58Dyx-wTr5o7NiC7CZRbMA91DC';
      case 'en-US': // English (United States)
        return 'PLrEnWoR732-DtKgaDdnPkezM_nDidBU9H';
      default:
        return null;
    }
  }

  /// Get the preferred quality.
  VideoQuality get preferredQuality {
    int index = getPreference<int>(
        key: 'preferred_quality', defaultValue: VideoQuality.medium480.index);
    return VideoQuality.values[index];
  }

  /// Set the preferred quality.
  void setPreferredQuality(VideoQuality quality) async {
    setPreference<int>(key: 'preferred_quality', value: quality.index);
  }

  /// Gets a video's cached caption languages.
  List<String>? getCaptionsLanguages({
    required MediaItem item,
    required bool autoGenerated,
  }) {
    return getPreference<List<String>?>(
      key: 'captions/$autoGenerated/${item.mediaIdentifier}',
      defaultValue: null,
    );
  }

  /// Persists a video's caption languages.
  void setCaptionsLanguages({
    required MediaItem item,
    required List<String> captionsLanguages,
    required bool autoGenerated,
  }) {
    setPreference<List<String>?>(
      key: 'captions/$autoGenerated/${item.mediaIdentifier}',
      value: captionsLanguages,
    );
  }

  /// Get the caption filter on the history page.
  bool get isCaptionFilterOn {
    return getPreference<bool>(key: 'caption_filter', defaultValue: false);
  }

  /// Toggle the caption filter on the history page.
  void toggleCaptionFilter() async {
    setPreference<bool>(key: 'caption_filter', value: !isCaptionFilterOn);
  }

  @override
  String getDisplaySubtitleFromMediaItem(MediaItem item) {
    return item.author ?? '';
  }

  /// Caches fetched playlists.
  Future<Playlist> getPlaylistFromId(String playlistId) async {
    Playlist? playlist = _playlistCache[playlistId];
    if (playlist == null) {
      playlist = await _playlistClient.get(playlistId);
      _playlistCache[playlistId] ??= playlist;
    }

    return playlist;
  }

  /// Launch a trending videos page.
  Future<void> showTrendingVideos({
    required AppModel appModel,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    String playlistId = getTrendingPlaylistId(appModel.targetLanguage)!;
    Playlist trendingPlaylist = await getPlaylistFromId(playlistId);

    PagingController<int, MediaItem>? pagingController =
        _pagingControllerCache[playlistId];
    if (pagingController == null) {
      pagingController = PagingController(firstPageKey: 1);

      pagingController.addPageRequestListener((pageKey) async {
        List<MediaItem> items = [];
        List<Video> videos = [];

        try {
          videos = await _playlistClient
              .getVideos(playlistId)
              .where((e) => e.duration != null)
              .toList();
          for (Video video in videos) {
            items.add(getMediaItem(video));
          }
        } finally {
          pagingController?.appendLastPage(items);
        }
      });

      _pagingControllerCache[playlistId] = pagingController;
    }

    // Prevent recursion.
    navigator.popUntil((route) => route.isFirst);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => YoutubeVideoResultsPage(
          showAppBar: true,
          title: trendingPlaylist.title,
          pagingController: pagingController!,
        ),
      ),
    );
  }

  /// Used to cache media identifiers that have had their channel IDs cached
  /// manually if the author identifier is null.
  final Map<String, String> _channelIdFetchedFromVideoCache = {};

  /// Launch a channel and view its videos in a page.
  Future<void> showChannelPage({
    required AppModel appModel,
    required BuildContext context,
    required MediaItem item,
  }) async {
    final navigator = Navigator.of(context);
    late String channelId;
    if (item.authorIdentifier == null) {
      String? fetchedId = _channelIdFetchedFromVideoCache[item.mediaIdentifier];
      if (fetchedId != null) {
        channelId = fetchedId;
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const LoadingPage()));

        Channel channel = await _channelClient.getByVideo(item.mediaIdentifier);
        _channelIdFetchedFromVideoCache[item.mediaIdentifier] =
            channel.id.value;
        channelId = channel.id.value;
      }
    } else {
      channelId = item.authorIdentifier!;
    }

    PagingController<int, MediaItem>? pagingController =
        _pagingControllerCache[channelId];
    if (pagingController == null) {
      pagingController = PagingController(firstPageKey: 1);
      pagingController.addPageRequestListener((pageKey) async {
        List<MediaItem> items = [];
        List<Video> videos = [];

        try {
          videos = await _channelClient
              .getUploads(channelId)
              .skip(pagingController?.itemList?.length ?? 0)
              .take(20)
              .where((e) => e.duration != null)
              .toList();
          for (Video video in videos) {
            items.add(getMediaItem(video));
          }
        } finally {
          if (items.isEmpty) {
            pagingController?.appendLastPage(items);
          } else {
            pagingController?.appendPage(items, pageKey + 1);
          }
        }
      });
      _pagingControllerCache[channelId] = pagingController;
    }

    // Prevent recursion.
    navigator.popUntil((route) => route.isFirst);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => YoutubeVideoResultsPage(
          showAppBar: true,
          title: item.author ?? '',
          pagingController: pagingController!,
        ),
      ),
    );
  }

  /// This is a list of captions that are currently being fetched. This is used
  /// to slow down and control the slowdown of calling
  /// [getAvailableCaptionLanguages].
  final List<String> _fetchingCaptions = [];

  /// Get the available languages for a video's closed captions with caching.
  Future<void> getAvailableCaptionLanguages({
    required MediaItem item,
    required bool Function() checkMounted,
    required bool autoGenerated,
  }) async {
    while (!checkMounted() || _fetchingCaptions.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200), () {});
    }

    String url = item.mediaIdentifier;

    try {
      _fetchingCaptions.add(url);
      ClosedCaptionManifest manifest = await getClosedCaptionsManifest(item);
      List<String> autoLanguageCodes = [];
      List<String> ccLanguageCodes = [];

      for (ClosedCaptionTrackInfo trackInfo in manifest.tracks) {
        String languageCode = trackInfo.language.code;

        if (trackInfo.isAutoGenerated) {
          autoLanguageCodes.add(languageCode);
        } else {
          ccLanguageCodes.add(languageCode);
        }
      }

      setCaptionsLanguages(
        item: item,
        captionsLanguages: autoLanguageCodes,
        autoGenerated: true,
      );
      setCaptionsLanguages(
        item: item,
        captionsLanguages: ccLanguageCodes,
        autoGenerated: false,
      );
    } finally {
      _fetchingCaptions.remove(url);
    }
  }

  /// Gets channel from ID.
  Future<Channel> getChannelFromId(String id) async {
    Channel? channel = _channelCache[id];
    if (channel != null) {
      return channel;
    }

    channel = await computeChannel(id);
    _channelCache[id] = channel;
    return channel;
  }

  /// Returns the paging controller for a video's comments.
  Future<PagingController<int, Comment>?> getCommentsForVideo(
      String videoUrl) async {
    Video video = await getVideoFromUrl(videoUrl);
    PagingController<int, Comment>? pagingController =
        _commentsPagingCache[video.id.value];
    if (pagingController != null) {
      return pagingController;
    }

    CommentsList? commentsList = await _commentsClient.getComments(video);
    pagingController = PagingController(firstPageKey: 1);

    pagingController.addPageRequestListener((pageKey) async {
      List<Comment> comments = [];

      try {
        comments.addAll(commentsList!.toList());
        commentsList = await compute(computeCommentsList, commentsList);
      } finally {
        if (comments.isEmpty) {
          pagingController?.appendLastPage(comments);
        } else {
          pagingController?.appendPage(comments, pageKey + 1);
        }
      }
    });
    _commentsPagingCache[video.id.value] = pagingController;

    return pagingController;
  }

  /// Returns the paging controller for a comment's replies.
  Future<PagingController<int, Comment>?> getRepliesForComment(
      Comment comment) async {
    PagingController<int, Comment>? pagingController =
        _repliesPagingCache[comment];
    if (pagingController != null) {
      return pagingController;
    }

    CommentsList? commentsList = await _commentsClient.getReplies(comment);
    pagingController = PagingController(firstPageKey: 1);

    pagingController.addPageRequestListener((pageKey) async {
      List<Comment> comments = [];

      try {
        comments.addAll(commentsList!.toList());
        commentsList = await commentsList?.nextPage();
      } finally {
        if (comments.isEmpty) {
          pagingController?.appendLastPage(comments);
        } else {
          pagingController?.appendPage(comments, pageKey + 1);
        }
      }
    });
    _repliesPagingCache[comment] = pagingController;

    return pagingController;
  }
}

/// Used to perform grabbing both manifests in a single isolate.
class VideoManifest {
  /// Initialise this object.
  const VideoManifest({
    required this.streamManifest,
    required this.closedCaptionManifest,
    required this.subtitlesByLanguageCache,
  });

  /// Contains streaming URL information.
  final StreamManifest streamManifest;

  /// Contains subtitles information.
  final ClosedCaptionManifest closedCaptionManifest;

  /// For each language.
  final Map<String, String> subtitlesByLanguageCache;
}

/// Used for [computeManifests].
RegExp vttRegex = RegExp(
  r'(\d+)?\n(\d{1,}:)?(\d{1,2}:)?(\d{1,2}).(\d+)\s?-->\s?(\d{1,}:)?(\d{1,2}:)?(\d{1,2}).(\d+)(.*(?:\r?(?!\r?).*)*)\n(.*(?:\r?\n(?!\r?\n).*)*)',
  caseSensitive: false,
  multiLine: true,
);

/// For allowing manifest to be used.
class ComputeManifestParams {
  /// Initialise this object.
  const ComputeManifestParams({
    required this.videoId,
    required this.subtitlesCached,
    this.closedCaptionsManifest,
  });

  /// Manifest if it is already fetched.
  final ClosedCaptionManifest? closedCaptionsManifest;

  /// Video ID.
  final String videoId;

  /// Whether or not cached.
  final bool subtitlesCached;
}

/// Used to be able to get both manifests at the same time.
Future<VideoManifest> computeManifests(ComputeManifestParams params) async {
  YoutubeExplode yt = YoutubeExplode();

  List<Future> futures = [
    yt.videos.streamsClient.getManifest(params.videoId),
  ];
  if (params.closedCaptionsManifest == null) {
    futures.add(yt.videos.closedCaptions.getManifest(
      params.videoId,
      formats: [ClosedCaptionFormat.vtt],
    ));
  }

  final manifests = await Future.wait(futures);
  StreamManifest streamManifest = manifests.elementAt(0) as StreamManifest;
  late ClosedCaptionManifest closedCaptionManifest;

  if (params.closedCaptionsManifest != null) {
    closedCaptionManifest = params.closedCaptionsManifest!;
  } else {
    closedCaptionManifest = manifests.elementAt(1) as ClosedCaptionManifest;
  }

  Map<String, ClosedCaptionTrackInfo> tracksByLanguage = {};
  List<ClosedCaptionTrackInfo> ccTracks =
      closedCaptionManifest.tracks.where((e) => !e.isAutoGenerated).toList();
  List<ClosedCaptionTrackInfo> autoTracks =
      closedCaptionManifest.tracks.where((e) => e.isAutoGenerated).toList();

  for (ClosedCaptionTrackInfo track in [...ccTracks, ...autoTracks]) {
    String shortCode = track.language.code.substring(0, 2);
    tracksByLanguage.putIfAbsent(shortCode, () => track);
  }

  List<MapEntry<String, String>> entries = [];

  if (!params.subtitlesCached) {
    entries.addAll(
      await Future.wait(
        tracksByLanguage.values.map(
          (trackInfo) async {
            String shortCode = trackInfo.language.code.substring(0, 2);
            String subtitles =
                await yt.videos.closedCaptions.getSubTitles(trackInfo);

            if (trackInfo.isAutoGenerated) {
              subtitles = subtitles.replaceAllMapped(vttRegex, (match) {
                String text = match.group(11) ?? '';
                List<String> lines = text.split('\n');

                String currentSubtitle =
                    subtitles.substring(match.start, match.end);
                int position = currentSubtitle
                    .lastIndexOf(text)
                    .clamp(0, currentSubtitle.length);

                String newSubtitle = currentSubtitle.replaceFirst(
                    text, lines.last.trim(), position);

                return newSubtitle;
              });
            }

            String metadata = trackInfo.isAutoGenerated
                ? 'YouTube - Auto - [$shortCode]'
                : 'YouTube - CC - [$shortCode]';

            return MapEntry(metadata, subtitles);
          },
        ),
      ),
    );
  }

  Map<String, String> subtitlesByLanguageCache = {};
  for (MapEntry<String, String> entry in entries) {
    subtitlesByLanguageCache.putIfAbsent(entry.key, () => entry.value);
  }

  return VideoManifest(
    streamManifest: streamManifest,
    closedCaptionManifest: closedCaptionManifest,
    subtitlesByLanguageCache: subtitlesByLanguageCache,
  );
}
