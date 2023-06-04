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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHardwareAccelerationSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(appModel.playerHardwareAcceleration);

    return Row(
      children: [
        Expanded(
          child: Text(t.player_hardware_acceleration),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.setPlayerHardwareAcceleration(value: value);
                _notifier.value = appModel.playerHardwareAcceleration;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildOpenSLESSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(appModel.playerUseOpenSLES);

    return Row(
      children: [
        Expanded(
          child: Text(t.player_use_opensles),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                appModel.setPlayerUseOpenSLES(value: value);
                _notifier.value = appModel.playerUseOpenSLES;
              },
            );
          },
        )
      ],
    );
  }
}
