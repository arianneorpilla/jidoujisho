enum ChapterProgressState {
  unstarted,
  viewed,
  finished,
}

class Chapter {
  Chapter({
    required this.name,
    this.pageProgress = 0,
    this.pageTotal,
  });

  final String name;
  final int? pageProgress;
  final int? pageTotal;

  ChapterProgressState getProgress() {
    if (pageTotal == null) {
      return ChapterProgressState.unstarted;
    }

    if (pageProgress == pageTotal) {
      return ChapterProgressState.finished;
    } else {
      return ChapterProgressState.viewed;
    }
  }
}
