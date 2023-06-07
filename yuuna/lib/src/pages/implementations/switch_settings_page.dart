import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for selecting segmented units of a source
/// text.
class SwitchSettingsPage<T> extends BasePage {
  /// Create an instance of this page.
  const SwitchSettingsPage({
    required this.items,
    required this.generateLabel,
    this.onSave,
    super.key,
  });

  /// All items in the list. Assumes each item is unique.
  final Map<T, bool> items;

  /// A function that converts a [T] to a usable label.
  final String Function(T) generateLabel;

  /// The callback to be called for a selection to extract from the text.
  final Function(Map<T, bool>)? onSave;

  @override
  BasePageState createState() => _SwitchSettingsPageState<T>();
}

class _SwitchSettingsPageState<T> extends BasePageState<SwitchSettingsPage<T>> {
  final ScrollController _scrollController = ScrollController();

  late final Map<T, ValueNotifier<bool>> _valuesSelected;

  @override
  void initState() {
    super.initState();

    _valuesSelected = Map<T, ValueNotifier<bool>>.fromEntries(
      widget.items.entries.map(
        (e) => MapEntry(
          e.key,
          ValueNotifier<bool>(e.value),
        ),
      ),
    );
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
          child: Wrap(
            children: List.generate(
              _valuesSelected.length,
              (index) {
                MapEntry<T, ValueNotifier<bool>> item =
                    _valuesSelected.entries.elementAt(index);
                T key = item.key;
                ValueNotifier<bool> notifier = item.value;

                return Row(
                  children: [
                    Expanded(
                      child: Text(widget.generateLabel(key)),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: notifier,
                      builder: (_, value, __) {
                        return Switch(
                          value: value,
                          onChanged: (value) {
                            notifier.value = !notifier.value;
                          },
                        );
                      },
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(t.dialog_save),
    );
  }

  Widget buildCancelButton() {
    return TextButton(
      child: Text(t.dialog_cancel),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  List<Widget> get actions => [
        if (widget.onSave != null) buildSaveButton(),
        buildCancelButton(),
      ];

  Map<T, bool> get selection {
    return Map<T, bool>.fromEntries(
        _valuesSelected.entries.map((e) => MapEntry(e.key, e.value.value)));
  }

  void executeSave() {
    widget.onSave?.call(selection);
    Navigator.pop(context);
  }
}
