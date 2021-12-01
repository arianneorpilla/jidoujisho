import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chisa/models/app_model.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageSelectWidget extends StatefulWidget {
  const ImageSelectWidget({
    Key? key,
    required this.appModel,
    required this.filesNotifier,
    required this.fileNotifier,
    required this.imageListNotifier,
    required this.imageSearchTermNotifier,
    required this.imageSearchingNotifier,
    required this.setImageFile,
  }) : super(key: key);

  final AppModel appModel;
  final ValueNotifier<List<NetworkToFileImage>> filesNotifier;
  final ValueNotifier<File?> fileNotifier;
  final ValueNotifier<int> imageListNotifier;
  final ValueNotifier<String> imageSearchTermNotifier;
  final ValueNotifier<bool> imageSearchingNotifier;
  final Function(int) setImageFile;

  @override
  State<StatefulWidget> createState() => ImageSelectWidgetState();
}

class ImageSelectWidgetState extends State<ImageSelectWidget> {
  late ValueNotifier<File?> fileNotifier;
  late ValueNotifier<int> imageListNotifier;
  late Color labelColor;

  @override
  void initState() {
    super.initState();
    fileNotifier = widget.fileNotifier;
    imageListNotifier = widget.imageListNotifier;
  }

  Widget fullViewGallery() {
    return PhotoViewGallery.builder(
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.contained * 4,
          imageProvider: widget.filesNotifier.value[index],
        );
      },
      itemCount: widget.filesNotifier.value.length,
      loadingBuilder: (context, event) {
        return Container(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).focusColor),
              ),
            ),
          ),
        );
      },
      pageController: PageController(initialPage: imageListNotifier.value),
      onPageChanged: (index) {
        imageListNotifier.value = index;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    labelColor = Theme.of(context).unselectedWidgetColor;

    if (widget.imageSearchingNotifier.value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image(
              image: MemoryImage(kTransparentImage),
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 10),
          getPlaceholderTextSpans(),
          const SizedBox(height: 10),
        ],
      );
    }

    if (imageListNotifier.value < 0 ||
        imageListNotifier.value >= widget.filesNotifier.value.length) {
      imageListNotifier.value = 0;
    }
    NetworkToFileImage imageToShow =
        widget.filesNotifier.value[imageListNotifier.value];
    fileNotifier.value = imageToShow.file!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => fullViewGallery(),
          ),
        );
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == 0) return;

        if (details.primaryVelocity!.compareTo(0) == -1) {
          if (imageListNotifier.value ==
              widget.filesNotifier.value.length - 1) {
            imageListNotifier.value = 0;
          } else {
            imageListNotifier.value += 1;
          }
        } else {
          if (imageListNotifier.value == 0) {
            imageListNotifier.value = widget.filesNotifier.value.length - 1;
          } else {
            imageListNotifier.value -= 1;
          }
        }

        setState(() {
          precacheImage(
                  widget.filesNotifier.value[imageListNotifier.value], context)
              .then((_) {
            widget.setImageFile(imageListNotifier.value);
          });
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: FadeInImage(
              image: imageToShow,
              placeholder: MemoryImage(kTransparentImage),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          getFooterTextSpans(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget getFooterTextSpans() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: widget.appModel.translate("image_label_before"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${imageListNotifier.value + 1} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: widget.appModel.translate("image_label_middle"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${widget.filesNotifier.value.length} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (widget.imageSearchTermNotifier.value.isNotEmpty)
            TextSpan(
              text: widget.appModel.translate("image_label_after"),
              style: TextStyle(
                fontSize: 12,
                color: labelColor,
              ),
            ),
          if (widget.imageSearchTermNotifier.value.isNotEmpty)
            TextSpan(
              text: "『",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (widget.imageSearchTermNotifier.value.isNotEmpty)
            TextSpan(
              text: widget.imageSearchTermNotifier.value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          if (widget.imageSearchTermNotifier.value.isNotEmpty)
            TextSpan(
              text: "』",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget getPlaceholderTextSpans() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: widget.appModel.translate("searching_before"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: widget.imageSearchTermNotifier.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: widget.appModel.translate("searching_after"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(
                color: widget.appModel.getIsDarkMode()
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
