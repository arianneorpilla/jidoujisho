import 'package:chisa/anki/anki_export_params.dart';
import 'package:flutter/material.dart';

class ExportButton extends StatefulWidget {
  const ExportButton({
    required this.label,
    required this.icon,
    required this.exportParams,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final AnkiExportParams exportParams;
  final Function() onTap;

  @override
  State<StatefulWidget> createState() => ExportButtonState();
}

class ExportButtonState extends State<ExportButton> {
  bool justClicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: InkWell(
          child: Container(
            color: justClicked
                ? Theme.of(context).unselectedWidgetColor.withOpacity(0.05)
                : Theme.of(context).unselectedWidgetColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: justClicked
                        ? Theme.of(context).unselectedWidgetColor
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: justClicked
                          ? Theme.of(context).unselectedWidgetColor
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: justClicked
              ? null
              : () async {
                  widget.onTap();
                  justClicked = true;
                  setState(() {});
                  await Future.delayed(const Duration(seconds: 1), () {
                    justClicked = false;
                    setState(() {});
                  });
                }),
    );
  }
}
