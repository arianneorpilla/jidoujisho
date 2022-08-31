import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Used for handling text selection.
typedef OffsetValue = void Function(int start, int end);

/// Defined on [SelectableText] objects to allow for a custom action when
/// selecting text.
class JidoujishoTextSelectionControls extends MaterialTextSelectionControls {
  /// Define text selection controls with custom behaviour.
  JidoujishoTextSelectionControls({
    required this.searchAction,
    required this.searchActionLabel,
    required this.stashAction,
    required this.stashActionLabel,
    required this.allowCopy,
    required this.allowCut,
    required this.allowPaste,
    required this.allowSelectAll,
    this.creatorAction,
    this.creatorActionLabel,
  });

  /// Localisation for the creator action.
  final Function(String)? creatorAction;

  /// Localisation for the creator action.
  final String? creatorActionLabel;

  /// Localisation for the search action.
  final String searchActionLabel;

  /// Behaviour for the search action.
  final Function(String) searchAction;

  /// Localisation for the stash action.
  final String stashActionLabel;

  /// Behaviour for the stash action.
  final Function(String) stashAction;

  /// Whether or not to allow copying.
  final bool allowCopy;

  /// Whether or not to allow cutting.
  final bool allowCut;

  /// Whether or not to allow pasting.
  final bool allowPaste;

  /// Whether or not to allow selecting all.
  final bool allowSelectAll;

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
      creatorAction: () {
        creatorAction?.call(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
      searchAction: () {
        searchAction(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
      stashAction: () {
        stashAction(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
      searchActionLabel: searchActionLabel,
      stashActionLabel: stashActionLabel,
      creatorActionLabel: creatorActionLabel,
      handleCopy: canCopy(delegate) && allowCopy
          ? () => handleCopy(delegate, clipboardStatus)
          : null,
      handleCut:
          canCut(delegate) && allowCut ? () => handleCut(delegate) : null,
      handlePaste:
          canPaste(delegate) && allowPaste ? () => handlePaste(delegate) : null,
      handleSelectAll: canSelectAll(delegate) && allowSelectAll
          ? () => handleSelectAll(delegate)
          : null,
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
    required this.creatorAction,
    required this.creatorActionLabel,
    required this.searchActionLabel,
    required this.searchAction,
    required this.stashAction,
    required this.stashActionLabel,
    required this.handleCopy,
    required this.handleCut,
    required this.handlePaste,
    required this.handleSelectAll,
    super.key,
  });

  /// Positioning details for the toolbar.
  final Offset anchorAbove;

  /// Positioning details for the toolbar.
  final Offset anchorBelow;

  /// Current details on the clipboard.
  final ClipboardStatusNotifier clipboardStatus;

  /// Localisation for the custom action.
  final String searchActionLabel;

  /// Behaviour for the custom action.
  final Function() searchAction;

  /// Localisation for the stash action.
  final String stashActionLabel;

  /// Behaviour for the stash action.
  final Function() stashAction;

  /// Localisation for the creator action.
  final String? creatorActionLabel;

  /// Behaviour for the creator action.
  final Function()? creatorAction;

  /// Behaviour for copying.
  final VoidCallback? handleCopy;

  /// Behaviour for cutting.
  final VoidCallback? handleCut;

  /// Behaviour for pasting.
  final VoidCallback? handlePaste;

  /// Behaviour for selecting all.
  final VoidCallback? handleSelectAll;

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
    assert(debugCheckHasMaterialLocalizations(context), 'Must have i18n');
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final List<_TextSelectionToolbarItemData> itemDatas =
        <_TextSelectionToolbarItemData>[
      _TextSelectionToolbarItemData(
        onPressed: widget.searchAction,
        label: widget.searchActionLabel,
      ),
      _TextSelectionToolbarItemData(
        onPressed: widget.stashAction,
        label: widget.stashActionLabel,
      ),
      if (widget.handleCut != null)
        _TextSelectionToolbarItemData(
          label: localizations.cutButtonLabel,
          onPressed: widget.handleCut,
        ),
      if (widget.handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: widget.handleCopy,
        ),
      if (widget.handlePaste != null &&
          widget.clipboardStatus.value == ClipboardStatus.pasteable)
        _TextSelectionToolbarItemData(
          label: localizations.pasteButtonLabel,
          onPressed: widget.handlePaste,
        ),
      if (widget.handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: widget.handleSelectAll,
        ),
      if (widget.creatorAction != null && widget.creatorActionLabel != null)
        _TextSelectionToolbarItemData(
          onPressed: widget.creatorAction,
          label: widget.creatorActionLabel!,
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
