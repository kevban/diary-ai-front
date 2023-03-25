import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';

class NewMessageForm extends StatefulWidget {
  final Function(Message newMsg)? send;
  final bool typing;

  NewMessageForm({super.key, required this.send, this.typing = false});

  @override
  State<NewMessageForm> createState() => _NewMessageFormState();
}

class _NewMessageFormState extends State<NewMessageForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _controller = TextEditingController();

  final _focusNode = FocusNode();

  void handleSubmit(TextEditingController controller, BuildContext context) {
    final text = controller.text.trim();
    if (_formKey.currentState!.validate() &&
        widget.send != null &&
        !widget.typing) {
      widget
          .send!(Message(text: text, sender: 'Me', timestamp: DateTime.now()));
      controller.clear();
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) {
                  String trimmedValue = value == null ? '' : value.trim();
                  if (trimmedValue.isEmpty) {
                    return "Message can't be empty";
                  } else if (trimmedValue.length > 400) {
                    return 'Message is too long!';
                  } else {
                    return null;
                  }
                },
                cursorColor: kTextColor,
                focusNode: _focusNode,
                onFieldSubmitted: (text) {
                  handleSubmit(_controller, context);
                },
                controller: _controller,
                decoration: InputDecoration(
                  suffixIcon: widget.typing
                      ? SizedBox(
                          child: Center(child: CircularProgressIndicator.adaptive()),
                          height: 12,
                          width: 12,
                        )
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            handleSubmit(_controller, context);
                          },
                        ),
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
          ],
        ),
      ),
    );
  }
}
