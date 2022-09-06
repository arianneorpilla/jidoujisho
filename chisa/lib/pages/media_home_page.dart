import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class MediaHomePage extends StatefulWidget {
  const MediaHomePage({
    Key? key,
    required this.mediaType,
  }) : super(key: key);

  final MediaType mediaType;
}

abstract class MediaHomePageState extends State<MediaHomePage>
    with AutomaticKeepAliveClientMixin {
  late AppModel appModel;

  TextEditingController wordController = TextEditingController(text: "");

  @override
  bool get wantKeepAlive => true;

  // @override
  // void didUpdateWidget(oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    appModel = Provider.of<AppModel>(context);

    if (!appModel.hasInitialized) {
      return Container();
    }

    if (widget.mediaType.getMediaHistory(appModel).getItems().isEmpty) {
      return buildEmptyBody();
    } else {
      return buildBody();
    }
  }

  Widget buildBody();

  Widget buildEmptyBody();

  Widget buildEmptyMessage();

  Widget buildButton();
}
