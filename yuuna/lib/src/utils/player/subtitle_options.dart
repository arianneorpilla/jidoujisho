/// Settings that are persisted for the blur widget used in the player.
class SubtitleOptions {
  /// Initialise this object.
  SubtitleOptions({
    required this.audioAllowance,
    required this.subtitleDelay,
    required this.fontSize,
    required this.fontName,
    required this.regexFilter,
  });

  /// Audio allowance, used for audio export, in milliseconds.
  int audioAllowance;

  /// Subtitle delay in milliseconds.
  int subtitleDelay;

  /// Subtitle font size.
  double fontSize;

  /// Name of the font preferred for the subtitle.
  String fontName;

  /// Regex filter used for the subtitle.
  String regexFilter;
}
