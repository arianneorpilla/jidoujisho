import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Used for handling text selection.
typedef OffsetValue = void Function(int start, int end);

/// Defined on [SelectableText] objects to allow for a custom action when
/// selecting text.
class JidoujishoTextSelectionControls extends MaterialTextSelectionControls {
  /// Define text selection controls with custom behaviour.
  JidoujishoTextSelectionControls({
    required this.customAction,
    required this.customActionLabel,
  });

  /// Localisation for the custom action.
  final String customActionLabel;

  /// Behaviour for the custom action.
  final Function(String) customAction;

  static const double _kToolbarContentDistanceBelow = 20;
  static const double _kToolbarContentDistance = 8;

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
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

    return JidoujishoSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus!,
      customAction: () {
        customAction(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
      customActionLabel: customActionLabel,
    );
  }
}

/// A toolbar that allows a custom button to be shown when selecting text.
class JidoujishoSelectionToolbar extends StatefulWidget {
  /// Define a toolbar with clipboard details and custom behaviour.
  const JidoujishoSelectionToolbar({
    required this.anchorAbove,
    required this.anchorBelow,
    required this.clipboardStatus,
    required this.customActionLabel,
    required this.customAction,
    super.key,
  });

  /// Positioning details for the toolbar.
  final Offset anchorAbove;

  /// Positioning details for the toolbar.
  final Offset anchorBelow;

  /// Current details on the clipboard.
  final ClipboardStatusNotifier clipboardStatus;

  /// Localisation for the custom action.
  final String customActionLabel;

  /// Behaviour for the custom action.
  final Function() customAction;

  @override
  State<JidoujishoSelectionToolbar> createState() =>
      _JidoujishoSelectionToolbarState();
}

class _JidoujishoSelectionToolbarState
    extends State<JidoujishoSelectionToolbar> {
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
  void didUpdateWidget(JidoujishoSelectionToolbar oldWidget) {
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
    final List<_TextSelectionToolbarItemData> itemDatas =
        <_TextSelectionToolbarItemData>[
      _TextSelectionToolbarItemData(
        onPressed: widget.customAction,
        label: widget.customActionLabel,
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

class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}
