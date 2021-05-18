import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show CircularProgressIndicator, Theme, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import 'internal/builder.dart' as builder;
import 'core_data.dart';
import 'core_widget_factory.dart';
import 'internal/tsh_widget.dart';

/// A widget that builds Flutter widget tree from HTML
/// (supports most popular tags and stylings).
class HtmlWidget extends StatefulWidget {
  /// The base url to resolve links and image urls.
  final Uri? baseUrl;

  /// Controls whether the widget tree is built asynchronously.
  ///
  /// If not set, async build will be enabled automatically if the
  /// [html] has at least [kShouldBuildAsync] characters.
  final bool? buildAsync;

  /// The callback to handle async build snapshot.
  ///
  /// By default, a [CircularProgressIndicator] will be shown until
  /// the widget tree is ready.
  /// This default builder doesn't do any error handling
  /// (it will just ignore any errors).
  final AsyncWidgetBuilder<Widget>? buildAsyncBuilder;

  /// The callback to specify custom stylings.
  final CustomStylesBuilder? customStylesBuilder;

  /// The callback to render a custom widget.
  final CustomWidgetBuilder? customWidgetBuilder;

  /// Controls whether the built widget tree is cached between rebuilds.
  ///
  /// Default: `true` if [buildAsync] is off, `false` otherwise.
  final bool? enableCaching;

  /// The input string.
  final String html;

  /// The text color for link elements.
  ///
  /// Default: [ThemeData.accentColor].
  final Color? hyperlinkColor;

  /// The custom [WidgetFactory] builder.
  final WidgetFactory Function()? factoryBuilder;

  /// The callback when user taps an image.
  final void Function(ImageMetadata)? onTapImage;

  /// The callback when user taps a link.
  ///
  /// Returns `false` to fallback to the built-in handler.
  /// Returns `true` (or anything that is not `false`) to skip default behaviors.
  /// Returning a `Future` is supported.
  final dynamic Function(String)? onTapUrl;

  /// The values that should trigger rebuild.
  ///
  /// By default, these fields' changes will invalidate cached widget tree:
  ///
  /// - [baseUrl]
  /// - [buildAsync]
  /// - [enableCaching]
  /// - [html]
  /// - [hyperlinkColor]
  ///
  /// In `flutter_widget_from_html` package, these are also included:
  ///
  /// - `unsupportedWebViewWorkaroundForIssue37`
  /// - `webView`
  /// - `webViewJs`
  RebuildTriggers get rebuildTriggers => RebuildTriggers([
        html,
        baseUrl,
        buildAsync,
        enableCaching,
        hyperlinkColor,
        if (_rebuildTriggers != null) _rebuildTriggers,
      ]);
  final RebuildTriggers? _rebuildTriggers;

  /// The default styling for text elements.
  final TextStyle? textStyle;

  /// Creates a widget that builds Flutter widget tree from html.
  ///
  /// The [html] argument must not be null.
  HtmlWidget(
    this.html, {
    this.baseUrl,
    this.buildAsync,
    this.buildAsyncBuilder,
    this.customStylesBuilder,
    this.customWidgetBuilder,
    this.enableCaching,
    this.factoryBuilder,
    this.hyperlinkColor,
    Key? key,
    this.onTapImage,
    this.onTapUrl,
    RebuildTriggers? rebuildTriggers,
    this.textStyle = const TextStyle(),
  })  : _rebuildTriggers = rebuildTriggers,
        super(key: key);

  @override
  State<HtmlWidget> createState() => _HtmlWidgetState();
}

class _HtmlWidgetState extends State<HtmlWidget> {
  Widget? _cache;
  Future<Widget>? _future;
  late BuildMetadata _rootMeta;
  late _RootTsb _rootTsb;
  late WidgetFactory _wf;

  bool get buildAsync =>
      widget.buildAsync ?? widget.html.length > kShouldBuildAsync;

  bool get enableCaching => widget.enableCaching ?? !buildAsync;

  @override
  void initState() {
    super.initState();

    _rootTsb = _RootTsb(this);
    _rootMeta = builder.BuildMetadata(dom.Element.tag('root'), _rootTsb);
    _wf = widget.factoryBuilder?.call() ?? WidgetFactory();

    _wf.onRoot(_rootTsb);

    if (buildAsync) {
      _future = _buildAsync();
    }
  }

  @override
  void dispose() {
    _wf.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _rootTsb.reset();
  }

  @override
  void didUpdateWidget(HtmlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    var needsRebuild = false;

    if (widget.rebuildTriggers != oldWidget.rebuildTriggers) {
      needsRebuild = true;
    }

    if (widget.textStyle != oldWidget.textStyle) {
      _rootTsb.reset();
      needsRebuild = true;
    }

    if (needsRebuild) {
      _cache = null;
      _future = buildAsync ? _buildAsync() : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future != null) {
      return FutureBuilder<Widget>(
        builder: widget.buildAsyncBuilder ?? _buildAsyncBuilder,
        future: _future!.then(_tshWidget),
      );
    }

    if (!enableCaching || _cache == null) _cache = _buildSync();

    return _tshWidget(_cache!);
  }

  Future<Widget> _buildAsync() async {
    final domNodes = await compute(_parseHtml, widget.html);

    Timeline.startSync('Build $widget (async)');
    final built = _buildBody(this, domNodes);
    Timeline.finishSync();

    return built;
  }

  Widget _buildSync() {
    Timeline.startSync('Build $widget (sync)');

    final domNodes = _parseHtml(widget.html);
    final built = _buildBody(this, domNodes);

    Timeline.finishSync();

    return built;
  }

  Widget _tshWidget(Widget child) =>
      TshWidget(tsh: _rootTsb._output, child: child);
}

class _RootTsb extends TextStyleBuilder {
  TextStyleHtml? _output;

  _RootTsb(_HtmlWidgetState state) {
    enqueue(builder, state);
  }

  @override
  TextStyleHtml build(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<TshWidget>();
    return super.build(context);
  }

  TextStyleHtml builder(TextStyleHtml? _, _HtmlWidgetState state) {
    if (_output != null) return _output!;
    return _output = TextStyleHtml.root(
      state._wf.getDependencies(state.context),
      state.widget.textStyle,
    );
  }

  void reset() => _output = null;
}

Widget _buildAsyncBuilder(
        BuildContext context, AsyncSnapshot<Widget> snapshot) =>
    snapshot.data ??
    Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(),
      ),
    );

Widget _buildBody(_HtmlWidgetState state, dom.NodeList domNodes) {
  final rootMeta = state._rootMeta;
  final wf = state._wf;
  wf.reset(state);

  final tree = builder.BuildTree(
    customStylesBuilder: state.widget.customStylesBuilder,
    customWidgetBuilder: state.widget.customWidgetBuilder,
    parentMeta: rootMeta,
    tsb: rootMeta.tsb,
    wf: wf,
  )..addBitsFromNodes(domNodes);
  return wf.buildBody(rootMeta, tree.build()) ?? widget0;
}

dom.NodeList _parseHtml(String html) => parser.HtmlParser(
      html,
      generateSpans: false,
      parseMeta: false,
    ).parseFragment().nodes;
