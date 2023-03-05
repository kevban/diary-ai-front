import 'package:flutter/material.dart';

class TopicsField extends StatefulWidget {
  final List<String> topics;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback? onEditingComplete;

  const TopicsField({
    required this.topics,
    required this.onChanged,
    this.onEditingComplete,
  });

  @override
  _TopicsFieldState createState() => _TopicsFieldState();
}

class _TopicsFieldState extends State<TopicsField> {
  final _controller = TextEditingController();
  late List<String> _topics;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _topics = List<String>.from(widget.topics);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTopic(String topic, BuildContext context) {
    setState(() {
      _topics.add(topic);
      _controller.clear();
      widget.onChanged(_topics);
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _removeTopic(int index) {
    setState(() {
      _topics.removeAt(index);
      widget.onChanged(_topics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Topics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 20,),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _topics.asMap().entries.map((entry) {
            final index = entry.key;
            final topic = entry.value;
            return Chip(
              label: Text(topic),
              onDeleted: () => _removeTopic(index),
            );
          }).toList(),
        ),
        SizedBox(height: 30,),
        Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add topic',
                ),
                onSubmitted: (text) {
                  _addTopic(text, context);
                },
                onEditingComplete: widget.onEditingComplete,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addTopic(_controller.text, context),
            ),
          ],
        ),
      ],
    );
  }
}
