import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing Reader settings.
class TtuSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const TtuSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  String get volumeButtonPageTurningLabel =>
      appModel.translate('volume_button_page_turning');
  String get invertVolumeButtonsLabel =>
      appModel.translate('invert_volume_buttons');
  String get volumeButtonTurningSpeed =>
      appModel.translate('volume_button_turning_speed');
  String get highlightOnTapLabel => appModel.translate('highlight_on_tap');
  String get extendPageNavbarLabel =>
      appModel.translate('extend_page_beyond_navbar');

  String get dialogCloseLabel => appModel.translate('dialog_close');
  String get resetLabel => appModel.translate('reset');

  ReaderTtuSource get source => ReaderTtuSource.instance;

  late TextEditingController _speedController;

  @override
  void initState() {
    super.initState();

    _speedController =
        TextEditingController(text: source.volumePageTurningSpeed.toString());
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
              buildHighlightOnTapSwitch(),
              buildEnablePageTurningSwitch(),
              buildInvertPageTurningSwitch(),
              buildExtendPageSwitch(),
              const Space.small(),
              const JidoujishoDivider(),
              buildPageTurningSpeedField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEnablePageTurningSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.volumePageTurningEnabled);

    return Row(
      children: [
        Expanded(
          child: Text(volumeButtonPageTurningLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningEnabled();
                _notifier.value = source.volumePageTurningEnabled;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildInvertPageTurningSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.volumePageTurningInverted);

    return Row(
      children: [
        Expanded(
          child: Text(invertVolumeButtonsLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningInverted();
                _notifier.value = source.volumePageTurningInverted;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildExtendPageSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.extendPageBeyondNavigationBar);

    return Row(
      children: [
        Expanded(
          child: Text(extendPageNavbarLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleExtendPageBeyondNavigationBar();
                _notifier.value = source.extendPageBeyondNavigationBar;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildHighlightOnTapSwitch() {
    ValueNotifier<bool> _notifier = ValueNotifier<bool>(source.highlightOnTap);

    return Row(
      children: [
        Expanded(
          child: Text(highlightOnTapLabel),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleHighlightOnTap();
                _notifier.value = source.highlightOnTap;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildPageTurningSpeedField() {
    return TextField(
      onChanged: (value) {
        double newSpeed = double.tryParse(value) ??
            ReaderTtuSource.defaultScrollingSpeed.toDouble();
        if (newSpeed.isNegative) {
          newSpeed = ReaderTtuSource.defaultScrollingSpeed.toDouble();
          _speedController.text = newSpeed.toString();
        }

        source.setVolumePageTurningSpeed(newSpeed.toInt());
      },
      controller: _speedController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: JidoujishoIconButton(
          tooltip: resetLabel,
          size: 18,
          onTap: () async {
            _speedController.text =
                ReaderTtuSource.defaultScrollingSpeed.toString();
            source.setVolumePageTurningSpeed(
                ReaderTtuSource.defaultScrollingSpeed);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: volumeButtonTurningSpeed,
      ),
    );
  }
}
