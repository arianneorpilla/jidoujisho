import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';

/// Shows a bare loading circle.
class LoadingPage extends BasePage {
  /// Create an instance of this page.
  const LoadingPage({
    super.key,
  });

  @override
  BasePageState createState() => _LoadingPageState();
}

class _LoadingPageState extends BasePageState<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildLoading());
  }
}
