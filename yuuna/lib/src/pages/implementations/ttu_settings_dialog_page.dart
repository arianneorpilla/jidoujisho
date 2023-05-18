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
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
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
              buildAdaptThemeSwitch(),
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
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(source.volumePageTurningEnabled);

    return Row(
      children: [
        Expanded(
          child: Text(t.volume_button_page_turning),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningEnabled();
                notifier.value = source.volumePageTurningEnabled;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildInvertPageTurningSwitch() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(source.volumePageTurningInverted);

    return Row(
      children: [
        Expanded(
          child: Text(t.invert_volume_buttons),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningInverted();
                notifier.value = source.volumePageTurningInverted;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildExtendPageSwitch() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(source.extendPageBeyondNavigationBar);

    return Row(
      children: [
        Expanded(
          child: Text(t.extend_page_beyond_navbar),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleExtendPageBeyondNavigationBar();
                notifier.value = source.extendPageBeyondNavigationBar;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildAdaptThemeSwitch() {
    ValueNotifier<bool> notifier = ValueNotifier<bool>(source.adaptTtuTheme);

    return Row(
      children: [
        Expanded(
          child: Text(t.adapt_ttu_theme),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleAdaptTtuTheme();
                notifier.value = source.adaptTtuTheme;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildHighlightOnTapSwitch() {
    ValueNotifier<bool> notifier = ValueNotifier<bool>(source.highlightOnTap);

    return Row(
      children: [
        Expanded(
          child: Text(t.highlight_on_tap),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleHighlightOnTap();
                notifier.value = source.highlightOnTap;
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
          tooltip: t.reset,
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
        labelText: t.volume_button_turning_speed,
      ),
    );
  }
}
