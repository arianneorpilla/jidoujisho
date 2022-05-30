// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// /// Directly adapted from [SelectableTextGoal] from Flutter Engage.
// class JidoujishoSelectableText extends StatefulWidget {
//   const JidoujishoSelectableText({
//     super.key,
//     this.text = '',
//     this.initialSelection,
//     this.style,
//     this.selectionColor,
//     this.caretColor = Colors.transparent,
//     this.caretWidth = 1,
//     this.changeCursor = true,
//     this.allowSelection = true,
//     this.paintTextBoxes = false,
//     this.textBoxesColor = Colors.grey,
//     this.onSelectionChange,
//   });

//   final String text;
//   final TextSelection? initialSelection;
//   final TextStyle? style;
//   final Color? selectionColor;
//   final Color caretColor;
//   final double caretWidth;
//   final bool changeCursor;
//   final bool allowSelection;
//   final bool paintTextBoxes;
//   final Color textBoxesColor;
//   final void Function(TextSelection?, String)? onSelectionChange;

//   @override
//   JidoujishoSelectableTextState createState() =>
//       JidoujishoSelectableTextState();
// }

// class JidoujishoSelectableTextState extends State<JidoujishoSelectableText> {
//   final _textKey = GlobalKey();

//   final _textBoxRects = <Rect>[];

//   final _selectionRects = <Rect>[];
//   TextSelection? _textSelection;
//   int? _selectionBaseOffset;

//   Rect? _caretRect;

//   MouseCursor _cursor = SystemMouseCursors.basic;

//   @override
//   void initState() {
//     super.initState();
//     _textSelection =
//         widget.initialSelection ?? const TextSelection.collapsed(offset: -1);
//     _scheduleTextLayoutUpdate();
//   }

//   @override
//   void didUpdateWidget(JidoujishoSelectableText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.text != oldWidget.text) {
//       _textBoxRects.clear();
//       _selectionRects.clear();
//       _textSelection = const TextSelection.collapsed(offset: -1);
//       _caretRect = null;

//       _scheduleTextLayoutUpdate();
//     }
//   }

//   RenderParagraph? get _renderParagraph =>
//       _textKey.currentContext?.findRenderObject() as RenderParagraph?;

//   void _scheduleTextLayoutUpdate() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _updateVisibleTextBoxes();
//       _updateSelectionDisplay();
//     });
//   }

//   void _onTapDown(TapDownDetails details) {
//     setState(() {
//       _selectionBaseOffset =
//           _getTextPositionAtOffset(details.localPosition).offset;

//       final textSelection = TextSelection(
//         baseOffset: _selectionBaseOffset!,
//         extentOffset: widget.text.length,
//       );

//       _onUserSelectionChange(textSelection);
//     });
//   }

//   void _onDragStart(DragStartDetails details) {
//     setState(() {
//       _selectionBaseOffset =
//           _getTextPositionAtOffset(details.localPosition).offset;

//       final textSelection = TextSelection(
//         baseOffset: _selectionBaseOffset!,
//         extentOffset: widget.text.length,
//       );

//       _onUserSelectionChange(textSelection);
//     });
//   }

//   void _onDragUpdate(DragUpdateDetails details) {
//     setState(() {
//       _selectionBaseOffset =
//           _getTextPositionAtOffset(details.localPosition).offset;

//       final textSelection = TextSelection(
//         baseOffset: _selectionBaseOffset!,
//         extentOffset: widget.text.length,
//       );

//       _onUserSelectionChange(textSelection);
//     });
//   }

//   void _onDragEnd(DragEndDetails details) {
//     setState(() {
//       _onUserSelectionChange(null);
//     });
//   }

//   void _onDragCancel() {
//     setState(() {
//       _selectionBaseOffset = null;
//       _onUserSelectionChange(null);
//     });
//   }

//   void _onUserSelectionChange(TextSelection? textSelection) {
//     _textSelection = textSelection;
//     _updateSelectionDisplay();
//     widget.onSelectionChange?.call(textSelection, widget.text);
//   }

//   void _updateSelectionDisplay() {
//     setState(() {
//       final selectionRects = _computeSelectionRects(_textSelection);
//       _selectionRects
//         ..clear()
//         ..addAll(selectionRects);
//       _caretRect = _textSelection != null
//           ? _computeCursorRectForTextOffset(_textSelection!.extentOffset)
//           : null;
//     });
//   }

