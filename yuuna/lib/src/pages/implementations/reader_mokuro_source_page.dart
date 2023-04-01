import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongol/mongol.dart';
import 'package:photo_view/photo_view.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The media page used for the [ReaderMokuroSource].
class ReaderMokuroSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const ReaderMokuroSourcePage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderMokuroSourcePageState();
}

class _ReaderMokuroSourcePageState
    extends BaseSourcePageState<ReaderMokuroSourcePage> {
  ReaderMokuroSource get mediaSource => ReaderMokuroSource.instance;
  late final CarouselController _carouselController = CarouselController();
  late final JidoujishoSelectableTextController _selectableTextController =
      JidoujishoSelectableTextController();
  String _currentSelection = '';

  @override
  void initState() {
    super.initState();

    _currentPosition = widget.item!.position;
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<MokuroPayload> payload =
        ref.watch(mokuroPayloadProvider(widget.item!.mediaIdentifier));

    return payload.when(
      data: buildData,
      error: (error, stack) => buildError(error: error, stack: stack),
      loading: buildLoading,
    );
  }

  late int _currentPosition;

  Widget buildData(MokuroPayload payload) {
    return Scaffold(
        body: Stack(
      children: [
        buildViewer(payload),
        Row(
          children: [
            Flexible(
              child: GestureDetector(
                child: Container(color: Colors.red),
                onTap: handleLeftBorderTap,
              ),
            ),
            const Spacer(flex: 10),
            Flexible(
              child: GestureDetector(
                child: Container(color: Colors.blue),
                onTap: handleRightBorderTap,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  void handleLeftBorderTap() {
    if (mediaSource.rightToLeft) {
      goNext();
    } else {
      goPrevious();
    }
  }

  void handleRightBorderTap() {
    if (mediaSource.rightToLeft) {
      goPrevious();
    } else {
      goNext();
    }
  }

  void goPrevious() {
    if (_currentPosition != 0) {
      _carouselController.jumpToPage(_currentPosition - 1);
    }
  }

  void goNext() {
    if (_currentPosition != widget.item!.duration - 1) {
      _carouselController.jumpToPage(_currentPosition + 1);
    }
  }

  ImageProvider<Object> getImageProvider(MokuroImage image) {
    if (image.url.startsWith('file://')) {
      return FileImage(File(image.url.replaceFirst('file://', '')));
    } else {
      return CachedNetworkImageProvider(image.url);
    }
  }

  Widget buildImageLoading(double value) {
    return Center(
      child: SizedBox(
        height: Spacing.of(context).spaces.big,
        width: Spacing.of(context).spaces.big,
        child: CircularProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget buildImage(MokuroImage image) {
    if (image.url.startsWith('file://')) {
      return Image(
        height: image.size.height,
        width: image.size.width,
        image: FileImage(File(image.url.replaceFirst('file://', ''))),
      );
    } else {
      return CachedNetworkImage(
        height: image.size.height,
        width: image.size.width,
        imageUrl: image.url,
        progressIndicatorBuilder: (_, __, event) {
          return buildImageLoading(event.progress ?? 0);
        },
      );
    }
  }

  Widget buildViewer(MokuroPayload payload) {
    return CarouselSlider.builder(
      itemCount: payload.images.length,
      carouselController: _carouselController,
      options: CarouselOptions(
        initialPage: widget.item!.position,
        reverse: true,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        height: MediaQuery.of(context).size.height,
        enlargeStrategy: CenterPageEnlargeStrategy.zoom,
        enlargeCenterPage: true,
        viewportFraction: 1,
        padEnds: false,
        onPageChanged: (index, reason) {
          updatePositionAndHistory(index);
        },
      ),
      itemBuilder: (context, index, realIndex) {
        MokuroImage image = payload.images[index];
        return PhotoView.customChild(
          childSize: image.size,
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.contained * 5,
          child: AspectRatio(
            aspectRatio: image.size.height / image.size.width,
            child: OverflowBox(
              maxWidth: image.size.width,
              maxHeight: image.size.height,
              child: Stack(
                children: <Widget>[
                  buildImage(image),
                  ...generatePositionedTextBlocks(image),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Positioned> generatePositionedTextBlocks(MokuroImage image) {
    return image.blocks
        .map((block) => generatePositionedTextBlock(image, block))
        .toList();
  }

  Positioned generatePositionedTextBlock(MokuroImage image, MokuroBlock block) {
    return Positioned.fromRect(
      rect: block.rectangle.shift(const Offset(-2, 5)),
      child: Container(
        alignment: Alignment.topRight,
        child: buildText(block),
        color: Colors.pink.withOpacity(0.1),
      ),
    );
  }

  void updatePositionAndHistory(int position) {
    _currentPosition = position;
    widget.item!.position = position;
    appModel.updateMediaItem(widget.item!);
  }

  Widget buildText(MokuroBlock block) {
    if (block.isVertical) {
      double letterSpacing = ((block.rectangle.width) -
              ((block.fontSize * 0.95) * block.lines.length)) /
          block.lines.length;
      print(letterSpacing);
      return MongolText.rich(
        TextSpan(children: getTextSpans(block)),
        style: TextStyle(height: 0.95, letterSpacing: letterSpacing),
        textScaleFactor: 0.95,
        overflow: TextOverflow.clip,
      );
    } else {
      return Text.rich(
        TextSpan(children: getTextSpans(block)),
        overflow: TextOverflow.clip,
      );
    }
  }

  List<InlineSpan> getTextSpans(MokuroBlock block) {
    String text = block.lines.reversed.join('\n');
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
            text: character,
            style: TextStyle(
              fontSize: block.fontSize,
              color: Colors.red,
            ),
            recognizer: TapGestureRecognizer()
              ..onTapDown = (details) async {
                onTapDown(
                  character: character,
                  text: text,
                  index: index,
                  controller: _selectableTextController,
                  details: details,
                );
              }),
      );
    });

    return spans;
  }

  void onTapDown({
    required String text,
    required String character,
    required int index,
    required TapDownDetails details,
    required JidoujishoSelectableTextController controller,
  }) {
    bool wholeWordCondition =
        controller.selection.start <= index && controller.selection.end > index;

    if (wholeWordCondition && currentResult != null) {
      clearDictionaryResult();
      return;
    }

    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;

    late JidoujishoPopupPosition position;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      if (y < MediaQuery.of(context).size.height / 2) {
        position = JidoujishoPopupPosition.bottomHalf;
      } else {
        position = JidoujishoPopupPosition.topHalf;
      }
    } else {
      if (x < MediaQuery.of(context).size.width / 2) {
        position = JidoujishoPopupPosition.rightHalf;
      } else {
        position = JidoujishoPopupPosition.leftHalf;
      }
    }

    String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
      text: text,
      index: index,
    );

    if (_currentSelection.isEmpty && character.trim().isNotEmpty) {
      bool isSpaceDelimited = appModel.targetLanguage.isSpaceDelimited;
      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex =
          appModel.targetLanguage.getStartingIndex(text: text, index: index) +
              whitespaceOffset;
      int length = appModel.targetLanguage
          .textToWords(searchTerm)
          .firstWhere((e) => e.trim().isNotEmpty)
          .length;

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        mediaSource.setCurrentSentence(
          appModel.targetLanguage
              .getSentenceFromParagraph(paragraph: text, index: index),
        );

        int length = isSpaceDelimited
            ? appModel.targetLanguage
                .textToWords(searchTerm)
                .firstWhere((e) => e.trim().isNotEmpty)
                .length
            : max(1, currentResult?.bestLength ?? 0);

        controller.setSelection(offsetIndex, offsetIndex + length);
      });
    } else {
      clearDictionaryResult();
      _currentSelection = '';
    }

    FocusScope.of(context).unfocus();
  }
}
