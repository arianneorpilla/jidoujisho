String fileNameAsChapterName(String path) =>
    path.split('/').last.replaceFirst(RegExp(r'\.[^.]+$'), '');
