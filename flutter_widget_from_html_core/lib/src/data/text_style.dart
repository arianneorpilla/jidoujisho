part of '../core_data.dart';

/// A text style.
@immutable
class TextStyleHtml {
  final Iterable<dynamic> _deps;

  /// The line height.
  final double? height;

  /// The number of max lines that should be rendered.
  final int? maxLines;

  /// The parent style.
  final TextStyleHtml? parent;

  /// The input [TextStyle].
  final TextStyle style;

  /// The text alignment.
  final TextAlign? textAlign;

  /// The text direction.
  final TextDirection textDirection;

  /// The overflow behavior.
  final TextOverflow? textOverflow;

  /// The whitespace behavior.
  final CssWhitespace whitespace;

  TextStyleHtml._({
    required Iterable<dynamic> deps,
    this.height,
    this.maxLines,
    this.parent,
    required this.style,
    this.textAlign,
    required this.textDirection,
    this.textOverflow,
    required this.whitespace,
  }) : _deps = deps;

  /// Creates the root text style.
  factory TextStyleHtml.root(Iterable<dynamic> deps, TextStyle? widgetStyle) {
    var style = _getDependency<TextStyle>(deps);
    if (widgetStyle != null) {
      style = widgetStyle.inherit ? style.merge(widgetStyle) : widgetStyle;
    }

    final mqd = _getDependency<MediaQueryData>(deps);
    final tsf = mqd.textScaleFactor;
    final fontSize = style.fontSize;
    if (tsf != 1 && fontSize != null) {
      style = style.copyWith(fontSize: fontSize * tsf);
    }

    return TextStyleHtml._(
      deps: deps,
      style: style,
      textDirection: _getDependency<TextDirection>(deps),
      whitespace: CssWhitespace.normal,
    );
  }

  /// Returns a [TextStyle] merged from [style] and [height].
  ///
  /// This needs to be done because
  /// `TextStyle` with existing height cannot be copied with `height=null`.
  /// See [flutter/flutter#58765](https://github.com/flutter/flutter/issues/58765).
  TextStyle get styleWithHeight =>
      height != null && height! >= 0 ? style.copyWith(height: height) : style;

  /// Creates a copy with the given fields replaced with the new values.
  TextStyleHtml copyWith({
    double? height,
    int? maxLines,
    TextStyleHtml? parent,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    TextOverflow? textOverflow,
    CssWhitespace? whitespace,
  }) =>
      TextStyleHtml._(
        deps: _deps,
        height: height ?? this.height,
        maxLines: maxLines ?? this.maxLines,
        parent: parent ?? this.parent,
        style: style ?? this.style,
        textAlign: textAlign ?? this.textAlign,
        textDirection: textDirection ?? this.textDirection,
        textOverflow: textOverflow ?? this.textOverflow,
        whitespace: whitespace ?? this.whitespace,
      );

  /// Gets dependency value by type.
  ///
  /// See [WidgetFactory.getDependencies].
  T getDependency<T>() => _getDependency<T>(_deps);

  static T _getDependency<T>(Iterable<dynamic> deps) {
    for (final value in deps.whereType<T>()) {
      return value;
    }

    throw StateError('The $T dependency could not be found');
  }
}

/// A text styling builder.
class TextStyleBuilder<T1> {
  /// The parent builder.
  final TextStyleBuilder? parent;

  List<Function>? _builders;
  List? _inputs;
  TextStyleHtml? _parentOutput;
  TextStyleHtml? _output;

  /// Create a builder.
  TextStyleBuilder({this.parent});

  /// Enqueues a callback.
  void enqueue<T2>(
    TextStyleHtml Function(TextStyleHtml tsh, T2 input) builder, [
    T2? input,
  ]) {
    assert(_output == null, 'Cannot add builder after being built');
    _builders ??= [];
    _builders!.add(builder);

    _inputs ??= [];
    _inputs!.add(input);
  }

  /// Builds a [TextStyleHtml] by calling queued callbacks.
  TextStyleHtml build(BuildContext context) {
    final parentOutput = parent?.build(context);
    if (parentOutput == null || parentOutput != _parentOutput) {
      _parentOutput = parentOutput;
      _output = null;
    }

    if (_output != null) return _output!;
    if (_builders == null) return _output = _parentOutput!;

    _output = _parentOutput?.copyWith(parent: _parentOutput);
    final l = _builders!.length;
    for (var i = 0; i < l; i++) {
      final builder = _builders![i];
      _output = builder(_output, _inputs![i]);
      assert(_output?.parent == _parentOutput);
    }

    return _output!;
  }

  /// Returns `true` if this shares same styling with [other].
  bool hasSameStyleWith(TextStyleBuilder? other) {
    if (other == null) return false;
    TextStyleBuilder thisWithBuilder = this;
    while (thisWithBuilder._builders == null) {
      final thisParent = thisWithBuilder.parent;
      if (thisParent == null) {
        break;
      } else {
        thisWithBuilder = thisParent;
      }
    }

    var otherWithBuilder = other;
    while (otherWithBuilder._builders == null) {
      final otherParent = otherWithBuilder.parent;
      if (otherParent == null) {
        break;
      } else {
        otherWithBuilder = otherParent;
      }
    }

    return thisWithBuilder == otherWithBuilder;
  }

  /// Creates a sub-builder.
  TextStyleBuilder sub() => TextStyleBuilder(parent: this);

  @override
  String toString() =>
      'tsb#$hashCode' + (parent != null ? '(parent=#${parent.hashCode})' : '');
}
