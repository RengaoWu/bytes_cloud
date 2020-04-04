import 'package:flutter/material.dart';

class CheckWidget extends StatefulWidget {
  final bool value;
  final Function onChanged;
  CheckWidget({this.value, this.onChanged});

  @override
  State<StatefulWidget> createState() {
    return CheckWidgetState();
  }
}

class CheckWidgetState extends State<CheckWidget> {
  bool value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      onChanged: (bool v) {
        widget.onChanged(v);
        setState(() {
          value = v;
        });
      },
      value: value,
    );
  }
}
