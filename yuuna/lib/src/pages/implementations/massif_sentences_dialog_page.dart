import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for selecting example sentences.
class MassifSentencesDialogPage extends BasePage {
  /// Create an instance of this page.
  const MassifSentencesDialogPage({
    required this.exampleSentences,
    required this.onSelect,
    super.key,
  });

  /// The example sentences to be shown in the dialog.
  final List<MassifResult> exampleSentences;

  /// The callback to be called when an example sentence has been picked.
  final Function(String) onSelect;

  @override
  BasePageState createState() => _MassifSentencesDialogPage();
}

class _MassifSentencesDialogPage
    extends BasePageState<MassifSentencesDialogPage> {
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

    widget.exampleSentences.forEachIndexed((index, result) {
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
              child: result.widget,
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

    widget.exampleSentences.forEachIndexed((index, result) {
      if (_valuesSelected[index]!.value) {
        buffer.writeln(result.text);
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
