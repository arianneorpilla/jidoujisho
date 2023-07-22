/// Settings that are persisted for the player.
class PlayerBasicOptions {
  /// Initialise this object.
  PlayerBasicOptions({
    required this.keepShown,
    required this.volume,
    required this.brightness,
  });

  /// Keep player bottom bar shown.
  bool keepShown;

  /// Player volume.
  int volume;

  /// Player brightness
  double brightness;
}
