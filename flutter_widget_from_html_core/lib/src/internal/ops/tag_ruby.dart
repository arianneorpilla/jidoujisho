part of '../core_ops.dart';

const kTagRuby = 'ruby';
const kTagRp = 'rp';
const kTagRt = 'rt';

class TagRuby {
  late final BuildOp op;
  final BuildMetadata rubyMeta;
  final WidgetFactory wf;

  late final BuildOp _rtOp;

  TagRuby(this.wf, this.rubyMeta) {
    op = BuildOp(onChild: onChild, onTree: onTree);
    _rtOp = BuildOp(
      onTree: (rtMeta, rtTree) {
        if (rtTree.isEmpty) return;
        final rtBit =
            _RtBit(rtTree, rtTree.tsb, rtMeta, rtTree.copyWith() as BuildTree);
        rtTree.replaceWith(rtBit);
      },
    );
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    if (e.parent != rubyMeta.element) return;

    switch (e.localName) {
      case kTagRp:
        childMeta[kCssDisplay] = kCssDisplayNone;
        break;
      case kTagRt:
        childMeta
          ..[kCssFontSize] = '0.5em'
          ..register(_rtOp);
        break;
    }
  }

  void onTree(BuildMetadata _, BuildTree tree) {
    final rubyBits = <BuildBit>[];
    for (final bit in tree.bits.toList(growable: false)) {
      if (rubyBits.isEmpty && bit is WhitespaceBit) {
        // the first bit is whitespace, just ignore it
        continue;
      }
      if (bit is! _RtBit || rubyBits.isEmpty) {
        rubyBits.add(bit);
        continue;
      }

      final rtBit = bit;
      final rtTree = rtBit.tree;
      final rubyTree = tree.sub();
      final placeholder = WidgetPlaceholder<List<BuildTree>>([rubyTree, rtTree])
        ..wrapWith((context, __) {
          final tsh = rubyTree.tsb.build(context);

          final ruby = wf.buildColumnWidget(
              rubyMeta, tsh, rubyTree.build().toList(growable: false));
          final rt = wf.buildColumnWidget(
              rtBit.meta, tsh, rtTree.build().toList(growable: false));

          return HtmlRuby(ruby ?? widget0, rt ?? widget0);
        });

      final anchor = rubyBits.first;
      WidgetBit.inline(anchor.parent!, placeholder).insertBefore(anchor);

      for (final rubyBit in rubyBits) {
        rubyTree.add(rubyBit.copyWith(parent: rubyTree));
        rubyBit.detach();
      }
      rubyBits.clear();
      rtBit.detach();
    }
  }
}

class _RtBit extends BuildBit<Null, BuildTree> {
  final BuildMetadata meta;
  final BuildTree tree;

  _RtBit(BuildTree parent, TextStyleBuilder tsb, this.meta, this.tree)
      : super(parent, tsb);

  @override
  BuildTree buildBit(Null _) => tree;

  @override
  BuildBit copyWith({BuildTree? parent, TextStyleBuilder? tsb}) =>
      _RtBit(parent ?? this.parent!, tsb ?? this.tsb, meta, tree);
}
