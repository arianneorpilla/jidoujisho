import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for showing dictionary import progress when
/// importing a dictionary from the dictionary menu. See the
/// [DictionaryDialogPage].
class DictionaryDialogImportPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogImportPage({
    required this.progressNotifier,
    Key? key,
  }) : super(key: key);

  /// A notifier for reporting text updates for the current progress text in
  /// the dialog.
  final ValueNotifier<String> progressNotifier;

  @override
  BasePageState createState() => _DictionaryDialogImportPageState();
}

class _DictionaryDialogImportPageState
    extends BasePageState<DictionaryDialogImportPage> {
  String get importInProgressLabel => appModel.translate('import_in_progress');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: EdgeInsets.all(Spacing.of(context).spaces.big),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildProgressSpinner(),
            const Space.semiBig(),
            buildProgressMessage(),
          ],
        ),
      ),
    );
  }

  Widget buildProgressSpinner() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        theme.colorScheme.primary,
      ),
    );
  }

  Widget buildProgressMessage() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Space.extraSmall(),
          Padding(
            padding: const EdgeInsets.only(left: 0.5),
            child: Text(
              importInProgressLabel,
              style: TextStyle(
                fontSize: textTheme.bodySmall?.fontSize,
                color: theme.unselectedWidgetColor,
              ),
            ),
          ),
          const Space.small(),
          ValueListenableBuilder<String>(
            valueListenable: widget.progressNotifier,
            builder: (context, progressNotification, _) {
              return Text(
                widget.progressNotifier.value,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }
}
