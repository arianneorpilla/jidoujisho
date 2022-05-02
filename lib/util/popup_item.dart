import 'package:flutter/material.dart';

PopupMenuItem<VoidCallback> popupItem({
  required String label,
  required IconData icon,
  required action,
}) {
  return PopupMenuItem<VoidCallback>(
    child: Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    ),
    value: action,
  );
}
