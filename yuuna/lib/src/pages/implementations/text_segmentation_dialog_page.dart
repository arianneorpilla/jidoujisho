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
  final Function(JidoujishoTextSelection)? onSelect;

  /// The callback to be called for a selection to perform a search on.
  final Function(JidoujishoTextSelection)? onSearch;

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
          /// Algorithm for deselecting values that are not adjacent trues to
          /// the newly selected index.

          _valuesSelected[index]!.value = !_valuesSelected[index]!.value;

          bool rightDeselectFlag = false;
          for (int i = index; i < _valuesSelected.length; i++) {
            if (rightDeselectFlag) {
              _valuesSelected[i]!.value = false;
              continue;
            }

            if (_valuesSelected[i]!.value) {
              continue;
            } else {
              _valuesSelected[i]!.value = false;
              rightDeselectFlag = true;
            }
          }

          bool leftDeselectFlag = false;
          for (int i = index; i >= 0; i--) {
            if (leftDeselectFlag) {
              _valuesSelected[i]!.value = false;
              continue;
            }

            if (_valuesSelected[i]!.value) {
              continue;
            } else {
              _valuesSelected[i]!.value = false;
              leftDeselectFlag = true;
            }
          }
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
                  segment.trim(),
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
      onPressed: executeStash,
      child: Text(t.dialog_stash),
    );
  }

  List<Widget> get actions => [
        buildStashButton(),
        if (widget.onSearch != null) buildSearchButton(),
        if (widget.onSelect != null) buildSelectButton(),
      ];

  Widget buildSearchButton() {
    return TextButton(
      onPressed: executeSearch,
      child: Text(t.dialog_search),
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      onPressed: executeSelect,
      child: Text(t.dialog_select),
    );
  }

  JidoujishoTextSelection get selection {
    StringBuffer buffer = StringBuffer();
    int? start;
    int? end;

    for (int i = 0; i < _valuesSelected.length; i++) {
      if (_valuesSelected[i]!.value) {
        start ??= buffer.length;
        end = buffer.length + widget.segmentedText[i].length;
      }
      buffer.write(widget.segmentedText[i]);
    }

    TextRange range = TextRange.empty;
    if (start != null && end != null) {
      range = TextRange(start: start, end: end);
    }

    return JidoujishoTextSelection(
      text: widget.sourceText,
      range: range,
    );
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
    if (selection.range == TextRange.empty) {
      return;
    }

    widget.onSearch?.call(selection);
  }

  void executeSelect() {
    if (selection.range == TextRange.empty) {
      return;
    }

    widget.onSelect?.call(selection);
  }
}
