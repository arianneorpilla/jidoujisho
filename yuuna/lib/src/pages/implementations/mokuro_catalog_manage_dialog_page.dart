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
  int? _selectedOrder;

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
      content: SizedBox(
        width: double.maxFinite,
        child: RawScrollbar(
          thickness: 3,
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildCatalogList(),
              ],
            ),
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
        setState(() {});
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

  Map<MokuroCatalog, ValueNotifier<bool>> _notifiersByCatalog = {};

  Widget buildCatalogList() {
    List<MokuroCatalog> catalogs = appModel.mokuroCatalogs;
    _notifiersByCatalog = {};
    _selectedOrder ??= catalogs.firstOrNull?.order;

    if (catalogs.isEmpty) {
      return buildEmptyMessage();
    }

    return ReorderableColumn(
      scrollController: _scrollController,
      children: List.generate(catalogs.length, (index) {
        MokuroCatalog catalog = catalogs[index];

        _notifiersByCatalog.putIfAbsent(
          catalogs[index],
          () => ValueNotifier<bool>(catalog.order == _selectedOrder),
        );
        return buildCatalogTile(
          catalogs[index],
          _notifiersByCatalog[catalog]!,
        );
      }),
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
    );
  }

  Widget buildCatalogTile(
    MokuroCatalog catalog,
    ValueNotifier<bool> notifier,
  ) {
    return ValueListenableBuilder<bool>(
      key: ValueKey(catalog.name),
      valueListenable: notifier,
      builder: (context, value, _) {
        return Material(
          type: MaterialType.transparency,
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
                        style:
                            TextStyle(fontSize: textTheme.bodyMedium?.fontSize),
                      ),
                      JidoujishoMarquee(
                        text: catalog.url,
                        style:
                            TextStyle(fontSize: textTheme.bodySmall?.fontSize),
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
              _selectedOrder = catalog.order;

              for (int i = 0; i < _notifiersByCatalog.length; i++) {
                _notifiersByCatalog.entries.elementAt(i).value.value = false;
              }
              notifier.value = true;
            },
          ),
        );
      },
    );
  }

  Widget buildCatalogTileTrailing(MokuroCatalog catalog) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<VoidCallback>(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            tooltip: t.show_options,
            color: Theme.of(context).popupMenuTheme.color,
            onSelected: (value) => value(),
            itemBuilder: (context) => getMenuItems(catalog),
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              child: Icon(
                Icons.more_vert,
                color: theme.iconTheme.color,
                size: 24,
              ),
            )),
      ),
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      value: action,
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
        t.catalog_delete_confirmation,
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
