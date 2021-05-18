part of 'epub_view.dart';

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.Chapters!.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.SubChapters!.forEach(acc.add);
        return acc;
      },
    );

List<dom.Element> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.children;

List<dom.Element> _removeAllDiv(List<dom.Element> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node.localName == 'div' && node.children.length > 1) {
      result.addAll(_removeAllDiv(node.children));
    } else {
      result.add(node);
    }
  }

  return result;
}

ParseParagraphsResult parseParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  String? filename = '';
  final List<int> chapterIndexes = [];
  final paragraphs = chapters.fold<List<Paragraph>>(
    [],
    (acc, next) {
      List<dom.Element> elmList = [];
      if (filename != next.ContentFileName) {
        filename = next.ContentFileName;
        final document = EpubCfiReader().chapterDocument(next);
        if (document != null) {
          final result = convertDocumentToElements(document);
          elmList = _removeAllDiv(result);
        }
      }

      if (next.Anchor == null) {
        // last element from document index as chapter index
        chapterIndexes.add(acc.length);
        acc.addAll(elmList
            .map((element) => Paragraph(element, chapterIndexes.length - 1)));
        return acc;
      } else {
        final index = elmList.indexWhere(
          (elm) => elm.outerHtml.contains(
            'id="${next.Anchor}"',
          ),
        );
        if (index == -1) {
          chapterIndexes.add(acc.length);
          acc.addAll(elmList
              .map((element) => Paragraph(element, chapterIndexes.length - 1)));
          return acc;
        }

        chapterIndexes.add(index);
        acc.addAll(elmList
            .map((element) => Paragraph(element, chapterIndexes.length - 1)));
        return acc;
      }
    },
  );

  return ParseParagraphsResult(paragraphs, chapterIndexes);
}

class Paragraph {
  Paragraph(this.element, this.chapterIndex);

  final dom.Element element;
  final int chapterIndex;
}

class ParseParagraphsResult {
  ParseParagraphsResult(this.flatParagraphs, this.chapterIndexes);

  final List<Paragraph> flatParagraphs;
  final List<int> chapterIndexes;
}
