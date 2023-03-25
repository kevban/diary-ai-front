import 'package:diary_ai/classes/message.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  final Function(String)? send;
  final String searchTarget;

  SearchForm({super.key, required this.send, required this.searchTarget});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _controller = TextEditingController();

  void handleSubmit(TextEditingController controller, BuildContext context) {
    final text = controller.text.trim();
    if (widget.send != null) {
      widget.send!(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: kTextColor,
              onSubmitted: (text) {
                handleSubmit(_controller, context);
              },
              controller: _controller,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    handleSubmit(_controller, context);
                  },
                ),
                hintText: 'Search for ${widget.searchTarget}',
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
    );
  }
}
