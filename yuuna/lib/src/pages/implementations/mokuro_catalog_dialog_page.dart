import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for showing catalogs.
class MokuroCatalogDialogPage extends BasePage {
  /// Create an instance of this page.
  const MokuroCatalogDialogPage({
    super.key,
  });

  @override
  BasePageState createState() => _MokuroCatalogDialogPageState();
}

class _MokuroCatalogDialogPageState
    extends BasePageState<MokuroCatalogDialogPage> {
  final ScrollController _scrollController = ScrollController();

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
          child: Padding(
            padding: Spacing.of(context).insets.onlyRight.normal,
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
      ),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildManageButton(),
        buildCloseButton(),
      ];

  Widget buildManageButton() {
    return TextButton(
      child: Text(t.dialog_manage),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => const MokuroCatalogManageDialogPage(),
        );

        setState(() {});
      },
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        catalogs.length,
        (index) => buildCatalogTile(
          catalogs[index],
        ),
      ),
    );
  }

  Widget buildCatalogTile(MokuroCatalog catalog) {
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(catalog.id),
      child: ListTile(
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
          ],
        ),
        onTap: () async {
          Navigator.popUntil(context, (route) => route.isFirst);

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MokuroCatalogBrowsePage(
                item: null,
                catalog: catalog,
              ),
            ),
          );
        },
      ),
    );
  }
}
