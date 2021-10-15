import 'package:daijidoujisho/media/media_type.dart';
import 'package:daijidoujisho/models/app_model.dart';
import 'package:flutter/material.dart';

abstract class MediaPage extends StatefulWidget {
  const MediaPage({
    Key? key,
    required this.mediaType,
    required this.uri,
    this.initialProgress = 0,
  }) : super(key: key);

  final MediaType mediaType;
  final Uri uri;
  final int initialProgress;
}
