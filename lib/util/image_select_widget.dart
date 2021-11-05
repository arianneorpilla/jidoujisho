import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chisa/models/app_model.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageSelectWidget extends StatefulWidget {
  const ImageSelectWidget({
    Key? key,
    required this.appModel,
    required this.filesNotifier,
    required this.fileNotifier,
  }) : super(key: key);

  final AppModel appModel;
  final ValueNotifier<List<NetworkToFileImage>> filesNotifier;
  final ValueNotifier<File?> fileNotifier;

  @override
  State<StatefulWidget> createState() => ImageSelectWidgetState();
}

class ImageSelectWidgetState extends State<ImageSelectWidget> {
  late ValueNotifier<File?> fileNotifier;
  late ValueNotifier<int> indexNotifier;
  late Color labelColor;

  @override
  void initState() {
    super.initState();
    fileNotifier = widget.fileNotifier;
    indexNotifier = ValueNotifier<int>(0);
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
      pageController: PageController(initialPage: indexNotifier.value),
      onPageChanged: (index) {
        indexNotifier.value = index;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    labelColor = Theme.of(context).unselectedWidgetColor;
    NetworkToFileImage imageToShow =
        widget.filesNotifier.value[indexNotifier.value];
    fileNotifier.value = imageToShow.file!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => fullViewGallery(),
          ),
        );
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == 0) return;

        if (details.primaryVelocity!.compareTo(0) == -1) {
          if (indexNotifier.value == widget.filesNotifier.value.length - 1) {
            indexNotifier.value = 0;
          } else {
            indexNotifier.value += 1;
          }
        } else {
          if (indexNotifier.value == 0) {
            indexNotifier.value = widget.filesNotifier.value.length - 1;
          } else {
            indexNotifier.value -= 1;
          }
        }

        setState(() {});
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
            text: "${indexNotifier.value + 1} ",
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
          TextSpan(
            text: widget.appModel.translate("image_label_after"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
