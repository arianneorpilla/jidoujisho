import 'dart:math';

import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/widgets.dart';

import '../core_data.dart';
import '../core_helpers.dart';

part 'parser/border.dart';
part 'parser/color.dart';
part 'parser/length.dart';

const kSuffixBlockEnd = '-block-end';
const kSuffixBlockStart = '-block-start';
const kSuffixBottom = '-bottom';
const kSuffixInlineEnd = '-inline-end';
const kSuffixInlineStart = '-inline-start';
const kSuffixLeft = '-left';
const kSuffixRight = '-right';
const kSuffixTop = '-top';
