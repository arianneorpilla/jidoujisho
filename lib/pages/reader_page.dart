import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:chisa/media/media_types/media_launch_params.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  final ReaderLaunchParams params;

  @override
  State<StatefulWidget> createState() => ReaderPageState();
}

class ReaderPageState extends State<ReaderPage> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Future<void> unselectWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String unselectJs = "window.getSelection().removeAllRanges();";
    await webViewController.evaluateJavascript(source: unselectJs);
  }

  String sanitizeWebViewTextSelection(String? text) {
    if (text == null) {
      return "";
    }

    text = text.replaceAll("\\n", "\n");
    text = text.trim();
    return text;
  }

  Future<String> getWebViewTextSelection(
      InAppWebViewController webViewController) async {
    String? selectedText = await webViewController.getSelectedText();
    selectedText = sanitizeWebViewTextSelection(selectedText);
    return selectedText;
  }
}
