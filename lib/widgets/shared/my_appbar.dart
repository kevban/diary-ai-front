import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget {
  final String title;
  const MyAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }
}
