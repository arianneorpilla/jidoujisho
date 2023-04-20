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
    String twoDigits(String n) => n.padLeft(2, '0');

    String hours = duration.inHours.toString();
    String mins = duration.inMinutes.remainder(60).toString();
    String secs = duration.inSeconds.remainder(60).toString();

    String padMins = twoDigits(mins);
    String padSecs = twoDigits(secs);

    if (duration.inHours != 0) {
      return '  $hours:$padMins:$padSecs  ';
    } else if (duration.inMinutes != 0) {
      return '  $mins:$padSecs  ';
    } else {
      return '  0:$padSecs  ';
    }
  }
}
