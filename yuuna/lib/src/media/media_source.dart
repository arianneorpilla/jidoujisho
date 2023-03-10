import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:subtitle/subtitle.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:path/path.dart' as path;

/// A source for a [MediaType] that will appear on the list of sources when
/// set as active. Handles sourcing and delivery of arguments such that the
/// [MediaType] is able to execute and launch with the proper arguments.
abstract class MediaSource {
  /// Initialise a media source.
  MediaSource({
    required this.uniqueKey,
    required this.sourceName,
    required this.description,
    required this.mediaType,
    required this.icon,
    required this.implementsSearch,
    required this.implementsHistory,
    this.overridesAutoImage = false,
    this.overridesAutoAudio = false,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys.
  final String uniqueKey;

  /// Name of the source that very shortly describes what it does.
  final String sourceName;

  /// The media type that this source is for.
  final MediaType mediaType;

  /// A longer description of what the source can do, or details left by or
  /// regarding the developer.
  final String description;

  /// An icon that will show the enhancement if activated by the user in the
  /// quick menu.
  final IconData icon;

  /// Localisations for this source, where the key is a locale tag and
  /// the value is the [sourceName] of the source. If the value for the current
  /// locale is non-null, it will be used instead of [sourceName].
  final Map<String, String> sourceNameLocalisatiton = const {};

  /// Localisations for this source, where the key is a locale tag and
  /// the value is the [description] of the enhancement. If the value for the
  /// current locale is non-null, it will be used instead of [description].
  final Map<String, String> descriptionLocalisation = const {};

  /// Whether or not this media source has a search function. If false, this
  /// media source will have an action executed by [onSearchBarTap].
  final bool implementsSearch;

  /// Whether or not this media source allows adding items to media history.
  /// Note that some media sources produce a history of media items but do
  /// not require this to be set true. For example, the reader fetches its
  /// history from a source other than the actual internal media history
  /// system provided by the media source framework. In such cases, this
  /// should be set as false. Setting this as true results to a media item
  /// being added to history when media is opened.
  final bool implementsHistory;

  /// Whether or not a media source overrides the auto image enhancement.
  /// See [generateImages].
  final bool overridesAutoImage;

  /// Whether or not a media source overrides the auto audio enhancement.
  /// See [generateAudio].
  final bool overridesAutoAudio;

  /// Used for accessing persistent key-value data specific to this source.
  /// See [initialise].
  late final Box _preferences;

  /// Whether or not [initialise] has been called for this source.
  bool _initialised = false;

  /// This function is run at startup. It is not called again if already run.
  Future<void> initialise() async {
    if (_initialised) {
      return;
    } else {
      _preferences = await Hive.openBox(uniqueKey);

      await prepareResources();
      _initialised = true;
    }
  }

  /// Get the preference value for a certain parameter [key] for this source.
  T getPreference<T>({required String key, required T defaultValue}) {
    return _preferences.get(key, defaultValue: defaultValue) as T;
  }

  /// Set the preference [value] for a certain parameter [key] for this source.
  Future<void> setPreference<T>({required String key, required T value}) async {
    await _preferences.put(key, value);
  }

  /// Set the preference for a certain parameter [key] for this source.
  Future<void> deletePreference({required String key}) async {
    await _preferences.delete(key);
  }

  /// Get the best localisation for the label of this media source. If there
  /// is no localisation, the fallback is [sourceName].
  String getLocalisedSourceName(AppModel appModel) {
    return sourceNameLocalisatiton[appModel.appLocale.toLanguageTag()] ??
        sourceName;
  }

  /// Get the best localisation for the description of this media source. If
  /// there is no localisation, the fallback is [description].
  String getLocalisedDescription(AppModel appModel) {
    return descriptionLocalisation[appModel.appLocale.toLanguageTag()] ??
        description;
  }

  /// If a media source requires resources to function, they can be prepared
  /// here and this function will be run once only at runtime during the
  /// initialisation step.
  Future<void> prepareResources() async {}

  /// Executed when this media source is closed. Perform this step to clean up
  /// resources or refresh media history.
  Future<void> onSourceExit({
    required AppModel appModel,
    required BuildContext context,
    required WidgetRef ref,
  }) async {}

  /// Get the floating search bar actions of this source when it is the active
  /// source being displayed on its respective media type tab.
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [];
  }

  /// The widget to show when this source is launched. An optional [MediaItem]
  /// can be supplied as a launch parameter.
  BaseSourcePage buildLaunchPage({MediaItem? item});

  /// If this is not null, this action is executed when the user taps on the
  /// search bar. Sources that do not have a search action should have this
  /// defined.
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    appModel.openMedia(
      context: context,
      ref: ref,
      mediaSource: this,
    );
  }

