import 'package:csslib/visitor.dart' as css;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    show Colors, MaterialTextSelectionControls, Theme, ThemeData, Tooltip;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:extended_text/extended_text.dart';

import 'internal/core_ops.dart';
import 'internal/core_parser.dart';
import 'internal/flattener.dart';
import 'internal/platform_specific/fallback.dart'
    if (dart.library.io) 'internal/platform_specific/io.dart';
import 'core_data.dart';
import 'core_helpers.dart';
import 'core_html_widget.dart';

/// A factory to build widgets.
class WidgetFactory {
  final _anchors = <String, GlobalKey>{};
  final _flattener = Flattener();

  BuildOp? _styleBgColor;
  BuildOp? _styleBlock;
  BuildOp? _styleBorder;
  BuildOp? _styleDisplayNone;
  BuildOp? _styleMargin;
  BuildOp? _stylePadding;
  BuildOp? _styleSizing;
  BuildOp? _styleTextDecoration;
  BuildOp? _styleVerticalAlign;
  BuildOp? _tagA;
  TextStyleHtml Function(TextStyleHtml, Null)? _tagAColor;
  BuildOp? _tagBr;
  BuildOp? _tagFont;
  BuildOp? _tagHr;
  BuildOp? _tagImg;
  BuildOp? _tagPre;
  BuildOp? _tagQ;
  TextStyleHtml Function(TextStyleHtml, css.Expression)? _tsbLineHeight;
  HtmlWidget? _widget;

  /// Builds [Align].
  Widget? buildAlign(
    BuildMetadata meta,
    Widget child,
    AlignmentGeometry alignment, {
    double? heightFactor,
    double? widthFactor,
  }) =>
      Align(
        alignment: alignment,
        heightFactor: heightFactor,
        widthFactor: widthFactor,
        child: child,
      );

  /// Builds [AspectRatio].
  Widget? buildAspectRatio(
          BuildMetadata meta, Widget child, double aspectRatio) =>
      AspectRatio(aspectRatio: aspectRatio, child: child);

  /// Builds primary column (body).
  WidgetPlaceholder? buildBody(
          BuildMetadata meta, Iterable<WidgetPlaceholder> children) =>
      buildColumnPlaceholder(meta, children, trimMarginVertical: true);

  /// Builds [border] with [Container] or [DecoratedBox].
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/CSS/box-sizing
  /// for more information regarding `content-box` (the default)
  /// and `border-box` (set [isBorderBox] to use).
  Widget? buildBorder(BuildMetadata meta, Widget child, BoxBorder border,
          {bool isBorderBox = false}) =>
      isBorderBox
          ? DecoratedBox(
              decoration: BoxDecoration(border: border),
              child: child,
            )
          : Container(
              decoration: BoxDecoration(border: border),
              child: child,
            );

  /// Builds column placeholder.
  WidgetPlaceholder? buildColumnPlaceholder(
    BuildMetadata meta,
    Iterable<WidgetPlaceholder> children, {
    bool trimMarginVertical = false,
  }) {
    if (children.isEmpty) return null;

    if (children.length == 1) {
      final child = children.first;
      if (child is ColumnPlaceholder) {
        if (child.trimMarginVertical == trimMarginVertical) {
          return child;
        }
      } else {
        return child;
      }
    }

    return ColumnPlaceholder(
      children,
      meta: meta,
      trimMarginVertical: trimMarginVertical,
      wf: this,
    );
  }

