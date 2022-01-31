import 'dart:math';

import 'package:flutter/material.dart';

class FooterLayout extends StatelessWidget {
  const FooterLayout({
    Key? key,
    required this.body,
    required this.footer,
  }) : super(key: key);

  final Container body;
  final Container footer;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _FooterLayoutDelegate(MediaQuery.of(context).viewInsets),
      children: <Widget>[
        LayoutId(
          id: _FooterLayout.body,
          child: body,
        ),
        LayoutId(
          id: _FooterLayout.footer,
          child: footer,
        ),
      ],
    );
  }
}

enum _FooterLayout {
  footer,
  body,
}

class _FooterLayoutDelegate extends MultiChildLayoutDelegate {
  final EdgeInsets viewInsets;

  _FooterLayoutDelegate(this.viewInsets);

  @override
  void performLayout(Size size) {
    size = Size(size.width, size.height + viewInsets.bottom);
    final footer =
    layoutChild(_FooterLayout.footer, BoxConstraints.loose(size));

    final bodyConstraints = BoxConstraints.tightFor(
      height: size.height - max(footer.height, viewInsets.bottom),
      width: size.width,
    );

    final body = layoutChild(_FooterLayout.body, bodyConstraints);

    positionChild(_FooterLayout.body, Offset.zero);
    positionChild(_FooterLayout.footer, Offset(0, body.height));
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}