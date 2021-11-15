import 'dart:io';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class ReaderHomePage extends MediaHomePage {
  const ReaderHomePage({
    Key? key,
    required MediaType mediaType,
    required this.searchBarController,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  final FloatingSearchBarController searchBarController;

  @override
  State<StatefulWidget> createState() => ReaderHomePageState();
}

class ReaderHomePageState extends State<ReaderHomePage> {
  late MediaType mediaType;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    mediaType = widget.mediaType;
  }

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Center(
      child: InkWell(
        onTap: () async {
          // mediaType.launchMediaPage(context, await selectFile());
        },
        child: Container(
          padding: const EdgeInsets.all(36),
          color: Colors.grey,
          child: Text(
            appModel.translate("start_reading"),
          ),
        ),
      ),
    );
  }
}
