import 'package:flutter/material.dart';

typedef DropdownCallback = void Function(String option);

class DropDownMenu extends StatefulWidget {
  final List<String> options;
  final String initialOption;
  final DropdownCallback callback;

  const DropDownMenu({
    Key? key,
    required this.options,
    required this.initialOption,
    required this.callback,
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
        widget.callback(newOption ?? selectedOption);

        setState(() {
          selectedOption = newOption ?? selectedOption;
        });
      },
    );
  }
}
