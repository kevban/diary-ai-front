import 'package:flutter/material.dart';

class NoticeMessage extends StatelessWidget {
  Widget content;

  NoticeMessage({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: content,
    );
  }
}
