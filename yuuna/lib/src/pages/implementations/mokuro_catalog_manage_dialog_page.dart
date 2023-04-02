import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// The content of the dialog used for managing catalogs.
class MokuroCatalogManageDialogPage extends BasePage {
  /// Create an instance of this page.
  const MokuroCatalogManageDialogPage({
    super.key,
  });

  @override
  BasePageState createState() => _MokuroCatalogManageDialogPageState();
}

class _MokuroCatalogManageDialogPageState
    extends BasePageState<MokuroCatalogManageDialogPage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedOrder = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCatalogList(),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCreateButton(),
        buildDoneButton(),
      ];

  Widget buildCreateButton() {
    return TextButton(
      child: Text(t.dialog_create),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => const MokuroCatalogEditDialogPage(),
        );
      },
    );
  }

  Widget buildDoneButton() {
    return TextButton(
      child: Text(t.dialog_done),
      onPressed: () => Navigator.pop(context),
    );
  }

  void updateSelectedOrder(int? newIndex) {
    if (newIndex != null) {
      _selectedOrder = newIndex;
      setState(() {});
    }
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: Icons.bookmark,
        message: t.no_catalogs_listed,
      ),
    );
  }

  Widget buildCatalogList() {
    List<MokuroCatalog> catalogs = appModel.mokuroCatalogs;

    if (catalogs.isEmpty) {
      return buildEmptyMessage();
    }

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: _scrollController,
      child: ReorderableColumn(
        scrollController: _scrollController,
        children: List.generate(
          catalogs.length,
          (index) => buildCatalogTile(catalogs[index]),
        ),
        onReorder: (oldIndex, newIndex) async {
          List<MokuroCatalog> cloneCatalogs = [];
          cloneCatalogs.addAll(catalogs);

          MokuroCatalog item = cloneCatalogs[oldIndex];
          cloneCatalogs.remove(item);
          cloneCatalogs.insert(newIndex, item);

          cloneCatalogs.forEachIndexed((index, mapping) {
            mapping.order = index;
          });

          updateSelectedOrder(newIndex);

          appModel.updateCatalogsOrder(cloneCatalogs);
          setState(() {});
        },
      ),
    );
  }

  Widget buildCatalogTile(MokuroCatalog catalog) {
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(catalog.id),
      child: ListTile(
        selected: _selectedOrder == catalog.order,
        leading: const Icon(Icons.bookmark),
        title: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  JidoujishoMarquee(
                    text: catalog.name,
                    style: TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                  ),
                  JidoujishoMarquee(
                    text: catalog.url,
                    style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
                  ),
                ],
              ),
            ),
            if (_selectedOrder == catalog.order) const Space.normal(),
            if (_selectedOrder == catalog.order)
              buildCatalogTileTrailing(catalog)
          ],
        ),
        onTap: () async {
          updateSelectedOrder(catalog.order);
        },
      ),
    );
  }

  Widget buildCatalogTileTrailing(MokuroCatalog catalog) {
    return JidoujishoIconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icons.more_vert,
      onTapDown: (details) => openCatalogOptionsMenu(
        details: details,
        catalog: catalog,
      ),
      tooltip: t.show_options,
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: textTheme.bodyMedium?.fontSize,
              color: color,
            ),
          if (icon != null) const Space.normal(),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
      value: action,
    );
  }

  void openCatalogOptionsMenu({
    required TapDownDetails details,
    required MokuroCatalog catalog,
  }) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(catalog),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems(MokuroCatalog catalog) {
    return [
      buildPopupItem(
        label: t.options_edit,
        icon: Icons.edit,
        action: () async {
          await showDialog(
            context: context,
            builder: (context) => MokuroCatalogEditDialogPage(catalog: catalog),
          );
          setState(() {});
        },
      ),
      buildPopupItem(
        label: t.options_delete,
        icon: Icons.delete,
        action: () {
          showCatalogDeleteDialog(catalog);
        },
        color: theme.colorScheme.primary,
      ),
    ];
  }

  Future<void> showCatalogDeleteDialog(MokuroCatalog catalog) async {
    Widget alertDialog = AlertDialog(
      title: Text(catalog.name),
      content: Text(
        t.catalog_name,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_delete,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            appModel.deleteCatalog(catalog);
            Navigator.pop(context);

            _selectedOrder = -1;
            setState(() {});
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}
