import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const _kGapVsMarker = 5.0;

/// A list item widget.
class HtmlListItem extends MultiChildRenderObjectWidget {
  /// The directionality of the item.
  final TextDirection textDirection;

  /// Creates a list item widget.
  HtmlListItem({
    required Widget child,
    Key? key,
    required Widget marker,
    required this.textDirection,
  }) : super(children: [child, marker], key: key);

  @override
  RenderObject createRenderObject(BuildContext _) =>
      _ListItemRenderObject(textDirection: textDirection);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<TextDirection>('textDirection', textDirection));
  }

  @override
  void updateRenderObject(BuildContext _, _ListItemRenderObject renderObject) =>
      renderObject.textDirection = textDirection;
}

class _ListItemData extends ContainerBoxParentData<RenderBox> {}

class _ListItemRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ListItemData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ListItemData> {
  _ListItemRenderObject({
    required TextDirection textDirection,
  }) : _textDirection = textDirection;

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      firstChild!.computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      firstChild!.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      firstChild!.computeMinIntrinsicHeight(width);

  @override
  double computeMinIntrinsicWidth(double height) =>
      firstChild!.getMinIntrinsicWidth(height);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = firstChild!;
    final childConstraints = constraints;
    final childData = child.parentData as _ListItemData;
    final childSize = child.getDryLayout(childConstraints);

    final marker = childData.nextSibling!;
    final markerConstraints = childConstraints.loosen();
    final markerSize = marker.getDryLayout(markerConstraints);

    return constraints.constrain(Size(
      childSize.width,
      childSize.height > 0 ? childSize.height : markerSize.height,
    ));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  void performLayout() {
    final child = firstChild!;
    final childConstraints = constraints;
    final childData = child.parentData as _ListItemData;
    child.layout(childConstraints, parentUsesSize: true);
    final childSize = child.size;

    final marker = childData.nextSibling!;
    final markerConstraints = childConstraints.loosen();
    final markerData = marker.parentData as _ListItemData;
    marker.layout(markerConstraints, parentUsesSize: true);
    final markerSize = marker.size;

    size = constraints.constrain(Size(
      childSize.width,
      childSize.height > 0 ? childSize.height : markerSize.height,
    ));

    final baseline = TextBaseline.alphabetic;
    final markerDistance =
        marker.getDistanceToBaseline(baseline, onlyReal: true) ??
            markerSize.height;
    final childDistance =
        child.getDistanceToBaseline(baseline, onlyReal: true) ?? markerDistance;

    markerData.offset = Offset(
      textDirection == TextDirection.ltr
          ? -markerSize.width - _kGapVsMarker
          : childSize.width + _kGapVsMarker,
      childDistance - markerDistance,
    );
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ListItemData) {
      child.parentData = _ListItemData();
    }
  }
}
