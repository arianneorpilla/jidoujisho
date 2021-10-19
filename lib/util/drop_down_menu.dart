import 'package:flutter/material.dart';

class DropDownMenu extends StatefulWidget {
  final List<String> options;
  final String initialOption;
  final Function(String) optionCallback;
  final VoidCallback voidCallback;

  const DropDownMenu({
    Key? key,
    required this.options,
    required this.initialOption,
    required this.optionCallback,
    required this.voidCallback,
  }) : super(key: key);

  @override
  DropDownMenuState createState() => DropDownMenuState();
}

class DropDownMenuState extends State<DropDownMenu> {
  late String selectedOption;

  @override
  Widget build(BuildContext context) {
    selectedOption = widget.initialOption;

    return DropdownButton<String>(
      isExpanded: true,
      value: selectedOption,
      items: widget.options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text("  $value"),
        );
      }).toList(),
      onChanged: (newOption) async {
        widget.optionCallback(newOption ?? selectedOption);
        widget.voidCallback();

        setState(() {
          selectedOption = newOption ?? selectedOption;
        });
      },
    );
  }
}
