import 'package:chisa/media/media_type.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:flutter/material.dart';

class PlayerHomePage extends MediaHomePage {
  const PlayerHomePage({
    Key? key,
    required MediaType mediaType,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  @override
  State<StatefulWidget> createState() => PlayerHomePageState();
}

class PlayerHomePageState extends State<PlayerHomePage> {
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
    return Container();
  }
}
