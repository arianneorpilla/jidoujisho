import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:yuuna/media.dart';

/// A type of media that is significantly distinguishable from other media such
/// that it is deserving of its own core functionality when viewing media items.
/// A [MediaType] has its own history and home tab.
abstract class MediaType {
  /// Initialise this media type with the predetermined and hardset values.
  MediaType({
    required this.uniqueKey,
    required this.icon,
    required this.outlinedIcon,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys. This does not differ when the user's app language changes.
  final String uniqueKey;

  /// An icon that will represent this media type in its home tab.
  final IconData icon;

  /// An icon that represents this media type when unselected in its home tab.
  final IconData outlinedIcon;

  /// The body that will be shown when this media type's tab is the current
  /// selected home tab.
  StatelessWidget get home;

  /// Used to open [Hive] boxes for storing progress and duration respectively.
  String get _progressKey => '$uniqueKey/progress';
  String get _durationKey => '$uniqueKey/duration';

  /// The key-value stores that this media type will use to store media history.
  late Box _persistedProgress;
  late Box _persistedDuration;

  /// Whether or not [initialise] has been called for the media type.
  bool _initialised = false;

  /// Given a media [item], get its persisted progress.
  int getItemProgress(MediaItem item) {
    return _persistedProgress.get(item.uniqueKey);
  }

  /// Given a media [item], get its persisted duration.
  int getItemDuration(MediaItem item) {
    return _persistedDuration.get(item.uniqueKey);
  }

  /// Given a media [item], update its persisted [progress].
  void persistItemProgress(MediaItem item, int progress) {
    _persistedProgress.put(item.uniqueKey, progress);
  }

  /// Given a media [item], update its persisted [duration].
  void persistItemDuration(MediaItem item, int duration) {
    _persistedDuration.put(item.uniqueKey, duration);
  }

  /// This function is run at startup. It is not called again if already run.
  Future<void> initialise() async {
    if (_initialised) {
      return;
    } else {
      _persistedProgress = await Hive.openBox(_progressKey);
      _persistedDuration = await Hive.openBox(_durationKey);
      _initialised = true;
    }
  }

  @override
  operator ==(Object other) =>
      other is MediaType && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}
