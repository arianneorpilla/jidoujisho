import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing player settings.
class PlayerSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const PlayerSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  late TextEditingController _seekDurationController;

  @override
  void initState() {
    super.initState();

    _seekDurationController = TextEditingController(
        text: appModelNoUpdate.doubleTapSeekDuration.toString());
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
              buildHardwareAccelerationSwitch(),
              buildOpenSLESSwitch(),
              const Space.small(),
              const JidoujishoDivider(),
              buildSeekDurationField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHardwareAccelerationSwitch() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(appModel.playerHardwareAcceleration);

    return Row(
      children: [
        Expanded(
          child: Text(t.player_hardware_acceleration),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.setPlayerHardwareAcceleration(value: value);
                notifier.value = appModel.playerHardwareAcceleration;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildOpenSLESSwitch() {
    ValueNotifier<bool> notifier =
        ValueNotifier<bool>(appModel.playerUseOpenSLES);

    return Row(
      children: [
        Expanded(
          child: Text(t.player_use_opensles),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.setPlayerUseOpenSLES(value: value);
                notifier.value = appModel.playerUseOpenSLES;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildSeekDurationField() {
    return TextField(
      onChanged: (value) {
        int newDuration = int.tryParse(value) ?? appModel.doubleTapSeekDuration;
        if (newDuration.isNegative) {
          newDuration = appModel.doubleTapSeekDuration;
          _seekDurationController.text = newDuration.toString();
        }

        appModel.setDoubleTapSeekDuration(newDuration);
      },
      controller: _seekDurationController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixText: t.unit_milliseconds,
        suffixIcon: JidoujishoIconButton(
          tooltip: t.reset,
          size: 18,
          onTap: () async {
            _seekDurationController.text =
                appModel.doubleTapSeekDuration.toString();
            appModel.setDoubleTapSeekDuration(appModel.doubleTapSeekDuration);
            FocusScope.of(context).unfocus();
          },
          icon: Icons.undo,
        ),
        labelText: t.double_tap_seek_duration,
      ),
    );
  }
}
