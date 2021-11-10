import 'dart:async';

import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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
    AppModel appModel = Provider.of<AppModel>(context);

    ScrollController scrollController = ScrollController();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });

    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
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
              color: (option.active)
                  ? Theme.of(context).focusColor
                  : appModel.getIsDarkMode()
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