  /// This function can be used to clean up resources associated with a
  /// media item upon clearing it.
  Future<void> onMediaItemClear(MediaItem item) async {}

  /// Supplies a sentence that can be used for the sentence field when making
  /// a card while this source is active. Can be set with [setCurrentSentence]
  /// and [clearCurrentSentence] in a source page.
  String get currentSentence => _currentSentence;
  String _currentSentence = '';

  /// Update the current sentence.
  void setCurrentSentence(String sentence) {
    _currentSentence = sentence;
  }

  /// Clear the current sentence.
  void clearCurrentSentence() {
    _currentSentence = '';
  }

  /// Gets whether or not a media source should currently supply images.
  bool get shouldGenerateImage => _shouldGenerateImage;
  bool _shouldGenerateImage = true;

  /// Gets whether or not a media source should currently supply audio.
  bool get shouldGenerateAudio => _shouldGenerateAudio;
  bool _shouldGenerateAudio = true;

  /// Controls whether or not a media source should currently supply images.
  void setShouldGenerateImage({required bool value}) {
    _shouldGenerateImage = value;
  }

  /// Controls whether or not a media source should currently supply audio.
  void setShouldGenerateAudio({required bool value}) {
    _shouldGenerateAudio = value;
  }

  /// Supplies a media item that can be used for tracking and updating history,
  /// as well as generating video and audio with timestamp information. This
  /// should be uniquely implemented for each source. Some sources may want
  /// to generate their media item based on current playback information or
  /// progress.
  MediaItem get currentMediaItem => throw UnimplementedError();

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  BasePage buildHistoryPage();

  /// Given a [MediaItem], return its title. Some media items may allow
  /// overriding of values for display purposes. If a source does this,
  /// override this function.
  String getDisplayTitleFromMediaItem(MediaItem item) {
    String? overrideTitle = getOverrideTitleFromMediaItem(item);
    if (overrideTitle != null) {
      return overrideTitle;
    }

    return item.title;
  }

  /// Given a [MediaItem], return its subtitle. Some media items may allow
  /// overriding of values for display purposes. If a source does this,
  /// override this function.
  String getDisplaySubtitleFromMediaItem(MediaItem item) {
    return item.mediaIdentifier;
  }

  /// Given a [MediaItem], return its thumbnail. Some media items may allow
  /// overriding of values for display purposes.
  ImageProvider<Object> getDisplayThumbnailFromMediaItem({
    required AppModel appModel,
    required MediaItem item,
    String? fallbackUrl,
    bool noOverride = false,
  }) {
    ImageProvider<Object>? overrideThumbnail =
        getOverrideThumbnailFromMediaItem(
      appModel: appModel,
      item: item,
    );

    if (!noOverride && overrideThumbnail != null) {
      return overrideThumbnail;
    }

    if (item.imageUrl != null) {
      return CachedNetworkImageProvider(
        fallbackUrl ?? item.imageUrl!,
        cacheKey: item.uniqueKey,
      );
    }

    if (item.base64Image == null) {
      return MemoryImage(kTransparentImage);
    }

    UriData data = Uri.parse(item.base64Image!).data!;

    /// A cached version of [MemoryImage] so that the image does not reload
    /// on every revisit
    return CacheImageProvider(item.uniqueKey, data.contentAsBytes());
  }

  /// Given a [MediaItem], return its thumbnail. Some media items may allow
  /// overriding of values for display purposes.
  String getThumbnailUri({
    required AppModel appModel,
    required MediaItem item,
    bool noOverride = false,
  }) {
    ImageProvider<Object>? overrideThumbnail =
        getOverrideThumbnailFromMediaItem(
      appModel: appModel,
      item: item,
    );

    if (!noOverride && overrideThumbnail != null) {
      return getOverrideThumbnailFilename(appModel: appModel, item: item);
    }

    if (item.imageUrl != null) {
      return item.imageUrl!;
    }

    if (item.base64Image == null) {
      return '';
    }

    return '';
  }

