import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A TABLE widget.
class HtmlTable extends MultiChildRenderObjectWidget {
  /// The table border sides.
  final Border? border;

  /// Controls whether to collapse borders.
  ///
  /// Default: `false`.
  final bool borderCollapse;

  /// The gap between borders.
  ///
  /// Default: `0.0`.
  final double borderSpacing;

  /// The companion data for table.
  final HtmlTableCompanion companion;

  /// Creates a TABLE widget.
  HtmlTable({
    this.border,
    this.borderCollapse = false,
    this.borderSpacing = 0.0,
    required List<Widget> children,
    required this.companion,
    Key? key,
  }) : super(children: children, key: key);

  @override
  RenderObject createRenderObject(BuildContext _) =>
      _TableRenderObject(border, borderCollapse, borderSpacing, companion);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<Border>('border', border, defaultValue: null));
    properties.add(FlagProperty('borderCollapse',
        value: borderCollapse,
        defaultValue: false,
        ifTrue: 'borderCollapse: true'));
    properties
        .add(DoubleProperty('borderSpacing', borderSpacing, defaultValue: 0.0));
  }

  @override
  void updateRenderObject(BuildContext _, _TableRenderObject renderObject) {
    renderObject
      ..border = border
      ..borderCollapse = borderCollapse
      ..borderSpacing = borderSpacing
      ..companion = companion;
  }
}

/// Companion data for table.
class HtmlTableCompanion {
  final _baselines = <int, List<_ValignBaselineRenderObject>>{};
}

/// A TD (table cell) widget.
class HtmlTableCell extends ParentDataWidget<_TableCellData> {
  /// The cell border sides.
  final Border? border;

  /// The number of columns this cell should span.
  final int columnSpan;

  /// The column index this cell should start.
  final int columnStart;

  /// The number of rows this cell should span.
  final int rowSpan;

  /// The row index this cell should start.
  final int rowStart;

  /// Creates a TD (table cell) widget.
  HtmlTableCell({
    this.border,
    required Widget child,
    this.columnSpan = 1,
    required this.columnStart,
    Key? key,
    this.rowSpan = 1,
    required this.rowStart,
  })   : assert(columnSpan >= 1),
        assert(columnStart >= 0),
        assert(rowSpan >= 1),
        assert(rowStart >= 0),
        super(child: child, key: key);

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData as _TableCellData;
    var needsLayout = false;

    if (data.border != border) {
      data.border = border;
      needsLayout = true;
    }

    if (data.columnSpan != columnSpan) {
      data.columnSpan = columnSpan;
      needsLayout = true;
    }

    if (data.columnStart != columnStart) {
      data.columnStart = columnStart;
      needsLayout = true;
    }

    if (data.rowStart != rowStart) {
      data.rowStart = rowStart;
      needsLayout = true;
    }

    if (data.rowSpan != rowSpan) {
      data.rowSpan = rowSpan;
      needsLayout = true;
    }

    if (needsLayout) {
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<Border>('border', border, defaultValue: null));
    properties.add(IntProperty('columnSpan', columnSpan, defaultValue: 1));
    properties.add(IntProperty('columnStart', columnStart));
    properties.add(IntProperty('rowSpan', rowSpan, defaultValue: 1));
    properties.add(IntProperty('rowStart', rowStart));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => HtmlTable;
}

/// A `valign=baseline` widget.
class HtmlTableValignBaseline extends SingleChildRenderObjectWidget {
  /// The table's companion data.
  final HtmlTableCompanion companion;

  /// The cell's row index.
  final int row;

  /// Creates a `valign=baseline` widget.
  HtmlTableValignBaseline({
    Widget? child,
    required this.companion,
    Key? key,
    required this.row,
  }) : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ValignBaselineRenderObject(companion, row);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('row', row));
  }

  @override
  void updateRenderObject(
      BuildContext _, _ValignBaselineRenderObject renderObject) {
    renderObject
      ..companion = companion
      ..row = row;
  }
}

extension _IterableDouble on Iterable<double> {
  double get sum => isEmpty ? 0.0 : reduce(_sum);

  static double _sum(double value, double element) => value + element;
}

class _TableCellData extends ContainerBoxParentData<RenderBox> {
  Border? border;
  int columnSpan = 1;
  int columnStart = -1;
  int rowSpan = 1;
  int rowStart = -1;

  double calculateHeight(_TableRenderObject tro, List<double> heights) {
    final gaps = (rowSpan - 1) * tro.rowGap;
    return heights.getRange(rowStart, rowStart + rowSpan).sum + gaps;
  }

  double calculateWidth(_TableRenderObject tro, List<double> widths) {
    final gaps = (columnSpan - 1) * tro.columnGap;
    return widths.getRange(columnStart, columnStart + columnSpan).sum + gaps;
  }

  double calculateX(_TableRenderObject tro, List<double> widths) {
    final padding = tro._border?.left.width ?? 0.0;
    final gaps = (columnStart + 1) * tro.columnGap;
    return padding + widths.getRange(0, columnStart).sum + gaps;
  }

