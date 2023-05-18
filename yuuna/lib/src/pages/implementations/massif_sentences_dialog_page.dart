import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for selecting example sentences.
class MassifSentencesDialogPage extends BasePage {
  /// Create an instance of this page.
  const MassifSentencesDialogPage({
    required this.exampleSentences,
    required this.onSelect,
    required this.onAppend,
    super.key,
  });

  /// The example sentences to be shown in the dialog.
  final List<MassifResult> exampleSentences;

  /// Select action callback.
  final Function(List<MassifResult>) onSelect;

  /// Append action callback.
  final Function(List<MassifResult>) onAppend;

  @override
  BasePageState createState() => _MassifSentencesDialogPage();
}

class _MassifSentencesDialogPage
    extends BasePageState<MassifSentencesDialogPage> {
  final ScrollController _scrollController = ScrollController();

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
      actions: widget.exampleSentences.isEmpty ? null : actions,
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: widget.exampleSentences.isEmpty
            ? SingleChildScrollView(
                controller: _scrollController, child: buildEmptyMessage())
            : buildTextWidgets(),
      ),
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: t.no_sentences_found,
      ),
    );
  }

  Widget buildTextWidgets() {
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 1
                  : 3),
      shrinkWrap: true,
      itemCount: widget.exampleSentences.length,
      itemBuilder: (context, index) {
        MassifResult result = widget.exampleSentences[index];

        return GestureDetector(
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
                child: buildTextWidget(result),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildTextWidget(MassifResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: result.spans),
        ),
        Text(
          result.source,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        )
      ],
    );
  }

  List<Widget> get actions => [
        buildAppendButton(),
        buildSelectButton(),
      ];

  Widget buildAppendButton() {
    return TextButton(
      onPressed: executeAppend,
      child: Text(t.dialog_append),
    );
  }

  Widget buildSelectButton() {
    return TextButton(
      onPressed: executeSelect,
      child: Text(t.dialog_select),
    );
  }

  List<MassifResult> get selection {
    List<MassifResult> results = [];

    widget.exampleSentences.forEachIndexed((index, result) {
      if (_valuesSelected[index]!.value) {
        results.add(result);
      }
    });

    return results;
  }

  void executeAppend() {
    Navigator.pop(context);
    widget.onAppend(selection);
  }

  void executeSelect() {
    Navigator.pop(context);
    widget.onSelect(selection);
  }
}
