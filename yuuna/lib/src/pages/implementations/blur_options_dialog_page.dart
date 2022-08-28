import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing [BlurOptions].
class BlurOptionsDialogPage extends BasePage {
  /// Create an instance of this page.
  const BlurOptionsDialogPage({
    super.key,
  });

  @override
  BasePageState createState() => _BlurOptionsDialogPageState();
}

class _BlurOptionsDialogPageState extends BasePageState<BlurOptionsDialogPage> {
  String get playerOptionBlurRadius =>
      appModel.translate('player_option_blur_radius');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get dialogSaveLabel => appModel.translate('dialog_save');
  String get resetLabel => appModel.translate('reset');

  late BlurOptions _blurOptions;
  late Color _pendingColor;
  late TextEditingController _blurrinessController;

  @override
  void initState() {
    super.initState();
    _blurOptions = appModelNoUpdate.blurOptions;
    _pendingColor = _blurOptions.color;
    _blurrinessController =
        TextEditingController(text: _blurOptions.blurRadius.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding:  Spacing.of(context).insets.all.big,
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (3 / 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: _pendingColor,
              onColorChanged: (color) async {
                _pendingColor = color;
              },
              colorPickerWidth: 200,
              pickerAreaHeightPercent: 0.8,
            ),
            TextField(
              controller: _blurrinessController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixText: 'px',
                suffixIcon: JidoujishoIconButton(
                  tooltip: resetLabel,
                  size: 18,
                  onTap: () async {
                    _blurrinessController.text = '5.0';
                    FocusScope.of(context).unfocus();
                  },
                  icon: Icons.undo,
                ),
                labelText: playerOptionBlurRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get actions => [
        buildCancelButton(),
        buildSaveButton(),
      ];

  Widget buildCancelButton() {
    return TextButton(
      child: Text(
        dialogCancelLabel,
      ),
      onPressed: executeCancel,
    );
  }

  Widget buildSaveButton() {
    return TextButton(
      child: Text(
        dialogSaveLabel,
      ),
      onPressed: executeSave,
    );
  }

  void executeCancel() async {
    Navigator.pop(context);
  }

  void executeSave() async {
    String blurrinessText = _blurrinessController.text;
    double? newBlurriness = double.tryParse(blurrinessText);

    if (newBlurriness != null && newBlurriness >= 0) {
      BlurOptions options = appModel.blurOptions;
      options.blurRadius = newBlurriness;
      options.color = _pendingColor;

      appModel.setBlurOptions(options);

      Navigator.pop(context);
    }
  }
}
