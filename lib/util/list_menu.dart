import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/models/app_model.dart';

class ListMenuItem {
  ListMenuItem({
    required this.label,
    required this.icon,
    required this.action,
  });

  final String label;
  final IconData icon;
  final VoidCallback? action;
}

class ListMenu extends StatefulWidget {
  const ListMenu({
    Key? key,
    required this.items,
    required this.indexNotifier,
    required this.emptyWidget,
    required this.stateCallback,
    required this.popOnSelect,
  }) : super(key: key);

  final List<ListMenuItem> items;
  final ValueNotifier<int> indexNotifier;
  final Widget emptyWidget;
  final VoidCallback stateCallback;
  final bool popOnSelect;

  @override
  State<StatefulWidget> createState() => ListMenuState();
}

class ListMenuState extends State<ListMenu> {
  ScrollController scrollController = ScrollController();

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: buildContent(),
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.items.isEmpty ? widget.emptyWidget : buildList(),
        ],
      ),
    );
  }

  Widget buildList() {
    return RawScrollbar(
      controller: scrollController,
      thumbColor:
          appModel.getIsDarkMode() ? Colors.grey[700] : Colors.grey[400],
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        shrinkWrap: true,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          ListMenuItem item = widget.items[index];

          return ListTile(
            selected: widget.indexNotifier.value == index,
            selectedTileColor: Theme.of(context).selectedRowColor,
            dense: true,
            title: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        appModel.getIsDarkMode() ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            onTap: () async {
              if (item.action != null) {
                item.action!;
              }
              setState(() {});
              if (widget.popOnSelect) {
                Navigator.pop(context, item);
              }
            },
          );
        },
      ),
    );
  }
}
