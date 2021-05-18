import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' as css;
import 'package:html/dom.dart' as dom;

import '../core_data.dart';
import '../core_widget_factory.dart';

extension DomElementExtension on dom.Element {
  static Expando<List<css.Declaration>>? _expando;

  /// Returns CSS declarations from the element's `style` attribute.
  ///
  /// This is different from [BuildMetadata.styles] as it doesn't include
  /// runtime additions from [WidgetFactory] or [BuildOp]s.
  ///
  /// Parsing CSS is a non-trivial task but the result is cached for each element
  /// so it's safe to call this again and again.
  List<css.Declaration> get styles {
    final expando = _expando ??= Expando();
    final existing = expando[this];
    if (existing != null) return existing;

    if (!attributes.containsKey('style')) {
      return expando[this] = const [];
    }

    final styleSheet = css.parse('*{${attributes['style']}}');
    return expando[this] = styleSheet.collectDeclarations();
  }
}

extension CssDeclarationExtension on css.Declaration {
  static Expando<List<css.Expression>>? _expando;

  /// Returns CSS expressions.
  ///
  /// Collecting expressions is a non-trivial task but the result is cached
  /// so it's safe to call this again and again.
  List<css.Expression> get values {
    final expando = _expando ??= Expando();
    final existing = expando[this];
    if (existing != null) return existing;

    return expando[this] = _ExpressionsCollector.collect(this);
  }

  /// Returns the CSS expression.
  ///
  /// If there are more than one, `null` will be returned.
  css.Expression? get value {
    final list = values;
    return list.length == 1 ? list.first : null;
  }

  /// Returns the CSS term (if available).
  String? get term {
    final v = value;
    return v is css.LiteralTerm ? v.valueAsString : null;
  }
}

extension CssFunctionTermExtension on css.FunctionTerm {
  static Expando<List<css.Expression>>? _expando;

  /// Returns function parameters.
  ///
  /// Collecting parameters is a non-trivial task but the result is cached
  /// so it's safe to call this again and again.
  List<css.Expression> get params {
    final expando = _expando ??= Expando();
    final existing = expando[this];
    if (existing != null) return existing;

    return expando[this] = _ExpressionsCollector.collect(this)
        .where((e) => (e is! css.OperatorComma) && (e is! css.OperatorSlash))
        .toList(growable: false);
  }
}

extension CssLiteralTermExtension on css.LiteralTerm {
  /// Returns [css.Identifier]'s name or unquoted [String] value.
  String get valueAsString {
    final v = value;
    if (v is css.Identifier) {
      return v.name;
    }

    if (v is String) {
      final first = v.codeUnitAt(0);
      final last = v.codeUnitAt(v.length - 1);
      if (first == last) {
        final escaped = v.substring(1, v.length - 1);
        switch (first) {
          case 34: // double quote
            return escaped.replaceAll(r'\"', '"');
          case 39: // single quote
            return escaped.replaceAll(r"\'", "'");
        }
      }
    }

    return '';
  }
}

extension CssNumberTermExtension on css.NumberTerm {
  /// Returns [num] value.
  num get number => value as num;
}

extension CssPercentageTermExtension on css.PercentageTerm {
  /// Returns [double] value.
  double get valueAsDouble => (value as num) / 100.0;
}

extension CssStyleSheetExtension on css.StyleSheet {
  static _DeclarationsCollector? _collector;

  /// Returns CSS declaration.
  List<css.Declaration> collectDeclarations() {
    final collector = _collector ??= _DeclarationsCollector();
    collector._tmp.clear();
    visit(collector);
    return collector._tmp.toList(growable: false);
  }
}

class _DeclarationsCollector extends css.Visitor {
  final _tmp = <css.Declaration>[];

  @override
  void visitDeclaration(css.Declaration node) => _tmp.add(node);
}

class _ExpressionsCollector extends css.Visitor {
  final _tmp = <css.Expression>[];

  @override
  void visitExpressions(css.Expressions node) => _tmp.addAll(node.expressions);

  static _ExpressionsCollector? _instance;

  static List<css.Expression> collect(css.TreeNode node) {
    final instance = _instance ??= _ExpressionsCollector();
    instance._tmp.clear();
    node.visit(instance);
    return instance._tmp.toList(growable: false);
  }
}
