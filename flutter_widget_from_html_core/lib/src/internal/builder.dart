import 'dart:collection';

import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' as css;

import 'package:html/dom.dart' as dom;

import '../core_data.dart';
import '../core_data.dart' as core_data show BuildMetadata, BuildTree;
import '../core_helpers.dart';
import '../core_widget_factory.dart';
import 'core_ops.dart';

final _regExpSpaceLeading = RegExp(r'^[^\S\u{00A0}]+', unicode: true);
final _regExpSpaceTrailing = RegExp(r'[^\S\u{00A0}]+$', unicode: true);
final _regExpSpaces = RegExp(r'[^\S\u{00A0}]+', unicode: true);

class BuildMetadata extends core_data.BuildMetadata {
  final Iterable<BuildOp> _parentOps;

  Set<BuildOp>? _buildOps;
  var _buildOpsIsLocked = false;
  List<css.Declaration>? _styles;
  var _stylesIsLocked = false;
  bool? _willBuildSubtree;

  BuildMetadata(dom.Element element, TextStyleBuilder tsb,
      [this._parentOps = const []])
      : super(element, tsb);

  @override
  Iterable<BuildOp> get buildOps => _buildOps ?? const [];

  @override
  Iterable<BuildOp> get parentOps => _parentOps;

  @override
  List<css.Declaration> get styles {
    assert(_stylesIsLocked);
    return _styles ?? const [];
  }

  @override
  bool? get willBuildSubtree => _willBuildSubtree;

  @override
  operator []=(String key, String value) {
    assert(!_stylesIsLocked, 'Metadata can no longer be changed.');
    final styleSheet = css.parse('*{$key: $value;}');
    _styles ??= [];
    _styles!.addAll(styleSheet.collectDeclarations());
  }

  @override
  void register(BuildOp op) {
    assert(!_buildOpsIsLocked, 'Metadata can no longer be changed.');
    _buildOps ??= SplayTreeSet(_compareBuildOps);
    _buildOps!.add(op);
  }
}

class BuildTree extends core_data.BuildTree {
  final CustomStylesBuilder? customStylesBuilder;
  final CustomWidgetBuilder? customWidgetBuilder;
  final core_data.BuildMetadata parentMeta;
  final Iterable<BuildOp> parentOps;
  final WidgetFactory wf;

  final _built = <WidgetPlaceholder>[];

  BuildTree({
    this.customStylesBuilder,
    this.customWidgetBuilder,
    core_data.BuildTree? parent,
    required this.parentMeta,
    this.parentOps = const [],
    required TextStyleBuilder tsb,
    required this.wf,
  }) : super(parent, tsb);

  @override
  T add<T extends BuildBit>(T bit) {
    assert(_built.isEmpty, "Built tree shouldn't be altered.");
    return super.add(bit);
  }

  void addBitsFromNodes(dom.NodeList domNodes) {
    for (final domNode in domNodes) {
      _addBitsFromNode(domNode);
    }
    for (final op in parentMeta.buildOps) {
      op.onTree?.call(parentMeta, this);
    }
  }

  @override
  Iterable<WidgetPlaceholder> build() {
    if (_built.isNotEmpty) return _built;

    var widgets = wf.flatten(parentMeta, this);
    for (final op in parentMeta.buildOps) {
      widgets = op.onWidgets
              ?.call(parentMeta, widgets)
              ?.map(WidgetPlaceholder.lazy)
              .toList(growable: false) ??
          widgets;
    }

    _built.addAll(widgets);
    return _built;
  }

  @override
  BuildTree sub({
    core_data.BuildTree? parent,
    BuildMetadata? parentMeta,
    Iterable<BuildOp> parentOps = const [],
    TextStyleBuilder? tsb,
  }) =>
      BuildTree(
        customStylesBuilder: customStylesBuilder,
        customWidgetBuilder: customWidgetBuilder,
        parent: parent ?? this,
        parentMeta: parentMeta ?? this.parentMeta,
        parentOps: parentOps,
        tsb: tsb ?? this.tsb.sub(),
        wf: wf,
      );

