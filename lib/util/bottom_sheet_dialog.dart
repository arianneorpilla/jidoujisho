import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class BottomSheetDialogOption {
  BottomSheetDialogOption({
    required this.label,
    required this.icon,
    required this.action,
    this.active = false,
  });

  String label;
  IconData icon;
  bool active;
  FutureOr<void> Function() action;
}

class BottomSheetDialog extends StatelessWidget {
  const BottomSheetDialog({
    required this.options,
    Key? key,
  }) : super(key: key);

  final List<BottomSheetDialogOption> options;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });

    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, i) {
        BottomSheetDialogOption option = options[i];

        return ListTile(
          dense: true,
          leading: Icon(
            option.icon,
            size: 20.0,
            color: Colors.red,
          ),
          title: Text(
            option.label,
            maxLines: 1,
            style: TextStyle(
              color:
                  (option.active) ? Theme.of(context).focusColor : Colors.white,
            ),
          ),
          onTap: () async {
            await option.action();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
