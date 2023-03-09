import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for showing dictionary import progress when
/// importing a dictionary from the dictionary menu. See the
/// [DictionaryDialogPage].
class DictionaryDialogImportPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogImportPage({
    required this.progressNotifier,
    required this.countNotifier,
    required this.totalNotifier,
    super.key,
  });

  /// A notifier for reporting text updates for the current progress text in
  /// the dialog.
  final ValueNotifier<String> progressNotifier;

  /// A notifier for reporting text updates for the current progress text in
  /// the dialog.
  final ValueNotifier<int?> countNotifier;

  /// The number of dictionaries being imported.
  final ValueNotifier<int?> totalNotifier;

  @override
  BasePageState createState() => _DictionaryDialogImportPageState();
}

class _DictionaryDialogImportPageState
    extends BasePageState<DictionaryDialogImportPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: Spacing.of(context).insets.all.big,
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
            child: MultiValueListenableBuilder(
                valueListenables: [widget.countNotifier, widget.totalNotifier],
                builder: (context, values, _) {
                  int? currentCount = values.elementAt(0);
                  int? totalCount = values.elementAt(1);

                  return Text(
                    currentCount != null &&
                            totalCount != null &&
                            totalCount != 1
                        ? '${t.import_in_progress}\n$currentCount / $totalCount'
                        : t.import_in_progress,
                    style: TextStyle(
                      fontSize: textTheme.bodySmall?.fontSize,
                      color: theme.unselectedWidgetColor,
                    ),
                  );
                }),
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
