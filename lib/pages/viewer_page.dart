import 'package:flutter/material.dart';

import 'package:chisa/media/media_types/media_launch_params.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  final ViewerLaunchParams params;

  @override
  State<StatefulWidget> createState() => ViewerPageState();
}

class ViewerPageState extends State<ViewerPage> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
