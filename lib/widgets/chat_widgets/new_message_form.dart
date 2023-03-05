import 'dart:js';

import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';

class NewMessageForm extends StatelessWidget {
  final Function(Message newMsg)? send;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void handleSubmit(TextEditingController controller, BuildContext context) {
    final text = controller.text.trim();
    if (text.isNotEmpty && send != null) {
      send!(Message(text: text, sender: 'Me', timestamp: DateTime.now()));
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  NewMessageForm({super.key, required this.send});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: kTextColor,
              focusNode: _focusNode,
              onSubmitted: (text) {
                handleSubmit(_controller, context);
              },
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: kTextColor)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              handleSubmit(_controller, context);
            },
          ),
        ],
      ),
    );
  }
}
