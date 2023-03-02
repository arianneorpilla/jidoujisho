import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing dictionary settings.
class DictionarySettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const DictionarySettingsDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  String get autoSearchLabel => appModel.translate('auto_search');
  String get autoSearchDebounceDelayLabel =>
      appModel.translate('auto_search_debounce_delay');
  String get dictionaryFontSizeLabel =>
      appModel.translate('dictionary_font_size');
  String get unitMillisecondsLabel => appModel.translate('unit_milliseconds');
  String get unitPixelsLabel => appModel.translate('unit_pixels');
  String get maximumEntriesLabel => appModel.translate('maximum_entries');
  String get maximumTermsLabel => appModel.translate('maximum_terms');

  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get resetLabel => appModel.translate('reset');

  late TextEditingController _debounceDelayController;
  late TextEditingController _dictionaryFontSizeController;
  late TextEditingController _maximumEntriesController;
  late TextEditingController _maximumTermsController;

  @override
  void initState() {
    super.initState();

    _debounceDelayController = TextEditingController(
        text: appModelNoUpdate.searchDebounceDelay.toString());
    _dictionaryFontSizeController = TextEditingController(
        text: appModelNoUpdate.dictionaryFontSize.toString());
    _maximumEntriesController =
        TextEditingController(text: appModelNoUpdate.maximumEntries.toString());
    _maximumTermsController =
        TextEditingController(text: appModelNoUpdate.maximumTerms.toString());
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
              buildDictionaryFontSizeField(),
              buildMaximumTermsField(),
              // buildMaximumEntriesField(),
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
        suffixText: unitMillisecondsLabel,
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

  Widget buildDictionaryFontSizeField() {
    return TextField(
      onChanged: (value) {
        double newSize =
            double.tryParse(value) ?? appModel.defaultDictionaryFontSize;
        if (newSize.isNegative) {
          newSize = appModel.defaultDictionaryFontSize;
          _dictionaryFontSizeController.text = newSize.toString();
        }

        appModel.setDictionaryFontSize(newSize);
      },
      controller: _dictionaryFontSizeController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixText: unitPixelsLabel,
        suffixIcon: JidoujishoIconButton(
          tooltip: resetLabel,
          size: 18,
          onTap: () async {
            _dictionaryFontSizeController.text =
                appModel.defaultDictionaryFontSize.toString();
            appModel.setDictionaryFontSize(appModel.defaultDictionaryFontSize);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: dictionaryFontSizeLabel,
      ),
    );
  }

  Widget buildMaximumEntriesField() {
    return TextField(
      onChanged: (value) {
        int newAmount = int.tryParse(value) ??
            appModel.defaultMaximumDictionaryEntrySearchMatch;
        if (newAmount.isNegative) {
          newAmount = appModel.defaultMaximumDictionaryEntrySearchMatch;
          _maximumEntriesController.text = newAmount.toString();
        }

        appModel.setMaximumEntries(newAmount);
        appModel.clearDictionaryResultsCache();
      },
      controller: _maximumEntriesController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: JidoujishoIconButton(
          tooltip: resetLabel,
          size: 18,
          onTap: () async {
            _maximumEntriesController.text =
                appModel.defaultMaximumDictionaryEntrySearchMatch.toString();
            appModel.setMaximumEntries(
                appModel.defaultMaximumDictionaryEntrySearchMatch);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: maximumEntriesLabel,
      ),
    );
  }

  Widget buildMaximumTermsField() {
    return TextField(
      onChanged: (value) {
        int newAmount = int.tryParse(value) ??
            appModel.defaultMaximumDictionaryTermsInResult;
        if (newAmount.isNegative) {
          newAmount = appModel.defaultMaximumDictionaryTermsInResult;
          _maximumTermsController.text = newAmount.toString();
        }

        appModel.setMaximumTerms(newAmount);
        appModel.clearDictionaryResultsCache();
      },
      controller: _maximumTermsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: JidoujishoIconButton(
          tooltip: resetLabel,
          size: 18,
          onTap: () async {
            _maximumTermsController.text =
                appModel.defaultMaximumDictionaryTermsInResult.toString();
            appModel.setMaximumTerms(
                appModel.defaultMaximumDictionaryTermsInResult);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: maximumTermsLabel,
      ),
    );
  }
}
