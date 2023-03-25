import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  String action;
  ElevatedButton actionWidget;

  ConfirmationDialog(
      {Key? key, required this.action, required this.actionWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Are you sure you want to ${action.toLowerCase()}?'),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel')),
        actionWidget
      ],
    );
  }
}
