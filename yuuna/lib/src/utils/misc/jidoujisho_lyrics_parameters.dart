/// Used for searching lyrics.
class JidoujishoLyricsParameters {
  /// Initialise given parameters.
  const JidoujishoLyricsParameters({
    required this.artist,
    required this.title,
  });

  /// Artist of the song.
  final String artist;

  /// Title of the song.
  final String title;

    @override
  operator ==(Object other) => other is JidoujishoLyricsParameters && artist == other.artist && title == other.title;

  @override
  int get hashCode => artist.hashCode * title.hashCode;

}
