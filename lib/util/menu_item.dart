import 'dart:ui';

import 'package:flutter/material.dart';

PopupMenuItem<VoidCallback> menuItem(
    {required String label, required IconData icon, required action}) {
  return PopupMenuItem<VoidCallback>(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(label),
      ],
    ),
    value: action,
    padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
  );
}
