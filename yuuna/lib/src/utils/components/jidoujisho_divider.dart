import 'package:flutter/material.dart';

/// A standard theme divider for use across the applicaton.
class JidoujishoDivider extends StatelessWidget {
  /// Build a standard themed divider.
  const JidoujishoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(
            width: 0.5,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
      ),
    );
  }
}
