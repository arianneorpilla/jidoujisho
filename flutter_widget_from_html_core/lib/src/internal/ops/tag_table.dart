part of '../core_ops.dart';

const kTagTable = 'table';
const kTagTableRow = 'tr';
const kTagTableHeaderGroup = 'thead';
const kTagTableRowGroup = 'tbody';
const kTagTableFooterGroup = 'tfoot';
const kTagTableHeaderCell = 'th';
const kTagTableCell = 'td';
const kTagTableCaption = 'caption';

const kAttributeBorder = 'border';
const kAttributeCellPadding = 'cellpadding';
const kAttributeColspan = 'colspan';
const kAttributeCellSpacing = 'cellspacing';
const kAttributeRowspan = 'rowspan';
const kAttributeValign = 'valign';

const kCssBorderCollapse = 'border-collapse';
const kCssBorderCollapseCollapse = 'collapse';
const kCssBorderCollapseSeparate = 'separate';
const kCssBorderSpacing = 'border-spacing';

const kCssDisplayTable = 'table';
const kCssDisplayTableRow = 'table-row';
const kCssDisplayTableHeaderGroup = 'table-header-group';
const kCssDisplayTableRowGroup = 'table-row-group';
const kCssDisplayTableFooterGroup = 'table-footer-group';
const kCssDisplayTableCell = 'table-cell';
const kCssDisplayTableCaption = 'table-caption';

class TagTable {
  final companion = HtmlTableCompanion();
  final BuildMetadata tableMeta;
  final WidgetFactory wf;

  final _captions = <BuildTree>[];
  final _data = _TagTableData();

  BuildOp? _tableOp;

  TagTable(this.wf, this.tableMeta);

  BuildOp get op {
    return _tableOp ??= BuildOp(
      onChild: onChild,
      onTree: onTree,
      onWidgets: onWidgets,
      priority: 0,
    );
  }

  void onChild(BuildMetadata childMeta) {
    if (childMeta.element.parent != tableMeta.element) return;

    final which = _getCssDisplayValue(childMeta);
    _TagTableDataGroup? latestGroup;
    switch (which) {
      case kCssDisplayTableRow:
        latestGroup ??= _data.body;
        final row = _TagTableDataRow();
        latestGroup.rows.add(row);
        childMeta.register(_TagTableRow(this, childMeta, row).op);
        break;
      case kCssDisplayTableHeaderGroup:
      case kCssDisplayTableRowGroup:
      case kCssDisplayTableFooterGroup:
        final rows = which == kCssDisplayTableHeaderGroup
            ? _data.header.rows
            : which == kCssDisplayTableRowGroup
                ? _data.body.rows
                : _data.footer.rows;
        childMeta.register(_TagTableRowGroup(this, childMeta, rows).op);
        latestGroup = null;
        break;
      case kCssDisplayTableCaption:
        childMeta.register(BuildOp(onTree: (_, tree) => _captions.add(tree)));
        break;
    }
  }

  void onTree(BuildMetadata _, BuildTree tree) {
    StyleBorder.skip(tableMeta);
    StyleSizing.treatHeightAsMinHeight(tableMeta);

    for (final caption in _captions) {
      final built = wf
          .buildColumnPlaceholder(tableMeta, caption.build())
          ?.wrapWith((_, child) => _TableCaption(child));
      if (built != null) {
        WidgetBit.block(tree.parent!, built).insertBefore(tree);
      }

      caption.detach();
    }
  }

