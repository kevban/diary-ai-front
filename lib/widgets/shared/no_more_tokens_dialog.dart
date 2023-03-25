import 'package:flutter/material.dart';

class NoMoreTokensDialog extends StatelessWidget {
  const NoMoreTokensDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('You have no more tokens'),
    );
  }
}
