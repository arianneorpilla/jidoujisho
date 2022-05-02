// Taken from
// https://ktuusj.medium.com/flutter-custom-selection-toolbar-3acbe7937dd3
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OffsetValue = void Function(int start, int end);

class SearchTextSelectionControls extends MaterialTextSelectionControls {
  SearchTextSelectionControls({
    required this.searchCallback,
    required this.searchLabel,
  });

  // Padding between the toolbar and the anchor.
  static const double _kToolbarContentDistanceBelow = 20;
  static const double _kToolbarContentDistance = 8;

  final Function(String) searchCallback;
  final String searchLabel;

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            _kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    int start = delegate.textEditingValue.selection.start;
    int end = delegate.textEditingValue.selection.end;

    String selectedText = delegate.textEditingValue.text.substring(start, end);

    return SearchTextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus,
      searchCallback: () {
        searchCallback(selectedText);
      },
      searchLabel: searchLabel,
    );
  }
}

class SearchTextSelectionToolbar extends StatefulWidget {
  const SearchTextSelectionToolbar({
    required this.anchorAbove,
    required this.anchorBelow,
    required this.clipboardStatus,
    required this.searchCallback,
    required this.searchLabel,
    Key? key,
  }) : super(key: key);

  final Offset anchorAbove;
  final Offset anchorBelow;
  final ClipboardStatusNotifier clipboardStatus;
  final VoidCallback searchCallback;
  final String searchLabel;

  @override
  SearchTextSelectionToolbarState createState() =>
      SearchTextSelectionToolbarState();
}

class SearchTextSelectionToolbarState
    extends State<SearchTextSelectionToolbar> {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus.addListener(_onChangedClipboardStatus);
    widget.clipboardStatus.update();
  }

  @override
  void didUpdateWidget(SearchTextSelectionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
    widget.clipboardStatus.update();
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.clipboardStatus.disposed) {
      widget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final List<TextSelectionToolbarItemData> itemDatas =
        <TextSelectionToolbarItemData>[
      TextSelectionToolbarItemData(
        onPressed: widget.searchCallback,
        label: widget.searchLabel,
      ),
    ];

    int childIndex = 0;
    return TextSelectionToolbar(
      anchorAbove: widget.anchorAbove,
      anchorBelow: widget.anchorBelow,
      toolbarBuilder: (context, child) {
        return Card(child: child);
      },
      children: itemDatas.map((itemData) {
        return TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(
              childIndex++, itemDatas.length),
          onPressed: itemData.onPressed,
          child: Text(itemData.label),
        );
      }).toList(),
    );
  }
}

class TextSelectionToolbarItemData {
  const TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}
