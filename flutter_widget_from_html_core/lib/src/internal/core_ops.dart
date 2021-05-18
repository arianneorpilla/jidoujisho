import 'dart:math';
import 'dart:ui';

import 'package:csslib/visitor.dart' as css;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;

import '../core_data.dart';
import '../core_helpers.dart';
import '../core_widget_factory.dart';
import 'core_parser.dart';
import 'margin_vertical.dart';

part 'ops/column.dart';
part 'ops/style_bg_color.dart';
part 'ops/style_border.dart';
part 'ops/style_margin.dart';
part 'ops/style_padding.dart';
part 'ops/style_sizing.dart';
part 'ops/style_text_align.dart';
part 'ops/style_vertical_align.dart';
part 'ops/tag_a.dart';
part 'ops/tag_img.dart';
part 'ops/tag_li.dart';
part 'ops/tag_q.dart';
part 'ops/tag_ruby.dart';
part 'ops/tag_table.dart';
part 'ops/text_style.dart';

const kAttributeId = 'id';

const kTagCode = 'code';
const kTagCodeFont1 = 'Courier';
const kTagCodeFont2 = 'monospace';
const kTagKbd = 'kbd';
const kTagPre = 'pre';
const kTagSamp = 'samp';
const kTagTt = 'tt';

const kTagFont = 'font';
const kAttributeFontColor = 'color';
const kAttributeFontFace = 'face';
const kAttributeFontSize = 'size';

const kCssDisplay = 'display';
const kCssDisplayBlock = 'block';
const kCssDisplayInline = 'inline';
const kCssDisplayInlineBlock = 'inline-block';
const kCssDisplayNone = 'none';

const kCssMaxLines = 'max-lines';
const kCssMaxLinesNone = 'none';
const kCssMaxLinesWebkitLineClamp = '-webkit-line-clamp';

const kCssTextOverflow = 'text-overflow';
const kCssTextOverflowClip = 'clip';
const kCssTextOverflowEllipsis = 'ellipsis';

const kCssWhitespace = 'white-space';
const kCssWhitespacePre = 'pre';
const kCssWhitespaceNormal = 'normal';

void wrapTree(
  BuildTree tree, {
  BuildBit Function(BuildTree parent)? append,
  BuildBit Function(BuildTree parent)? prepend,
}) {
  if (tree.isEmpty) {
    if (prepend != null) {
      final prependBit = prepend(tree);
      tree.add(prependBit);
    }
    if (append != null) {
      final appendBit = append(tree);
      tree.add(appendBit);
    }
    return;
  }

  if (prepend != null) {
    final first = tree.first!;
    prepend(first.parent!).insertBefore(first);
  }

  if (append != null) {
    final last = tree.last!;
    append(last.parent!).insertAfter(last);
  }
}
