import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/models/app_model.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for picking creator fields.
class FieldPickerDialogPage extends BasePage {
  /// Create an instance of this page.
  const FieldPickerDialogPage({
    required this.mapping,
    required this.isCollapsed,
    super.key,
  });

  /// What mapping to alter upon picking an enhancement.
  final AnkiMapping mapping;

  /// Whether or not the field being picked for will be collapsed.
  final bool isCollapsed;

  @override
  BasePageState createState() => _FieldPickerDialogPageState();
}

class _FieldPickerDialogPageState extends BasePageState<FieldPickerDialogPage> {
  String get noMoreAvailableFieldsLabel =>
      appModel.translate('no_more_available_fields');

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.all.big
          : Spacing.of(context).insets.all.normal,
      content: buildContent(),
    );
  }

  Widget buildContent() {
    List<Field> fields = [...globalFields];
    for (Field field in widget.mapping.getCreatorCollapsedFields()) {
      fields.remove(field);
    }
    for (Field field in widget.mapping.getCreatorFields()) {
      fields.remove(field);
    }

    ScrollController contentController = ScrollController();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fields.isEmpty)
                buildEmptyMessage()
              else
                Flexible(
                  child: buildFieldTiles(fields),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.edit,
        message: noMoreAvailableFieldsLabel,
      ),
    );
  }

  Widget buildFieldTiles(List<Field> fields) {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: fields.length,
        itemBuilder: (context, index) => buildFieldTile(fields[index]),
      ),
    );
  }

  Widget buildFieldTile(Field field) {
    return ListTile(
      key: ValueKey(field.uniqueKey),
      leading: Icon(
        field.icon,
        color: theme.appBarTheme.foregroundColor,
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.getLocalisedLabel(appModel),
                  style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                ),
                Text(
                  field.getLocalisedDescription(appModel),
                  style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        appModel.setField(
          mapping: widget.mapping,
          field: field,
          isCollapsed: widget.isCollapsed,
        );
        Navigator.pop(context);
      },
    );
  }
}