  Iterable<Widget> onWidgets(BuildMetadata _, Iterable<WidgetPlaceholder> __) {
    final builders = <_HtmlTableCellBuilder>[];
    // occupations data: { rowId: { columnId: occupied } }
    final occupations = <int, Map<int, bool>>{};
    _prepareHtmlTableCellBuilders(_data.header, occupations, builders);
    for (final body in _data.bodies) {
      _prepareHtmlTableCellBuilders(body, occupations, builders);
    }
    _prepareHtmlTableCellBuilders(_data.footer, occupations, builders);
    if (builders.isEmpty) return [];

    final border = tryParseBorder(tableMeta);
    final borderCollapse = tableMeta[kCssBorderCollapse]?.term;
    final borderSpacingExpression = tableMeta[kCssBorderSpacing]?.value;
    final borderSpacing = borderSpacingExpression != null
        ? tryParseCssLength(borderSpacingExpression)
        : null;

    return [
      WidgetPlaceholder<BuildMetadata>(tableMeta).wrapWith((context, _) {
        final tsh = tableMeta.tsb.build(context);

        return HtmlTable(
          border: border.getValue(tsh),
          borderCollapse: borderCollapse == kCssBorderCollapseCollapse,
          borderSpacing: borderSpacing?.getValue(tsh) ?? 0.0,
          companion: companion,
          children: List.from(
              builders
                  .map((f) => f(context))
                  .where((element) => element != null),
              growable: false),
        );
      }),
    ];
  }

  void _prepareHtmlTableCellBuilders(
      _TagTableDataGroup group,
      Map<int, Map<int, bool>> occupations,
      List<_HtmlTableCellBuilder> builders) {
    var rowStart = occupations.keys.length - 1;
    final rowSpanMax = group.rows.length;
    for (final row in group.rows) {
      rowStart++;
      occupations[rowStart] ??= {};

      for (final cell in row.cells) {
        var columnStart = 0;
        while (occupations[rowStart]!.containsKey(columnStart)) {
          columnStart++;
        }

        final columnSpan = cell.colspan > 0 ? cell.colspan : 1;
        final rowSpan = min(
            rowSpanMax,
            cell.rowspan > 0
                ? cell.rowspan
                : cell.rowspan == 0
                    ? group.rows.length
                    : 1);
        for (var r = 0; r < rowSpan; r++) {
          final row = rowStart + r;
          occupations[row] ??= {};
          for (var c = 0; c < columnSpan; c++) {
            occupations[row]![columnStart + c] = true;
          }
        }

        final cellMeta = cell.meta;
        cellMeta.row = rowStart;

        final cssBorderParsed = tryParseBorder(cellMeta);
        final cssBorder = cssBorderParsed.inherit
            ? tryParseBorder(tableMeta).copyFrom(cssBorderParsed)
            : cssBorderParsed;

        builders.add((context) {
          Widget? child = cell.child;

          final border = cssBorder.getValue(cellMeta.tsb.build(context));
          if (border != null) {
            child = wf.buildPadding(cellMeta, cell.child, border.dimensions);
          }
          if (child == null) return null;

          return HtmlTableCell(
            border: border,
            columnSpan: columnSpan,
            columnStart: columnStart,
            rowSpan: rowSpan,
            rowStart: cellMeta.row,
            child: child,
          );
        });
      }
    }
  }

  static BuildOp cellPaddingOp(double px) => BuildOp(
      onChild: (meta) =>
          (meta.element.localName == 'td' || meta.element.localName == 'th')
              ? meta[kCssPadding] = '${px}px'
              : null);

  static BuildOp borderOp(double border, double borderSpacing) => BuildOp(
        defaultStyles: (_) => {
          kCssBorder: '${border}px solid black',
          kCssBorderCollapse: kCssBorderCollapseSeparate,
          kCssBorderSpacing: '${borderSpacing}px',
        },
        onChild: border > 0
            ? (meta) {
                switch (meta.element.localName) {
                  case kTagTableCell:
                  case kTagTableHeaderCell:
                    meta[kCssBorder] = kCssBorderInherit;
                }
              }
            : null,
      );

  static String? _getCssDisplayValue(BuildMetadata meta) {
    for (final style in meta.element.styles.reversed) {
      if (style.property == kCssDisplay) {
        final term = style.term;
        if (term != null) return term;
      }
    }

    switch (meta.element.localName) {
      case kTagTableRow:
        return kCssDisplayTableRow;
      case kTagTableHeaderGroup:
        return kCssDisplayTableHeaderGroup;
      case kTagTableRowGroup:
        return kCssDisplayTableRowGroup;
      case kTagTableFooterGroup:
        return kCssDisplayTableFooterGroup;
      case kTagTableHeaderCell:
      case kTagTableCell:
        return kCssDisplayTableCell;
      case kTagTableCaption:
        return kCssDisplayTableCaption;
    }

    return null;
  }
}

