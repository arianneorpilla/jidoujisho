import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for showing dictionary import progress when
/// deleting a dictionary from the dictionary menu. See the
/// [DictionaryDialogPage].
class DictionaryDialogDeletePage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogDeletePage({
    this.name,
    super.key,
  });

  /// Name of current dictionary being deleted.
  final String? name;

  @override
  BasePageState createState() => _DictionaryDialogDeletePageState();
}

class _DictionaryDialogDeletePageState
    extends BasePageState<DictionaryDialogDeletePage> {
  String get deleteInProgress => appModel.translate('delete_in_progress');
  String get dictionariesDeletingEntries =>
      appModel.translate('dictionaries_deleting_data');

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
            child: Text(
              widget.name != null
                  ? '${t.delete_in_progress}\n${widget.name}'
                  : t.delete_in_progress,
              style: TextStyle(
                fontSize: textTheme.bodySmall?.fontSize,
                color: theme.unselectedWidgetColor,
              ),
            ),
          ),
          const Space.small(),
          Text(
            dictionariesDeletingEntries,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
