/// Settings that are persisted for the blur widget used in the player.
class SubtitleOptions {
  /// Initialise this object.
  SubtitleOptions({
    required this.audioAllowance,
    required this.subtitleDelay,
    required this.fontSize,
    required this.fontName,
    required this.fontColor,
    required this.fontWeight,
    required this.subtitleBackgroundOpacity,
    required this.regexFilter,
    required this.subtitleOutlineWidth,
    required this.subtitleOutlineColor,
    required this.subtitleBackgroundBlurRadius,
    required this.alwaysAboveBottomBar,
  });

  /// Audio allowance, used for audio export, in milliseconds.
  int audioAllowance;

  /// Subtitle delay in milliseconds.
  int subtitleDelay;

  /// Subtitle font size.
  double fontSize;

  /// Name of the font preferred for the subtitle.
  String fontName;

  /// Font color preferred for the subtitle.
  int fontColor;

  /// Font weight preferred for the subtitle.
  String fontWeight;

  /// Subtitle background blur radius.
  double subtitleBackgroundBlurRadius;

  /// Subtitle background opacity.
  double subtitleBackgroundOpacity;

  /// Subtitle outline width.
  double subtitleOutlineWidth;

  /// Subtitle outline color.
  int subtitleOutlineColor;

  /// Regex filter used for the subtitle.
  String regexFilter;

  /// Whether or not the subtitle should always be above the bottom bar.
  bool alwaysAboveBottomBar;
}