//   void _updateVisibleTextBoxes() {
//     setState(() {
//       _textBoxRects
//         ..clear()
//         ..addAll(_computeAllTextBoxRects());
//     });
//   }

//   Rect _computeCursorRectForTextOffset(int offset) {
//     if (offset < 0) {
//       return Rect.zero;
//     }
//     if (_renderParagraph == null) {
//       return Rect.zero;
//     }

//     final caretOffset = _renderParagraph!.getOffsetForCaret(
//       TextPosition(offset: offset),
//       Rect.zero,
//     );
//     final caretHeight = _renderParagraph!.getFullHeightForCaret(
//       TextPosition(offset: offset),
//     );
//     return Rect.fromLTWH(
//       caretOffset.dx - (widget.caretWidth / 2),
//       caretOffset.dy,
//       widget.caretWidth,
//       caretHeight!,
//     );
//   }

//   TextPosition _getTextPositionAtOffset(Offset localOffset) {
//     final myBox = context.findRenderObject();
//     final textOffset =
//         _renderParagraph?.globalToLocal(localOffset, ancestor: myBox);
//     return _renderParagraph!.getPositionForOffset(textOffset!);
//   }

//   List<Rect> _computeAllTextBoxRects() {
//     if (_textKey.currentContext == null) {
//       return const [];
//     }

//     if (_renderParagraph == null) {
//       return const [];
//     }

//     return _computeSelectionRects(
//       TextSelection(
//         baseOffset: 0,
//         extentOffset: widget.text.length,
//       ),
//     );
//   }

//   List<Rect> _computeSelectionRects(TextSelection? selection) {
//     if (selection == null) {
//       return [];
//     }
//     if (_renderParagraph == null) {
//       return [];
//     }

//     final textBoxes = _renderParagraph?.getBoxesForSelection(selection);
//     return textBoxes!.map((box) => box.toRect()).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: widget.allowSelection ? _onTapDown : null,
//       onVerticalDragStart: widget.allowSelection ? _onDragStart : null,
//       onVerticalDragUpdate: widget.allowSelection ? _onDragUpdate : null,
//       onVerticalDragEnd: widget.allowSelection ? _onDragEnd : null,
//       onVerticalDragCancel: widget.allowSelection ? _onDragCancel : null,
//       onHorizontalDragStart: widget.allowSelection ? _onDragStart : null,
//       onHorizontalDragUpdate: widget.allowSelection ? _onDragUpdate : null,
//       onHorizontalDragEnd: widget.allowSelection ? _onDragEnd : null,
//       onHorizontalDragCancel: widget.allowSelection ? _onDragCancel : null,
//       behavior: HitTestBehavior.translucent,
//       child: Stack(
//         children: [
//           CustomPaint(
//             painter: _SelectionPainter(
//               color: widget.selectionColor ??
//                   Theme.of(context).colorScheme.primary.withOpacity(0.5),
//               rects: _selectionRects,
//             ),
//           ),
//           if (widget.paintTextBoxes)
//             CustomPaint(
//               painter: _SelectionPainter(
//                 color: widget.textBoxesColor,
//                 rects: _textBoxRects,
//                 fill: false,
//               ),
//             ),
//           Column(
//             children: [
//               Text(
//                 widget.text,
//                 key: _textKey,
//                 style: widget.style,
//               ),
//             ],
//           ),
//           CustomPaint(
//             painter: _SelectionPainter(
//               color: widget.caretColor,
//               rects: _caretRect != null ? [_caretRect!] : const [],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SelectionPainter extends CustomPainter {
//   _SelectionPainter({
//     required Color color,
//     required List<Rect> rects,
//     bool fill = true,
//   })  : _color = color,
//         _rects = rects,
//         _fill = fill,
//         _paint = Paint()..color = color;

//   final Color _color;
//   final bool _fill;
//   final List<Rect> _rects;
//   final Paint _paint;

//   @override
//   void paint(Canvas canvas, Size size) {
//     _paint.style = _fill ? PaintingStyle.fill : PaintingStyle.stroke;
//     for (final rect in _rects) {
//       canvas.drawRect(rect, _paint);
//     }
//   }

//   @override
//   bool shouldRepaint(_SelectionPainter other) {
//     return true;
//   }
// }