  /// The map key used to store the override title of an item.
  String getOverrideTitleKey(MediaItem item) {
    return 'override_title://${item.mediaSourceIdentifier}/${item.uniqueKey}';
  }

  /// The map value used to store the override thumbnail of an item.
  String getOverrideThumbnailFilename({
    required AppModel appModel,
    required MediaItem item,
  }) {
    String key =
        '${item.mediaIdentifier}/${item.mediaSourceIdentifier}/override_thumbnail';
    String basename = key.hashCode.toString();
    String filename = path.join(appModel.thumbnailsDirectory.path, basename);

    return filename;
  }

  /// Given a [MediaItem], return its override display title.
  String? getOverrideTitleFromMediaItem(MediaItem item) {
    if (!item.canEdit) {
      return null;
    }

    String key = getOverrideTitleKey(item);
    String? overrideTitle =
        getPreference<String?>(key: key, defaultValue: null);
    return overrideTitle;
  }

  /// Given a [MediaItem], return its override display thumbnail.
  ImageProvider<Object>? getOverrideThumbnailFromMediaItem({
    required AppModel appModel,
    required MediaItem item,
  }) {
    String filename = getOverrideThumbnailFilename(
      appModel: appModel,
      item: item,
    );

    File file = File(filename);
    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  /// Given a [MediaItem], set its override display title. If the title is
  /// blank, the override title is cleared.
  Future<void> setOverrideTitleFromMediaItem({
    required MediaItem item,
    required String? title,
  }) async {
    String key = getOverrideTitleKey(item);
    String? value;
    if (title != null) {
      String trimmedTitle = title.trim();
      if (trimmedTitle.isNotEmpty) {
        value = trimmedTitle;
      }
    }

    await setPreference<String?>(key: key, value: value);
  }

  /// Given a [MediaItem], set its override display thumbnail. If null, this
  /// deletes the override thumbnail.
  Future<void> setOverrideThumbnailFromMediaItem({
    required AppModel appModel,
    required MediaItem item,
    required File? file,
  }) async {
    String filename = getOverrideThumbnailFilename(
      appModel: appModel,
      item: item,
    );

    File thumbnailFile = File(filename);
    thumbnailFile.createSync(recursive: true);
    if (file == null) {
      thumbnailFile.deleteSync();
    } else {
      file.copySync(filename);
    }
  }

  /// Used to clear override values of a [MediaItem] upon deletion.
  Future<void> clearOverrideValues({
    required AppModel appModel,
    required MediaItem item,
  }) async {
    await deletePreference(key: getOverrideTitleKey(item));
    await setOverrideThumbnailFromMediaItem(
      appModel: appModel,
      item: item,
      file: null,
    );
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the image field over the auto enhancement. Extra durations can be
  /// invoked and defined when initially opening the creator, to call attention
  /// to multiple durations to be used for image generation.
  Future<List<NetworkToFileImage>> generateImages({
    required AppModel appModel,
    required MediaItem item,
    required List<Subtitle>? subtitles,
    required SubtitleOptions options,
  }) {
    throw UnimplementedError();
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the audio field over the auto enhancement.
  Future<File?>? generateAudio({
    required AppModel appModel,
    required MediaItem item,
    required List<Subtitle>? subtitles,
    required SubtitleOptions options,
  }) {
    throw UnimplementedError();
  }

  /// This returns a list of [MediaItem], and is performed to search the media
  /// source for items.
  Future<List<MediaItem>?> searchMediaItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) async {
    throw UnimplementedError();
  }

  /// Given a search term, this source may give search suggestions. If the
  /// empty list is returned, then search history will be shown instead.
  Future<List<String>> generateSearchSuggestions(String searchTerm) async {
    throw UnimplementedError();
  }

  /// Used to override the search bar if needed by a source that implements search.
  BaseMediaSearchBar? buildBar() {
    return null;
  }

  /// Aspect ratio of media items.
  double get aspectRatio;
}
