import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

/// Helper class for processing Yomitan JSON structured content.
class StructuredContent {
  /// Processes a JSON structured content object and returns a DOM node.
  static dom.Node processContent(dynamic json) {
    return _buildNode(json);
  }

  static dom.Node _buildNode(dynamic content) {
    if (content is String) {
      return dom.Text(content);
    } else if (content is List) {
      final fragment = dom.DocumentFragment();
      for (var item in content) {
        fragment.append(_buildNode(item));
      }
      return fragment;
    } else if (content is Map<String, dynamic>) {
      return _createStructuredContentGenericElement(content);
    }
    return dom.Text('');
  }

  static dom.Node _createStructuredContentGenericElement(
      Map<String, dynamic> content) {
    final tag = content['tag'] as String?;
    if (tag == null) {
      return dom.Text('');
    }

    switch (tag) {
      case 'br':
        return _createStructuredContentElement(
            tag, content, 'simple', false, false);
      case 'ruby':
      case 'rt':
      case 'rp':
        return _createStructuredContentElement(
            tag, content, 'simple', true, false);
      case 'table':
        return _createStructuredContentTableElement(tag, content);
      case 'thead':
      case 'tbody':
      case 'tfoot':
      case 'tr':
        return _createStructuredContentElement(
            tag, content, 'table', true, false);
      case 'th':
      case 'td':
        return _createStructuredContentElement(
            tag, content, 'table-cell', true, true);
      case 'div':
      case 'span':
      case 'ol':
      case 'ul':
      case 'li':
      case 'details':
      case 'summary':
        return _createStructuredContentElement(
            tag, content, 'simple', true, true);
      case 'a':
        return _createLinkElement(content);
      case 'img':
        return _createImageElement(content);
      default:
        return dom.Text('');
    }
  }

  static dom.Element _createStructuredContentTableElement(
      String tag, Map<String, dynamic> content) {
    final container = dom.Element.tag('div')
      ..classes.add('gloss-sc-table-container');
    final table =
        _createStructuredContentElement(tag, content, 'table', true, false);
    container.append(table);
    return container;
  }

  static dom.Element _createStructuredContentElement(
    String tag,
    Map<String, dynamic> content,
    String type,
    bool hasChildren,
    bool hasStyle,
  ) {
    final node = dom.Element.tag(tag)..classes.add('gloss-sc-$tag');

    _setAttributes(node, content);

    if (type == 'table-cell') {
      if (content['colSpan'] != null) {
        node.attributes['colspan'] = content['colSpan'].toString();
      }
      if (content['rowSpan'] != null) {
        node.attributes['rowspan'] = content['rowSpan'].toString();
      }
    }

    if (hasStyle && content['style'] != null) {
      node.attributes['style'] =
          _createStyle(content['style'] as Map<String, dynamic>);
    }

    if (hasChildren) {
      _appendStructuredContent(node, content['content']);
    }

    return node;
  }

  static dom.Element _createLinkElement(Map<String, dynamic> content) {
    final node = dom.Element.tag('a');
    if (content['href'] != null) {
      node.attributes['href'] = content['href'];
    }
    _setAttributes(node, content);
    _appendStructuredContent(node, content['content']);
    return node;
  }

  static dom.Node _createImageElement(Map<String, dynamic> content) {
    final imageNode = dom.Element.tag('img');

    final path = content['path'] as String?;
    if (path == null) {
      return dom.Text('');
    }

    final srcAttr = 'jidoujisho://$path';
    final widthAttr = content['width'] != null
        ? '${content['width']}${content['sizeUnits'] ?? ''}'
        : null;
    final heightAttr = content['height'] != null
        ? '${content['height']}${content['sizeUnits'] ?? ''}'
        : null;
    final altAttr = content['description'] as String?;

    imageNode.attributes.addAll({
      'src': srcAttr,
      if (altAttr != null) 'alt': altAttr,
      if (widthAttr != null) 'width': widthAttr,
      if (heightAttr != null) 'height': heightAttr,
    });

    _setAttributes(imageNode, content);

    final title = content['title'] as String?;
    if (title == null) {
      return imageNode;
    } else {
      final figureNode = dom.Element.tag('figure');
      final figcaptionNode = dom.Element.tag('figcaption')
        ..append(dom.Text(title));

      figureNode
        ..append(imageNode)
        ..append(figcaptionNode);

      return figureNode;
    }
  }

