import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/models.dart';

/// An option to show in a bottom sheet.
class JidoujishoBottomSheetOption {
  /// Defines an option in a bottom sheet.
  JidoujishoBottomSheetOption({
    required this.label,
    required this.icon,
    required this.action,
    this.active = false,
  });

  /// Label to display in the option.
  String label;
  /// Icon to display left of the label.
  IconData icon;
  /// Whether or not the option is available.
  bool active;
  /// Action to perform upon selecting the option.
  FutureOr<void> Function() action;
}

///  
class JidoujishoBottomSheet extends ConsumerWidget {
  /// Initialise a bottom sheet.
  const JidoujishoBottomSheet({
    required this.options,
    super.key,
  });

  /// Options to show in the bottom sheet.
  final List<JidoujishoBottomSheetOption> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    ScrollController scrollController = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });

    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, i) {
        JidoujishoBottomSheetOption option = options[i];

        return ListTile(
          dense: true,
          leading: Icon(
            option.icon,
            size: 20,
            color: Colors.red,
          ),
          title: Text(
            option.label,
            maxLines: 1,
            style: TextStyle(
              color: (option.active)
                  ? Colors.red
                  : appModel.isDarkMode
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          onTap: () async {
            Navigator.of(context).pop();
            await option.action();
          },
        );
      },
    );
  }
}