  double calculateY(_TableRenderObject tro, List<double> heights) {
    final padding = tro._border?.top.width ?? 0.0;
    final gaps = (rowStart + 1) * tro.rowGap;
    return padding + heights.getRange(0, rowStart).sum + gaps;
  }
}

class _TableRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TableCellData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TableCellData> {
  _TableRenderObject(
      this._border, this._borderCollapse, this._borderSpacing, this._companion);

  Border? _border;
  set border(Border? v) {
    if (v == _border) return;
    _border = v;
    markNeedsLayout();
  }

  bool _borderCollapse;
  set borderCollapse(bool v) {
    if (v == _borderCollapse) return;
    _borderCollapse = v;
    markNeedsLayout();
  }

  double _borderSpacing;
  set borderSpacing(double v) {
    if (v == _borderSpacing) return;
    _borderSpacing = v;
    markNeedsLayout();
  }

  HtmlTableCompanion _companion;
  set companion(HtmlTableCompanion v) {
    if (v == _companion) return;
    _companion = v;
    markNeedsLayout();
  }

  double get columnGap => _border != null && _borderCollapse
      ? (_border!.left.width * -1.0)
      : _borderSpacing;

  double get paddingBottom => _border?.bottom.width ?? 0.0;

  double get paddingLeft => _border?.left.width ?? 0.0;

  double get paddingRight => _border?.right.width ?? 0.0;

  double get paddingTop => _border?.top.width ?? 0.0;

  double get rowGap => _border != null && _borderCollapse
      ? (_border!.top.width * -1.0)
      : _borderSpacing;

  double? _calculatedHeight;
  double? _calculatedWidth;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    double? result;

    var child = firstChild;
    while (child != null) {
      final data = child.parentData as _TableCellData;
      // only compute cells in the first row
      if (data.rowStart != 0) continue;

      var candidate = child.getDistanceToActualBaseline(baseline);
      if (candidate != null) {
        candidate += data.offset.dy;
        if (result != null) {
          result = min(result, candidate);
        } else {
          result = candidate;
        }
      }

      child = data.nextSibling;
    }

    return result;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _performLayout(this, firstChild!, constraints, _performLayoutDry);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    _companion._baselines.clear();

    assert(_calculatedHeight != null);
    assert(_calculatedWidth != null);
    _border?.paint(
        context.canvas,
        Rect.fromLTWH(offset.dx, offset.dy, _calculatedWidth ?? 0.0,
            _calculatedHeight ?? 0.0));

    var child = firstChild;
    while (child != null) {
      final data = child.parentData as _TableCellData;
      final childOffset = data.offset + offset;
      final childSize = child.size;
      context.paintChild(child, childOffset);

      data.border?.paint(
        context.canvas,
        Rect.fromLTWH(
          childOffset.dx,
          childOffset.dy,
          childSize.width,
          childSize.height,
        ),
      );

      child = data.nextSibling;
    }
  }

  @override
  void performLayout() {
    final calculatedSize =
        _performLayout(this, firstChild!, constraints, _performLayoutLayouter);
    _calculatedHeight = calculatedSize.height;
    _calculatedWidth = calculatedSize.width;

    size = constraints.constrain(calculatedSize);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TableCellData) {
      child.parentData = _TableCellData();
    }
  }

  static Size _performLayout(
      final _TableRenderObject tro,
      final RenderBox firstChild,
      final BoxConstraints constraints,
      final Size Function(RenderBox renderBox, BoxConstraints constraints)
          layouter) {
    final children = <RenderBox>[];
    final cells = <_TableCellData>[];

    RenderBox? child = firstChild;
    var columnCount = 0;
    var rowCount = 0;
    while (child != null) {
      final data = child.parentData as _TableCellData;
      children.add(child);
      cells.add(data);

      columnCount = max(columnCount, data.columnStart + data.columnSpan);
      rowCount = max(rowCount, data.rowStart + data.rowSpan);

      child = data.nextSibling;
    }

    final columnGaps = (columnCount + 1) * tro.columnGap;
    final rowGaps = (rowCount + 1) * tro.rowGap;
    final width0 = (constraints.maxWidth -
            tro.paddingLeft -
            tro.paddingRight -
            columnGaps) /
        columnCount;
    final childSizes = List.filled(children.length, Size.zero);
    final columnWidths = List.filled(columnCount, 0.0);
    final rowHeights = List.filled(rowCount, 0.0);
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final data = cells[i];

      // assume even distribution of column widths if width is finite
      final childColumnGaps = (data.columnSpan - 1) * tro.columnGap;
      final childWidth =
          width0.isFinite ? width0 * data.columnSpan + childColumnGaps : null;
      final cc = BoxConstraints(
        maxWidth: childWidth ?? double.infinity,
        minWidth: childWidth ?? 0.0,
      );
      final childSize = childSizes[i] = layouter(child, cc);

      // distribute cell width across spanned columns
      final columnWidth = (childSize.width - childColumnGaps) / data.columnSpan;
      for (var c = 0; c < data.columnSpan; c++) {
        final column = data.columnStart + c;
        columnWidths[column] = max(columnWidths[column], columnWidth);
      }

      // distribute cell height across spanned rows
      final childRowGaps = (data.rowSpan - 1) * tro.rowGap;
      final rowHeight = (childSize.height - childRowGaps) / data.rowSpan;
      for (var r = 0; r < data.rowSpan; r++) {
        final row = data.rowStart + r;
        rowHeights[row] = max(rowHeights[row], rowHeight);
      }
    }

    // we now know all the widths and heights, let's position cells
    // sometime we have to relayout child, e.g. stretch its height for rowspan
    final calculatedHeight =
        tro.paddingTop + rowHeights.sum + rowGaps + tro.paddingBottom;
    final constraintedHeight = constraints.constrainHeight(calculatedHeight);
    final deltaHeight =
        max(0, (constraintedHeight - calculatedHeight) / rowCount);
    final calculatedWidth =
        tro.paddingLeft + columnWidths.sum + columnGaps + tro.paddingRight;
    final constraintedWidth = constraints.constrainWidth(calculatedWidth);
    final deltaWidth = (constraintedWidth - calculatedWidth) / columnCount;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final data = cells[i];
      final childSize = childSizes[i];

      final childHeight = data.calculateHeight(tro, rowHeights) + deltaHeight;
      final childWidth = data.calculateWidth(tro, columnWidths) + deltaWidth;
      if (childSize.height != childHeight || childSize.width != childWidth) {
        final cc2 = BoxConstraints.tight(Size(childWidth, childHeight));
        layouter(child, cc2);
      }

      if (child.hasSize) {
        data.offset = Offset(
          data.calculateX(tro, columnWidths),
          data.calculateY(tro, rowHeights),
        );
      }
    }

    return Size(calculatedWidth, calculatedHeight);
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

