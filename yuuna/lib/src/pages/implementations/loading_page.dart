import 'package:flutter/material.dart';
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(body: buildLoading()),
    );
  }
}
