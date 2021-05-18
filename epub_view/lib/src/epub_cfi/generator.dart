import 'package:epubx/epubx.dart';
import 'package:epub_view/src/utils.dart';
import 'package:html/dom.dart';
import 'package:flutter/foundation.dart';

class EpubCfiGenerator {
  const EpubCfiGenerator();

  String generateCompleteCFI(List<String?> entries) =>
      'epubcfi(${entries.join()})';

  String generatePackageDocumentCFIComponent(
      EpubChapter chapter, EpubPackage? packageDocument) {
    validatePackageDocument(packageDocument, chapter.Anchor);

    final index = getIdRefIndex(chapter, packageDocument!);
    final pos = getIdRefPosition(index);
    final spineIdRef = index >= 0
        ? packageDocument.Spine!.Items![index].IdRef
        : chapter.Anchor;

    // Append an !; this assumes that a CFI content document CFI component
    // will be appended at some point
    // `/6` - is position of the Spine element in Package
    return '/6/$pos[$spineIdRef]!';
  }

  String generateElementCFIComponent(Node? startElement) {
    validateStartElement(startElement);

    // Call the recursive method to create all the steps up to the head element
    // of the content document (the "html" element)
    final contentDocCFI =
        createCFIElementSteps(startElement as Element, 'html');

    // Remove the !
    return contentDocCFI.substring(1, contentDocCFI.length);
  }

  String createCFIElementSteps(Element currentNode, String topLevelElement) {
    int currentNodePosition = 0;
    String elementStep = '';

    // Find position of current node in parent list
    int index = 0;
    currentNode.parent!.children.forEach((node) {
      if (node == currentNode) {
        currentNodePosition = index;
      }
      index++;
    });

    // Convert position to the CFI even-integer representation
    final int cfiPosition = (currentNodePosition + 1) * 2;

    // Create CFI step with id assertion, if the element has an id
    if (currentNode.attributes.containsKey('id')) {
      elementStep = '/' +
          cfiPosition.toString() +
          '[' +
          currentNode.attributes['id']! +
          ']';
    } else {
      elementStep = '/' + cfiPosition.toString();
    }

    // If a parent is an html element return the (last) step for this content
    // document, otherwise, continue.
    //   Also need to check if the current node is the top-level element.
    //   This can occur if the start node is also the
    //   top level element.
    final parentNode = currentNode.parent!;
    if (parentNode.localName == topLevelElement ||
        currentNode.localName == topLevelElement) {
      // If the top level node is a type from which an indirection step, add an
      // indirection step character (!)
      // REFACTORING CANDIDATE: It is possible that this should be changed to:
      // if (topLevelElement = 'package') do
      //   not return an indirection character. Every other type of top-level
      //   element may require an indirection
      //   step to navigate to, thus requiring that ! is always prepend.
      if (topLevelElement == 'html') {
        return '!' + elementStep;
      } else {
        return elementStep;
      }
    } else {
      return createCFIElementSteps(parentNode, topLevelElement) + elementStep;
    }
  }

  int getIdRefIndex(EpubChapter chapter, EpubPackage packageDocument) {
    final items = packageDocument.Spine!.Items!;
    int index = -1;
    int partIndex = -1;
    String? edRef = chapter.Anchor;

    if (chapter.Anchor == null) {
      // filename w/o extension
      edRef = fileNameAsChapterName(chapter.ContentFileName!);
    }

    for (var i = 0; i < items.length; i++) {
      if (edRef == items[i].IdRef) {
        index = i;
        break;
      }
      if (edRef!.contains(items[i].IdRef!)) {
        partIndex = i;
      }
    }

    return index >= 0 ? index : partIndex;
  }

  int getIdRefPosition(int idRefIndex) => (idRefIndex + 1) * 2;

  void validatePackageDocument(EpubPackage? packageDocument, String? idRef) {
    // Check that the package document is non-empty
    // and contains an item ref element for the supplied id ref
    if (packageDocument == null || packageDocument is! EpubPackage) {
      throw FlutterError(
          'A package document must be supplied to generate a CFI');
    }
    // Commented, because there may be cases when id is not listed in object!!!
    // else if (getIdRefIndex(idRef, packageDocument) == -1) {
    //   throw FlutterError(
    // ignore: lines_longer_than_80_chars
    //       'The id ref of the content document could not be found in the spine');
    // }
  }

  void validateStartElement(Node? startElement) {
    if (startElement == null) {
      throw FlutterError('$startElement: CFI target element is null');
    }

    if (startElement.nodeType != Node.ELEMENT_NODE) {
      throw FlutterError(
          '$startElement: CFI target element is not an HTML element');
    }
  }
}