extension _BuildMetadataExtension on BuildMetadata {
  static final _rows = Expando<int>();

  set row(int v) => _rows[this] = v;
  int get row => _rows[this] ?? -1;
}

typedef _HtmlTableCellBuilder = HtmlTableCell? Function(BuildContext);

class _TableCaption extends SingleChildRenderObjectWidget {
  _TableCaption(Widget child, {Key? key}) : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderProxyBox();
}

class _TagTableRow {
  late final BuildOp op;
  final TagTable parent;
  final _TagTableDataRow row;
  final BuildMetadata rowMeta;

  late final BuildOp _cellOp;
  late final BuildOp _valignBaselineOp;

  _TagTableRow(this.parent, this.rowMeta, this.row) {
    op = BuildOp(onChild: onChild);
    _cellOp = BuildOp(
      onWidgets: (cellMeta, widgets) {
        final child =
            parent.wf.buildColumnPlaceholder(cellMeta, widgets) ?? widget0;

        final attributes = cellMeta.element.attributes;
        row.cells.add(_TagTableDataCell(
          cellMeta,
          child: child,
          colspan: tryParseIntFromMap(attributes, kAttributeColspan) ?? 1,
          rowspan: tryParseIntFromMap(attributes, kAttributeRowspan) ?? 1,
        ));

        return [child];
      },
      priority: BuildOp.kPriorityMax,
    );
    _valignBaselineOp = BuildOp(
      onWidgets: (cellMeta, widgets) {
        final v = cellMeta[kCssVerticalAlign]?.term;
        if (v != kCssVerticalAlignBaseline) return widgets;

        return listOrNull(parent.wf
            .buildColumnPlaceholder(cellMeta, widgets)
            ?.wrapWith((_, child) {
          final row = cellMeta.row;

          return HtmlTableValignBaseline(
            companion: parent.companion,
            row: row,
            child: child,
          );
        }));
      },
      priority: StyleVerticalAlign.kPriority4500,
    );
  }

  void onChild(BuildMetadata childMeta) {
    if (childMeta.element.parent != rowMeta.element) return;
    if (TagTable._getCssDisplayValue(childMeta) != kCssDisplayTableCell) {
      return;
    }

    final attrs = childMeta.element.attributes;
    if (attrs.containsKey(kAttributeValign)) {
      childMeta[kCssVerticalAlign] = attrs[kAttributeValign]!;
    }

    childMeta.register(_cellOp);
    StyleBorder.skip(childMeta);
    StyleSizing.treatHeightAsMinHeight(childMeta);
    childMeta.register(_valignBaselineOp);
  }
}

class _TagTableRowGroup {
  final TagTable parent;
  final List<_TagTableDataRow> rows;
  final BuildMetadata groupMeta;

  late BuildOp op;

  _TagTableRowGroup(this.parent, this.groupMeta, this.rows) {
    op = BuildOp(onChild: onChild);
  }

  void onChild(BuildMetadata childMeta) {
    if (childMeta.element.parent != groupMeta.element) return;
    if (TagTable._getCssDisplayValue(childMeta) != kCssDisplayTableRow) {
      return;
    }

    final row = _TagTableDataRow();
    rows.add(row);
    childMeta.register(_TagTableRow(parent, childMeta, row).op);
  }
}

@immutable
class _TagTableData {
  final bodies = <_TagTableDataGroup>[];
  final footer = _TagTableDataGroup();
  final header = _TagTableDataGroup();

  _TagTableDataGroup get body {
    final body = _TagTableDataGroup();
    bodies.add(body);
    return body;
  }
}

@immutable
class _TagTableDataGroup {
  final rows = <_TagTableDataRow>[];
}

@immutable
class _TagTableDataRow {
  final cells = <_TagTableDataCell>[];
}

@immutable
class _TagTableDataCell {
  final Widget child;
  final int colspan;
  final BuildMetadata meta;
  final int rowspan;

  _TagTableDataCell(this.meta,
      {required this.child, required this.colspan, required this.rowspan});
}
