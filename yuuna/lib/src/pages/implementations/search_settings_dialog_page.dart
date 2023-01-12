import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing search settings.
class SearchSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const SearchSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  String get autoSearchLabel => appModel.translate('auto_search');
  String get autoSearchDebounceDelayLabel =>
      appModel.translate('auto_search_debounce_delay');

  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get resetLabel => appModel.translate('reset');

  late TextEditingController _debounceDelayController;

  @override
  void initState() {
    super.initState();

    _debounceDelayController = TextEditingController(
        text: appModelNoUpdate.searchDebounceDelay.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(dialogCloseLabel),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildAutoSearchSwitch(),
              const Space.small(),
              const JidoujishoDivider(),
              buildDebounceDelayField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAutoSearchSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(appModel.autoSearchEnabled);

    return Row(
      children: [
        Expanded(
          child: Text(autoSearchLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.toggleAutoSearchEnabled();
                _notifier.value = appModel.autoSearchEnabled;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildDebounceDelayField() {
    return TextField(
      onChanged: (value) {
        int newDelay =
            int.tryParse(value) ?? appModel.defaultSearchDebounceDelay;
        if (newDelay.isNegative) {
          newDelay = appModel.defaultSearchDebounceDelay;
          _debounceDelayController.text = newDelay.toString();
        }

        appModel.setSearchDebounceDelay(newDelay);
      },
      controller: _debounceDelayController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: JidoujishoIconButton(
          tooltip: resetLabel,
          size: 18,
          onTap: () async {
            _debounceDelayController.text =
                appModel.defaultSearchDebounceDelay.toString();
            appModel
                .setSearchDebounceDelay(appModel.defaultSearchDebounceDelay);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: autoSearchDebounceDelayLabel,
      ),
    );
  }
}
