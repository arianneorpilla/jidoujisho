import 'dart:async';

import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class MediaSourceActionButton extends StatelessWidget {
  const MediaSourceActionButton({
    required this.context,
    required this.refreshCallback,
    required this.icon,
    required this.onPressed,
    this.showIfOpened = false,
    this.showIfClosed = true,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final Function() refreshCallback;
  final IconData icon;
  final FutureOr<void> Function() onPressed;
  final bool showIfOpened;
  final bool showIfClosed;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return FloatingSearchBarAction(
      showIfOpened: showIfOpened,
      showIfClosed: showIfClosed,
      child: CircularButton(
        icon: Icon(
          icon,
          size: 20,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          onPressed();
          refreshCallback();
        },
      ),
    );
  }
}