  void _addBitsFromNode(dom.Node domNode) {
    if (domNode.nodeType == dom.Node.TEXT_NODE) {
      final text = domNode as dom.Text;
      return _addText(text.data);
    }
    if (domNode.nodeType != dom.Node.ELEMENT_NODE) return;

    final element = domNode as dom.Element;
    final customWidget = customWidgetBuilder?.call(element);
    if (customWidget != null) {
      add(WidgetBit.block(this, customWidget));
      // skip further processing if a custom widget found
      return;
    }

    final meta = BuildMetadata(element, parentMeta.tsb.sub(), parentOps);
    _collectMetadata(meta);

    final subTree = sub(
      parentMeta: meta,
      parentOps: _prepareParentOps(parentOps, meta),
      tsb: meta.tsb,
    );
    add(subTree);

    subTree.addBitsFromNodes(element.nodes);

    if (meta.willBuildSubtree == true) {
      for (final widget in subTree.build()) {
        add(WidgetBit.block(this, widget));
      }
      subTree.detach();
    }
  }

  void _addText(String data) {
    final leading = _regExpSpaceLeading.firstMatch(data);
    final trailing = _regExpSpaceTrailing.firstMatch(data);
    final start = leading == null ? 0 : leading.end;
    final end = trailing == null ? data.length : trailing.start;

    if (end <= start) {
      // the string contains all spaces
      addWhitespace(data);
      return;
    }

    if (start > 0) addWhitespace(leading!.group(0)!);

    final contents = data.substring(start, end);
    final spaces = _regExpSpaces.allMatches(contents);
    var offset = 0;
    for (final space in [...spaces, null]) {
      if (space == null) {
        // reaches end of string
        final text = contents.substring(offset);
        if (text.isNotEmpty) {
          addText(text);
        }
        break;
      } else {
        final spaceData = space.group(0)!;
        if (spaceData == ' ') {
          // micro optimization: ignore single space (ASCII 32)
          continue;
        }

        final text = contents.substring(offset, space.start);
        addText(text);

        addWhitespace(spaceData);
        offset = space.end;
      }
    }

    if (end < data.length) addWhitespace(trailing!.group(0)!);
  }

  void _collectMetadata(BuildMetadata meta) {
    wf.parse(meta);

    for (final op in meta.parentOps) {
      op.onChild?.call(meta);
    }

    // stylings, step 1: get default styles from tag-based build ops
    for (final op in meta.buildOps) {
      final map = op.defaultStyles?.call(meta.element);
      if (map == null) continue;

      final str = map.entries.map((e) => '${e.key}: ${e.value}').join(';');
      final styleSheet = css.parse('*{$str}');

      meta._styles ??= [];
      meta._styles!.insertAll(0, styleSheet.collectDeclarations());
    }

    _customStylesBuilder(meta);

    // stylings, step 2: get styles from `style` attribute
    for (final declaration in meta.element.styles) {
      meta._styles ??= [];
      meta._styles!.add(declaration);
    }

    meta._stylesIsLocked = true;
    for (final style in meta.styles) {
      wf.parseStyle(meta, style);
    }

    wf.parseStyleDisplay(meta, meta[kCssDisplay]?.term);

    meta._willBuildSubtree = meta[kCssDisplay]?.term == kCssDisplayBlock ||
        meta._buildOps?.where(_opRequiresBuildingSubtree).isNotEmpty == true;
    meta._buildOpsIsLocked = true;
  }

  void _customStylesBuilder(BuildMetadata meta) {
    final map = customStylesBuilder?.call(meta.element);
    if (map == null) return;

    for (final pair in map.entries) {
      meta[pair.key] = pair.value;
    }
  }
}

int _compareBuildOps(BuildOp a, BuildOp b) {
  if (identical(a, b)) return 0;

  final cmp = a.priority.compareTo(b.priority);
  if (cmp == 0) {
    // if two ops have the same priority, they should not be considered equal
    // fallback to compare hash codes for stable sorting
    // while still provide pseudo random order across different runs
    return a.hashCode.compareTo(b.hashCode);
  } else {
    return cmp;
  }
}

bool _opRequiresBuildingSubtree(BuildOp op) =>
    op.onWidgets != null && !op.onWidgetsIsOptional;

Iterable<BuildOp> _prepareParentOps(Iterable<BuildOp> ops, BuildMetadata meta) {
  // try to reuse existing list if possible
  final withOnChild = meta.buildOps.where((op) => op.onChild != null).toList();
  return withOnChild.isEmpty
      ? ops
      : List.unmodifiable([...ops, ...withOnChild]);
}
