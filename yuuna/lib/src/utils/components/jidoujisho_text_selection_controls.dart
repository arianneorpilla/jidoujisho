// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuuna/utils.dart';

/// Used for handling text selection.
typedef OffsetValue = void Function(int start, int end);

/// Defined on [SelectableText] objects to allow for a custom action when
/// selecting text.
class JidoujishoTextSelectionControls extends MaterialTextSelectionControls {
  /// Define text selection controls with custom behaviour.
  JidoujishoTextSelectionControls({
    required this.stashAction,
    required this.shareAction,
    required this.allowCopy,
    required this.allowCut,
    required this.allowPaste,
    required this.allowSelectAll,
    this.searchAction,
    this.handleColor,
    this.creatorAction,
    this.sentenceAction,
  });

  /// Allows the text handles to be customized.
  final Color? handleColor;

  final TextSelectionControls _controls = Platform.isIOS
      ? cupertinoTextSelectionControls
      : materialTextSelectionControls;

  /// Behaviour for the creator action.
  final Function(JidoujishoTextSelection)? sentenceAction;

  /// Behaviour for the creator action.
  final Function(String)? creatorAction;

  /// Behaviour for the search action.
  final Function(String)? searchAction;

  /// Behaviour for the share action.
  final Function(String) shareAction;

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

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) =>
      Platform.isIOS
          // ios handle uses the CupertinoTheme primary color, so override that.
          ? CupertinoTheme(
              data: CupertinoThemeData(primaryColor: handleColor),
              child: Builder(builder: builder))
          // material handle uses the selection handle color, so override that.
          : TextSelectionTheme(
              data: TextSelectionThemeData(selectionHandleColor: handleColor),
              child: Builder(builder: builder));

  @override
  Widget buildHandle(
          BuildContext context, TextSelectionHandleType type, double textHeight,
          [VoidCallback? onTap]) =>
      _wrapWithThemeData(
          (context) => _controls.buildHandle(context, type, textHeight, onTap));

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }

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
      creatorAction: (creatorAction != null)
          ? () {
              creatorAction?.call(
                delegate.textEditingValue.selection
                    .textInside(delegate.textEditingValue.text),
              );

              delegate.hideToolbar();
            }
          : null,
      sentenceAction: (sentenceAction != null)
          ? () {
              sentenceAction?.call(
                JidoujishoTextSelection(
                  text: delegate.textEditingValue.text,
                  range: TextRange(
                    start: delegate.textEditingValue.selection.start,
                    end: delegate.textEditingValue.selection.end,
                  ),
                ),
              );

              delegate.hideToolbar();
            }
          : null,
      searchAction: (searchAction != null)
          ? () {
              searchAction?.call(
                delegate.textEditingValue.selection
                    .textInside(delegate.textEditingValue.text),
              );

              delegate.hideToolbar();
            }
          : null,
      stashAction: () {
        stashAction(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
      shareAction: () {
        shareAction(
          delegate.textEditingValue.selection
              .textInside(delegate.textEditingValue.text),
        );

        delegate.hideToolbar();
      },
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
    required this.searchAction,
    required this.sentenceAction,
    required this.stashAction,
    required this.shareAction,
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

  /// Behaviour for the custom action.
  final Function()? searchAction;

  /// Behaviour for the custom action.
  final Function()? sentenceAction;

  /// Behaviour for the stash action.
  final Function() stashAction;

  /// Behaviour for the share action.
  final Function() shareAction;

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
      if (widget.sentenceAction != null)
        _TextSelectionToolbarItemData(
          onPressed: widget.sentenceAction,
          label: t.cloze,
        ),
      if (widget.searchAction != null)
        _TextSelectionToolbarItemData(
          onPressed: widget.searchAction,
          label: t.search,
        ),
      _TextSelectionToolbarItemData(
        onPressed: widget.stashAction,
        label: t.stash,
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
      _TextSelectionToolbarItemData(
        onPressed: widget.shareAction,
        label: t.share,
      ),
      if (widget.creatorAction != null)
        _TextSelectionToolbarItemData(
          onPressed: widget.creatorAction,
          label: t.creator,
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
