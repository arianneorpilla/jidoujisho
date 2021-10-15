/// Used for languages, to indicate what ideal reading direction they should
/// have by default. "LTR" stands for left-to-right, and "RTL" stands for
/// "right-to-left".
///
/// This enum also distinguishes between text that should be displayed
/// horizontally and text that should be displayed vertically.
enum ReadingDirection {
  horizontalLTR, // e.g. English
  horizontalRTL, // e.g. Arabic
  verticalLTR, // e.g. Mongolian
  verticalRTL, // e.g. Japanese
}
