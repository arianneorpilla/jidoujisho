import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

Widget showCenterIconMessage(
    {required BuildContext context,
    required String label,
    required IconData icon,
    required bool jumpingDots}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: Theme.of(context).unselectedWidgetColor,
        size: 36,
      ),
      const SizedBox(height: 6),
      Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
              fontSize: 20,
            ),
          ),
          (jumpingDots)
              ? SizedBox(
                  width: 12,
                  height: 16,
                  child: JumpingDotsProgressIndicator(
                    color: Colors.grey,
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    ],
  );
}