class _ValignBaselineRenderObject extends RenderProxyBox {
  _ValignBaselineRenderObject(this._companion, this._row);

  HtmlTableCompanion _companion;
  set companion(HtmlTableCompanion v) {
    if (v == _companion) return;
    _companion = v;
    markNeedsLayout();
  }

  int _row;
  set row(int v) {
    if (v == _row) return;
    _row = v;
    markNeedsLayout();
  }

  double? _baselineWithOffset;
  var _paddingTop = 0.0;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _performLayout(child, _paddingTop, constraints, _performLayoutDry);

  @override
  void paint(PaintingContext context, Offset offset) {
    offset = offset.translate(0, _paddingTop);

    final child = this.child;
    if (child == null) return;

    final baselineWithOffset = _baselineWithOffset = offset.dy +
        (child.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0.0);

    final siblings = _companion._baselines;
    if (siblings.containsKey(_row)) {
      final rowBaseline = siblings[_row]!
          .map((e) => e._baselineWithOffset!)
          .reduce((v, e) => max(v, e));
      siblings[_row]!.add(this);

      if (rowBaseline > baselineWithOffset) {
        final offsetY = rowBaseline - baselineWithOffset;
        if (size.height - child.size.height >= offsetY) {
          // paint child with additional offset
          context.paintChild(child, offset.translate(0, offsetY));
          return;
        } else {
          // skip painting this frame, wait for the correct padding
          _paddingTop += offsetY;
          _baselineWithOffset = rowBaseline;
          WidgetsBinding.instance
              ?.addPostFrameCallback((_) => markNeedsLayout());
          return;
        }
      } else if (rowBaseline < baselineWithOffset) {
        for (final sibling in siblings[_row]!) {
          if (sibling == this) continue;

          final offsetY = baselineWithOffset - sibling._baselineWithOffset!;
          if (offsetY != 0.0) {
            sibling._paddingTop += offsetY;
            sibling._baselineWithOffset = baselineWithOffset;
            WidgetsBinding.instance
                ?.addPostFrameCallback((_) => sibling.markNeedsLayout());
          }
        }
      }
    } else {
      siblings[_row] = [this];
    }

    context.paintChild(child, offset);
  }

  @override
  void performLayout() {
    size = _performLayout(
      child,
      _paddingTop,
      constraints,
      _performLayoutLayouter,
    );
  }

  static Size _performLayout(
      final RenderBox? child,
      final double paddingTop,
      final BoxConstraints constraints,
      final Size? Function(RenderBox? renderBox, BoxConstraints constraints)
          layouter) {
    final cc = constraints.loosen().deflate(EdgeInsets.only(top: paddingTop));
    final childSize = layouter(child, cc) ?? Size.zero;
    return constraints.constrain(childSize + Offset(0, paddingTop));
  }

  static Size? _performLayoutDry(
          RenderBox? renderBox, BoxConstraints constraints) =>
      renderBox?.getDryLayout(constraints);

  static Size? _performLayoutLayouter(
      RenderBox? renderBox, BoxConstraints constraints) {
    renderBox?.layout(constraints, parentUsesSize: true);
    return renderBox?.size;
  }
}
