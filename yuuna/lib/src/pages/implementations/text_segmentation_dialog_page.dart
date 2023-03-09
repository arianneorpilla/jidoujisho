import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for selecting segmented units of a source
/// text.
class TextSegmentationDialogPage extends BasePage {
  /// Create an instance of this page.
  const TextSegmentationDialogPage({
    required this.sourceText,
    required this.segmentedText,
    this.onSelect,
    this.onSearch,
    super.key,
  });

  /// The original text before segmentation. This could be a sentence or a
  /// dictionary definition.
  final String sourceText;

  /// The text after segmentation.
  final List<String> segmentedText;

  /// The callback to be called for a selection to extract from the text.
  final Function(String, List<String>)? onSelect;

  /// The callback to be called for a selection to perform a search on.
  final Function(String, List<String>)? onSearch;

  @override
  BasePageState createState() => _TextSegmentationDialogPage();
}

class _TextSegmentationDialogPage
    extends BasePageState<TextSegmentationDialogPage> {
  final ScrollController _scrollController = ScrollController();

  final Map<int, ValueNotifier<bool>> _valuesSelected = {};

  @override
  void initState() {
    super.initState();

    widget.segmentedText.forEachIndexed((index, element) {
      _valuesSelected[index] = ValueNotifier<bool>(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Wrap(children: getTextWidgets()),
        ),
      ),
    );
  }

  List<Widget> getTextWidgets() {
    List<Widget> widgets = [];

    widget.segmentedText.forEachIndexed((index, segment) {
      Widget widget = GestureDetector(
        onTap: () {
          _valuesSelected[index]!.value = !_valuesSelected[index]!.value;
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: _valuesSelected[index]!,
          builder: (context, value, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: Spacing.of(context).spaces.small,
                horizontal: Spacing.of(context).spaces.semiSmall,
              ),
              margin: EdgeInsets.only(
                top: Spacing.of(context).spaces.normal,
                right: Spacing.of(context).spaces.normal,
              ),
              color: _valuesSelected[index]!.value
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.unselectedWidgetColor.withOpacity(0.1),
              child: SizedBox(
                height: (textTheme.titleLarge?.fontSize)! * 1.3,
                child: Text(
                  segment,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: textTheme.titleMedium?.fontSize,
                  ),
                ),
              ),
            );
          },
        ),
      );

      widgets.add(widget);
    });

    return widgets;
  }

  Widget buildStashButton() {
    return TextButton(
      child: Text(t.dialog_stash),
      onPressed: executeStash,
    );
  }

  List<Widget> get actions => [
        buildStashButton(),
        if (widget.onSearch != null) buildSearchButton(),
        if (widget.onSelect != null) buildSelectButton(),
      ];

  Widget buildSearchButton() {
    return TextButton(
      child: Text(t.dialog_search),
      onPressed: executeSearch,
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      child: Text(t.dialog_select),
      onPressed: executeSelect,
    );
  }

  String get selection {
    StringBuffer buffer = StringBuffer();

    widget.segmentedText.forEachIndexed((index, segment) {
      if (_valuesSelected[index]!.value) {
        buffer.write(segment);

        if (appModel.targetLanguage.isSpaceDelimited) {
          buffer.write(' ');
        }
      }
    });

    return buffer.toString().trim();
  }

  List<String> get selectedItems {
    List<String> items = [];

    widget.segmentedText.forEachIndexed((index, segment) {
      if (_valuesSelected[index]!.value) {
        items.add(segment);
      }
    });

    return items;
  }

  void executeStash() {
    List<String> terms = [];
    widget.segmentedText.forEachIndexed((index, segment) {
      if (_valuesSelected[index]!.value) {
        terms.add(segment);
      }
    });

    appModel.addToStash(terms: terms);
  }

  void executeSearch() {
    if (selection.isEmpty) {
      widget.onSearch?.call(widget.sourceText, selectedItems);
    } else {
      widget.onSearch?.call(selection, selectedItems);
    }
  }

  void executeSelect() {
    if (selection.isEmpty) {
      widget.onSelect?.call(widget.sourceText, selectedItems);
    } else {
      widget.onSelect?.call(selection, selectedItems);
    }
  }
}