  // static dom.Node _createImageElement(Map<String, dynamic> content) {
  //   final imageNode = dom.Element.tag('img');
  //   final path = content['path'] as String?;
  //   if (path == null) return dom.Text('');
  //
  //   final srcAttr = 'jidoujisho://$path';
  //   final widthAttr = (width != null) ? '$width${sizeUnits ?? ''}' : null;
  //   final heightAttr = (height != null) ? '$height${sizeUnits ?? ''}' : null;
  //   final altAttr = content['description'] as String?;
  //
  //   imageNode.attributes.addAll({
  //     'src': srcAttr,
  //     if (altAttr != null) 'alt': altAttr,
  //     if (widthAttr != null) 'width': widthAttr,
  //     if (heightAttr != null) 'height': heightAttr,
  //   });
  //
  //   _setAttributes(imageNode, content);
  //
  //   final title = content['title'] as String?;
  //   if (title == null) {
  //     return imageNode;
  //   } else {
  //     final figureNode = dom.Element.tag('figure');
  //     final figcaptionNode = dom.Element.tag('figcaption')..append(dom.Text(title));
  //
  //     figureNode
  //       ..append(imageNode)
  //       ..append(figcaptionNode);
  //
  //     if (content['collapsible'] == true) {
  //       _makeCollapsible(figureNode, content['collapsed'] == true);
  //     }
  //
  //     return figureNode;
  //   }
  // }

  static void _setAttributes(
      dom.Element element, Map<String, dynamic> content) {
    if (content['lang'] != null) {
      element.attributes['lang'] = content['lang'];
    }
    if (content['data'] is Map<String, dynamic>) {
      final data = content['data'] as Map<String, dynamic>;
      element.attributes.addAll(
          data.map((key, value) => MapEntry('data-sc-$key', value.toString())));
    }
    if (content['title'] != null) {
      element.attributes['title'] = content['title'];
    }
  }

  static void _appendStructuredContent(dom.Element node, dynamic content) {
    if (content != null) {
      node.append(_buildNode(content));
    }
  }

  static String _createStyle(Map<String, dynamic> style) {
    final styleAttributes = <String>[];

    void addIfPresent(String cssProperty, String jsonKey) {
      if (style[jsonKey] != null) {
        styleAttributes.add('$cssProperty: ${style[jsonKey]}');
      }
    }

    void addMarginPadding(String cssProperty, String jsonKey) {
      if (style[jsonKey] is num || style[jsonKey] is String) {
        styleAttributes.add('$cssProperty: ${style[jsonKey]}');
      }
    }

    List<String> validListStyleTypes =
        ListStyleType.values.map((e) => e.counterStyle).toList();
    List<String> validTextDecorationStyles = [
      'solid',
      'double',
      'dotted',
      'dashed',
      'wavy'
    ];
    List<String> validTextDecorationLines = [
      'none',
      'underline',
      'overline',
      'line-through'
    ];

    addIfPresent('font-size', 'fontSize');
    addIfPresent('font-weight', 'fontWeight');
    addIfPresent('color', 'color');
    addIfPresent('background-color', 'backgroundColor');
    addIfPresent('text-align', 'textAlign');
    addIfPresent('vertical-align', 'verticalAlign');
    addIfPresent('white-space', 'whiteSpace');

    addIfPresent('margin', 'margin');
    addMarginPadding('margin-top', 'marginTop');
    addMarginPadding('margin-right', 'marginRight');
    addMarginPadding('margin-bottom', 'marginBottom');
    addMarginPadding('margin-left', 'marginLeft');

    addIfPresent('padding', 'padding');
    addMarginPadding('padding-top', 'paddingTop');
    addMarginPadding('padding-right', 'paddingRight');
    addMarginPadding('padding-bottom', 'paddingBottom');
    addMarginPadding('padding-left', 'paddingLeft');

    if (style['textDecorationLine'] != null) {
      final tdl = style['textDecorationLine'];
      if (tdl is String && validTextDecorationLines.contains(tdl)) {
        styleAttributes.add('text-decoration-line: $tdl');
      } else if (tdl is List) {
        final validValues = tdl
            .whereType<String>()
            .where(validTextDecorationLines.contains)
            .toList();
        if (validValues.isNotEmpty) {
          styleAttributes.add('text-decoration-line: ${validValues.join(' ')}');
        }
      }
    }

    if (style['textDecorationStyle'] is String) {
      final textDecorationStyle = style['textDecorationStyle'];
      if (validTextDecorationStyles.contains(textDecorationStyle)) {
        styleAttributes.add('text-decoration-style: $textDecorationStyle');
      }
    }

    if (style['listStyleType'] is String) {
      final listStyleType = style['listStyleType'];
      if (listStyleType == 'disc' ||
          !validListStyleTypes.contains(listStyleType)) {
        styleAttributes.add('list-style-type: square');
      } else {
        styleAttributes.add('list-style-type: $listStyleType');
      }
    }

    if (style['textEmphasis'] is String) {
      styleAttributes.add('text-decoration-line: underline');
    }

    return styleAttributes.join('; ');
  }
}
