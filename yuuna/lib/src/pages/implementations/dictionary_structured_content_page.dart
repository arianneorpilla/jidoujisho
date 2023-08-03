import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';

/// Custom widget for structured content HTML from a Yomichan dictionary.
/// See resource for solution:
/// https://stackoverflow.com/questions/66477207/flutter-and-inappwebview-how-to-get-height
class DictionaryStructuredContentPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryStructuredContentPage({
    required this.html,
    super.key,
  });

  /// Definition to display as HTML.
  final String html;

  @override
  BasePageState createState() => _DictionaryStructuredContentPageState();
}

class _DictionaryStructuredContentPageState
    extends BasePageState<DictionaryStructuredContentPage> {
  /// To be used as data in the [InAppWebView];
  late final String data;

  double height = 1;

  @override
  void initState() {
    super.initState();

    String color = ref.read(appProvider).isDarkMode ? 'white' : 'black';
    data = '''
<html>
    <head>
    <style>
    ul {
      padding-left: 6;
    }
    li {
      margin: 0;
      padding-left: 0.2em;
    }
    body {
      color: $color;
    }
    </style>
    </head>
    <meta name="viewport" content="width=device-width user-scalable=no zoom=1">
    <style>img {max-width: 100%; height: auto}</style>
    <body>
    <div class="container" id="_flutter_target_do_not_delete">${widget.html}</div>
    <script>
    function outputsize() {
        if (typeof window.flutter_inappwebview !== "undefined" && typeof window.flutter_inappwebview.callHandler !== "undefined")
            window.flutter_inappwebview.callHandler('newHeight', document.getElementById("_flutter_target_do_not_delete").offsetHeight);
        }
      new ResizeObserver(outputsize).observe(_flutter_target_do_not_delete)
    </script>
  </body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + Spacing.of(context).spaces.normal,
      child: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            supportZoom: false,
            disableHorizontalScroll: true,
            disableVerticalScroll: true,
            transparentBackground: true,
          ),
          android: AndroidInAppWebViewOptions(
              defaultFontSize: appModel.dictionaryFontSize.toInt() + 1),
        ),
        initialData: InAppWebViewInitialData(data: data),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
              handlerName: 'newHeight',
              callback: (arguments) async {
                int height = arguments.firstOrNull ??
                    await controller.getContentHeight();
                if (mounted) {
                  setState(() {
                    this.height = height.toDouble();
                  });
                }
              });
        },
      ),
    );
  }
}
