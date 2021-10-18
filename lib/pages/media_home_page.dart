import 'package:chisa/media/media_type.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:flutter/material.dart';

abstract class MediaHomePage extends StatefulWidget {
  const MediaHomePage({
    Key? key,
    required this.mediaType,
  });

  final MediaType mediaType;
}
