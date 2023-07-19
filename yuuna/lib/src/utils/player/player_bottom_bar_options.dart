/// Settings that are persisted for the bottom bar used in the player.
class PlayerBottomBarOptions {
  /// Initialise this object.
  PlayerBottomBarOptions({
    required this.keepShown,
  });

  /// Audio allowance, used for audio export, in milliseconds.
  bool keepShown;
}
