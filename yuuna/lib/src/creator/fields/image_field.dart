import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Returns audio information from context.
class ImageField extends ImageExportField {
  /// Initialise this field with the predetermined and hardset values.
  ImageField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Image',
          description: 'Visual supplement. Text field can be used to enter'
              ' search terms for image sources.',
          icon: Icons.image,
        );

  /// Get the singleton instance of this field.
  static ImageField get instance => _instance;

  static final ImageField _instance = ImageField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'image';

  @override
  String? onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
    required bool creatorJustLaunched,
  }) {
    return null;
  }

  @override
  Widget buildTopWidget({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
  }) {
    if (isSearching) {
      return Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 4.5),
          const Space.normal(),
          buildFooterLoading(
            appModel: appModel,
            context: context,
          ),
        ],
      );
    }

    if (!showWidget) {
      return const SizedBox.shrink();
    }

    ValueListenableBuilder<int?>(
      valueListenable: indexNotifier,
      builder: (context, index, _) => buildFooterTextSpans(
        context: context,
        appModel: appModel,
      ),
    );

    InfiniteScrollController controller =
        InfiniteScrollController(initialItem: selectedIndex!);

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 4.5,
          child: InfiniteCarousel.builder(
            itemCount: currentImageSuggestions!.length,
            itemExtent: MediaQuery.of(context).size.width / 1.2,
            velocityFactor: 0.7,
            onIndexChanged: (index) {
              indexNotifier.value = index;
              setSelectedSearchSuggestion(index: index);
            },
            controller: controller,
            itemBuilder: (context, index, _) {
              late OverlayEntry popup;
              NetworkToFileImage image = currentImageSuggestions![index];

              return GestureDetector(
                onLongPress: () {
                  popup = OverlayEntry(
                    builder: (context) => ColoredBox(
                      color: Colors.black.withOpacity(0.5),
                      child: buildImage(image),
                    ),
                  );
                  Overlay.of(context)?.insert(popup);
                },
                onLongPressEnd: (details) {
                  popup.remove();
                },
                child: Padding(
                  padding: Spacing.of(context).insets.horizontal.small,
                  child: buildImage(currentImageSuggestions![index]),
                ),
              );
            },
          ),
        ),
        const Space.normal(),
        ValueListenableBuilder<int?>(
          valueListenable: indexNotifier,
          builder: (context, index, _) => buildFooterTextSpans(
            context: context,
            appModel: appModel,
          ),
        ),
      ],
    );
  }

  /// Build the given image and fade in to load if network.
  Widget buildImage(ImageProvider<Object> image) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FadeInImage(
        image: image,
        placeholder: MemoryImage(kTransparentImage),
        fit: BoxFit.contain,
      ),
    );
  }

  /// Get the footer under the carousel that returns the current image index.
  Widget buildFooterTextSpans({
    required BuildContext context,
    required AppModel appModel,
  }) {
    double fontSize =
        (Theme.of(context).textTheme.labelMedium?.fontSize)! * 0.9;

    String imageSearchLabelBefore =
        appModel.translate('image_search_label_before');
    String imageSearchLabelMiddle =
        appModel.translate('image_search_label_middle');
    String imageSearchLabelAfter =
        appModel.translate('image_search_label_after');

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              child: Icon(
                icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
            ),
          ),
          TextSpan(
            text: imageSearchLabelBefore,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '${selectedIndex! + 1} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: imageSearchLabelMiddle,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '${currentImageSuggestions!.length} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: imageSearchLabelAfter,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: currentSearchTerm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Get the footer under the carousel that returns the current image index.
  Widget buildFooterLoading({
    required BuildContext context,
    required AppModel appModel,
  }) {
    double fontSize =
        (Theme.of(context).textTheme.labelMedium?.fontSize)! * 0.9;

    String searchingInProgress = appModel.translate('searching_in_progress');
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              child: Icon(
                icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
            ),
          ),
          TextSpan(
            text: searchingInProgress,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: currentSearchTerm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(
                color: Theme.of(context).appBarTheme.foregroundColor!,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
