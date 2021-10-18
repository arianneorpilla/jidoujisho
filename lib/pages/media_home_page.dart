import 'package:chisa/media/media_type.dart';
import 'package:flutter/material.dart';

abstract class MediaHomePage extends StatefulWidget {
  const MediaHomePage({
    Key? key,
    required this.mediaType,
  }) : super(key: key);

  final MediaType mediaType;
}
