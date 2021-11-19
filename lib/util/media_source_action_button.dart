import 'dart:async';

import 'package:chisa/media/media_source.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class MediaSourceActionButton extends FloatingSearchBarAction {
  MediaSourceActionButton({
    required this.context,
    required this.source,
    required this.refreshCallback,
    required this.icon,
    required this.onPressed,
    required bool showIfClosed,
    required bool showIfOpened,
    Key? key,
  }) : super(
          key: key,
          showIfClosed: showIfClosed,
          showIfOpened: source.noSearchAction || showIfOpened,
          child: CircularButton(
            icon: Icon(icon,
                size: 20,
                color: (Provider.of<AppModel>(context, listen: false)
                        .getIsDarkMode()
                    ? Colors.white
                    : Colors.black)),
            onPressed: () async {
              await onPressed();
              refreshCallback();
            },
          ),
        );

  final MediaSource source;
  final BuildContext context;
  final Function() refreshCallback;
  final IconData icon;
  final FutureOr<void> Function() onPressed;
}
