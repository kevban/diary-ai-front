import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Discover'),
      content: Container(
        width: 400,
        child: Text(
            'You can find and add any user created character or scenarios to your own collection'),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Got it'))
      ],
    );
  }
}
