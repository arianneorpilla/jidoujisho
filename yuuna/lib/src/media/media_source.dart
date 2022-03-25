/// A source of media.
abstract class MediaSource {
  /// Initialise this media source with the hardset parameters.
  MediaSource({
    required this.uniqueKey,
  });

  /// The unique identifier of this media source. Used to optimise and be able
  /// to fetch this media source at constant time.
  final String uniqueKey;
}