  /// Builds [Column].
  Widget? buildColumnWidget(
      BuildMetadata meta, TextStyleHtml tsh, List<Widget> children) {
    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      textDirection: tsh.textDirection,
      children: children,
    );
  }

  /// Builds [DecoratedBox].
  Widget? buildDecoratedBox(
    BuildMetadata meta,
    Widget child, {
    Color? color,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(color: color),
        child: child,
      );

  /// Builds 1-pixel-height divider.
  Widget? buildDivider(BuildMetadata meta) => const DecoratedBox(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1)),
        child: SizedBox(height: 1),
      );

  /// Builds [GestureDetector].
  Widget? buildGestureDetector(
          BuildMetadata meta, Widget child, GestureTapCallback onTap) =>
      GestureDetector(onTap: onTap, child: child);

  /// Builds horizontal scroll view.
  Widget? buildHorizontalScrollView(BuildMetadata meta, Widget child) =>
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);

  /// Builds image widget from an [ImageMetadata].
  Widget? buildImage(BuildMetadata meta, ImageMetadata data) {
    final src = data.sources.isNotEmpty ? data.sources.first : null;
    if (src == null) return null;

    var built = buildImageWidget(
      meta,
      semanticLabel: data.alt ?? data.title,
      url: src.url,
    );

    final title = data.title;
    if (built != null && title != null) {
      built = buildTooltip(meta, built, title);
    }

    if (built != null &&
        src.height?.isNegative == false &&
        src.width?.isNegative == false &&
        src.height != 0) {
      built = buildAspectRatio(meta, built, src.width! / src.height!);
    }

    if (_widget?.onTapImage != null && built != null) {
      built = buildGestureDetector(
          meta, built, () => _widget?.onTapImage?.call(data));
    }

    return built;
  }

  /// Builds [Image].
  Widget? buildImageWidget(
    BuildMetadata meta, {
    String? semanticLabel,
    required String url,
  }) {
    late final ImageProvider? provider;
    if (url.startsWith('asset:')) {
      provider = imageProviderFromAsset(url);
    } else if (url.startsWith('data:image/')) {
      provider = imageProviderFromDataUri(url);
    } else if (url.startsWith('file:')) {
      provider = imageProviderFromFileUri(url);
    } else {
      provider = imageProviderFromNetwork(url);
    }
    if (provider == null) return null;

    return Image(
      errorBuilder: (_, error, __) {
        print('$provider error: $error');
        final text = semanticLabel ?? '❌';
        return Text(text);
      },
      excludeFromSemantics: semanticLabel == null,
      fit: BoxFit.fill,
      image: provider,
      semanticLabel: semanticLabel,
    );
  }

  /// Builds [Padding].
  Widget? buildPadding(
          BuildMetadata meta, Widget child, EdgeInsetsGeometry padding) =>
      padding == EdgeInsets.zero
          ? child
          : Padding(padding: padding, child: child);

  /// Builds [RichText].
  Widget? buildText(BuildMetadata meta, TextStyleHtml tsh, InlineSpan text) {
    return ExtendedText.rich(
      text,
      style: tsh.style,
      selectionEnabled: true,
      textSelectionControls: CustomTextSelectionControls(),
      selectionColor: Colors.blue,
    );
  }

  /// Builds [Tooltip].
  Widget? buildTooltip(BuildMetadata meta, Widget child, String message) =>
      Tooltip(message: message, child: child);

  /// Called when the [HtmlWidget]'s state is disposed.
  @mustCallSuper
  void dispose() {
    _flattener.dispose();
  }

  /// Flattens a [BuildTree] into widgets.
  Iterable<WidgetPlaceholder> flatten(BuildMetadata meta, BuildTree tree) {
    final widgets = <WidgetPlaceholder>[];

    for (final flattened in _flattener.flatten(tree)) {
      if (flattened.widget != null) {
        widgets.add(WidgetPlaceholder.lazy(flattened.widget!));
        continue;
      }

      if (flattened.widgetBuilder != null) {
        widgets.add(WidgetPlaceholder<BuildTree>(tree)
            .wrapWith((context, _) => flattened.widgetBuilder!(context)));
        continue;
      }

      if (flattened.spanBuilder == null) continue;
      widgets.add(WidgetPlaceholder<BuildTree>(tree).wrapWith((context, _) {
        final tsh = tree.tsb.build(context);
        final span = flattened.spanBuilder!(context, tsh.whitespace);
        if (span == null || span is! InlineSpan) return widget0;

        final textAlign = tsh.textAlign ?? TextAlign.start;

        if (span is WidgetSpan &&
            span.alignment == PlaceholderAlignment.baseline &&
            textAlign == TextAlign.start) {
          return span.child;
        }

        return buildText(meta, tsh, span);
      }));
    }

    return widgets;
  }

  /// Prepares [GestureTapCallback].
  GestureTapCallback? gestureTapCallback(String url) => () => onTapUrl(url);

  /// Returns [context]-based dependencies.
  ///
  /// Includes these by default:
  ///
  /// - [MediaQueryData] via [MediaQuery.of]
  /// - [TextDirection] via [Directionality.of]
  /// - [TextStyle] via [DefaultTextStyle.of]
  /// - [ThemeData] via [Theme.of]
  ///
  /// Use [TextStyleHtml.getDependency] to get value by type.
  ///
  /// ```dart
  /// // in normal widget building:
  /// final scale = MediaQuery.of(context).textScaleFactor;
  /// final color = Theme.of(context).accentColor;
  ///
  /// // in build ops:
  /// final scale = tsh.getDependency<MediaQueryData>().textScaleFactor;
  /// final color = tsh.getDependency<ThemeData>().accentColor;
  /// ```
  ///
  /// It's recommended to use values from [TextStyleHtml] instead of
  /// obtaining from [BuildContext] for performance reason.
  ///
  /// ```dart
  /// // avoid doing this:
  /// final widgetValue = Directionality.of(context);
  ///
  /// // do this:
  /// final buildOpValue = tsh.textDirection;
  /// ```
  Iterable<dynamic> getDependencies(BuildContext context) => [
        MediaQuery.of(context),
        Directionality.of(context),
        DefaultTextStyle.of(context).style,
        Theme.of(context),
      ];

  /// Returns marker for the specified [type] at index [i].
  ///
  /// Note: `circle`, `disc` and `square` type won't trigger this method
  String getListStyleMarker(String type, int i) {
    switch (type) {
      case kCssListStyleTypeAlphaLower:
      case kCssListStyleTypeAlphaLatinLower:
        if (i >= 1 && i <= 26) {
          // the specs said it's unspecified after the 26th item
          // TODO: generate something like aa, ab, etc. when needed
          return '${String.fromCharCode(96 + i)}.';
        }
        return '';
      case kCssListStyleTypeAlphaUpper:
      case kCssListStyleTypeAlphaLatinUpper:
        if (i >= 1 && i <= 26) {
          // the specs said it's unspecified after the 26th item
          // TODO: generate something like AA, AB, etc. when needed
          return '${String.fromCharCode(64 + i)}.';
        }
        return '';
      case kCssListStyleTypeDecimal:
        return '$i.';
      case kCssListStyleTypeRomanLower:
        final roman = _getListStyleMarkerRoman(i)?.toLowerCase();
        return roman != null ? '$roman.' : '';
      case kCssListStyleTypeRomanUpper:
        final roman = _getListStyleMarkerRoman(i);
        return roman != null ? '$roman.' : '';
    }

    return '';
  }

  String? _getListStyleMarkerRoman(int i) {
    // TODO: find some lib to generate programatically
    const map = <int, String>{
      1: 'I',
      2: 'II',
      3: 'III',
      4: 'IV',
      5: 'V',
      6: 'VI',
      7: 'VII',
      8: 'VIII',
      9: 'IX',
      10: 'X',
    };

    return map[i];
  }

  /// Returns an [AssetImage].
  ImageProvider? imageProviderFromAsset(String url) {
    final uri = Uri.parse(url);
    final assetName = uri.path;
    if (assetName.isEmpty) return null;

    final package = uri.queryParameters.containsKey('package') == true
        ? uri.queryParameters['package']
        : null;

    return AssetImage(assetName, package: package);
  }

  /// Returns a [MemoryImage].
  ImageProvider? imageProviderFromDataUri(String dataUri) {
    final bytes = bytesFromDataUri(dataUri);
    if (bytes == null) return null;

    return MemoryImage(bytes);
  }

  /// Returns a [FileImage].
  ImageProvider? imageProviderFromFileUri(String url) {
    final filePath = Uri.parse(url).toFilePath();
    if (filePath.isEmpty) return null;

    return fileImageProvider(filePath);
  }

  /// Returns a [NetworkImage].
  ImageProvider? imageProviderFromNetwork(String url) =>
      url.isNotEmpty ? NetworkImage(url) : null;

  /// Prepares the root [TextStyleBuilder].
  void onRoot(TextStyleBuilder rootTsb) {}

  /// Ensures anchor is visible.
  ///
  /// Returns `true` if anchor has been found and
  /// [ScrollPosition.ensureVisible] completes successfully.
  Future<bool> onTapAnchor(String id, BuildContext? anchorContext) async {
    if (anchorContext == null) return false;

    final renderObject = anchorContext.findRenderObject();
    if (renderObject == null) return false;

    final offsetToReveal = RenderAbstractViewport.of(renderObject)
        ?.getOffsetToReveal(renderObject, 0.0)
        .offset;
    final position = Scrollable.of(anchorContext)?.position;
    if (offsetToReveal == null || position == null) return false;

    await position.ensureVisible(
      renderObject,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
    return true;
  }

  /// Calls [HtmlWidget.onTapUrl] with [url].
  ///
  /// Returns `true` if there is a callback and
  /// it finishes with non-`false` value.
  Future<bool> onTapCallback(String url) async {
    final callback = _widget?.onTapUrl;
    if (callback == null) return false;

    final result = await Future.value(callback(url));
    return result != false;
  }

  /// Handles user tapping a link.
  Future<bool> onTapUrl(String url) async {
    final handledViaCallback = await onTapCallback(url);
    if (handledViaCallback) return true;

    if (url.startsWith('#')) {
      final id = url.substring(1);
      final anchorContext = _anchors[id]?.currentContext;
      final handledViaAnchor = await onTapAnchor(id, anchorContext);
      if (handledViaAnchor) return true;
    }

    return false;
  }

  /// Parses [meta] for build ops and text styles.
  void parse(BuildMetadata meta) {
    final attrs = meta.element.attributes;

    switch (meta.element.localName) {
      case kTagA:
        _tagA ??= TagA(this).buildOp;
        meta.register(_tagA!);

        meta.tsb.enqueue(_tagAColor ??= (tsh, _) => tsh.copyWith(
            style: tsh.style.copyWith(
                color: _widget?.hyperlinkColor ??
                    tsh.getDependency<ThemeData>().accentColor)));

        final name = attrs[kAttributeAName];
        if (name != null) meta.register(_anchorOp(name));
        break;

      case 'abbr':
      case 'acronym':
        meta.tsb.enqueue(
          TextStyleOps.textDeco,
          TextDeco(style: TextDecorationStyle.dotted, under: true),
        );
        break;

      case 'address':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..tsb.enqueue(TextStyleOps.fontStyle, FontStyle.italic);
        break;

      case 'article':
      case 'aside':
      case 'div':
      case 'figcaption':
      case 'footer':
      case 'header':
      case 'main':
      case 'nav':
      case 'section':
        meta[kCssDisplay] = kCssDisplayBlock;
        break;

      case 'blockquote':
      case 'figure':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '1em 40px';
        break;

      case 'b':
      case 'strong':
        meta.tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;

      case 'big':
        meta.tsb.enqueue(TextStyleOps.fontSizeTerm, kCssFontSizeLarger);
        break;
      case 'small':
        meta.tsb.enqueue(TextStyleOps.fontSizeTerm, kCssFontSizeSmaller);
        break;

      case 'br':
        _tagBr ??= BuildOp(onTree: (_, tree) => tree.addNewLine());
        meta.register(_tagBr!);
        break;

      case kTagCenter:
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssTextAlign] = kCssTextAlignWebkitCenter;
        break;

      case 'cite':
      case 'dfn':
      case 'em':
      case 'i':
      case 'var':
        meta.tsb.enqueue(TextStyleOps.fontStyle, FontStyle.italic);
        break;

      case kTagCode:
      case kTagKbd:
      case kTagSamp:
      case kTagTt:
        meta.tsb.enqueue(
            TextStyleOps.fontFamily, const [kTagCodeFont1, kTagCodeFont2]);
        break;
      case kTagPre:
        _tagPre ??= BuildOp(
            onWidgets: (meta, widgets) => listOrNull(
                buildColumnPlaceholder(meta, widgets)
                    ?.wrapWith((_, w) => buildHorizontalScrollView(meta, w))));
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssWhitespace] = kCssWhitespacePre
          ..tsb.enqueue(
              TextStyleOps.fontFamily, const [kTagCodeFont1, kTagCodeFont2])
          ..register(_tagPre!);
        break;

      case 'dd':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '0 0 1em 40px';
        break;
      case 'dl':
        meta[kCssDisplay] = kCssDisplayBlock;
        break;
      case 'dt':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;

      case 'del':
      case 's':
      case 'strike':
        meta.tsb.enqueue(TextStyleOps.textDeco, TextDeco(strike: true));
        break;

      case kTagFont:
        _tagFont ??= BuildOp(
          defaultStyles: (element) {
            final attrs = element.attributes;
            final color = attrs[kAttributeFontColor];
            final fontFace = attrs[kAttributeFontFace];
            final fontSize = kCssFontSizes[attrs[kAttributeFontSize] ?? ''];
            return {
              if (color != null) kCssColor: color,
              if (fontFace != null) kCssFontFamily: fontFace,
              if (fontSize != null) kCssFontSize: fontSize,
            };
          },
        );
        meta.register(_tagFont!);
        break;

      case 'hr':
        _tagHr ??=
            BuildOp(onWidgets: (meta, _) => listOrNull(buildDivider(meta)));
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin + kSuffixBottom] = '1em'
          ..register(_tagHr!);
        break;

      case 'h1':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '0.67em 0'
          ..tsb.enqueue(TextStyleOps.fontSizeEm, 2.0)
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case 'h2':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '0.83em 0'
          ..tsb.enqueue(TextStyleOps.fontSizeEm, 1.5)
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case 'h3':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '1em 0'
          ..tsb.enqueue(TextStyleOps.fontSizeEm, 1.17)
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case 'h4':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '1.33em 0'
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case 'h5':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '1.67em 0'
          ..tsb.enqueue(TextStyleOps.fontSizeEm, .83)
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case 'h6':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '2.33em 0'
          ..tsb.enqueue(TextStyleOps.fontSizeEm, .67)
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;

      case kTagImg:
        _tagImg ??= TagImg(this).buildOp;
        meta.register(_tagImg!);
        break;

      case 'ins':
      case 'u':
        meta.tsb.enqueue(TextStyleOps.textDeco, TextDeco(under: true));
        break;

      case kTagOrderedList:
      case kTagUnorderedList:
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..register(TagLi(this, meta).op);
        break;

      case 'mark':
        meta
          ..[kCssBackgroundColor] = '#ff0'
          ..[kCssColor] = '#000';
        break;

      case 'p':
        meta
          ..[kCssDisplay] = kCssDisplayBlock
          ..[kCssMargin] = '1em 0';
        break;

      case kTagQ:
        _tagQ ??= TagQ(this).buildOp;
        meta.register(_tagQ!);
        break;

      case kTagRuby:
        meta.register(TagRuby(this, meta).op);
        break;

      case 'script':
      case 'style':
        meta[kCssDisplay] = kCssDisplayNone;
        break;

      case 'sub':
        meta
          ..[kCssVerticalAlign] = kCssVerticalAlignSub
          ..tsb.enqueue(TextStyleOps.fontSizeTerm, kCssFontSizeSmaller);
        break;
      case 'sup':
        meta
          ..[kCssVerticalAlign] = kCssVerticalAlignSuper
          ..tsb.enqueue(TextStyleOps.fontSizeTerm, kCssFontSizeSmaller);
        break;

      case kTagTable:
        meta
          ..[kCssDisplay] = kCssDisplayTable
          ..register(TagTable.borderOp(
            tryParseDoubleFromMap(attrs, kAttributeBorder) ?? 0.0,
            tryParseDoubleFromMap(attrs, kAttributeCellSpacing) ?? 2.0,
          ))
          ..register(TagTable.cellPaddingOp(
              tryParseDoubleFromMap(attrs, kAttributeCellPadding) ?? 1.0));
        break;
      case kTagTableCell:
        meta[kCssVerticalAlign] = kCssVerticalAlignMiddle;
        break;
      case kTagTableHeaderCell:
        meta
          ..[kCssVerticalAlign] = kCssVerticalAlignMiddle
          ..tsb.enqueue(TextStyleOps.fontWeight, FontWeight.bold);
        break;
      case kTagTableCaption:
        meta[kCssTextAlign] = kCssTextAlignCenter;
        break;
    }

    for (final attribute in attrs.entries) {
      switch (attribute.key) {
        case kAttributeAlign:
          meta[kCssTextAlign] = attribute.value;
          break;
        case kAttributeDir:
          meta[kCssDirection] = attribute.value;
          break;
        case kAttributeId:
          meta.register(_anchorOp(attribute.value));
          break;
      }
    }
  }

  /// Parses inline style [key] and [value] pair.
  void parseStyle(BuildMetadata meta, css.Declaration style) {
    final key = style.property;
    switch (key) {
      case kCssBackground:
      case kCssBackgroundColor:
        _styleBgColor ??= StyleBgColor(this).buildOp;
        meta.register(_styleBgColor!);
        break;

      case kCssColor:
        final color = tryParseColor(style.value);
        if (color != null) meta.tsb.enqueue(TextStyleOps.color, color);
        break;

      case kCssDirection:
        meta.tsb.enqueue(TextStyleOps.textDirection, style.term);
        break;

      case kCssFontFamily:
        final list = TextStyleOps.fontFamilyTryParse(style.values);
        meta.tsb.enqueue(TextStyleOps.fontFamily, list);
        break;

      case kCssFontSize:
        meta.tsb.enqueue(TextStyleOps.fontSize, style.value);
        break;

      case kCssFontStyle:
        final term = style.term;
        final fontStyle =
            term != null ? TextStyleOps.fontStyleTryParse(term) : null;
        if (fontStyle != null) {
          meta.tsb.enqueue(TextStyleOps.fontStyle, fontStyle);
        }
        break;

      case kCssFontWeight:
        final value = style.value;
        final fontWeight =
            value != null ? TextStyleOps.fontWeightTryParse(value) : null;
        if (fontWeight != null) {
          meta.tsb.enqueue(TextStyleOps.fontWeight, fontWeight);
        }
        break;

      case kCssHeight:
      case kCssMaxHeight:
      case kCssMaxWidth:
      case kCssMinHeight:
      case kCssMinWidth:
      case kCssWidth:
        _styleSizing ??= StyleSizing(this).buildOp;
        meta.register(_styleSizing!);
        break;

      case kCssLineHeight:
        _tsbLineHeight ??= TextStyleOps.lineHeight(this);
        meta.tsb.enqueue(_tsbLineHeight!, style.value);
        break;

      case kCssMaxLines:
      case kCssMaxLinesWebkitLineClamp:
        final maxLines = TextStyleOps.maxLinesTryParse(style.value);
        if (maxLines != null) meta.tsb.enqueue(TextStyleOps.maxLines, maxLines);
        break;

      case kCssTextAlign:
        final term = style.term;
        if (term != null) {
          meta.register(StyleTextAlign(this, term).op);
        }
        break;

      case kCssTextDecoration:
        _styleTextDecoration ??= BuildOp(onTree: (meta, _) {
          for (final style in meta.styles) {
            if (style.property == kCssTextDecoration) {
              final textDeco = TextDeco.tryParse(style.values);
              if (textDeco != null) {
                meta.tsb.enqueue(TextStyleOps.textDeco, textDeco);
              }
            }
          }
        });
        meta.register(_styleTextDecoration!);
        break;

      case kCssTextOverflow:
        final term = style.term;
        final textOverflow =
            term != null ? TextStyleOps.textOverflowTryParse(term) : null;
        if (textOverflow != null) {
          meta.tsb.enqueue(TextStyleOps.textOverflow, textOverflow);
        }
        break;

      case kCssVerticalAlign:
        _styleVerticalAlign ??= StyleVerticalAlign(this).buildOp;
        meta.register(_styleVerticalAlign!);
        break;

      case kCssWhitespace:
        final term = style.term;
        final whitespace =
            term != null ? TextStyleOps.whitespaceTryParse(term) : null;
        if (whitespace != null) {
          meta.tsb.enqueue(TextStyleOps.whitespace, whitespace);
        }
        break;
    }

    if (key.startsWith(kCssBorder)) {
      _styleBorder ??= StyleBorder(this).buildOp;
      meta.register(_styleBorder!);
    }

    if (key.startsWith(kCssMargin)) {
      _styleMargin ??= StyleMargin(this).buildOp;
      meta.register(_styleMargin!);
    }

    if (key.startsWith(kCssPadding)) {
      _stylePadding ??= StylePadding(this).buildOp;
      meta.register(_stylePadding!);
    }
  }

  /// Parses display inline style.
  void parseStyleDisplay(BuildMetadata meta, String? value) {
    switch (value) {
      case kCssDisplayBlock:
        _styleBlock ??= DisplayBlockOp(this);
        meta.register(_styleBlock!);
        break;
      case kCssDisplayNone:
        _styleDisplayNone ??= BuildOp(
          onTree: (_, tree) {
            for (final bit in tree.bits.toList(growable: false)) {
              bit.detach();
            }
          },
          priority: 0,
        );
        meta.register(_styleDisplayNone!);
        break;
      case kCssDisplayTable:
        meta.register(TagTable(this, meta).op);
        break;
    }
  }

  /// Resets for a new build.
  @mustCallSuper
  void reset(State state) {
    _anchors.clear();
    _flattener.reset();

    final widget = state.widget;
    _widget = widget is HtmlWidget ? widget : null;
  }

  /// Resolves full URL with [HtmlWidget.baseUrl] if available.
  String? urlFull(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('data:')) return url;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.hasScheme) return url;

    final baseUrl = _widget?.baseUrl;
    if (baseUrl == null) return null;

    return baseUrl.resolveUri(uri).toString();
  }

  BuildOp _anchorOp(String id) {
    final anchor = GlobalKey(debugLabel: id);
    _anchors[id] = anchor;

    return BuildOp(
      onTree: (meta, tree) {
        if (meta.willBuildSubtree == true) return;

        final widget = WidgetPlaceholder('#$id').wrapWith(
          (context, _) => SizedBox(
            height: meta.tsb.build(context).style.fontSize,
            key: anchor,
          ),
        );

        final bit = tree.first;
        if (bit == null) {
          // most likely an A[name]
          tree.add(WidgetBit.inline(tree, widget));
        } else {
          // most likely a SPAN[id]
          WidgetBit.inline(bit.parent!, widget).insertBefore(bit);
        }
      },
      onWidgets: (meta, widgets) {
        if (meta.willBuildSubtree == false) return widgets;

        return listOrNull(buildColumnPlaceholder(meta, widgets)?.wrapWith(
          (context, child) => SizedBox(key: anchor, child: child),
        ));
      },
      onWidgetsIsOptional: true,
    );
  }
}

class CustomTextSelectionControls extends MaterialTextSelectionControls {
  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    return false;
  }
}
