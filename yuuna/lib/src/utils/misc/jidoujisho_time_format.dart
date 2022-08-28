/// Used for formatting time-related strings.
class JidoujishoTimeFormat {
  /// Used for generating a timestamp for use with FFMPEG.
  static String getFfmpegTimestamp(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    String hours = twoDigits(duration.inHours);
    String mins = twoDigits(duration.inMinutes.remainder(60));
    String secs = twoDigits(duration.inSeconds.remainder(60));
    String mills = threeDigits(duration.inMilliseconds.remainder(1000));

    return '$hours:$mins:$secs.$mills';
  }

  /// Used to display duration on video history items.
  static String getVideoDurationText(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String mins = twoDigits(duration.inMinutes.remainder(60));
    String secs = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours != 0) {
      return '  $hours:$mins:$secs  ';
    } else if (duration.inMinutes != 0) {
      return '  $mins:$secs  ';
    } else {
      return '  0:$secs  ';
    }
  }
}
