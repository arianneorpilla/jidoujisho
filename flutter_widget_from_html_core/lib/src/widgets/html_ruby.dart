import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A RUBY widget.
class HtmlRuby extends MultiChildRenderObjectWidget {
  /// Creates a RUBY widget.
  HtmlRuby(Widget ruby, Widget rt, {Key? key})
      : super(children: [ruby, rt], key: key);

  @override
  RenderObject createRenderObject(BuildContext _) => _RubyRenderObject();
}

class _RubyParentData extends ContainerBoxParentData<RenderBox> {}

class _RubyRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RubyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RubyParentData> {
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final ruby = firstChild!;
    final rubyValue = ruby.getDistanceToActualBaseline(baseline) ?? 0.0;

    final offset = (ruby.parentData as _RubyParentData).offset;
    return offset.dy + rubyValue;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final ruby = firstChild!;
    final rubyValue = ruby.computeMaxIntrinsicHeight(width);

    final rt = (ruby.parentData as _RubyParentData).nextSibling!;
    final rtValue = rt.computeMaxIntrinsicHeight(width);

    return rubyValue + rtValue;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final ruby = firstChild!;
    final rubyValue = ruby.computeMaxIntrinsicWidth(height);

    final rt = (ruby.parentData as _RubyParentData).nextSibling!;
    final rtValue = rt.computeMaxIntrinsicWidth(height);

    return max(rubyValue, rtValue);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final ruby = firstChild!;
    final rubyValue = ruby.computeMinIntrinsicHeight(width);

    final rt = (ruby.parentData as _RubyParentData).nextSibling!;
    final rtValue = rt.computeMinIntrinsicHeight(width);

    return rubyValue + rtValue;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final ruby = firstChild!;
    final rubyValue = ruby.getMinIntrinsicWidth(height);

    final rt = (ruby.parentData as _RubyParentData).nextSibling!;
    final rtValue = rt.getMinIntrinsicWidth(height);

    return min(rubyValue, rtValue);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _performLayout(firstChild!, constraints, _performLayoutDry);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  void performLayout() {
    size = _performLayout(firstChild!, constraints, _performLayoutLayouter);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RubyParentData) {
      child.parentData = _RubyParentData();
    }
  }

  static Size _performLayout(
      final RenderBox ruby,
      final BoxConstraints constraints,
      final Size Function(RenderBox renderBox, BoxConstraints constraints)
          layouter) {
    final rubyConstraints = constraints.loosen();
    final rubyData = ruby.parentData as _RubyParentData;
    final rubySize = layouter(ruby, rubyConstraints);

    final rt = rubyData.nextSibling!;
    final rtConstraints = rubyConstraints.copyWith(
        maxHeight: rubyConstraints.maxHeight - rubySize.height);
    final rtData = rt.parentData as _RubyParentData;
    final rtSize = layouter(rt, rtConstraints);

    final height = rubySize.height + rtSize.height;
    final width = max(rubySize.width, rtSize.width);

    if (ruby.hasSize) {
      rubyData.offset = Offset((width - rubySize.width) / 2, rtSize.height);
      rtData.offset = Offset((width - rtSize.width) / 2, 0);
    }

    return constraints.constrain(Size(width, height));
  }

  static Size _performLayoutDry(
          RenderBox renderBox, BoxConstraints constraints) =>
      renderBox.getDryLayout(constraints);

  static Size _performLayoutLayouter(
      RenderBox renderBox, BoxConstraints constraints) {
    renderBox.layout(constraints, parentUsesSize: true);
    return renderBox.size;
  }
}
