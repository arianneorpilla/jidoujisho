import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for selecting example sentences.
class ExampleSentencesDialogPage extends BasePage {
  /// Create an instance of this page.
  const ExampleSentencesDialogPage({
    required this.exampleSentences,
    required this.onSelect,
    super.key,
  });

  /// The example sentences to be shown in the dialog.
  final List<String> exampleSentences;

  /// The callback to be called when an example sentence has been picked.
  final Function(String) onSelect;

  @override
  BasePageState createState() => _ExampleSentencesDialogPageState();
}

class _ExampleSentencesDialogPageState
    extends BasePageState<ExampleSentencesDialogPage> {
  final ScrollController _scrollController = ScrollController();

  String get dialogSelectLabel => appModel.translate('dialog_select');

  final Map<int, ValueNotifier<bool>> _valuesSelected = {};

  @override
  void initState() {
    super.initState();

    widget.exampleSentences.forEachIndexed((index, element) {
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

    widget.exampleSentences.forEachIndexed((index, segment) {
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

  List<Widget> get actions => [
        buildSelectButton(),
      ];

  Widget buildSelectButton() {
    return TextButton(
      child: Text(dialogSelectLabel),
      onPressed: executeSelect,
    );
  }

  String get selection {
    StringBuffer buffer = StringBuffer();

    widget.exampleSentences.forEachIndexed((index, sentence) {
      if (_valuesSelected[index]!.value) {
        buffer.writeln(sentence);
      }
    });

    return buffer.toString().trim();
  }

  void executeSelect() {
    Navigator.pop(context);
    if (selection.isNotEmpty) {
      widget.onSelect(selection);
    }
  }
}
